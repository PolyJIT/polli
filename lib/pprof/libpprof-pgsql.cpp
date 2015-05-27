#include "pprof/pgsql.h"
#include "pprof/pprof.h"
#include <pqxx/pqxx>

#include <ctime>
#include <stdlib.h>
#include <string>
#include <set>

#define FMT_HEADER_ONLY
#include <cppformat/format.h>
using namespace pqxx;

namespace pprof {
struct DbOptions {
  std::string host;
  int port;
  std::string user;
  std::string pass;
  std::string name;
  std::string uuid;
  std::string exp_uuid;
};

DbOptions getDBOptionsFromEnv() {
  DbOptions Opts;

  const char *host = std::getenv("PPROF_DB_HOST");
  const char *user = std::getenv("PPROF_DB_USER");
  const char *pass = std::getenv("PPROF_DB_PASS");
  const char *name = std::getenv("PPROF_DB_NAME");
  const char *port = std::getenv("PPROF_DB_PORT");
  const char *uuid = std::getenv("PPROF_DB_RUN_GROUP");
  const char *exp_uuid = std::getenv("PPROF_EXPERIMENT_ID");

  Opts.host = host ? host : "localhost";
  Opts.port = port ? stoi(port) : 49153;
  Opts.name = name ? name : "pprof";
  Opts.user = user ? user : "pprof";
  Opts.pass = pass ? pass : "pprof";
  Opts.uuid = uuid ? uuid : "00000000-0000-0000-0000-000000000000";
  Opts.exp_uuid = exp_uuid ? exp_uuid : "00000000-0000-0000-0000-000000000000";

  return Opts;
}

std::string now() {
  char buf[sizeof "YYYY-MM-DDTHH:MM:SS"];
  time_t now;
  time(&now);

  strftime(buf, sizeof buf, "%F %T", gmtime(&now));
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
      std::string SELECT_RUN_IDs =
          "SELECT id FROM run WHERE run_group = $1;";
      std::string SELECT_RUN_GROUPS =
          "SELECT DISTINCT run_group FROM run WHERE experiment_group = $1;";

      c->prepare("select_run", SELECT_RUN);
      c->prepare("select_run_ids", SELECT_RUN_IDs);
      c->prepare("select_run_groups", SELECT_RUN_GROUPS);
    }
  }

  ~DBConnection() {
    c->disconnect();
    c.reset(nullptr);
  }
};
static DBConnection DB;

UuidSet ReadAvailableRunGroups() {
  using namespace fmt;

  DbOptions Opts = getDBOptionsFromEnv();
  pqxx::read_transaction txn(*DB.c);
  pqxx::result r = txn.prepared("select_run_groups")(Opts.exp_uuid).exec();

  UuidSet RunGroups;
  for (size_t i = 0; i < r.size(); i++) {
    RunGroups.insert(r[i][0].as<std::string>());
  }

  return RunGroups;
}

IdVector ReadAvailableRunIDs(std::string run_group) {
  using namespace fmt;

  DbOptions Opts = getDBOptionsFromEnv();
  pqxx::read_transaction txn(*DB.c);
  pqxx::result r = txn.prepared("select_run_ids")(run_group).exec();

  IdVector RunIDs(r.size());
  for (size_t i = 0; i < r.size(); i++) {
    RunIDs[i] = r[i][0].as<uint32_t>();
  }

  txn.commit();
  return RunIDs;
}

void StoreRun(Run<PPEvent> &Events, const pprof::Options &opts) {
  using namespace fmt;
  static std::string SEARCH_PROJECT_SQL =
      "SELECT name FROM project WHERE name = '{}';";

  static std::string NEW_RUN_SQL =
      "INSERT INTO run (finished, command, "
      "project_name, experiment_name, run_group, experiment_group) "
      "VALUES (TIMESTAMP '{}', '{}', "
      "'{}', '{}', '{}', '{}') RETURNING id;";
  static std::string NEW_RUN_RESULT_SQL = "INSERT INTO papi_results (type, id, "
                                          "timestamp, run_id) VALUES";

  DBConnection DB;
  DbOptions Opts = getDBOptionsFromEnv();
  pqxx::work w(*DB.c);
  pqxx::result project_exists =
      w.exec(format(SEARCH_PROJECT_SQL, opts.project));
  if (project_exists.affected_rows() == 0) {
    // Insert project
    w.exec(format("INSERT INTO project (name, description, src_url, domain, "
                  "group_name) VALUES ('{}', '{}', '{}', '{}', '{}');",
                  opts.project, opts.project, opts.src_uri, opts.domain,
                  opts.group));
  }
  pqxx::result r = w.exec(format(NEW_RUN_SQL, now(), opts.command, opts.project,
                                 opts.experiment, Opts.uuid, Opts.exp_uuid));

  long run_id;
  r[0]["id"].to(run_id);

  int n = 500;
  size_t i;
  for (i = 0; i < Events.size(); i += n) {
    std::stringstream vals;
    for (size_t j = i; j < std::min(Events.size(), (size_t)(n + i)); j++) {
      const PPEvent &Ev = Events[j];
      if (j != i)
        vals << ",";
      vals << format(" ({}, {}, {}, {})", Ev.event(), Ev.id(), Ev.timestamp(),
                     run_id);
    }
    vals << ";";
    w.exec(NEW_RUN_RESULT_SQL + vals.str());
    vals.clear();
    vals.flush();
  }

  w.commit();
}

Run<PPEvent> ReadRun(uint32_t run_id,
                     std::map<uint32_t, PPStringRegion> &Regions) {
  using namespace fmt;

  DbOptions Opts = getDBOptionsFromEnv();
  Run<PPEvent> Events(run_id);
  Events.clear();

  pqxx::read_transaction txn(*DB.c);
  pqxx::result r = txn.prepared("select_run")(run_id).exec();

  Events.ID = run_id;
  for (size_t i = 0; i < r.size(); i++) {
    uint16_t ev_id = r[i][0].as<uint16_t>();
    uint32_t ev_ty = r[i][1].as<uint32_t>();
    uint64_t ev_ts = r[i][2].as<uint64_t>();

    Events.push_back(PPEvent(ev_id, (PPEventType)ev_ty, ev_ts));
  }

  return Events;
}

void StoreRunMetrics(long run_id, const Metrics &M) {
  using namespace std;
  using namespace fmt;

  const DbOptions Opts = getDBOptionsFromEnv();
  static std::string NewMetric =
      "INSERT INTO metrics (name, value, run_id) VALUES ('{}', {}, {});";

  pqxx::work w(*DB.c);

  pqxx::result r =
      w.exec(format("SELECT name FROM metrics WHERE run_id = {}", run_id));

  if (r.affected_rows() == 0) {
    for (auto e : M)
      w.exec(format(NewMetric, e.first, e.second, run_id));
  }

  w.commit();
};

} // end of sql namespace
} // end of pprof namespace
