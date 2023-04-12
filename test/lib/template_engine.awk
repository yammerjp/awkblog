@include "src/lib/template_engine.awk"
@include "testutil.awk"

{
  variables["helloworld"] = "hello, world!"
  assertEqual("<html>\n\
  <body>\n\
    <p>hello, world!</p>\n\
  </body>\n\
</html>\n", lib::renderTemplate("test/lib/template_engine.html", variables))
}

