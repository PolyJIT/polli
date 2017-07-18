#include "polli/Compiler.h"
#include "polli/RuntimeOptimizer.h"
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

  TM.setOptLevel(llvm::CodeGenOpt::Aggressive);
  if (TM.addPassesToEmitMC(PM, Ctx, ObjStream))
    llvm_unreachable("Target does not support MC emission.");
  PM.run(M);

  std::unique_ptr<llvm::MemoryBuffer> ObjBuffer(
      new llvm::ObjectMemoryBuffer(std::move(ObjBufferSV)));

  Expected<std::unique_ptr<llvm::object::ObjectFile>> Obj =
      object::ObjectFile::createObjectFile(ObjBuffer->getMemBufferRef());
  if (Obj)
    return ObjFileT(std::move(*Obj), std::move(ObjBuffer));

  consumeError(Obj.takeError());
  return ObjFileT(nullptr, nullptr);
}

PolyJITEngine::PolyJITEngine()
    : TM(llvm::EngineBuilder()
             .setMArch(opt::runtime::MArch)
             .setMCPU(opt::runtime::MCPU)
             .setMAttrs(opt::runtime::MAttrs)
             .selectTarget()),
      DL(TM->createDataLayout()),
      ObjectLayer([]() {
        return std::make_shared<PolySectionMemoryManager>();
      }),
      CompileLayer(ObjectLayer, ModuleCompiler(*TM)),
      OptimizeLayer(CompileLayer, optimizeForRuntime),
      LibHandle(nullptr) {
  SPDLOG_DEBUG("libpjit", "Starting PolyJIT Engine.");
  LibHandle = dlopen(nullptr, RTLD_NOW | RTLD_GLOBAL);
  llvm::sys::DynamicLibrary::LoadLibraryPermanently(nullptr);
}

Module &PolyJITEngine::getModule(const char *prototype, bool &cache_hit) {
  cache_hit = true;
  if (!LoadedModules.count(prototype)) {
    MemoryBufferRef Buf(prototype, "polli.prototype.module");
    SMDiagnostic Err;
    auto Ctx = std::make_shared<LLVMContext>();

    CtxList.push_back(Ctx);
    if (UniqueModule Mod = parseIR(Buf, Err, *Ctx)) {
      LoadedModules.insert(std::make_pair(prototype, std::move(Mod)));
    } else {
      std::string FileName = Err.getFilename().str();
      console->critical("{:s}:{:d}:{:d} {:s}", FileName, Err.getLineNo(),
                        Err.getColumnNo(), Err.getMessage().str());
      console->critical("{0}", prototype);
    }

    auto PrototypeM = LoadedModules[prototype];
    if (!PrototypeM)
      console->critical("Parsing the prototype module failed!");
    assert(PrototypeM && "Parsing the prototype module failed!");
    cache_hit = false;
  }

  return *LoadedModules[prototype];
}

Expected<PolyJITEngine::ModuleHandleT>
PolyJITEngine::addModule(std::unique_ptr<Module> M) {
  if (CompiledModules.count(M.get()))
    return CompiledModules[M.get()];

  DEBUG({
    std::string buf;
    raw_string_ostream os(buf);
    M->print(os, nullptr);
    console->error(os.str());
  });
  for (GlobalValue &GV : M->globals()) {
    std::lock_guard<std::mutex> Lock(DLMutex);
    dlerror();
    void *Addr = dlsym(LibHandle, GV.getName().str().c_str());
    if (char *Error = dlerror())
      console->error("(dlsym) Could not locate the symbol: {:s}", Error);
    if (Addr)
      llvm::sys::DynamicLibrary::AddSymbol(GV.getName(), Addr);
  }

  auto Resolver = orc::createLambdaResolver(
      [&](const std::string &Name) -> JITSymbol {
        if (auto Sym = findSymbol(Name))
          return Sym;
        return JITSymbol(nullptr);
      },
      [](const std::string &S) {
        if (auto SymAddr = RTDyldMemoryManager::getSymbolAddressInProcess(S))
          return JITSymbol(SymAddr, JITSymbolFlags::Exported);
        return JITSymbol(nullptr);
      });

  Expected<ModuleHandleT> MH =
      OptimizeLayer.addModule(std::move(M), std::move(Resolver));
  CompiledModules.insert(std::make_pair(M.get(), *MH));
  return MH;
}

void PolyJITEngine::removeModule(ModuleHandleT H) {
  llvm::Error status = CompileLayer.removeModule(H);
  console->error_if(!status.success(), "Unable to remove module!"); 
  assert(status.success() && "Unable to remove module!");
    
}

JITSymbol PolyJITEngine::findSymbol(const std::string &Name) {
  std::string MangledName;
  raw_string_ostream MangledNameStream(MangledName);
  Mangler::getNameWithPrefix(MangledNameStream, Name, DL);
  return CompileLayer.findSymbol(MangledNameStream.str(), false);
}

PolyJITEngine::~PolyJITEngine() {
  CompiledModules.clear();
  LoadedModules.clear();
  CtxList.clear();
  SPDLOG_DEBUG("libpjit", "Stopping PolyJIT Engine.");
}
}
