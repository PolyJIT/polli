#include "polli/Db.h"
#include "polli/Jit.h"
#include "polli/Options.h"
#include "polli/log.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/ManagedStatic.h"

#include <ctime>
#include <iostream>
#include <numeric>
#include <pqxx/pqxx>
#include <set>
#include <stdlib.h>
#include <string>
#include <thread>

using namespace pqxx;
using namespace llvm;

namespace papi {
#include <papi.h>
} // namespace papi

namespace polli {
namespace opt {
static std::string Experiment;
static cl::opt<std::string, true>
    ExperimentX("polli-db-experiment",
                cl::desc("Name of the experiment we are running under."),
                cl::location(Experiment), cl::init("unknown"),
                cl::cat(PolyJitRuntime));

static std::string ExperimentUUID;
static cl::opt<std::string, true>
    ExperimentUUIDX("polli-db-experiment-uuid", cl::desc("Experiment UUID."),
                    cl::location(ExperimentUUID),
                    cl::init("00000000-0000-0000-0000-000000000000"),
                    cl::cat(PolyJitRuntime));

static std::string Project;
static cl::opt<std::string, true>
    ProjectX("polli-db-project", cl::desc("The project we are running under."),
             cl::location(Project), cl::init("unknown"),
             cl::cat(PolyJitRuntime));

static std::string Domain;
static cl::opt<std::string, true>
    DomainX("polli-db-domain", cl::desc("The domain we are running under."),
            cl::location(Domain), cl::init("unknown"),
            cl::cat(PolyJitRuntime));

static std::string Group;
static cl::opt<std::string, true>
    GroupX("polli-db-group", cl::desc("The group we are running under."),
           cl::location(Group), cl::init("unknown"), cl::cat(PolyJitRuntime));

static std::string SourceUri;
static cl::opt<std::string, true> SourceUriX(
    "polli-db-src-uri", cl::desc("The src_uri we are running under."),
    cl::location(SourceUri), cl::init("unknown"), cl::cat(PolyJitRuntime));

static std::string Argv0;
static cl::opt<std::string, true>
    Argv0X("polli-db-argv", cl::desc("The command we are executing."),
           cl::location(SourceUri), cl::init("unknown"),
           cl::cat(PolyJitRuntime));

static bool EnableDatabase;
static cl::opt<bool, true> EnableDatabaseX(
    "polli-db-enable", cl::desc("Enable database communication."),
    cl::location(EnableDatabase), cl::init(false), cl::cat(PolyJitRuntime));

static bool ExecuteAtExit;
static cl::opt<bool, true> ExecuteAtExitX(
    "polli-db-execute-atexit", cl::desc("Enable execution of atexit handler."),
    cl::location(ExecuteAtExit), cl::init(false), cl::cat(PolyJitRuntime));

static std::string DbHost;
static cl::opt<std::string, true>
    DbHostX("polli-db-host", cl::desc("DB Hostname"), cl::location(DbHost),
            cl::init("localhost"), cl::cat(PolyJitRuntime));

static int DbPort;
static cl::opt<int, true> DbPortX("polli-db-port", cl::desc("DB Port"),
                                  cl::location(DbPort), cl::init(5432),
                                  cl::cat(PolyJitRuntime));

static std::string DbUsername;
static cl::opt<std::string, true> DbUsernameX("polli-db-username",
                                              cl::desc("DB Username"),
                                              cl::location(DbUsername),
                                              cl::init("benchbuild"),
                                              cl::cat(PolyJitRuntime));

static std::string DbPassword;
static cl::opt<std::string, true> DbPasswordX("polli-db-password",
                                              cl::desc("DB Password"),
                                              cl::location(DbPassword),
                                              cl::init("benchbuild"),
                                              cl::cat(PolyJitRuntime));
static std::string DbName;
static cl::opt<std::string, true> DbNameX("polli-db-name", cl::desc("DB Name"),
                                          cl::location(DbName),
                                          cl::init("benchbuild"),
                                          cl::cat(PolyJitRuntime));

static std::string RunGroupUUID;
static cl::opt<std::string, true>
    DbRunGroupUUIDX("polli-db-run-group", cl::desc("DB RunGroup (UUID)"),
                    cl::location(RunGroupUUID),
                    cl::init("00000000-0000-0000-0000-000000000000"),
                    cl::cat(PolyJitRuntime));

static int RunID;
static cl::opt<int, true> DbRunIdX("polli-db-run-id",
                                   cl::desc("DB RunGroup (UUID)"),
                                   cl::location(RunID), cl::init(0),
                                   cl::cat(PolyJitRuntime));
} // namespace opt

std::string now() {
  char Buf[sizeof "YYYY-MM-DDTHH:MM:SS"];
  time_t Now;
  time(&Now);

  strftime(Buf, sizeof Buf, "%F %T", localtime(&Now));
  return std::string(Buf);
}

static bool enable_tracking() {
  return opt::EnableDatabase;
}

static pqxx::result submit(const std::string &Query,
                           pqxx::work &w) throw(pqxx::syntax_error) {
  pqxx::result Res;
  try {
    Res = w.exec(Query);
  } catch (pqxx::data_exception E) {
    std::cerr << "pgsql: Encountered the following error:\n";
    std::cerr << E.what();
    std::cerr << "\n";
    std::cerr << E.query();
    throw E;
  }
  return Res;
}


class DBConnection {
  std::unique_ptr<pqxx::connection> c;
  std::string ConnectionString;

  std::string Experiment;
  std::string ExperimentUUID;

  std::string Project;
  std::string Domain;
  std::string Group;
  std::string SourceURI;
  std::string Argv0;

  std::string RunGroupUUID;
  int RunID;

  void connect() {
    if (!enable_tracking())
      return;

    c = std::unique_ptr<pqxx::connection>(
        new pqxx::connection(ConnectionString));
  }

public:
  explicit DBConnection(std::string Experiment, std::string ExperimentUUID,
                        std::string Project, std::string Domain,
                        std::string Group, std::string SourceURI,
                        std::string Argv0, std::string RunGroupUUID, int RunID)
      : Experiment(Experiment), ExperimentUUID(ExperimentUUID),
        Project(Project), Domain(Domain), Group(Group), SourceURI(SourceURI),
        Argv0(Argv0), RunGroupUUID(RunGroupUUID), RunID(RunID) {
    std::string ConnectionFmtStr =
        "user={} port={} host={} dbname={} password={}";
    ConnectionString =
        fmt::format(ConnectionFmtStr, opt::DbUsername, opt::DbPort,
                    opt::DbHost, opt::DbName, opt::DbPassword);
  }

  void prepare() {
    if (c) {
      std::string SelectRun =
          "SELECT id,type,timestamp FROM papi_results WHERE run_id=$1 ORDER BY "
          "timestamp;";
      std::string SelectSimpleRun = "SELECT id,type,start,duration,name,tid "
                                      "FROM benchbuild_events WHERE run_id=$1 "
                                      "ORDER BY "
                                      "start;";
      std::string DeleteSimpleRun =
          "DELETE FROM benchbuild_events WHERE run_id=$1";
      std::string SelectRunIDs = "SELECT id FROM run WHERE run_group = $1;";
      std::string SelectRunGroups =
          "SELECT DISTINCT run_group FROM run WHERE experiment_group = $1;";

      c->prepare("select_run", SelectRun);
      c->prepare("select_simple_run", SelectSimpleRun);
      c->prepare("delete_simple_run", DeleteSimpleRun);
      c->prepare("select_run_ids", SelectRunIDs);
      c->prepare("select_run_groups", SelectRunGroups);
    }
  }

  pqxx::connection &operator->() {
    if (c)
      return *c;
    connect();
    return *c;
  }

  pqxx::connection &operator*() {
    if (c)
      return *c;
    connect();
    return *c;
  }

  uint64_t prepareRun(pqxx::work &w) {
    std::string SearchProjectSql =
        "SELECT name FROM project WHERE name = '{}';";

    std::string NewProjectSql =
        "INSERT INTO project (name, description, src_url, domain, group_name) "
        "VALUES ('{}', '{}', '{}', '{}', '{}');";

    std::string NewRunSql =
        "INSERT INTO run (\"end\", command, "
        "project_name, experiment_name, run_group, experiment_group) "
        "VALUES (TIMESTAMP '{}', '{}', "
        "'{}', '{}', '{}', '{}') RETURNING id;";

    pqxx::result ProjectExists =
        submit(fmt::format(SearchProjectSql, Project), w);

    if (ProjectExists.affected_rows() == 0)
      submit(fmt::format(NewProjectSql, Project, Project,
                         SourceURI, Domain, Group),
             w);

    uint64_t RunId = 0;
    if (!opt::RunID) {
      pqxx::result R =
          submit(fmt::format(NewRunSql, now(), Argv0, Project, Experiment,
                             RunGroupUUID, ExperimentUUID),
                 w);
      R[0]["id"].to(RunId);
    } else {
      RunId = RunID;
    }

    return RunId;
  }

  ~DBConnection() {
    if (c && c->is_open())
      c->disconnect();
    c.reset(nullptr);
  }
};

struct DBCreator {
  static void *call() {
    return new DBConnection(
        opt::Experiment, opt::ExperimentUUID, opt::Project, opt::Domain,
        opt::Group, opt::SourceUri, opt::Argv0, opt::RunGroupUUID, opt::RunID);
  }
};

static llvm::ManagedStatic<DBConnection, DBCreator> DB;

struct Event {
  std::string Name;
  uint64_t ID;
  uint64_t Time;
};

namespace db {
void ValidateOptions() {
  // This needs to be supported via environment variable too
  // because there is no way for the tool 'benchbuild' to provide
  // the run_id as program argument for now.
  if (opt::RunID == 0) {
    if (const char *RunId = std::getenv("BB_DB_RUN_ID")) {
      opt::RunID = RunId ? std::stoi(RunId) : 0;
    }
  }

  DB->prepare();
}
void StoreRun(const EventMapTy &Events, const EventMapTy &Entries,
              const RegionMapTy &Regions) {
  if (!enable_tracking())
    return;

  pqxx::work W(**DB);
  uint64_t RunId = DB->prepareRun(W);

  std::string NewRunResultSql = "INSERT INTO regions (name, id, "
                                   "duration, events, run_id) "
                                   "VALUES";

  if (Events.size() <= 0)
    return;

  int Cnt = 0;
  std::stringstream Vals;
  for (auto KV : Events) {
    if (Cnt > 0)
      Vals << ",";
    auto Key  = KV.first;
    if (! Regions.count(Key))
        std::cerr << fmt::format("Key {:d} missing in Regions.", Key);
    if (! Events.count(Key))
        std::cerr << fmt::format("Key {:d} missing in Events.", Key);
    if (! Entries.count(Key))
        std::cerr << fmt::format("Key {:d} missing in Entries.", Key);
    Vals << fmt::format(" ('{:s}', {:d}, {:d}, {:d}, {:d})",
                        Regions.at(Key), Key, KV.second,
                        Entries.at(Key), RunId);
    Cnt++;
  }
  Vals << ";";
  submit(NewRunResultSql + Vals.str(), W);
  Vals.clear();
  Vals.flush();
  W.commit();
}

void StoreTransformedScop(const std::string &FnName,
                          const std::string &IslAstStr,
                          const std::string &ScheduleTreeStr) {
  if (!enable_tracking())
    return;

  pqxx::work W(**DB);
  uint64_t RunId = DB->prepareRun(W);

  std::string ScheduleSql = "INSERT INTO schedules (function, schedule, "
                             "run_id) VALUES ('{:s}', '{:s}', {:d});";
  std::string AstSql = "INSERT INTO isl_asts (function, ast, run_id) VALUES "
                        "('{:s}', '{:s}', {:d});";

  submit(fmt::format(ScheduleSql, FnName, ScheduleTreeStr, RunId), W);
  submit(fmt::format(AstSql, FnName, IslAstStr, RunId), W);
  W.commit();
}
} // namespace db

namespace tracing {
static ManagedStatic<TraceData> TD;

void enter_region(uint64_t id, const char *name) {
  uint64_t Time = papi::PAPI_get_real_usec();
  if (!TD->Events.count(id))
    TD->Events[id] = 0;
  if (!TD->Entries.count(id))
    TD->Entries[id] = 0;
  if (!TD->Regions.count(id))
    TD->Regions[id] = name;

  TD->Events[id] -= Time;
  TD->Entries[id] += 1;
}

void exit_region(uint64_t id) {
  uint64_t Time = papi::PAPI_get_real_usec();
  if (!TD->Events.count(id))
    std::cerr << fmt::format(
        "exit_region called before enter_region for ID: {:d}!\n", id);

  TD->Events[id] += Time;
}

TraceData::~TraceData() {
  if (!polli::opt::ExecuteAtExit)
    return;

  std::cerr << fmt::format("Submitting: {:d} events", Events.size()) << "\n";
  polli::db::StoreRun(Events, Entries, Regions);
}

void setup_tracing() {
  cl::ParseEnvironmentOptions("profile-scops", "PJIT_ARGS", "");
  opt::ValidateOptions();
  db::ValidateOptions();
  papi::PAPI_library_init(PAPI_VER_CURRENT);
}
} // namespace tracing
} // namespace polli
