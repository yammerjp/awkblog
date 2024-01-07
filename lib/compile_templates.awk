function compile_page(filename) {
  while(1) {
    # out of <% %>
    RS = "<%"
    if ((getline < filename) == 0) {
      break
    }

    gsub("\"", "\\\"", $0)
    gsub("\n", "\\n", $0)
    print "      ret = ret sprintf(\"%s\", \""  $0 "\")"

    # in <% %>
    RS = "%>"
    if ((getline < filename) == 0) {
      break
    }
    switch ($1) {
      case "#include":
        addPage($2)
        print "      ret = ret render(\"" $2 "\", v)"
        break
      case "##":
        break
      case "=":
        $1 = ""
        print "      ret = ret sprintf(\"%s\", " $0 ")"
        break
      default:
        print $0
        break
    }
  }
  RS="\n"
}

function addPage(filename) {
  Pages[length(Pages) + 1] = filename
}

BEGIN {
  Pages["arraydefinition"] = 1
  delete Pages["arraydefinition"]
}

{
  addPage($0)
}

END {
  print "@namespace \"compiled_templates\"\n\
\n\
function render(path, v    , ret) {\n\
  switch(path) {"

  for(i=1; i <= length(Pages); i++ ) {
    print "    case \"" Pages[i] "\":"
    compile_page(Pages[i])
    print "      break"
  }
  for (page in Pages) {
  }

  print "\n\
    default:\n\
      print \"unknown path\" > \"/dev/stderr\"\n\
      exit 1\n\
  }\n\
  return ret\n\
}"
}

