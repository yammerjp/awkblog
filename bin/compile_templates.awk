function compile_and_print(file_in    , funcname, filename) {
  funcname = file_in
  gsub("/", "SLASH", funcname)
  gsub("\\.", "DOT", funcname)
  gsub("\n", "", funcname)
  funcname = "render_" funcname
  filename = BASE_DIR file_in

  print "function " funcname "(v    , ret) {"

  while(1) {
    # out of <% %>
    RS = "<%"
    if ((getline < filename) == 0) {
      break
    }

    gsub("\"", "\\\"", $0)
    gsub("\n", "\\n", $0)
    print "  ret = ret sprintf(\"%s\", \""  $0 "\");"

    # in <% %>
    RS = "%>"
    if ((getline < filename) == 0) {
      break
    }
    switch ($1) {
      case "#include#for":
        # TODO
        break
      case "#include#if":
        # TODO
        break
      case "#include":
        # TODO
        break
      case "##":
        break
      case "=":
        $1 = ""
        print "  ret = ret sprintf(\"%s\", " $0 ");"
        break
      default:
        print $0
        break
    }
  }

  print "  return ret"
  print "}"
  RS="\n"
}

BEGIN {
  print "@namespace \"compiled_templates\"\n\
\n\
function render(path, v) {\n\
  gsub(\"/\", \"SLASH\", path)\n\
  gsub(\"\\\\.\", \"DOT\", path)\n\
  gsub(\"\\n\", \"\", path)\n\
  funcname = \"compiled_templates::render_\" path\n\
  logger::debug(\"path : \" path)\n\
  logger::debug(\"funcname : \" funcname)\n\
  return @funcname(v)\n\
}"

}

{
  compile_and_print($0)
}
