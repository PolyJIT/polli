#include "catch.hpp"
#include "llvm/ADT/SmallVector.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/GlobalValue.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Type.h"

#include "polli/RunValues.h"
#include "llvm/Support/raw_ostream.h"

#include <memory>

using llvm::Attribute;
using llvm::AttrBuilder;
using llvm::Module;
using llvm::Function;
using llvm::LLVMContext;
using llvm::FunctionType;
using llvm::Type;
using llvm::GlobalValue;
using llvm::SmallVector;

using polli::SpecializerRequest;
using polli::RunValueList;
using polli::runValues;

SCENARIO("String-Attribute attached to function arguments", "[unit]") {
  LLVMContext Ctx;
  auto M = std::make_shared<Module>("test_RunValues", Ctx);

  GIVEN("An llvm function that has one argument.") {
    SmallVector<Type*, 1> Args;
    Args.push_back(Type::getInt64Ty(Ctx));
    Function *F = Function::Create(
        FunctionType::get(Type::getVoidTy(Ctx), Args, false),
        GlobalValue::ExternalLinkage, "test_attributes", M.get());

    WHEN("The attribute 'polli.specialize' is attached to the first argument") {
      Attribute ParamAttr = llvm::Attribute::get(Ctx, "polli.specialize");
      AttrBuilder Builder(ParamAttr);
      F->addParamAttrs(0, Builder);
      THEN("The first Fn attribute has string value 'polli.specialize'") {
        Attribute FnArgAttr = F->getAttribute(1, "polli.specialize");
        REQUIRE(FnArgAttr.getKindAsEnum() != llvm::Attribute::AttrKind::None);
        REQUIRE(FnArgAttr.getAsString() == "\"polli.specialize\"");
        REQUIRE(ParamAttr.getAsString() == "\"polli.specialize\"");
      }
    }
  }
}
