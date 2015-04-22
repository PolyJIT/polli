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
    int         port;
    std::string user;
    std::string pass;
    std::string name;
  };

  DbOptions getDBOptionsFromEnv() {
    DbOptions Opts;

    const char *host = std::getenv("PPROF_DB_HOST");
    const char *user = std::getenv("PPROF_DB_USER");
    const char *pass = std::getenv("PPROF_DB_PASS");
    const char *name = std::getenv("PPROF_DB_NAME");
    const char *port = std::getenv("PPROF_DB_PORT");

    Opts.host = host ? host : "localhost";
    Opts.port = port ? stoi(port) : 49153;
    Opts.name = name ? name : "pprof";
    Opts.user = user ? user : "pprof";
    Opts.pass = pass ? pass : "pprof";

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
  void StoreRun(const std::vector<const PPEvent *> &Events,
                const pprof::Options &opts) {
    using namespace fmt;

    DbOptions Opts = getDBOptionsFromEnv();
    std::string connection_str =
        format("user={} port={} host={} dbname={}", Opts.user, Opts.port,
               Opts.host, Opts.name);
    std::string new_run_sql =
        "INSERT INTO run (finished, command, "
        "project_name, experiment_name) VALUES (TIMESTAMP '{}', '{}', "
        "'{}', '{}\') RETURNING id;";

    pqxx::connection c(connection_str);
    pqxx::work w(c);
    pqxx::result r = w.exec(format(new_run_sql, now(), opts.command,
                                   opts.project, opts.experiment));

    long run_id;
    r[0]["id"].to(run_id);

    std::string new_run_result_sql = "INSERT INTO papi_results (type, id, "
                                     "timestamp, run_id) VALUES";

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
      w.exec(new_run_result_sql + vals.str());
      vals.clear();
      vals.flush();
    }

    w.commit();
  }
  }
  }
