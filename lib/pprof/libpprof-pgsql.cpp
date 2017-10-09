#include "polli/log.h"
#include "pprof/pgsql.h"
#include "pprof/pprof.h"
#include <pqxx/pqxx>

#include <ctime>
#include <numeric>
#include <set>
#include <stdlib.h>
#include <string>
#include <thread>

using namespace pqxx;

namespace pprof {
DbOptions getDBOptionsFromEnv() {
  DbOptions Opts;

  const char *Host = std::getenv("BB_DB_HOST");
  const char *User = std::getenv("BB_DB_USER");
  const char *Pass = std::getenv("BB_DB_PASS");
  const char *Name = std::getenv("BB_DB_NAME");
  const char *Port = std::getenv("BB_DB_PORT");
  const char *RunId = std::getenv("BB_DB_RUN_ID");
  const char *Uuid = std::getenv("BB_DB_RUN_GROUP");
  const char *ExpUuid = std::getenv("BB_EXPERIMENT_ID");

  Opts.host = Host ? Host : "localhost";
  Opts.port = Port ? stoi(Port) : 5432;
  Opts.name = Name ? Name : "pprof";
  Opts.user = User ? User : "pprof";
  Opts.pass = Pass ? Pass : "pprof";
  Opts.run_id = RunId ? stoi(RunId) : 0;
  Opts.uuid = Uuid ? Uuid : "00000000-0000-0000-0000-000000000000";
  Opts.exp_uuid = ExpUuid ? ExpUuid : "00000000-0000-0000-0000-000000000000";

  return Opts;
}

std::string now() {
  char Buf[sizeof "YYYY-MM-DDTHH:MM:SS"];
  time_t Now;
  time(&Now);

  strftime(Buf, sizeof Buf, "%F %T", localtime(&Now));
  return std::string(Buf);
}

namespace pgsql {

class DBConnection {
  std::unique_ptr<pqxx::connection> c;

  void connect() {
    std::string ConnectionFmtStr =
        "user={} port={} host={} dbname={} password={}";
    DbOptions Opts = getDBOptionsFromEnv();
    std::string ConnectionStr =
        fmt::format(ConnectionFmtStr, Opts.user, Opts.port, Opts.host,
                    Opts.name, Opts.pass);

    c = std::unique_ptr<pqxx::connection>(new pqxx::connection(ConnectionStr));
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

public:
  DBConnection() { connect(); }

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

  ~DBConnection() {
    c->disconnect();
    c.reset(nullptr);
  }
};

static DBConnection &getDatabase() {
  static DBConnection DB;
  return DB;
}

UuidSet ReadAvailableRunGroups() {
  DbOptions Opts = getDBOptionsFromEnv();
  pqxx::read_transaction Txn(*getDatabase());
  pqxx::result R = Txn.prepared("select_run_groups")(Opts.exp_uuid).exec();

  UuidSet RunGroups;
  for (auto Elem : R) {
    RunGroups.insert(Elem[0].as<std::string>());
  }

  return RunGroups;
}

IdVector ReadAvailableRunIDs(std::string run_group) {
  DbOptions Opts = getDBOptionsFromEnv();
  pqxx::read_transaction Txn(*getDatabase());
  pqxx::result R = Txn.prepared("select_run_ids")(run_group).exec();

  IdVector RunIDs(R.size());
  for (size_t I = 0; I < R.size(); I++) {
    RunIDs[I] = R[I][0].as<uint32_t>();
  }

  Txn.commit();
  return RunIDs;
}

struct EventGroup {
  int32_t ID;
  std::vector<Event> Events;
};

static Run<Event> AggregateGroupedRun(const Run<EventGroup> &GroupedEvents) {
  Run<Event> NewRun;
  for (auto &Group : GroupedEvents) {
    Event Init = *Group.Events.begin();
    Event Result = std::accumulate(
        (Group.Events.begin()++), Group.Events.end(), Init,
        [](const Event &LHS, const Event &RHS) -> Event {
          return {LHS.ID,   LHS.Type, LHS.Start, LHS.Duration + RHS.Duration,
                  LHS.Name, LHS.TID};
        });
    NewRun.push_back(Result);
  }
  return NewRun;
}

static Run<EventGroup> GetGroupedRun(const Run<Event> &Events) {
  Run<EventGroup> R;
  std::unordered_map<uint64_t, EventGroup> Buckets;

  for (auto &Ev : Events) {
    int32_t Id = Ev.ID;
    if (!Buckets.count(Id))
      Buckets[Id] = {Id, {}};
    Buckets[Id].Events.emplace_back(Ev);
  }

  for (auto KV : Buckets)
    R.emplace_back(KV.second);

  return R;
}

static Run<pprof::Event> GetSimplifiedRun(Run<PPEvent> &Events) {
  Run<pprof::Event> SRun;
  SRun.ID = Events.ID;
  Run<PPEvent>::iterator Start = Events.begin();

  for (Run<PPEvent>::iterator I = Events.begin(), IE = Events.end(); I != IE;
       ++I) {
    switch (I->event()) {
    default:
      break;
    case ScopEnter:
    case RegionEnter:
      PPEvent &S = *I;
      PPEvent &E = *getMatchingExit(I, IE);
      const pprof::Event Ev = pprof::simplify(S, E, Start->timestamp());
      SRun.push_back(Ev);
      break;
    }
  }

  return SRun;
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

void StoreRun(const uint64_t tid, Run<PPEvent> &Events,
              const pprof::Options &opts) {
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
  std::string NewRunResultSql = "INSERT INTO benchbuild_events (id, type, "
                                   "start, duration, name, tid, run_id) "
                                   "VALUES";

  DbOptions Opts = getDBOptionsFromEnv();
  pqxx::work W(*getDatabase());
  pqxx::result ProjectExists =
      submit(fmt::format(SearchProjectSql, opts.project), W);

  if (ProjectExists.affected_rows() == 0)
    submit(fmt::format(NewProjectSql, opts.project, opts.project,
                       opts.src_uri, opts.domain, opts.group),
           W);

  uint64_t RunId = 0;
  if (!Opts.run_id) {
    pqxx::result R =
        submit(fmt::format(NewRunSql, now(), opts.command, opts.project,
                           opts.experiment, Opts.uuid, Opts.exp_uuid),
               W);
    R[0]["id"].to(RunId);
  } else {
    RunId = Opts.run_id;
  }

  Run<pprof::Event> SimpleEvents = GetSimplifiedRun(Events);
  Run<EventGroup> GroupedEvents = GetGroupedRun(SimpleEvents);
  SimpleEvents = AggregateGroupedRun(GroupedEvents);

  int N = 500;
  size_t I;
  for (I = 0; I < SimpleEvents.size(); I += N) {
    std::stringstream Vals;
    for (size_t J = I; J < std::min(SimpleEvents.size(), (size_t)(N + I));
         J++) {
      pprof::Event &Ev = SimpleEvents[J];
      Ev.TID = tid;

      if (J != I)
        Vals << ",";

      Vals << fmt::format(" ({:d}, {:d}, {:d}, {:d}, '{:s}', {:d}, {:d})",
                          Ev.ID, (int)Ev.Type, Ev.Start, Ev.Duration, Ev.Name,
                          Ev.TID, RunId);
    }
    Vals << ";";

    submit(NewRunResultSql + Vals.str(), W);
    Vals.clear();
    Vals.flush();
  }

  W.commit();
}

Run<pprof::Event> ReadSimpleRun(uint32_t run_id) {
  DbOptions Opts = getDBOptionsFromEnv();
  Run<Event> Events(run_id);
  Events.clear();

  pqxx::work Txn(*getDatabase());
  pqxx::result R = Txn.prepared("select_simple_run")(run_id).exec();

  Events.ID = run_id;
  for (auto Elem : R) {
    // id, start, duration, name
    int32_t EvId = Elem[0].as<int32_t>();
    uint16_t EvTy = Elem[1].as<uint16_t>();
    uint64_t EvStart = Elem[2].as<uint64_t>();
    uint64_t EvDuration = Elem[3].as<uint64_t>();
    std::string EvName = Elem[4].as<std::string>();
    uint64_t EvTid = Elem[5].as<uint64_t>();

    Events.push_back(Event(EvId, (PPEventType)EvTy, EvStart, EvDuration,
                           EvName, EvTid));
  }

  R = Txn.prepared("delete_simple_run")(run_id).exec();
  Txn.commit();
  return Events;
}

void StoreRunMetrics(long run_id, const Metrics &M) {
  using namespace std;
  const DbOptions Opts = getDBOptionsFromEnv();
  std::string NewMetric =
      "INSERT INTO metrics (name, value, run_id) VALUES ('{}', {}, {});";

  pqxx::work W(*getDatabase());

  pqxx::result R =
      W.exec(fmt::format("SELECT name FROM metrics WHERE run_id = {}", run_id));

  if (R.affected_rows() == 0) {
    for (auto E : M)
      W.exec(fmt::format(NewMetric, E.first, E.second, run_id));
  }

  W.commit();
}

} // namespace pgsql
} // namespace pprof
