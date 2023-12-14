@include "src/lib/template.awk"
@include "test/testutil.awk"

{
  delete vairables
  variables["hey"] = "yoo"
  assertEqual("yoo", template::getVar(variables, "hey"))
}

"getVar()" {
  delete vairables
  variables["path"]["to"]["str"] = "yoo"
  assertEqual("yoo", template::getVar(variables, "path.to.str"))
}

"variable" {
  delete vairables
  variables["username"] = "yammerjp"
  assertEqual("\
<footer>Copyright (C) 2023 yammerjp. All Rights Reserved.</footer>\n\
", template::render("test/lib/template/variable.html", variables))
}

"include subtree" {
  delete vairables
  variables["post"]["name"] = "yammerjp"
  assertEqual("<div><div>yammerjp</div>\n</div>\n\
", template::render("test/lib/template/include-subtree.html", variables))
}

"include for" {
  delete vairables
  variables["tags"][1]["name"] = "fruit"
  variables["tags"][2]["name"] = "food"
  assertEqual("<div><div>fruit</div>\n<div>food</div>\n</div>\n\
", template::render("test/lib/template/include-for.html", variables))
}

"rootvar" {
  str = "fruit"
  assertEqual("<div>fruit</div>\n", template::render("test/lib/template/rootvar.html", str))
}

"comment" {
  assertEqual("<div>hello</div>\n", template::render("test/lib/template/comment.html"))
}

"include if" {
  delete vairables
  variables["name"] = "food"
  variables["printtag"] = 1
  assertEqual("<div><div>food</div>\n</div>\n", template::render("test/lib/template/include-if.html", variables))
}

"integration test" {
  delete variables
  variables["helloworld"] = "hello, world!"
  variables["username"] = "yammerjp"
  variables["posts"]["title"] = "apple"
  variables["posts"]["content"] = "fruit"
  variables["posts"]["tags"][1]["name"] = "food"
  variables["posts"]["tags"][2]["name"] = "good"
  assertEqual("<html>\n\
  <body>\n\
    <p>hello, world!</p>\n\
    <h1>apple</h1>\n\
    <article>fruit</article>\n\
    <div>\n\
<div>food</div>\n\
<div>good</div>\n\
\n\
    </div>\n\
    <footer>Copyright (C) 2023 yammerjp. All Rights Reserved.</footer>\n\
\n\
  </body>\n\
</html>\n", template::render("test/lib/template/integration/index.html", variables))
}
