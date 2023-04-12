@load "pgsql"

@namespace "pgsql"

function exec(query, params,        response, number_of_fields, col, number_of_row, row) {
  response = awk::pg_execparams(Connection, query, length(params), params)
  delete RESULT
  RESULT[0] = ""
  delete RESULT[0]
  if (response ~ /^OK/) {
     awk::pg_clear(response)
    return 1
  }
  if (response ~ /^TUPLES /) {
     number_of_fields = awk::pg_nfields(response)
     for (col = 0; col < number_of_fields; col++) {
       columns[col] = awk::pg_fname(response, col)
o    }
     number_of_rows = awk::pg_ntuples(response)
     for (row = 0; row < number_of_rows; row++) {
       for (col = 0; col < number_of_fields; col++) {
         RESULT[row][columns[col]] = (awk::pg_getisnull(response,row,col) ? "<NULL>" : awk::pg_getvalue(response,row,col))
       }
     }

    if (DEBUG) {
      for(i in RESULT) {
        printf "  %s:\n", i
        for (column_name in RESULT[i]) {
          printf "    %s: %s\n", column_name, RESULT[i][column_name]
        }
      }
    }
    awk::pg_clear(response)
    return 1
  }
  awk::pg_clear(response)
  return 0
}

function createConnection() {
  print "createConnection"
  if ((Connection = awk::pg_connect("host=db dbname=postgres user=postgres password=passw0rd")) == "") {
    printf "pg_connectionect failed: %s\n", ERRNO > "/dev/stderr"
    return 0
  }
  return 1
}

function fetchRows() {
  return length(RESULT)
}

function fetchResult(row, column_name) {
  return RESULT[row][column_name]
}
