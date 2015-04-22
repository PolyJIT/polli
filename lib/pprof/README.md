# libpprof - Profiling library for use with libpjit #

libpprof provides methods for tracking PAPI events from within an instrumented
binary. It is used in conjunction with libpjit to provide PAPI measurements
on arbitrary code-regions.

In order to measure whole code regions, instrumentation calls are placed at
the beginning and the end of each code region.

A profiling events currently takes 24bytes and consists of these 3 fields:
EventID, EventType, Value.

libpprof tries to minimize the measurement overhead as much as possible and
therefore starts storing measurement data on disk / in db only during
processing of the atexit() handler.

## Features ##

libpprof supports different output backends for a tracked run:

 * File backend: plain simple file output, no special formatting.
 * CSV file backend: csv output with header, values are separated by ','
 * PostgreSQL backend: store runs in a database.


## Configuration ##

 libpprof is configured via environment variables. The following variables
 are available:

### General options ###

  | Name                 | Type     | Description                                 |
  | -------------------- | -------- | ------------------------------------------- |
  | PPROF_EXPERIMENT     | text     | Which experiment does this run belong to.   |
  | PPROF_PROJECT        | text     | Which project does this run belong to.      |
  | PPROF_CMD            | text     | Command line that has been executed.        |
  | PPROF_USE_DATABASE   | bool     | Use the Postgres backend.                   |
  | PPROF_USE_CSV        | bool     | Use the CSV file backend.                   |
  | PPROF_USE_FILE       | bool     | Use the RAW file backend.                   |

### PostgreSQL options ###

  libpq automatically derives missing connection parameters from the
  $HOME/.pgpass file.

  | Name              | Type       | Description                           |
  | ----------------- | ---------- | ------------------------------------- |
  | PPROF_DB_HOST     | text       | Database Host                         |
  | PPROF_DB_PORT     | text       | Database Port                         |
  | PPROF_DB_USER     | text       | Username to connect with (optional)   |
  | PPROF_DB_PASS     | text       | Password to connect with (optional)   |
  | PPROF_DB_NAME     | text       | Which DB should we select             |

### CSV file options ###

  | Name              | Type       | Description                           |
  | ----------------- | ---------- | ------------------------------------- |
  | PPROF_CSV_FILE    | text       | Path to store the csv file in.        |

### RAW file options ###

  | Name                 | Type    | Description                                 |
  | -------------------- | ------- | ------------------------------------------- |
  | PPROF_FILE_PROFILE   | text    | Path to store the profile in.               |
  | PPROF_FILE_CALLS     | text    | Path to store the library calls count in.   |
