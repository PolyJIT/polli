#include "absl/memory/memory.h"

#include "polli/Compiler.h"
#include "polli/Monitor.h"
#include "polli/RuntimeOptimizer.h"
#include "polli/log.h"

#include "llvm/ADT/StringRef.h"
#include "llvm/IR/Mangler.h"
#include "llvm/IR/Verifier.h"
#include "llvm/IRReader/IRReader.h"
#include "llvm/ExecutionEngine/ExecutionEngine.h"
#include "llvm/ExecutionEngine/Orc/CompileUtils.h"
#include "llvm/ExecutionEngine/Orc/LambdaResolver.h"
#include "llvm/ExecutionEngine/RTDyldMemoryManager.h"
#include "llvm/ExecutionEngine/SectionMemoryManager.h"
#include "llvm/PassSupport.h"
#include "llvm/Support/DynamicLibrary.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/TargetSelect.h"

#include <dlfcn.h>

using llvm::CodeGenOpt::Level;
using llvm::EngineBuilder;
using llvm::Error;
using llvm::Expected;
using llvm::errs;
using llvm::GlobalValue;
using llvm::JITSymbolFlags;
using llvm::LLVMContext;
using llvm::legacy::PassManager;
using llvm::Mangler;
using llvm::MCContext;
using llvm::MemoryBuffer;
using llvm::MemoryBufferRef;
using llvm::Module;
using llvm::ObjectMemoryBuffer;
using llvm::object::ObjectFile;
using llvm::orc::createLambdaResolver;
using llvm::parseIR;
using llvm::RTDyldMemoryManager;
using llvm::raw_string_ostream;
using llvm::raw_svector_ostream;
using llvm::SectionMemoryManager;
using llvm::SMDiagnostic;
using llvm::SmallVector;
using llvm::StringRef;
using llvm::sys::DynamicLibrary;
using llvm::TargetMachine;
using llvm::verifyModule;

REGISTER_LOG(console, "compiler");

namespace polli {
class PolySectionMemoryManager : public SectionMemoryManager {
public:
  uint8_t *allocateCodeSection(uintptr_t Size, unsigned Alignment,
                               unsigned SectionID,
                               StringRef SectionName) override {
    uint8_t *Ptr = SectionMemoryManager::allocateCodeSection(
        Size, Alignment, SectionID, SectionName);
    SPDLOG_DEBUG(
        console, "cs @ 0x{:x} sz: {:d} align: {:d} id: {:d} name: {:s}",
        (uint64_t)ptr, (uint64_t)Size, Alignment, SectionID, SectionName.str());
    return Ptr;
  }

  uint8_t *allocateDataSection(uintptr_t Size, unsigned Alignment,
                               unsigned SectionID, StringRef SectionName,
                               bool isReadOnly) override {
    uint8_t *Ptr = SectionMemoryManager::allocateDataSection(
        Size, Alignment, SectionID, SectionName, isReadOnly);
    SPDLOG_DEBUG(console,
        "ds @ 0x{:x} sz: {:d} align: {:d} id: {:d} name: {:s} ro: {:d}",
        (uint64_t)ptr, (uint64_t)Size, Alignment, SectionID, SectionName.str(),
        isReadOnly);
    return Ptr;
  }
};

ModuleCompiler::ObjFileT ModuleCompiler::operator()(Module &M) const {
  SmallVector<char, 0> ObjBufferSV;
  raw_svector_ostream ObjStream(ObjBufferSV);

  PassManager PM;
  MCContext *Ctx;
  EngineBuilder BuildEngine;
  TargetMachine *TM = BuildEngine.setMCPU(opt::runtime::MCPU)
                          .setMArch(opt::runtime::MArch)
                          .setMAttrs(opt::runtime::MAttrs)
                          .selectTarget();

  TM->setOptLevel(Level::Aggressive);
  if (TM->addPassesToEmitMC(PM, Ctx, ObjStream))
    llvm_unreachable("Target does not support MC emission.");
  PM.run(M);

  std::unique_ptr<MemoryBuffer> ObjBuffer(
      new ObjectMemoryBuffer(std::move(ObjBufferSV)));

  Expected<std::unique_ptr<ObjectFile>> Obj =
      ObjectFile::createObjectFile(ObjBuffer->getMemBufferRef());

  if (Obj)
    return ObjFileT(std::move(*Obj), std::move(ObjBuffer));

  llvm_unreachable("No object file generated.");
}

SpecializingCompiler::SpecializingCompiler()
    : ObjectLayer(
          []() { return std::make_shared<PolySectionMemoryManager>(); }),
      CompileLayer(ObjectLayer, ModuleCompiler()),
      OptimizeLayer(CompileLayer, RuntimeOptimizer(OptimizedModules)),
      LibHandle(nullptr) {
  SPDLOG_DEBUG("libpjit", "Starting PolyJIT Engine.");
  LibHandle = dlopen(nullptr, RTLD_NOW | RTLD_GLOBAL);
  DynamicLibrary::LoadLibraryPermanently(nullptr);
}

SpecializingCompiler::ModCacheResult
SpecializingCompiler::getModule(const uint64_t ID, const char *prototype) {
  bool CacheHit = LoadedModules.find(ID) != LoadedModules.end();
  if (!CacheHit) {
    auto &Errs = errs();
    std::string Str(prototype);
    MemoryBufferRef Buf(Str, "polli.prototype.module");
    SMDiagnostic Err;
    std::unique_ptr<Module> M = parseIR(Buf, Err, Ctx.monitored());

    if (!M) {
      Err.print("libpjit", Errs, true, true);
    }
    assert(M && "Could not load the prototype!");

    // Ensure the module is not broken.
    if (!verifyModule(*M, &Errs)) {
      std::lock_guard<std::mutex> Guard(ModuleMutex);
      LoadedModules.insert(std::make_pair(ID, std::move(M)));
    }
  }

  return std::make_pair(LoadedModules.at(ID), CacheHit);
}

const polli::Monitor<LLVMContext> &
SpecializingCompiler::getContext() const {
  return Ctx;
}

SpecializingCompiler::OptimizedModule
SpecializingCompiler::addModule(std::shared_ptr<Module> M) {
  for (GlobalValue &GV : M->globals()) {
    if (GV.hasInternalLinkage() || GV.hasPrivateLinkage()) {
      continue;
    }
    std::lock_guard<std::mutex> Lock(DLMutex);
    dlerror();
    {
      void *Addr = dlsym(LibHandle, GV.getName().str().c_str());
      if (Addr) {
        DynamicLibrary::AddSymbol(GV.getName(), Addr);
      }
    }

    if (char *Error = dlerror()) {
      console->error("(dlsym) Could not locate the symbol: {:s}", Error);
      std::string Buf;
      raw_string_ostream Os(Buf);
      M->print(Os, nullptr, true, true);
      console->error("{:s}", Os.str());
    }
  }

  auto Resolver = createLambdaResolver(
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
  const bool IsOptimized = OptimizedModules.find(M) != OptimizedModules.end();
  console->debug("Compiler: {:d}", IsOptimized);
  if (!IsOptimized) {
    block(M);
  }

  console->error_if(!MH, "Module compilation failed!");
  assert(MH && "Adding the module failed!");
  return std::make_pair(std::move(MH), IsOptimized);
}

void SpecializingCompiler::removeModule(ModuleHandleT H) {
  Error Status = CompileLayer.removeModule(H);
  console->error_if(!Status.success(), "Unable to remove module!");
  assert(Status.success() && "Unable to remove module!");

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
  SPDLOG_DEBUG("libpjit", "Stopping PolyJIT Engine.");
}

bool SpecializingCompiler::IsOptimizeable(const polli::SharedModule &M) const {
  auto RtOptFtorEnd = OptimizedModules.end();
  return OptimizedModules.find(M) != RtOptFtorEnd;
}
} // namespace polli
