@load "pgsql"

@namespace "pgsql"

function exec(query, params,        response, numberOfFields, col, numberOfRow, row, logstr) {
  logDebug("pgsql::exec() query: " query)
  response = awk::pg_execparams(Connection, query, length(params), params)
  logDebug("pgsql::exec() response: " response)
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
    logDebug(logstr)

    awk::pg_clear(response)
    return 1
  }
  awk::pg_clear(response)
  return 0
}

function createConnection(  param) {
  if (!("POSTGRES_HOSTNAME" in ENVIRON)) {
    print "need environment variable: POSTGRES_HOSTNAME" > "/dev/stderr"
    exit 1
  }
  if (!("POSTGRES_DATABASE" in ENVIRON)) {
    print "need environment variable: POSTGRES_DATABASE" > "/dev/stderr"
    exit 1
  }
  if (!("POSTGRES_USER" in ENVIRON)) {
    print "need environment variable: POSTGRES_USER" > "/dev/stderr"
    exit 1
  }
  if (!("POSTGRES_PASSWORD" in ENVIRON)) {
    print "need environment variable: POSTGRES_PASSWORD" > "/dev/stderr"
    exit 1
  }
  param = "host=" ENVIRON["POSTGRES_HOSTNAME"] " dbname=" ENVIRON["POSTGRES_DATABASE"] " user=" ENVIRON["POSTGRES_USER"] " password=" ENVIRON["POSTGRES_PASSWORD"]
  if ("POSTGRES_SSLMODE" in ENVIRON) {
    param = param " sslmode=" ENVIRON["POSTGRES_SSLMODE"]
  }
  if ("POSTGRES_OPTIONS" in ENVIRON) {
    param = param " options=" ENVIRON["POSTGRES_OPTIONS"]
  }
  if ((Connection = awk::pg_connect(param)) == "" ) {
    logError("pgsql::createConnection(): pg_connectionect failed: " ERRNO)
    return 0
  }
  logInfo("created a postgres connection")
  logError("pgsql::createConnection(): Connection: " Connection)
  return 1
}

function fetchRows() {
  return length(RESULT)
}

function fetchResult(row, columnName) {
  return RESULT[row][columnName]
}

function logInfo(message) {
  logger::info(message, "pgsql")
}

function logDebug(message) {
  logger::debug(message, "pgsql")
}

function logError(message) {
  logger::error(message, "pgsql")
}
