function compile_page(filename) {
  while(1) {
    # out of <% %>
    RS = "<%"
    if ((getline < filename) == 0) {
      break
    }

    gsub("\"", "\\\"", $0)
    gsub("\n", "\\n", $0)
    print "      ret = ret sprintf(\"%s\", \""  $0 "\");"

    # in <% %>
    RS = "%>"
    if ((getline < filename) == 0) {
      break
    }
    switch ($1) {
      case "#include":
        # TODO
        print "need to implement #include" > "/dev/stderr"
        exit 1
        break
      case "##":
        break
      case "=":
        $1 = ""
        print "      ret = ret sprintf(\"%s\", " $0 ");"
        break
      default:
        print $0
        break
    }
  }
  RS="\n"
}

BEGIN {
  print "@namespace \"compiled_templates\"\n\
\n\
function render(path, v    , ret) {\n\
  switch(path) {"
}

END {
  print "\n\
    default:\n\
      print \"unknown path\" > \"/dev/stderr\"\n\
      exit 1\n\
  }\n\
  return ret\n\
}"
}

{
  print "    case \"" $0 "\":"
  compile_page(BASE_DIR "/" $0)
  print "      break"
}
