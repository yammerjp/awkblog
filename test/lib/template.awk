@include "src/lib/template.awk"
@include "testutil.awk"

{
  variables["helloworld"] = "hello, world!"
  variables["posts"]["title"] = "apple"
  variables["posts"]["content"] = "fruit"
  assertEqual("<html>\n\
  <body>\n\
    <p>hello, world!</p>\n\
    <h1>apple</h1>\n\
    <article>fruit</article>\n\
  </body>\n\
</html>\n", template::render("test/lib/template.html", variables))
}

