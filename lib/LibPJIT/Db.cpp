#include <iostream>
#include <pqxx/pqxx>
#include <stdlib.h>
#include <string>

#include "absl/strings/str_cat.h"

#include "polli/Db.h"
#include "polli/Options.h"
#include "polli/log.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/ManagedStatic.h"

using namespace llvm::cl;
using llvm::ManagedStatic;
using std::cerr;
using std::string;
using std::stringstream;

namespace papi {
#include <papi.h>
} // namespace papi

namespace polli {
namespace opt {
static string Experiment;
static ::opt<string, true>
    ExperimentX("polli-db-experiment",
                ::desc("Name of the experiment we are running under."),
                ::location(Experiment), ::init("unknown"),
                ::cat(PolyJitRuntime));

static string ExperimentUUID;
static ::opt<string, true>
    ExperimentUUIDX("polli-db-experiment-uuid", ::desc("Experiment UUID."),
                    ::location(ExperimentUUID),
                    ::init("00000000-0000-0000-0000-000000000000"),
                    ::cat(PolyJitRuntime));

static string Project;
static ::opt<string, true> ProjectX("polli-db-project",
                                    ::desc("The project we are running under."),
                                    ::location(Project), ::init("unknown"),
                                    ::cat(PolyJitRuntime));

static string Domain;
static ::opt<string, true> DomainX("polli-db-domain",
                                   ::desc("The domain we are running under."),
                                   ::location(Domain), ::init("unknown"),
                                   ::cat(PolyJitRuntime));

static string Group;
static ::opt<string, true> GroupX("polli-db-group",
                                  ::desc("The group we are running under."),
                                  ::location(Group), ::init("unknown"),
                                  ::cat(PolyJitRuntime));

static string SourceUri;
static ::opt<string, true>
    SourceUriX("polli-db-src-uri", ::desc("The src_uri we are running under."),
               ::location(SourceUri), ::init("unknown"), ::cat(PolyJitRuntime));

static string Argv0;
static ::opt<string, true> Argv0X("polli-db-argv",
                                  ::desc("The command we are executing."),
                                  ::location(SourceUri), ::init("unknown"),
                                  ::cat(PolyJitRuntime));

static bool EnableDatabase;
static ::opt<bool, true>
    EnableDatabaseX("polli-db-enable", ::desc("Enable database communication."),
                    ::location(EnableDatabase), ::init(false),
                    ::cat(PolyJitRuntime));

static bool ExecuteAtExit;
static ::opt<bool, true> ExecuteAtExitX(
    "polli-db-execute-atexit", ::desc("Enable execution of atexit handler."),
    ::location(ExecuteAtExit), ::init(false), ::cat(PolyJitRuntime));

static string DbHost;
static ::opt<string, true> DbHostX("polli-db-host", ::desc("DB Hostname"),
                                   ::location(DbHost), ::init("localhost"),
                                   ::cat(PolyJitRuntime));

static int DbPort;
static ::opt<int, true> DbPortX("polli-db-port", ::desc("DB Port"),
                                ::location(DbPort), ::init(5432),
                                ::cat(PolyJitRuntime));

static string DbUsername;
static ::opt<string, true> DbUsernameX("polli-db-username",
                                       ::desc("DB Username"),
                                       ::location(DbUsername),
                                       ::init("benchbuild"),
                                       ::cat(PolyJitRuntime));

static string DbPassword;
static ::opt<string, true> DbPasswordX("polli-db-password",
                                       ::desc("DB Password"),
                                       ::location(DbPassword),
                                       ::init("benchbuild"),
                                       ::cat(PolyJitRuntime));
static string DbName;
static ::opt<string, true> DbNameX("polli-db-name", ::desc("DB Name"),
                                   ::location(DbName), ::init("benchbuild"),
                                   ::cat(PolyJitRuntime));

static string RunGroupUUID;
static ::opt<string, true>
    DbRunGroupUUIDX("polli-db-run-group", ::desc("DB RunGroup (UUID)"),
                    ::location(RunGroupUUID),
                    ::init("00000000-0000-0000-0000-000000000000"),
                    ::cat(PolyJitRuntime));

static int RunID;
static ::opt<int, true> DbRunIdX("polli-db-run-id",
                                 ::desc("DB RunGroup (UUID)"),
                                 ::location(RunID), ::init(0),
                                 ::cat(PolyJitRuntime));
} // namespace opt

string now() {
  char Buf[sizeof "YYYY-MM-DDTHH:MM:SS"];
  time_t Now;
  time(&Now);

  strftime(Buf, sizeof Buf, "%F %T", localtime(&Now));
  return string(Buf);
}

static bool enable_tracking() { return opt::EnableDatabase; }

static pqxx::result submit(const string &Query, pqxx::work &w) noexcept(false) {
  pqxx::result Res;
  try {
    Res = w.exec(Query);
  } catch (pqxx::data_exception E) {
    cerr << "pgsql: Encountered the following error:\n";
    cerr << E.what();
    cerr << "\n";
    cerr << E.query();
    throw E;
  }
  return Res;
}

class DBConnection {
  std::unique_ptr<pqxx::connection> c;
  string ConnectionString;

  string Experiment;
  string ExperimentUUID;

  string Project;
  string Domain;
  string Group;
  string SourceURI;
  string Argv0;

  string RunGroupUUID;
  int RunID;

  void connect() {
    if (!enable_tracking())
      return;

    c = std::unique_ptr<pqxx::connection>(
        new pqxx::connection(ConnectionString));
  }

public:
  explicit DBConnection(string Experiment, string ExperimentUUID,
                        string Project, string Domain, string Group,
                        string SourceURI, string Argv0, string RunGroupUUID,
                        int RunID)
      : Experiment(Experiment), ExperimentUUID(ExperimentUUID),
        Project(Project), Domain(Domain), Group(Group), SourceURI(SourceURI),
        Argv0(Argv0), RunGroupUUID(RunGroupUUID), RunID(RunID) {
    string ConnectionFmtStr = "user={} port={} host={} dbname={} password={}";
    ConnectionString =
        fmt::format(ConnectionFmtStr, opt::DbUsername, opt::DbPort, opt::DbHost,
                    opt::DbName, opt::DbPassword);
  }

  void prepare() {
    if (c) {
      string SelectRun =
          "SELECT id,type,timestamp FROM papi_results WHERE run_id=$1 ORDER BY "
          "timestamp;";
      string SelectSimpleRun = "SELECT id,type,start,duration,name,tid "
                               "FROM benchbuild_events WHERE run_id=$1 "
                               "ORDER BY "
                               "start;";
      string DeleteSimpleRun = "DELETE FROM benchbuild_events WHERE run_id=$1";
      string SelectRunIDs = "SELECT id FROM run WHERE run_group = $1;";
      string SelectRunGroups =
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
    string SearchProjectSql = "SELECT name, group_name FROM project WHERE name "
                              "= '{}' AND group_name = '{}';";

    string NewProjectSql =
        "INSERT INTO project (name, description, src_url, domain, group_name) "
        "VALUES ('{}', '{}', '{}', '{}', '{}');";

    string NewRunSql = "INSERT INTO run (\"end\", command, "
                       "project_name, project_group, experiment_name, "
                       "run_group, experiment_group) "
                       "VALUES (TIMESTAMP '{}', '{}', '{}', "
                       "'{}', '{}', '{}', '{}') RETURNING id;";

    pqxx::result ProjectExists =
        submit(fmt::format(SearchProjectSql, Project, Group), w);

    if (ProjectExists.affected_rows() == 0)
      submit(fmt::format(NewProjectSql, Project, Project, SourceURI, Domain,
                         Group),
             w);

    uint64_t RunId = opt::RunID;
    if (RunID == 0) {
      pqxx::result R = submit(
          absl::StrCat(
              "INSERT INTO run (\"end\", command, project_name, project_group, "
              "experiment_name, run_group, experiment_group) "
              "VALUES (TIMESTAMP '",
              now(), "', '", Argv0, "', '", Project, "', '", Group, "', '",
              Experiment, "', '", RunGroupUUID, "', '", ExperimentUUID,
              "')"
              "RETURNING id;"),
          w);
      R[0]["id"].to(RunId);
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
    return new DBConnection(opt::Experiment, opt::ExperimentUUID, opt::Project,
                            opt::Domain, opt::Group, opt::SourceUri, opt::Argv0,
                            opt::RunGroupUUID, opt::RunID);
  }
};

static llvm::ManagedStatic<DBConnection, DBCreator> DB;

struct Event {
  string Name;
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

  string NewRunResultSql = "INSERT INTO regions (name, id, "
                           "duration, events, run_id) "
                           "VALUES";

  if (Events.size() <= 0)
    return;

  int Cnt = 0;
  stringstream Vals;
  for (auto KV : Events) {
    if (Cnt > 0)
      Vals << ",";
    auto Key = KV.first;
    if (!Regions.count(Key))
      cerr << fmt::format("Key {:d} missing in Regions.", Key);
    if (!Events.count(Key))
      cerr << fmt::format("Key {:d} missing in Events.", Key);
    if (!Entries.count(Key))
      cerr << fmt::format("Key {:d} missing in Entries.", Key);
    Vals << fmt::format(" ('{:s}', {:d}, {:d}, {:d}, {:d})", Regions.at(Key),
                        Key, KV.second, Entries.at(Key), RunId);
    Cnt++;
  }
  Vals << ";";
  submit(NewRunResultSql + Vals.str(), W);
  Vals.clear();
  Vals.flush();
  W.commit();
}

void StoreTransformedScop(const string &FnName, const string &IslAstStr,
                          const string &ScheduleTreeStr) {
  if (!enable_tracking())
    return;

  pqxx::work W(**DB);
  uint64_t RunId = DB->prepareRun(W);

  string ScheduleSql = "INSERT INTO schedules (function, schedule, "
                       "run_id) VALUES ('{:s}', '{:s}', {:d});";
  string AstSql = "INSERT INTO isl_asts (function, ast, run_id) VALUES "
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
    cerr << fmt::format(
        "exit_region called before enter_region for ID: {:d}!\n", id);

  TD->Events[id] += Time;
}

TraceData::~TraceData() {
  if (!polli::opt::ExecuteAtExit)
    return;

  cerr << fmt::format("Submitting: {:d} events", Events.size()) << "\n";
  polli::db::StoreRun(Events, Entries, Regions);
}

void setup_tracing() {
  ::ParseEnvironmentOptions("profile-scops", "PJIT_ARGS", "");
  opt::ValidateOptions();
  db::ValidateOptions();
  papi::PAPI_library_init(PAPI_VER_CURRENT);
}
} // namespace tracing
} // namespace polli
