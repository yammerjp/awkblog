@include "src/lib/template.awk"
@include "testutil.awk"

{
  variables["helloworld"] = "hello, world!"
  assertEqual("<html>\n\
  <body>\n\
    <p>hello, world!</p>\n\
  </body>\n\
</html>\n", template::render("test/lib/template.html", variables))
}

