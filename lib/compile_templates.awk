function compile_template_file(filename) {
  while(1) {
    # out of <% %>
    RS = "<%"
    if (!((getline < filename) > 0)) {
      break
    }

    gsub("\"", "\\\"", $0)
    gsub("\n", "\\n", $0)

    print "      ret = ret sprintf(\"%s\", \""  $0 "\")"

    # in <% %>
    RS = "%>"
    if (!((getline < filename) > 0)) {
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
  close(filename)
  RS="\n"
}

function addPage(filename) {
  if (filename in TemplateFileMap) {
    # detect duplication
    return
  }
  TemplateFileMap[filename] = 1
  TemplateFiles[length(TemplateFiles) + 1] = filename
}

BEGIN {
  TemplateFiles["arraydefinition"] = 1
  delete TemplateFiles["arraydefinition"]
  TemplateFileMap["arraydefinition"] = 1
  delete TemplateFilesKeys["arraydefinition"]
}

{
  addPage($0)
}

END {
  print "@namespace \"compiled_templates\"\n\
\n\
function render(path, v    , ret) {\n\
  switch(path) {"

  for(i=1; i <= length(TemplateFiles); i++ ) {
    print "    case \"" TemplateFiles[i] "\":"

    compile_template_file(TemplateFiles[i])

    print "      break"
  }

  print "\n\
    default:\n\
      print \"unknown path\" > \"/dev/stderr\"\n\
      exit 1\n\
  }\n\
  return ret\n\
}"
}

