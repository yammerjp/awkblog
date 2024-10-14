@namespace "router"

RoutingNotFoundCallback = "router::default_404"

function default_404() {
  http::send(404, "");
}

function register(method, path, callback,      key) {
  key = method " " path
  RoutingTable[key] = callback

  register_wildcard_position(path)
}

function register_notfound(callback) {
  RoutingNotFoundCallback = callback
}

function find(method, path,    key, pos) {
  key = method " " path
  if (key in RoutingTable) {
    return RoutingTable[key]
  }

  for (pos in WildcardPositions) {
    key = method " " wildcard_compress(path, pos)
    if (key in RoutingTable) {
      return RoutingTable[key]
    }
  }
  return RoutingNotFoundCallback
}

function debug_print(    i) {
  for(i in RoutingTable) {
    logger::debug("RoutingTable[\"" i "\"] = " RoutingTable[i], "router")
  }
}

function call(method, path,        controller) {
  controller = find(method, path)
  @controller();
}

function register_wildcard_position(path,         pos, path_parts, i) {
  path = substr(path, 2) # ignore leading a slash
  split(path, path_parts, "/")
  for (i in path_parts) {
    if (path_parts[i] == "*") {
      pos = pos " " i
    }
  }
  if (pos) {
    WildcardPositions[pos] = 1
  }
}

function wildcard_compress(path, pos,        path_parts, masked_path, pos_parts, i) {
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

function split_index(str, arr, sep,        arr_val, i) {
  split(str, arr_val, sep)
  for (i in arr_val)
    arr[arr_val[i]] = 1
}
