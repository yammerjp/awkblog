@load "gd"

# OGP画像生成
#
# Usage:
#   GDFONTPATH=/usr/share/fonts/opentype/noto gawk -f misc/generate_ogp.awk \
#     -v title="タイトル" -v github_user="yammerjp" -v output="ogp.png"
#
# Test command:
#   docker compose exec app bash -c 'GDFONTPATH=/usr/share/fonts/opentype/noto gawk -f /app/misc/generate_ogp.awk -v title="AWKでブログを作る" -v github_user="yammerjp" -v output="/tmp/ogp_test.png"'
#   docker compose cp app:/tmp/ogp_test.png /tmp/ogp_test.png && open /tmp/ogp_test.png

BEGIN {
    # デフォルト値
    if (title == "") title = "Sample Blog Post Title"
    if (github_user == "") github_user = "yammerjp"
    if (output == "") output = "/tmp/ogp.png"

    # GitHubプロフィール画像をダウンロード（小さいサイズで）
    avatar_url = "https://github.com/" github_user ".png?size=100"
    avatar_file = "/tmp/github_avatar_" github_user "_small.png"
    cmd = "curl -sL '" avatar_url "' -o " avatar_file
    system(cmd)

    # フォント
    fontBold = "NotoSansCJK-Bold.ttc"
    fontRegular = "NotoSansCJK-Regular.ttc"

    # OGPサイズを縮小: 800x420
    width = 800
    height = 420

    # 画像を作成
    im = gdImageCreateTrueColor(width, height)
    if (im == "") {
        print "Error: Failed to create image" > "/dev/stderr"
        exit 1
    }

    # 色の定義
    white = gdImageColorAllocate(im, 255, 255, 255)
    primary = gdImageColorAllocate(im, 62, 168, 255)
    darkGray = gdImageColorAllocate(im, 51, 51, 51)
    lightGray = gdImageColorAllocate(im, 156, 163, 175)

    # 背景
    gdImageFilledRectangle(im, 0, 0, width - 1, height - 1, white)

    # 上部の帯
    gdImageFilledRectangle(im, 0, 0, width - 1, 80, primary)

    # ロゴ
    delete brect
    gdImageStringFT(im, brect, white, fontBold, 32, 0, 40, 58, "AWKBLOG")

    # アバター画像
    avatar = gdImageCreateFromFile(avatar_file)
    if (avatar != "") {
        avatarW = gdImageSX(avatar)
        avatarH = gdImageSY(avatar)
        avatarSize = 80
        avatarX = width - avatarSize - 40
        avatarY = 20

        # リサンプリングしてコピー
        gdImageCopyResampled(im, avatar, avatarX, avatarY, 0, 0, avatarSize, avatarSize, avatarW, avatarH)

        # TODO: gdImageFilledEllipseが実装されたら、円形マスクを追加
        # 円形マスク（背景色の円を上から描画）
        # gdImageFilledEllipse(im, avatarX + avatarSize/2, avatarY + avatarSize/2, avatarSize, avatarSize, primary)

        gdImageDestroy(avatar)
    }

    # タイトル
    titleSize = 36
    gdImageStringFT(im, brect, darkGray, fontBold, titleSize, 0, 50, 220, title)

    # フッター
    footer = "A blog system implemented with AWK"
    gdImageStringFT(im, brect, lightGray, fontRegular, 16, 0, 50, height - 60, footer)

    # 保存
    result = gdImagePngName(im, output)
    if (result != 0) {
        print "Error: Failed to save image" > "/dev/stderr"
        gdImageDestroy(im)
        exit 1
    }

    gdImageDestroy(im)
    print "OGP image created: " output
}
