//===-- Schema.h - Database persistence ------------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//
//
//
//===----------------------------------------------------------------------===//
#ifndef POLLI_SCHEMA_H
#define POLLI_SCHEMA_H
#include "polli/log.h"
#include "pprof/pgsql.h"
#include "pprof/pprof.h"
#include "llvm/IR/Module.h"
#include <pqxx/pqxx>
#include <string>

namespace polli {
using ModulePtr = std::shared_ptr<const llvm::Module>;
using ConnectionPtr = std::shared_ptr<pqxx::connection>;

namespace db {
class Tuple {
private:
  uint64_t RunID;
  std::string ProjectName;

public:
  explicit Tuple() : RunID(0) {}
  explicit Tuple(uint64_t RunID) : RunID(RunID), ProjectName("") {}

  void setRunID(const uint64_t ID) { RunID = ID; }
  uint64_t runID() const { return RunID; }

  void setProjectName(const std::string PrjName) { ProjectName = PrjName; }
  const std::string projectName() const { return ProjectName; }

  virtual const std::string formulate(pqxx::work &W) const = 0;
  virtual ~Tuple(){};
};

class RegressionTest : public virtual Tuple {
private:
  const static std::string TableName;
  std::string Name;
  std::string Module;

public:
  explicit RegressionTest() : Tuple(), Name(""), Module("") {}
  explicit RegressionTest(std::string Name, std::string Module)
      : Tuple(), Name(Name), Module(Module) {}
  virtual ~RegressionTest() override {}

  void setName(const std::string NewName) { Name = NewName; }
  const std::string name() const { return Name; }

  void setModule(const std::string &M) { Module = M; }
  const std::string &module() const { return Module; }

  virtual const std::string formulate(pqxx::work &W) const override;
  const std::string str() const;
};

static ConnectionPtr
createDefaultConnection(const pprof::DbOptions *DbOpts = nullptr) {
  const pprof::DbOptions Opts = DbOpts ? *DbOpts : pprof::getDBOptionsFromEnv();
  std::string ConnectString =
      fmt::format("user={} port={} host={} dbname={} password={}", Opts.user,
                  Opts.port, Opts.host, Opts.name, Opts.pass);
  static std::shared_ptr<pqxx::connection> C;
  if (!C || !C->is_open())
    C = std::make_shared<pqxx::connection>(ConnectString);

  return C;
}

class Session {
private:
  std::vector<std::shared_ptr<Tuple>> Items;
  pprof::DbOptions DbOpts;
  pprof::Options Opts;
  ConnectionPtr C;

public:
  explicit Session()
      : DbOpts(pprof::getDBOptionsFromEnv()),
        Opts(pprof::getPprofOptionsFromEnv()), C(createDefaultConnection()) {}
  ~Session() {
    Items.clear();
    C->disconnect();
  }

  Session &add(std::shared_ptr<Tuple> T) {
    Items.push_back(T);
    return *this;
  }

  void commit();
  void rollback() { Items.clear(); }
};
} // namespace db
} // namespace polli
#endif // POLLI_SCHEMA_H
