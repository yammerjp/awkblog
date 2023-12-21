function compile_and_print(file_in    , funcname, filename) {
  funcname = file_in
  gsub("/", "SLASH", funcname)
  gsub("\\.", "DOT", funcname)
  gsub("\n", "", funcname)
  funcname = "render_" funcname
  filename = BASE_DIR file_in

  print "function " funcname "(v) {"

  while(1) {
    # out of {{ }}
    RS = "{{"
    if ((getline < filename) == 0) {
      break
    }

    gsub("\"", "\\\"", $0)
    gsub("\n", "\\n", $0)
    print "  printf \"%s\", \""  $0 "\";"

    # in {{ }}
    RS = "}}"
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
      default:
        print "  printf \"%s\", " $0 ";"
        break
    }
  }

  print "}"
  RS="\n"
}

BEGIN {
  print "@namespace \"compiled_templates\"\n\
\n\
function render(path, v) {\n\
  gsub(\"/\", \"SLASH\", path)\n\
  gsub(\"\\\\.\", \"DOT\", $0)\n\
  gsub(\"\\n\", \"\", $0)\n\
  funcname = \"render_\" $0\n\
  @funcname(v)\n\
}"

}

{
  compile_and_print($0)
}
