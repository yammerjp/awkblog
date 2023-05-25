@namespace "router"

routing_notfound_callback = "router::default_404"

function default_404() {
  http::finishRequest(404, "");
}

function register(method, path, callback,      key) {
  key = method " " path
  routing_tables[key] = callback

  register_wildcard_position(path)
}

function register_notfound(callback) {
  routing_notfound_callback = callback
}

function find(method, path,    key) {
  key = method " " path
  if (key in routing_tables) {
    return routing_tables[key]
  }

  for (i in wildcard_positions) {
    key = method " " wildcard_compress(path, wildcard_positions[i])
    if (key in routing_tables) {
      return routing_tables[key]
    }
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

function register_wildcard_position(path,         wildcard_idx, before_wildcard) {
  wildcard_idx = index(path, "*")
  if (wildcard_idx > 0) {
    # path includes *
    before_wildcard = substr(path, 0, wildcard_idx)
    gsub(/[^\/]/, "", before_wildcard)
    wildcard_positions_append(length(before_wildcard))
  }
}

function wildcard_positions_append(pos) {
  if (1 in wildcard_positions) {
    wildcard_positions[length(wildcard_positions) + 1] = pos
  } else {
    wildcard_positions[1] = pos
  }
}

function wildcard_compress(path, pos,        path_parts, masked_path) {
  path = substr(path, 2)
  split(path, path_parts, "/")
  for(i in path_parts) {
    if (i == pos) {
      masked_path = masked_path "/*"
    } else {
      masked_path = masked_path "/" path_parts[i]
    }
  }
  return masked_path
}

