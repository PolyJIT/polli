#include "polli/Compiler.h"
#include "polli/RuntimeOptimizer.h"
#include "polli/Monitor.h"
#include "polli/log.h"

#include "llvm/Support/DynamicLibrary.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/IR/Mangler.h"

#include <dlfcn.h>

using namespace llvm;

REGISTER_LOG(console, "compiler");

namespace polli {
class PolySectionMemoryManager : public SectionMemoryManager {
  uint8_t *allocateCodeSection(uintptr_t Size, unsigned Alignment,
                               unsigned SectionID,
                               StringRef SectionName) override {
    uint8_t *ptr = SectionMemoryManager::allocateCodeSection(
        Size, Alignment, SectionID, SectionName);
    SPDLOG_DEBUG(
        console, "cs @ 0x{:x} sz: {:d} align: {:d} id: {:d} name: {:s}",
        (uint64_t)ptr, (uint64_t)Size, Alignment, SectionID, SectionName.str());
    return ptr;
  }

  uint8_t *allocateDataSection(uintptr_t Size, unsigned Alignment,
                               unsigned SectionID, StringRef SectionName,
                               bool isReadOnly) override {
    uint8_t *ptr = SectionMemoryManager::allocateDataSection(
        Size, Alignment, SectionID, SectionName, isReadOnly);
    SPDLOG_DEBUG(console,
        "ds @ 0x{:x} sz: {:d} align: {:d} id: {:d} name: {:s} ro: {:d}",
        (uint64_t)ptr, (uint64_t)Size, Alignment, SectionID, SectionName.str(),
        isReadOnly);
    return ptr;
  }
};

ModuleCompiler::ObjFileT ModuleCompiler::operator()(llvm::Module &M) const {
  SmallVector<char, 0> ObjBufferSV;
  raw_svector_ostream ObjStream(ObjBufferSV);

  legacy::PassManager PM;
  MCContext *Ctx;
  llvm::EngineBuilder BuildEngine;
  TargetMachine *TM = BuildEngine.setMCPU(opt::runtime::MCPU)
                          .setMArch(opt::runtime::MArch)
                          .setMAttrs(opt::runtime::MAttrs)
                          .selectTarget();

  TM->setOptLevel(llvm::CodeGenOpt::Aggressive);
  if (TM->addPassesToEmitMC(PM, Ctx, ObjStream))
    llvm_unreachable("Target does not support MC emission.");
  PM.run(M);

  std::unique_ptr<llvm::MemoryBuffer> ObjBuffer(
      new llvm::ObjectMemoryBuffer(std::move(ObjBufferSV)));

  Expected<std::unique_ptr<llvm::object::ObjectFile>> Obj =
      object::ObjectFile::createObjectFile(ObjBuffer->getMemBufferRef());

  if (Obj)
    return ObjFileT(std::move(*Obj), std::move(ObjBuffer));

  llvm_unreachable("No object file generated.");
}


SpecializingCompiler::SpecializingCompiler()
    : ObjectLayer([]() {
        return std::make_shared<PolySectionMemoryManager>();
      }),
      CompileLayer(ObjectLayer, ModuleCompiler()),
      OptimizeLayer(CompileLayer, optimizeForRuntime), LibHandle(nullptr) {
  SPDLOG_DEBUG("libpjit", "Starting PolyJIT Engine.");
  LibHandle = dlopen(nullptr, RTLD_NOW | RTLD_GLOBAL);
  llvm::sys::DynamicLibrary::LoadLibraryPermanently(nullptr);
}

SpecializingCompiler::SharedModule
SpecializingCompiler::getModule(const uint64_t ID, const char *prototype,
                                bool &cache_hit) {
  cache_hit = LoadedModules.find(ID) != LoadedModules.end();
  if (!cache_hit) {
    std::string Str(prototype);
    MemoryBufferRef Buf(Str, "polli.prototype.module");
    SMDiagnostic Err;
    auto Ctx = std::make_unique<monitor<LLVMContext>>();
    auto M = parseIR(Buf, Err, Ctx->monitored());

    if (!M) {
      Err.print("libpjit", errs(), true, true);
    }
    assert(M && "Could not load the prototype!");

    std::lock_guard<std::mutex> Guard(ModuleMutex);
    LoadedModules.insert(std::make_pair(ID, std::move(M)));
    LoadedContexts.insert(std::make_pair(ID, std::move(Ctx)));
  }

  return LoadedModules[ID];
}

std::shared_ptr<SpecializingCompiler::context_type>
SpecializingCompiler::getContext(const uint64_t ID) {
  assert(LoadedContexts.count(ID) && "No context with this ID.");
  return LoadedContexts[ID];
}

Expected<SpecializingCompiler::ModuleHandleT>
SpecializingCompiler::addModule(std::shared_ptr<Module> M) {
  for (GlobalValue &GV : M->globals()) {
    if (GV.hasInternalLinkage() ||
        GV.hasPrivateLinkage())
        continue;
    std::lock_guard<std::mutex> Lock(DLMutex);
    dlerror();
    void *Addr = dlsym(LibHandle, GV.getName().str().c_str());
    if (char *Error = dlerror()) {
      console->error("(dlsym) Could not locate the symbol: {:s}", Error);
      std::string buf;
      raw_string_ostream os(buf);
      M->print(os, nullptr, true, true);
      console->error("{:s}", os.str());
    }

    if (Addr)
      llvm::sys::DynamicLibrary::AddSymbol(GV.getName(), Addr);
  }

  auto Resolver = orc::createLambdaResolver(
      [&](const std::string &Name) -> JITSymbol {
        if (auto Sym = findSymbol(Name, M->getDataLayout()))
          return Sym;
        return JITSymbol(nullptr);
      },
      [](const std::string &S) {
        if (auto SymAddr = RTDyldMemoryManager::getSymbolAddressInProcess(S))
          return JITSymbol(SymAddr, JITSymbolFlags::Exported);
        return JITSymbol(nullptr);
      });

  Expected<ModuleHandleT> MH = OptimizeLayer.addModule(M, Resolver);

  return MH;
}

void SpecializingCompiler::removeModule(ModuleHandleT H) {
  llvm::Error status = CompileLayer.removeModule(H);
  console->error_if(!status.success(), "Unable to remove module!"); 
  assert(status.success() && "Unable to remove module!");
    
}

JITSymbol SpecializingCompiler::findSymbol(const std::string &Name,
                                           const DataLayout &DL) {
  std::string MangledName;
  raw_string_ostream MangledNameStream(MangledName);
  Mangler::getNameWithPrefix(MangledNameStream, Name, DL);
  return CompileLayer.findSymbol(MangledNameStream.str(), false);
}

SpecializingCompiler::~SpecializingCompiler() {
  std::lock_guard<std::mutex> Guard(ModuleMutex);
  LoadedModules.clear();
  LoadedContexts.clear();
  SPDLOG_DEBUG("libpjit", "Stopping PolyJIT Engine.");
}
}
