@namespace "router"

routing_notfound_callback = "router::default_404"

function default_404() {
  http::send(404, "");
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

  for (pos in wildcard_positions) {
    key = method " " wildcard_compress(path, pos)
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

function register_wildcard_position(path,         pos, path_parts) {
  path = substr(path, 2) # ignore leading a slash
  split(path, path_parts, "/")
  for (i in path_parts) {
    if (path_parts[i] == "*") {
      pos = pos " " i
    }
  }
  if (pos) {
    wildcard_positions[pos] = 1
  }
}

function wildcard_compress(path, pos,        path_parts, masked_path, pos_parts) {
  path = substr(path, 2) # ignore leading a slash
  split(path, path_parts, "/")
  split_index(pos, pos_parts, " ")
  for(i in path_parts) {
    if (i in pos_parts) {
      masked_path = masked_path "/*"
    } else {
      masked_path = masked_path "/" path_parts[i]
    }
  }
  return masked_path
}

function split_index(str, arr, sep,        arr_val) {
  split(str, arr_val, sep)
  for (i in arr_val)
    arr[arr_val[i]] = 1
}
