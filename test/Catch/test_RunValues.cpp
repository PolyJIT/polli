#include "catch.hpp"
#include "llvm/ADT/SmallVector.h"
#include "llvm/IR/LLVMContext.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Type.h"
#include "llvm/IR/GlobalValue.h"

#include "polli/RunValues.h"
#include "llvm/Support/raw_ostream.h"

#include <memory>

SCENARIO("Pointer indirection over the stack", "[run]") {
  GIVEN("An array with 1 pointer to a 64-bit integer on the stack") {
    std::array<int64_t *, 1> A;
    int64_t i = 0;
    A[0] = &i;

    WHEN("The value 1 is written to the pointer in the first array cell") {
      *(A[0]) = 1;
      THEN("1 can be read from the stack variable") {
        REQUIRE(i == 1);
      }
    }

    WHEN("The value 2 is written to the stack variable") {
      i = 2;
      THEN("2 can be read from the array") {
        REQUIRE(*(A[0]) == 2);
      }
    }
  }
}

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

SCENARIO("runValues() can align parameter values to run-time values", "[run]") {
  LLVMContext Ctx;
  Module M("test_RunValues", Ctx);

  GIVEN("A Specializer Request for the function 'void f(int a)' with the"
        "arguments a=1") {
    SmallVector<Type*, 1> Args;
    Args.push_back(Type::getInt64Ty(Ctx));
    Function *F =
        Function::Create(FunctionType::get(Type::getVoidTy(Ctx), Args, false),
                         GlobalValue::ExternalLinkage, "test_run_values", &M);

    int64_t *A = reinterpret_cast<int64_t *>(std::malloc(sizeof(int64_t*)));
    int64_t i = 1;
    A[0] = reinterpret_cast<int64_t>(&i);

    SpecializerRequest R(nullptr, 1, reinterpret_cast<char **>(A));
    R.F = F;

    WHEN("runValues() is called") {
      RunValueList RVs = runValues(R);
      THEN("The returned list has size 1") {
        REQUIRE(RVs.size() == 1);
      }

      THEN("The returned list is not empty") {
        REQUIRE(RVs.begin() != RVs.end());
      }

      THEN("The first element of the RunValueList has the value 1.") {
        REQUIRE(*reinterpret_cast<int64_t *>(RVs[0].value) == 1);
      }

      THEN("The argument type of the first parameter is Int64.") {
        Type *Ty = RVs[0].Arg->getType();
        REQUIRE(Ty->isIntegerTy());
        REQUIRE(Ty->getIntegerBitWidth() == 64);
      }
    }
    std::free(A);
  }

  GIVEN("A SpecializerRequest for the function void f(int64_t, int64_t *)") {
    SmallVector<Type*, 2> Args;
    Args.push_back(Type::getInt64Ty(Ctx));
    Args.push_back(Type::getInt64PtrTy(Ctx));
    Function *F =
        Function::Create(FunctionType::get(Type::getVoidTy(Ctx), Args, false),
                         GlobalValue::ExternalLinkage, "test_run_values_2", &M);

    int64_t *A = reinterpret_cast<int64_t *>(std::malloc(2*sizeof(int64_t*)));
    int64_t i = 2;
    int64_t *B = reinterpret_cast<int64_t *>(std::malloc(sizeof(int64_t)));

    A[0] = reinterpret_cast<int64_t>(&i);
    A[1] = reinterpret_cast<int64_t>(&B);

    SpecializerRequest R(nullptr, 2, reinterpret_cast<char **>(A));
    R.F = F;

    WHEN("runValues() is called") {
      RunValueList RVs = runValues(R);
      THEN("The returned list has size 2") {
        REQUIRE(RVs.size() == 2);
      }

      THEN("The first element of the RunValueList has the value 2.") {
        REQUIRE(*reinterpret_cast<int64_t *>(RVs[0].value) == 2);
      }

      THEN("The second element of the RunValueList is of type 'Pointer'.") {
        Type *Ty = RVs[1].Arg->getType();
        REQUIRE(Ty->isPointerTy());
      }
    }
    std::free(A);
    std::free(B);
  }

}
