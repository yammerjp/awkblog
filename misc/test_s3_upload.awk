@include "src/lib/environ.awk"
@include "src/lib/error.awk"
@include "src/lib/shell.awk"
@include "src/lib/logger.awk"
@include "src/lib/github.awk"
@include "src/lib/ogp.awk"
@include "src/lib/datetime.awk"
@include "src/lib/json.awk"
@include "src/lib/base64.awk"
@include "src/lib/hmac.awk"
@include "src/lib/awss3.awk"

# Test command:
#   docker compose exec app bash -c 'gawk -f /app/misc/test_s3_upload.awk'

BEGIN {
    if (title == "") title = "Test OGP Image"
    if (github_user == "") github_user = "yammerjp"
    tempFile = "/tmp/ogp_test_" systime() ".png"

    print "Generating OGP image..."
    result = ogp::generateImage(title, github_user, tempFile)
    if (result != 0) {
        print "Failed to generate OGP image"
        exit 1
    }
    print "OGP image created: " tempFile

    print "Uploading to S3..."
    key = "ogp/test/" systime() ".png"
    publicUrl = awss3::upload(tempFile, key, "image/png")
    print "Uploaded to: " publicUrl

    # Clean up
    system("rm " tempFile)
    print "Done!"
}
