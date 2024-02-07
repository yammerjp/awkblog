function codegen_header() {
  print "@namespace \"compiled_templates\"\n\
\n\
function render(path, v    , ret) {\n\
  switch(path) {"
}

function codegen_by_file(filename) {
  printf "    case \"%s\":\n", filename

  RS = "<%"

  while((getline < filename) > 0) {
    if (RS == "<%") { # out of <% %>
      # escape charactors
      gsub("\\\\", "\\\\", $0)
      gsub("\"", "\\\"", $0)
      gsub("\n", "\\n", $0)

      print "      ret = ret sprintf(\"%s\", \""  $0 "\")"

      RS = "%>"
    } else { # in <% %>
      switch ($1) {
        case "#include":
          if (!($2 in TemplateFileMap)) {
            printf "unknown file path, %s\n", $2 > "/dev/stderr"
            exit 1
          }
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
      RS = "<%"
    }
  }
  close(filename)

  RS="\n"

  print "      break"
}

function codegen_footer() {
  print "    default:\n\
      print \"unknown path\" > \"/dev/stderr\"\n\
      exit 1\n\
  }\n\
  return ret\n\
}"
}

{
  filename = $0
  if (filename in TemplateFileMap) {
    # detect duplication
    next
  }
  TemplateFileMap[filename] = 1
}

END {
  codegen_header()
  for(path in TemplateFileMap) {
    codegen_by_file(path)
  }
  codegen_footer()
}
