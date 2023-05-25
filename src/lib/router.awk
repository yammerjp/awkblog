@namespace "router"

routing_notfound_callback = "router::default_404"

function default_404() {
  http::finishRequest(404, "");
}

function register(method, path, callback,      key) {
  key = method " " path
  routing_tables[key] = callback
}

function register_notfound(callback) {
  routing_notfound_callback = callback
}

function find(method, path,        key) {
  key = method " " path
  if (key in routing_tables) {
    return routing_tables[key]
  }
  return routing_notfound_callback
}

function debug_print() {
  for(i in routing_tables) {
    printf "routing_tables[\"%s\"] = %s\n", i, routing_tables[i]
  }
}

function call(method, path,        controller) {
  controller = find(method, path)
  @controller();
}
