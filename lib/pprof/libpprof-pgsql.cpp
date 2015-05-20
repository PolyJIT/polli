#include "pprof/pgsql.h"
#include "pprof/pprof.h"
#include <pqxx/pqxx>

#include <ctime>
#include <stdlib.h>
#include <string>

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
};

DbOptions getDBOptionsFromEnv() {
  DbOptions Opts;

  const char *host = std::getenv("PPROF_DB_HOST");
  const char *user = std::getenv("PPROF_DB_USER");
  const char *pass = std::getenv("PPROF_DB_PASS");
  const char *name = std::getenv("PPROF_DB_NAME");
  const char *port = std::getenv("PPROF_DB_PORT");
  const char *uuid = std::getenv("PPROF_DB_RUN_GROUP");

  Opts.host = host ? host : "localhost";
  Opts.port = port ? stoi(port) : 49153;
  Opts.name = name ? name : "pprof";
  Opts.user = user ? user : "pprof";
  Opts.pass = pass ? pass : "pprof";
  Opts.uuid = uuid ? uuid : "00000000-0000-0000-0000-000000000000";

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
static std::string CONNECTION_FMT_STR = "user={} port={} host={} dbname={}";

void StoreRun(Run<PPEvent> &Events, const pprof::Options &opts) {
  using namespace fmt;
  static std::string NEW_RUN_SQL = "INSERT INTO run (finished, command, "
                                   "project_name, experiment_name, run_group) "
                                   "VALUES (TIMESTAMP '{}', '{}', "
                                   "'{}', '{}', '{}') RETURNING id;";
  static std::string NEW_RUN_RESULT_SQL = "INSERT INTO papi_results (type, id, "
                                          "timestamp, run_id) VALUES";

  DbOptions Opts = getDBOptionsFromEnv();
  std::string connection_str =
      format("user={} port={} host={} dbname={}", Opts.user, Opts.port,
             Opts.host, Opts.name);

  pqxx::connection c(connection_str);
  pqxx::work w(c);
  pqxx::result r = w.exec(format(NEW_RUN_SQL, now(), opts.command, opts.project,
                                 opts.experiment, Opts.uuid));

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

static std::unique_ptr<pqxx::connection> c;

using IdVector = std::vector<uint32_t>;
static IdVector RunIDs;

static void printRunIDs(const IdVector &IDs) {
  std::cout << "RunIds: [";
  for (size_t i = 0; i < IDs.size(); i++) {
    if (i != 0)
      std::cout << ", ";

    std::cout << IDs[i];
  }
  std::cout << "]\n";
}

static IdVector ReadAvailableRunIDs(std::unique_ptr<pqxx::connection> &c) {
  using namespace fmt;

  DbOptions Opts = getDBOptionsFromEnv();
  pqxx::read_transaction txn(*c);
  pqxx::result r = txn.prepared("select_run_ids")(Opts.uuid).exec();

  IdVector RunIDs(r.size());
  for (size_t i = 0; i < r.size(); i++) {
    RunIDs[i] = r[i][0].as<uint32_t>();
  }

  std::cout << "Runs available in database:\n";
  printRunIDs(RunIDs);
  txn.commit();
  return RunIDs;
}

static Run<PPEvent> ReadRun(std::unique_ptr<pqxx::connection> &c,
                            IdVector &RunIDs,
                            std::map<uint32_t, PPStringRegion> &Regions) {
  using namespace fmt;

  DbOptions Opts = getDBOptionsFromEnv();
  uint32_t id = RunIDs.back();
  Run<PPEvent> Events(id);
  Events.clear();

  if (RunIDs.size() == 0)
    return Events;

  pqxx::read_transaction txn(*c);
  pqxx::result r = txn.prepared("select_run")(id).exec();

  Events.ID = id;
  for (size_t i = 0; i < r.size(); i++) {
    uint16_t ev_id = r[i][0].as<uint16_t>();
    uint32_t ev_ty = r[i][1].as<uint32_t>();
    uint64_t ev_ts = r[i][2].as<uint64_t>();

    Events.push_back(PPEvent(ev_id, (PPEventType)ev_ty, ev_ts));
  }

  std::cout << "Completed reading a run #" << id << "\n";
  RunIDs.pop_back();

  std::cout << "Remaining runs in database:\n";
  printRunIDs(RunIDs);

  return Events;
}

static void PrepareReadStatements(std::unique_ptr<pqxx::connection> &c,
                                  const DbOptions &DbOpts) {
  static std::string SELECT_RUN =
      "SELECT id,type,timestamp FROM papi_results WHERE run_id=$1 ORDER BY "
      "timestamp;";
  static std::string SELECT_RUN_IDs =
      "SELECT id FROM run WHERE run_group = $1;";

  c->prepare("select_run", SELECT_RUN);
  c->prepare("select_run_ids", SELECT_RUN_IDs);
}

static void OpenNewConnection(const DbOptions &Opts) {
  using namespace fmt;
  std::string connection_str =
      format(CONNECTION_FMT_STR, Opts.user, Opts.port, Opts.host, Opts.name);
  c = std::unique_ptr<pqxx::connection>(new pqxx::connection(connection_str));
}

bool ReadRun(Run<PPEvent> &Events, std::map<uint32_t, PPStringRegion> &Regions,
             const Options &opt) {
  DbOptions Opts = getDBOptionsFromEnv();
  bool gotValidRun = false;

  if (!c) {
    OpenNewConnection(Opts);
    PrepareReadStatements(c, Opts);
    RunIDs = ReadAvailableRunIDs(c);
  }

  if (c) {
    Events.clear();
    Events = pgsql::ReadRun(c, RunIDs, Regions);
    gotValidRun = Events.size() > 0;

    if (!gotValidRun) {
      c->disconnect();
      c.reset(nullptr);
    }
  }
  return gotValidRun;
}

void StoreRunMetrics(long run_id, const Metrics &M) {
  using namespace std;
  using namespace fmt;

  const DbOptions Opts = getDBOptionsFromEnv();
  if (!c)
    OpenNewConnection(Opts);

  static std::string NewMetric =
      "INSERT INTO metrics (name, value, run_id) VALUES ('{}', {}, {});";

  pqxx::work w(*c);

  for (auto e : M)
    w.exec(format(NewMetric, e.first, e.second, run_id));

  w.commit();
};

} // end of sql namespace
} // end of pprof namespace
