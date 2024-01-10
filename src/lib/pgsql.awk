@load "pgsql"

@namespace "pgsql"

function exec(query, params,        response, numberOfFields, col, numberOfRow, row, logstr, extraMessage) {
  logger::debug("pgsql::exec() query: " query, "pgsql")
  response = awk::pg_execparams(Connection, query, length(params), params)
  logger::debug("pgsql::exec() response: " response, "pgsql")
  delete RESULT
  RESULT[0] = ""
  delete RESULT[0]
  if (response ~ /^OK/) {
     awk::pg_clear(response)
    return 1
  }
  if (response ~ /^TUPLES /) {
    numberOfFields = awk::pg_nfields(response)
    for (col = 0; col < numberOfFields; col++) {
      columns[col] = awk::pg_fname(response, col)
o   }
    numberOfRows = awk::pg_ntuples(response)
    for (row = 0; row < numberOfRows; row++) {
      for (col = 0; col < numberOfFields; col++) {
        RESULT[row][columns[col]] = (awk::pg_getisnull(response,row,col) ? "<NULL>" : awk::pg_getvalue(response,row,col))
      }
    }

    logstr = "\n"
    for(i in RESULT) {
      logstr = logstr "  " i ":\n"
      for (columnName in RESULT[i]) {
        logstr = logstr "    " columnName ": " RESULT[i][columnName] "\n"
      }
    }
    logger::debug(logstr, "pgsql")

    awk::pg_clear(response)
    return 1
  }
  extraMessage = awk::pg_errormessage(Connection)
  awk::pg_clear(response)
  error::raise("failed to pgsql::exec(): " response ", extraMessage: " extraMessage, "pgsql")
  return 0
}

function createConnection(  param) {
  if (!("POSTGRES_HOSTNAME" in ENVIRON)) {
    error::panic("need environment variable: POSTGRES_HOSTNAME")
  }
  if (!("POSTGRES_DATABASE" in ENVIRON)) {
    error::panic("need environment variable: POSTGRES_DATABASE")
  }
  if (!("POSTGRES_USER" in ENVIRON)) {
    error::panic("need environment variable: POSTGRES_USER")
  }
  if (!("POSTGRES_PASSWORD" in ENVIRON)) {
    error::panic("need environment variable: POSTGRES_PASSWORD")
  }
  param = "host=" ENVIRON["POSTGRES_HOSTNAME"] " dbname=" ENVIRON["POSTGRES_DATABASE"] " user=" ENVIRON["POSTGRES_USER"] " password=" ENVIRON["POSTGRES_PASSWORD"]
  if ("POSTGRES_SSLMODE" in ENVIRON) {
    param = param " sslmode=" ENVIRON["POSTGRES_SSLMODE"]
  }
  if ("POSTGRES_OPTIONS" in ENVIRON) {
    param = param " options=" ENVIRON["POSTGRES_OPTIONS"]
  }
  if ((Connection = awk::pg_connect(param)) == "" ) {
    logger::error(message, "pgsql")
    error::panic("pgsql::createConnection(): pg_connectionect failed: " ERRNO)
  }
  logger::info("created a postgres connection", "pgsql")
  logger::info("pgsql::createConnection(): Connection: " Connection, "pgsql")
}

function fetchRows() {
  return length(RESULT)
}

function fetchResult(row, columnName) {
  return RESULT[row][columnName]
}
