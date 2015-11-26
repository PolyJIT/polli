#include "polli/Schema.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/LLVMContext.h"

#include <gtest/gtest.h>

using namespace polli::db;
using namespace llvm;

TEST(RegressionTest, TestConstructDestroy) { RegressionTest T; }

TEST(RegressionTest, TestGetRunID) {
  RegressionTest T;
  EXPECT_EQ((uint64_t)0, T.runID());
}

TEST(RegressionTest, TestGetSetRunID) {
  RegressionTest T;
  T.setRunID(1);
  EXPECT_EQ((uint64_t)1, T.runID());
}

TEST(RegressionTest, TestGetEmptyModule) {
  RegressionTest T;
  EXPECT_EQ("", T.module());
}

TEST(RegressionTest, TestSetName) {
  RegressionTest T;
  T.setName("test.module");
  EXPECT_EQ(T.str(), "<RegressionTest (0) Module<test.module>>");
}

TEST(RegressionTest, TestFormulate) {
  pqxx::connection C("");
  pqxx::work W(C);
  RegressionTest T;
  T.setName("test.module");
  T.setModule("test.module.foo");
  EXPECT_EQ(T.formulate(W), "INSERT INTO regressions (run_id, name, module) "
                           "VALUES (0, 'test.module', 'test.module.foo');");
}
