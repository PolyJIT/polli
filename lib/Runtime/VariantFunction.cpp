#include "likwid.h"

#include "absl/memory/memory.h"

#include "polli/FunctionCloner.h"
#include "polli/RunValues.h"
#include "polli/RuntimeValues.h"
#include "polli/Stats.h"
#include "polli/Utils.h"
#include "polli/VariantFunction.h"
#include "polli/log.h"

#include "llvm/IR/Constants.h"

#define DEBUG_TYPE "polyjit"

using namespace llvm;

REGISTER_LOG(console, "variants");

namespace polli {
llvm::raw_ostream &operator<<(llvm::raw_ostream &OS, const Param &P) {
  return OS << P.Val->getUniqueInteger();
}

llvm::raw_ostream &operator<<(llvm::raw_ostream &out,
                              const RunValueList &Params) {
  out << "[";

  for (auto &Val : Params) {
    out << Val.value;
    out << " ";
  }
  out << "]";
  return out;
}

llvm::raw_ostream &operator<<(llvm::raw_ostream &out,
                              const ParamVector<Param> &Params) {
  out << "[";
  for (size_t I = 0; I < Params.size(); ++I) {
    out << Params[I];
    if (!(I == Params.size() - 1))
      out << " ";
  }

  out << "]";
  return out;
}

void getRuntimeParameters(Function *F, unsigned paramc, void *params,
                          std::vector<Param> &ParamV) {
  int I = 0;
  for (const Argument &Arg : F->args()) {
    Type *ArgTy = Arg.getType();

    /* TODO: Add more types to be suitable for spawning new functions. */
    if (auto *IntTy = dyn_cast<IntegerType>(ArgTy)) {
      Param P;
      P.Ty = IntTy;
      P.Name = Arg.getName();
      P.Val = ConstantInt::get(IntTy, ((uint64_t **)params)[I][0]);
      ParamV.push_back(P);
    }
    I++;
  }
}

/**
 * @brief  Convert srcF signature into a 'main' function format,
 * i.e. f(int argc, char** argv). This way the parameters can be passed by
 * the MCJIT while it does not support real parameter passing at run time.
 *
 * The parameters are unpacked inside the function again, maybe it does not
 * get too inefficient ;-).
 */
struct MainCreator {
  /**
   * @brief Unpack the parameters from the array onto the stack. O2 version.
   *
   * @param Builder IRBuilder we use to create the unpack stuff.
   * @param VMap Value-to-Value map to track rewritten arguments.
   * @param SrcF Source function we convert to main() format.
   * @param TgtF Target function we convert into.
   */
  static void CreateUnpackParamsO2(IRBuilder<> &Builder,
                                   ValueToValueMapTy &VMap, Function *SrcF,
                                   Function *TgtF) {
    LLVMContext &Ctx = Builder.getContext();
    // 2nd argument is our array, 1st is argc
    Function::arg_iterator TgtArg = TgtF->arg_begin();
    Argument &ArgV = *++TgtArg;

    ArgV.setName("argv");

    // Unpack params. Allocate space on the stack and store the pointers.
    // Some parameters are not required anymore.
    unsigned I = 0;
    for (Argument &Arg : SrcF->args()) {
      Value *IdxI = ConstantInt::get(Type::getInt64Ty(Ctx), I++);

      Type *ArgTy = Arg.getType();
      std::string SlotName =
          fmt::format("polyjit.slot.{:d}_{:s}", I - 1, Arg.getName().str());
      std::string IdxName =
          fmt::format("polyjit.idx.{:d}_{:s}", I - 1, Arg.getName().str());
      if (!ArgTy->isPointerTy()) {
        Value *ArrIdx = Builder.CreateInBoundsGEP(&ArgV, {IdxI});
        Value *CastVal = Builder.CreateBitCast(
            ArrIdx, ArgTy->getPointerTo()->getPointerTo());
        Value *LoadSlot = Builder.CreateLoad(CastVal, SlotName);
        Value *LoadVal = Builder.CreateLoad(LoadSlot, IdxName);
        VMap[&Arg] = LoadVal;
      } else {
        Value *ArrIdx = Builder.CreateInBoundsGEP(&ArgV, {IdxI});
        Value *CastVal = Builder.CreateBitCast(ArrIdx, ArgTy->getPointerTo());
        Value *LoadArr = Builder.CreateLoad(CastVal, IdxName);
        VMap[&Arg] = LoadArr;
      }
    }
  }

  /**
   * @brief Map arguments from an array back to single values.
   *
   * @param VMap Value-To-Value tracker.
   * @param SrcF Source function.
   * @param TgtF Target function.
   */
  static void MapArguments(ValueToValueMapTy &VMap, Function *SrcF,
                           Function *TgtF) {
    LLVMContext &Context = TgtF->getContext();
    IRBuilder<> Builder(Context);

    BasicBlock *EntryBB = BasicBlock::Create(Context, "entry.param", TgtF);
    Builder.SetInsertPoint(EntryBB);

    CreateUnpackParamsO2(Builder, VMap, SrcF, TgtF);
  }

  /**
   * @brief Create a new target function to perform the main creator policy on.
   *
   * @param SrcF Source function to create a main-version from.
   * @param TgtM Target module to create the new function into.
   *
   * @return A new function, with main()-compatible signature.
   */
  static Function *Create(Function *SrcF, Module *TgtM) {
    LLVMContext &Ctx = TgtM->getContext();
    Type *RetType = Type::getVoidTy(Ctx);
    PointerType *PtoArr = Type::getInt8PtrTy(Ctx)->getPointerTo();

    Function *F = cast<Function>(TgtM->getOrInsertFunction(
        SrcF->getName(), RetType, Type::getInt32Ty(Ctx), PtoArr));

    F->setLinkage(SrcF->getLinkage());
    return F;
  }
};

//===----------------------------------------------------------------------===//
// SpecializeEndpoint policy.
//
// Specializes the endpoint with a list of parameter values.
// All uses of the a Value are replaced with the parameter value associated
// to this value.
//
template <class ParamT> class SpecializeEndpoint {
private:
  llvm::SmallVector<VarParam, 4> SpecValues;

public:
  void setParameters(llvm::SmallVector<VarParam, 4> const &Values) {
    SpecValues = Values;
  }

  Function::arg_iterator getArgument(Function *F, StringRef ArgName) {
    return std::find_if(
        F->arg_begin(), F->arg_end(),
        [&](Function::arg_iterator &It) { return It->getName() == ArgName; });
  }

  /**
   * @brief Apply the parameter value specialization in the endpoint.
   *
   * It is necessary that SpecValues is already set. Next we align the
   * specialization values with the formal function arguments and substitute
   * all uses of this argument with a constant representing the specialization
   * value.
   *
   * @param TgtF The function we specialize.
   * @param SrcF Our source function.
   * @param VMap A value-to-value map that tracks cloned values/function args.
   */
  void Apply(Function *From, Function *To, ValueToValueMapTy &VMap) {
    auto I = SpecValues.begin();
    for (Argument &Arg : From->args()) {
      Type *Ty = Arg.getType();
      if (!canSpecialize(Arg)) {
        continue;
      }

      if (Ty->isIntegerTy()) {
        auto *IntVal = ConstantInt::get(Ty, absl::get<uint64_t>(*I));
        Value *MappedArg = VMap[&Arg];
        MappedArg->replaceAllUsesWith(IntVal);
      }

      I++;
    }
  }
};

static std::unique_ptr<FunctionClonerBase>
createCloner(const VariantRequest Req, ValueToValueMapTy &VMap) {
  if (!opt::runtime::DisableSpecialization) {
    // Perform parameter value substitution.
    auto Specializer = absl::make_unique<FunctionCloner<
        CopyCreator, IgnoreSource, SpecializeEndpoint<RunValue<uint64_t *>>>>();

    /* Perform a parameter specialization by taking the unchanged base
     * function
     * and substitute all known parameter values.
     */
    Specializer->setParameters(Req.Params);
    return Specializer;
  }

  // auto Specializer = std::make_unique<
  //    FunctionCloner<MainCreator, IgnoreSource, ConnectTarget>>();
  auto Specializer = absl::make_unique<DefaultFunctionCloner>();
  return Specializer;
}

/**
 * @brief Create a new variant of this function using the function key K.
 *
 * This creates a copy of the existing prototype function and substitutes
 * all uses of K's name with K's value.
 *
 * @param R The request we process.
 * @param FnName the function name of the new variant inside the module.
 *
 * @return a copy of the base function, with the values of K substituted.
 */
std::unique_ptr<Module> createVariant(VariantRequest R, std::string &FnName) {
  ValueToValueMapTy VMap;

  /* Copy properties of our source module */

  // Prepare a new module to hold our new function.
  const Function *BaseF = R.F.value();
  const Module *M = BaseF->getParent();
  assert(M && "Function without parent module?!");
  if (!M)
    llvm_unreachable("Broken function.");

  LLVMContext &Ctx = M->getContext();
  auto NewM =
      std::unique_ptr<Module>(new Module(M->getModuleIdentifier(), Ctx));
  NewM->setTargetTriple(M->getTargetTriple());
  NewM->setDataLayout(M->getDataLayout());
  NewM->setMaterializer(M->getMaterializer());
  NewM->setModuleIdentifier(fmt::format("{}.{}-{:d}.variant",
                                        M->getModuleIdentifier(),
                                        BaseF->getName().str(), R.Hash));

#if 0
  DEBUG({
    console->error(
        "\n==============================================================="
        "\n VariantFunction:: {:s}"
        "\n===============================================================\n",
        BaseF.getName().str());
    std::string buf;
    raw_string_ostream os(buf);
    BaseF.getType()->print(os << "\nBaseT:");
    os << "\n";
    for (auto RV : K) {
      Type *ArgTy = RV.Arg->getType();
      RV.Arg->print(os);
      os << " = ";

      Constant *C = nullptr;
      if (canSpecialize(RV)) {
        if (ArgTy->isIntegerTy()) {
          C = ConstantInt::get(ArgTy, *RV.value, /*isSigned=*/true);
        } else if (ArgTy->isFloatTy()) {
          C = llvm::ConstantFP::get(ArgTy, (double)*RV.value);
        }
      } else {
        os << RV.value;
      }

      if (C)
        C->print(os);

      os << ", ";
    }
    os << "\n";
    console->error("Create Variant {} Hash: {:d}:\n{:s}", K.str(), K.hash(),
                   os.str());
  });
#endif
  auto Specializer = createCloner(R, VMap);
  Specializer->setTargetModule(NewM.get());
  Specializer->setSource(const_cast<llvm::Function *>(BaseF));

  if (!BaseF->hasFnAttribute("polyjit-id"))
    console->critical("{:s} has no polyjit-id. Tracking will not work.",
                      BaseF->getName().str());
  Function *NewF = Specializer->start(VMap, /*RemapCalls=*/true);
  NewF->setName(fmt::format("{:s}_{:d}", NewF->getName().str(), R.Hash));
  NewF->addFnAttr("polyjit-id",
                  fmt::format("{:d}", polli::GetCandidateId(*BaseF)));
  FnName = NewF->getName().str();

  return NewM;
}
} // namespace polli
