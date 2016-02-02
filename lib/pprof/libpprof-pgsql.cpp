#include <cppformat/format.h>

#include "pprof/pgsql.h"
#include "pprof/pprof.h"
#include <pqxx/pqxx>

#include <ctime>
#include <set>
#include <stdlib.h>
#include <string>
#include <thread>

using namespace pqxx;

namespace pprof {
DbOptions getDBOptionsFromEnv() {
  DbOptions Opts;

  const char *host = std::getenv("PPROF_DB_HOST");
  const char *user = std::getenv("PPROF_DB_USER");
  const char *pass = std::getenv("PPROF_DB_PASS");
  const char *name = std::getenv("PPROF_DB_NAME");
  const char *port = std::getenv("PPROF_DB_PORT");
  const char *run_id = std::getenv("PPROF_DB_RUN_ID");
  const char *uuid = std::getenv("PPROF_DB_RUN_GROUP");
  const char *exp_uuid = std::getenv("PPROF_EXPERIMENT_ID");

  Opts.host = host ? host : "localhost";
  Opts.port = port ? stoi(port) : 5432;
  Opts.name = name ? name : "pprof";
  Opts.user = user ? user : "pprof";
  Opts.pass = pass ? pass : "pprof";
  Opts.run_id = run_id ? stoi(run_id) : 0;
  Opts.uuid = uuid ? uuid : "00000000-0000-0000-0000-000000000000";
  Opts.exp_uuid = exp_uuid ? exp_uuid : "00000000-0000-0000-0000-000000000000";

  return Opts;
}

std::string now() {
  char buf[sizeof "YYYY-MM-DDTHH:MM:SS"];
  time_t now;
  time(&now);

  strftime(buf, sizeof buf, "%F %T", localtime(&now));
  return std::string(buf);
}

namespace pgsql {

struct DBConnection {
  std::unique_ptr<pqxx::connection> c;

public:
  DBConnection() {
    using namespace fmt;
    std::string CONNECTION_FMT_STR =
      "user={} port={} host={} dbname={} password={}";
    DbOptions Opts = getDBOptionsFromEnv();
    std::string connection_str =
        format(CONNECTION_FMT_STR, Opts.user, Opts.port, Opts.host, Opts.name,
               Opts.pass);

    c = std::unique_ptr<pqxx::connection>(new pqxx::connection(connection_str));
    if (c) {
      std::string SELECT_RUN =
          "SELECT id,type,timestamp FROM papi_results WHERE run_id=$1 ORDER BY "
          "timestamp;";
      std::string SELECT_SIMPLE_RUN =
          "SELECT id,type,start,duration,name,tid FROM pprof_events WHERE run_id=$1 ORDER BY "
          "start;";
      std::string DELETE_SIMPLE_RUN =
          "DELETE FROM pprof_events WHERE run_id=$1";
      std::string SELECT_RUN_IDs =
          "SELECT id FROM run WHERE run_group = $1;";
      std::string SELECT_RUN_GROUPS =
          "SELECT DISTINCT run_group FROM run WHERE experiment_group = $1;";

      c->prepare("select_run", SELECT_RUN);
      c->prepare("select_simple_run", SELECT_SIMPLE_RUN);
      c->prepare("delete_simple_run", DELETE_SIMPLE_RUN);
      c->prepare("select_run_ids", SELECT_RUN_IDs);
      c->prepare("select_run_groups", SELECT_RUN_GROUPS);
    }
  }

  ~DBConnection() {
    c->disconnect();
    c.reset(nullptr);
  }
};

static DBConnection& getDatabase() {
  static DBConnection DB;
  return DB;
}

UuidSet ReadAvailableRunGroups() {
  using namespace fmt;

  DbOptions Opts = getDBOptionsFromEnv();
  pqxx::read_transaction txn(*getDatabase().c);
  pqxx::result r = txn.prepared("select_run_groups")(Opts.exp_uuid).exec();

  UuidSet RunGroups;
  for (auto elem : r) {
    RunGroups.insert(elem[0].as<std::string>());
  }

  return RunGroups;
}

IdVector ReadAvailableRunIDs(std::string run_group) {
  using namespace fmt;

  DbOptions Opts = getDBOptionsFromEnv();
  pqxx::read_transaction txn(*getDatabase().c);
  pqxx::result r = txn.prepared("select_run_ids")(run_group).exec();

  IdVector RunIDs(r.size());
  for (size_t i = 0; i < r.size(); i++) {
    RunIDs[i] = r[i][0].as<uint32_t>();
  }

  txn.commit();
  return RunIDs;
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
      const pprof::Event Ev =
          pprof::simplify(S, E, Start->timestamp());
      SRun.push_back(Ev);
      break;
    }
  }

  return SRun;
}

static pqxx::result submit(const std::string &Query,
                           pqxx::work &w) throw(pqxx::syntax_error) {
  pqxx::result res;
  try {
    res = w.exec(Query);
  } catch (pqxx::data_exception e) {
    std::cerr << "pgsql: Encountered the following error:\n";
    std::cerr << e.what();
    std::cerr << "\n";
    std::cerr << e.query();
    throw e;
  }
  return res;
}

void StoreRun(const uint64_t tid, Run<PPEvent> &Events,
              const pprof::Options &opts) {
  static std::string SEARCH_PROJECT_SQL =
      "SELECT name FROM project WHERE name = '{}';";

  static std::string NEW_PROJECT_SQL =
      "INSERT INTO project (name, description, src_url, domain, group_name) "
      "VALUES ('{}', '{}', '{}', '{}', '{}');";

  static std::string NEW_RUN_SQL =
      "INSERT INTO run (\"end\", command, "
      "project_name, experiment_name, run_group, experiment_group) "
      "VALUES (TIMESTAMP '{}', '{}', "
      "'{}', '{}', '{}', '{}') RETURNING id;";
  static std::string NEW_RUN_RESULT_SQL = "INSERT INTO pprof_events (id, type, "
                                          "start, duration, name, tid, run_id) "
                                          "VALUES";

  using namespace fmt;
  DbOptions Opts = getDBOptionsFromEnv();
  pqxx::work w(*getDatabase().c);
  pqxx::result project_exists =
      submit(format(SEARCH_PROJECT_SQL, opts.project), w);

  if (project_exists.affected_rows() == 0)
    submit(format(NEW_PROJECT_SQL, opts.project, opts.project, opts.src_uri,
                  opts.domain, opts.group), w);

  pqxx::result r = submit(format(NEW_RUN_SQL, now(), opts.command, opts.project,
                                 opts.experiment, Opts.uuid, Opts.exp_uuid), w);

  uint64_t run_id = 0;
  r[0]["id"].to(run_id);

  Run<pprof::Event> SimpleEvents = GetSimplifiedRun(Events);
  int n = 500;
  size_t i;
  for (i = 0; i < SimpleEvents.size(); i += n) {
    std::stringstream vals;
    for (size_t j = i; j < std::min(SimpleEvents.size(), (size_t)(n + i)); j++) {
      pprof::Event &Ev = SimpleEvents[j];
      Ev.TID = tid;

      if (j != i)
        vals << ",";
      vals << format(" ({:d}, {:d}, {:d}, {:d}, '{:s}', {:d}, {:d})", Ev.ID,
                     Ev.Type, Ev.Start, Ev.Duration, Ev.Name, Ev.TID, run_id);
    }
    vals << ";";

    submit(NEW_RUN_RESULT_SQL + vals.str(), w);
    vals.clear();
    vals.flush();
  }

  w.commit();
}

Run<pprof::Event> ReadSimpleRun(uint32_t run_id) {
  using namespace fmt;

  DbOptions Opts = getDBOptionsFromEnv();
  Run<Event> Events(run_id);
  Events.clear();

  pqxx::work txn(*getDatabase().c);
  pqxx::result r = txn.prepared("select_simple_run")(run_id).exec();

  Events.ID = run_id;
  for (auto elem : r) {
    //id, start, duration, name
    int32_t ev_id = elem[0].as<int32_t>();
    uint16_t ev_ty = elem[1].as<uint16_t>();
    uint64_t ev_start = elem[2].as<uint64_t>();
    uint64_t ev_duration = elem[3].as<uint64_t>();
    std::string ev_name = elem[4].as<std::string>();
    uint64_t ev_tid = elem[5].as<uint64_t>();

    Events.push_back(Event(ev_id, (PPEventType)ev_ty, ev_start, ev_duration,
                           ev_name, ev_tid));
  }

  r = txn.prepared("delete_simple_run")(run_id).exec();
  txn.commit();
  return Events;
}

void StoreRunMetrics(long run_id, const Metrics &M) {
  using namespace std;
  using namespace fmt;

  const DbOptions Opts = getDBOptionsFromEnv();
  static std::string NewMetric =
      "INSERT INTO metrics (name, value, run_id) VALUES ('{}', {}, {});";

  pqxx::work w(*getDatabase().c);

  pqxx::result r =
      w.exec(format("SELECT name FROM metrics WHERE run_id = {}", run_id));

  if (r.affected_rows() == 0) {
    for (auto e : M)
      w.exec(format(NewMetric, e.first, e.second, run_id));
  }

  w.commit();
};

} // namespace pgsql
} // namespace pprof
