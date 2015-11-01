#include "polli/Schema.h"
#include "llvm/Support/raw_ostream.h"
#include <cppformat/format.h>

namespace polli {
namespace db {

const std::string RegressionTest::str() const {
  return fmt::format("<RegressionTest ({:d}) Module<{:s}>>", runID(), name());
}

const std::string RegressionTest::formulate(pqxx::work &W) const {
  std::string ModuleStr = W.esc(module());
  std::string NameStr = W.esc(name());
  std::string ProjectNameStr = W.esc(projectName());
  return fmt::format(
      "INSERT INTO {:s} (run_id, project_name, name, module) "
      "SELECT {:d}, '{:s}', '{:s}', '{:s}'"
      "WHERE NOT EXISTS (SELECT name FROM {:s} WHERE name = '{:s}'"
      "AND project_name = '{:s}');",
      RegressionTest::TableName, runID(), ProjectNameStr, NameStr, ModuleStr,
      RegressionTest::TableName, NameStr, ProjectNameStr);
}

void Session::commit() {
  pqxx::work W(*C);

  for (auto &I : Items) {
    I->setProjectName(Opts.project);
    I->setRunID(DbOpts.run_id);
    W.exec(I->formulate(W));
  }

  W.commit();
  Items.clear();
}
const std::string RegressionTest::TableName = "regressions";
} // enf of namespace db
} // end of namespace polli
