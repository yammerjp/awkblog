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
  POSTGRES_HOSTNAME = environ::getOrPanic("POSTGRES_HOSTNAME")
  POSTGRES_DATABASE = environ::getOrPanic("POSTGRES_DATABASE")
  POSTGRES_USER = environ::getOrPanic("POSTGRES_USER")
  POSTGRES_PASSWORD = environ::getOrPanic("POSTGRES_PASSWORD")

  param = "host=" POSTGRES_HOSTNAME " dbname=" POSTGRES_DATABASE " user=" POSTGRES_USER " password=" POSTGRES_PASSWORD
  if (environ::has("POSTGRES_SSLMODE")) {
    param = param " sslmode=" environ::get("POSTGRES_SSLMODE")
  }
  if (environ::has("POSTGRES_OPTIONS")) {
    param = param " options=" environ::get("POSTGRES_OPTIONS")
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
