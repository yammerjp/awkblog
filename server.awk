#!/usr/bin/env -S gawk -f 

@load "pgsql"
@include ".autoload.awk"

function pgsql_try() {
  if ((connection = pg_connect("host=db dbname=postgres user=postgres password=passw0rd")) == "") {
    printf "pg_connectionect failed: %s\n", ERRNO > "/dev/stderr"
    return 0
  }
  query = "SELECT 1 = 1 as hello, 1=0 as world, 1 as int1, 0 as int0;"

  if (pg_sendquery(connection, query) == 0) {
    printf "pg_sendquery(%s) failed: %s\n", query, ERRNO
    return 0
  }
  response = pg_getresult(connection)
  delete RESULT
  RESULT[0] = ""
  delete RESULT[0]
  if (response ~ /^OK/) {
    return 1
  }
  if (response ~ /^TUPLES /) {
     number_of_fields = pg_nfields(response)
     for (col = 0; col < number_of_fields; col++) {
       columns[col] = pg_fname(response, col)
o    }
     number_of_rows = pg_ntuples(response)
     for (row = 0; row < number_of_rows; row++) {
       for (col = 0; col < number_of_fields; col++) {
         RESULT[row][columns[col]] = (pg_getisnull(response,row,col) ? "<NULL>" : pg_getvalue(response,row,col))
       }
     }
     pg_clear(response)

    for(i in RESULT) {
      printf "  %s:\n", i
      for (column_name in RESULT[i]) {
        printf "    %s: %s\n", column_name, RESULT[i][column_name]
      }
    }
    return 1
  }
  return 0
}

BEGIN {
  pgsql_try()

  print "Start awkblog. listen port " PORT " ..."
  http::initialize_http();
}

!http::REQUEST_PROCESS {
  # start to process a request;
  http::start_request();
}

@include "./routing.awk"
