@include "src/lib/environ.awk"
@include "src/lib/error.awk"
@include "src/lib/shell.awk"
@include "src/lib/logger.awk"
@include "src/lib/github.awk"
@include "src/lib/ogp.awk"

# Test command:
#   docker compose exec app bash -c 'gawk -f /app/misc/generate_ogp.awk -v title="Test Title" -v github_user="yammerjp" -v output="/tmp/ogp_test.png"'
#   docker compose cp app:/tmp/ogp_test.png /tmp/ogp_test.png && open /tmp/ogp_test.png

BEGIN {
    if (title == "") title = "Sample Blog Post Title"
    if (github_user == "") github_user = "yammerjp"
    if (output == "") output = "/tmp/ogp.png"

    result = ogp::generateImage(title, github_user, output)
    if (result == 0) {
        print "OGP image created: " output
    }
    exit result
}
