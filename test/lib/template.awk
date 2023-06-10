@include "src/lib/template.awk"
@include "testutil.awk"

{
  variables["helloworld"] = "hello, world!"
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
  </body>\n\
</html>\n", template::render("test/lib/template.html", variables))
}

