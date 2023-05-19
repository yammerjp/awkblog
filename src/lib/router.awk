@namespace "router"

routing_notfound_callback = "router::default_404"

function default_404() {
  http::finishRequest(404, "");
}

function routing_register(method, path, callback) {
  routing_tables[method][path] = callback
}

function routing_register_notfound(callback) {
  routing_notfound_callback = callback
}

function routing_find(method, path) {
  if (!(method in routing_tables)) {
    return routing_notfound_callback
  }
  if (!(path in routing_tables[method])) {
    return routing_notfound_callback
  }
  return routing_tables[method][path]
}

function routing_call(method, path,        controller) {
  controller = routing_find(method, path)
  @controller();
}
