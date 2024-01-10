@namespace "error"

function defaultErrorHandler(message) {
  print message > "/dev/stderr"
}

function defaultPanicHandler(message) {
  print message > "/dev/stderr"
  exit 1
}

function registerErrorHandler(funcname) {
  logger::debug("error::registerErrorHandler(): " funcname)
  ERROR_HANDLER = funcname
}

function currentErrorHandler() {
  return ERROR_HANDLER
}

function currentPanicHandler() {
  return PANIC_HANDLER
}


function registerPanicHandler(funcname) {
  PANIC_HANDLER = funcname
}

function raise(message, extraContext) {
  if (ERROR_HANDLER == "") {
    defaultErrorHandler(message)
  } else {
    @ERROR_HANDLER(message, extraContext)
  }
}

function panic(message, extraContxt) {
  if (PANIC_HANDLER == "") {
    defaultPanicHandler(message)
  } else {
    @PANIC_HANDLER(message, extraContext)
  }
}
