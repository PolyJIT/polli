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
static std::string NEW_RUN_SQL = "INSERT INTO run (finished, command, "
                                 "project_name, experiment_name, run_group) "
                                 "VALUES (TIMESTAMP '{}', '{}', "
                                 "'{}', '{}', '{}') RETURNING id;";
static std::string NEW_RUN_RESULT_SQL = "INSERT INTO papi_results (type, id, "
                                        "timestamp, run_id) VALUES";

void StoreRun(const std::vector<const PPEvent *> &Events,
              const pprof::Options &opts) {
  using namespace fmt;

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
      const PPEvent *Ev = Events[j];
      if (j != i)
        vals << ",";
      vals << format(" ({}, {}, {}, {})", Ev->EventTy, Ev->ID, Ev->Timestamp,
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

static std::string SELECT_RUN =
    "SELECT id,type,timestamp FROM papi_results WHERE run_id=$1 ORDER BY "
    "timestamp;";
static std::string SELECT_RUN_IDs = "SELECT id FROM run WHERE run_group = $1;";
static std::vector<uint32_t> RunIDs;

static bool ReadRun(std::unique_ptr<pqxx::connection> &c, std::vector<const PPEvent *> &Events,
                    std::map<uint32_t, PPStringRegion> &Regions) {
  using namespace fmt;
  if (RunIDs.size() == 0)
    return false;

  uint32_t id = RunIDs.back();
  DbOptions Opts = getDBOptionsFromEnv();

  pqxx::read_transaction txn(*c);
  pqxx::result r = txn.prepared("select_run")(id).exec();

  for (size_t i = 0; i < r.size(); i++) {
    PPEvent Ev;
    Ev.ID = r[i][0].as<uint32_t>();
    Ev.EventTy = (PPEventType)r[i][1].as<uint32_t>();
    Ev.Timestamp = r[i][3].as<uint64_t>();
    Events.push_back(new PPEvent(Ev));
  }

  std::cout << "Completed reading a single run!\n";
  RunIDs.pop_back();
  return true;
}

static void ReadAvailableRunIDs(std::unique_ptr<pqxx::connection> &c,
                                std::vector<uint32_t> &RunIDs) {
  using namespace fmt;

  DbOptions Opts = getDBOptionsFromEnv();
  pqxx::read_transaction txn(*c);
  pqxx::result r = txn.prepared("select_run_ids")(Opts.uuid).exec();

  RunIDs.clear();
  for (size_t i = 0; i < r.size(); i++) {
    RunIDs.push_back(r[0][0].as<uint32_t>());
  }
  txn.commit();
}

static void PrepareReadStatements(std::unique_ptr<pqxx::connection> &c,
                                  const DbOptions &DbOpts) {
  c->prepare("select_run", SELECT_RUN);
  c->prepare("select_run_ids", SELECT_RUN_IDs);
}

bool ReadRun(std::vector<const PPEvent *> &Events,
             std::map<uint32_t, PPStringRegion> &Regions, const Options &opt) {
  using namespace fmt;
  DbOptions Opts = getDBOptionsFromEnv();
  bool gotValidRun = false;

  if (!c) {
    std::string connection_str =
        format(CONNECTION_FMT_STR, Opts.user, Opts.port, Opts.host, Opts.name);
    c = std::unique_ptr<pqxx::connection>(new pqxx::connection(connection_str));
    PrepareReadStatements(c, Opts);
    ReadAvailableRunIDs(c, RunIDs);
  }

  if (c) {
    Events.clear();
    gotValidRun = pgsql::ReadRun(c, Events, Regions);

    if (!gotValidRun) {
      c->disconnect();
      c.reset(nullptr);
    }
  }
  return gotValidRun;
}

} // end of sql namespace
} // end of pprof namespace
