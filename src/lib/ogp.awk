@load "gd"
@namespace "ogp"

function generateImage(title, github_user, output,
    fontBold, fontRegular, width, height, avatarSize,
    avatar_url, avatar_file, cmd, im, white, darkGray, lightGray, accentYellow,
    margin, radius, y, ratio, r, g, b, lineColor,
    topRatio, cornerTopR, cornerTopG, cornerTopB,
    bottomRatio, cornerBottomR, cornerBottomG, cornerBottomB,
    largeRadius, corner, bgColor,
    padding, contentLeft, contentRight, contentTop, contentBottom,
    titleSize, titleX, titleY, titleLineHeight, titleLineCount, titleLines, i, brect,
    avatarX, avatarY, avatarCenterY, avatar, avatarW, avatarH, largeSize, avatarLarge,
    userFontSize, userX, userY, userName,
    brandFontSize, brandWidth, brandX, brandY, result) {

    if (!github::isValidUsername(github_user)) {
        print "Error: Invalid GitHub username: " github_user > "/dev/stderr"
        return 1
    }

    fontBold = "/usr/share/fonts/opentype/noto/NotoSansCJK-Bold.ttc"
    fontRegular = "/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc"

    width = 1200
    height = 630

    avatarSize = 90

    avatar_url = "https://github.com/" github_user ".png?size=200"
    avatar_file = "/tmp/github_avatar_" github_user ".png"
    cmd = "curl -sL '" avatar_url "' -o " avatar_file
    system(cmd)

    im = awk::gdImageCreateTrueColor(width, height)
    if (im == "") {
        print "Error: Failed to create image" > "/dev/stderr"
        return 1
    }

    white = awk::gdImageColorAllocate(im, 255, 255, 255)
    darkGray = awk::gdImageColorAllocate(im, 51, 51, 51)
    lightGray = awk::gdImageColorAllocate(im, 120, 120, 120)
    accentYellow = awk::gdImageColorAllocate(im, 255, 191, 0)

    margin = 28
    radius = 24

    for (y = 0; y < height; y++) {
        ratio = y / height
        r = 255
        g = int(210 + (179 - 210) * ratio)
        b = int(127 + (71 - 127) * ratio)
        lineColor = awk::gdImageColorAllocate(im, r, g, b)
        awk::gdImageFilledRectangle(im, 0, y, width - 1, y, lineColor)
    }

    topRatio = margin / height
    cornerTopR = 255
    cornerTopG = int(210 + (179 - 210) * topRatio)
    cornerTopB = int(127 + (71 - 127) * topRatio)

    bottomRatio = (height - margin - radius) / height
    cornerBottomR = 255
    cornerBottomG = int(210 + (179 - 210) * bottomRatio)
    cornerBottomB = int(127 + (71 - 127) * bottomRatio)

    awk::gdImageFilledRectangle(im, margin + radius, margin, width - margin - radius - 1, height - margin - 1, white)
    awk::gdImageFilledRectangle(im, margin, margin + radius, width - margin - 1, height - margin - radius - 1, white)

    largeRadius = radius * 4

    corner = awk::gdImageCreateTrueColor(largeRadius, largeRadius)
    bgColor = awk::gdImageColorAllocate(corner, cornerTopR, cornerTopG, cornerTopB)
    awk::gdImageFilledRectangle(corner, 0, 0, largeRadius - 1, largeRadius - 1, bgColor)
    awk::gdImageFilledEllipse(corner, largeRadius, largeRadius, largeRadius * 2, largeRadius * 2, awk::gdImageColorAllocate(corner, 255, 255, 255))
    awk::gdImageCopyResampled(im, corner, margin, margin, 0, 0, radius, radius, largeRadius, largeRadius)
    awk::gdImageDestroy(corner)

    corner = awk::gdImageCreateTrueColor(largeRadius, largeRadius)
    bgColor = awk::gdImageColorAllocate(corner, cornerTopR, cornerTopG, cornerTopB)
    awk::gdImageFilledRectangle(corner, 0, 0, largeRadius - 1, largeRadius - 1, bgColor)
    awk::gdImageFilledEllipse(corner, 0, largeRadius, largeRadius * 2, largeRadius * 2, awk::gdImageColorAllocate(corner, 255, 255, 255))
    awk::gdImageCopyResampled(im, corner, width - margin - radius, margin, 0, 0, radius, radius, largeRadius, largeRadius)
    awk::gdImageDestroy(corner)

    corner = awk::gdImageCreateTrueColor(largeRadius, largeRadius)
    bgColor = awk::gdImageColorAllocate(corner, cornerBottomR, cornerBottomG, cornerBottomB)
    awk::gdImageFilledRectangle(corner, 0, 0, largeRadius - 1, largeRadius - 1, bgColor)
    awk::gdImageFilledEllipse(corner, largeRadius, 0, largeRadius * 2, largeRadius * 2, awk::gdImageColorAllocate(corner, 255, 255, 255))
    awk::gdImageCopyResampled(im, corner, margin, height - margin - radius, 0, 0, radius, radius, largeRadius, largeRadius)
    awk::gdImageDestroy(corner)

    corner = awk::gdImageCreateTrueColor(largeRadius, largeRadius)
    bgColor = awk::gdImageColorAllocate(corner, cornerBottomR, cornerBottomG, cornerBottomB)
    awk::gdImageFilledRectangle(corner, 0, 0, largeRadius - 1, largeRadius - 1, bgColor)
    awk::gdImageFilledEllipse(corner, 0, 0, largeRadius * 2, largeRadius * 2, awk::gdImageColorAllocate(corner, 255, 255, 255))
    awk::gdImageCopyResampled(im, corner, width - margin - radius, height - margin - radius, 0, 0, radius, radius, largeRadius, largeRadius)
    awk::gdImageDestroy(corner)

    padding = 56
    contentLeft = margin + padding
    contentRight = width - margin - padding
    contentTop = margin + padding
    contentBottom = height - margin - padding

    titleSize = 52
    titleX = contentLeft
    titleY = contentTop + titleSize + 20
    titleLineHeight = int(titleSize * 1.4)

    titleLineCount = split(title, titleLines, "\n")
    for (i = 1; i <= titleLineCount; i++) {
        delete brect
        awk::gdImageStringFT(im, brect, darkGray, fontBold, titleSize, 0, titleX, titleY + (i - 1) * titleLineHeight, titleLines[i])
    }

    avatarX = contentLeft
    avatarY = contentBottom - avatarSize
    avatarCenterY = avatarY + avatarSize / 2

    avatar = awk::gdImageCreateFromFile(avatar_file)

    if (avatar != "") {
        avatarW = awk::gdImageSX(avatar)
        avatarH = awk::gdImageSY(avatar)

        largeSize = avatarSize * 4

        avatarLarge = awk::gdImageCreateTrueColor(largeSize, largeSize)
        awk::gdImageCopyResampled(avatarLarge, avatar, 0, 0, 0, 0, largeSize, largeSize, avatarW, avatarH)
        awk::gdImageCircleCrop(avatarLarge, largeSize / 2, largeSize / 2, largeSize)
        awk::gdImageCopyResampled(im, avatarLarge, avatarX, avatarY, 0, 0, avatarSize, avatarSize, largeSize, largeSize)

        awk::gdImageDestroy(avatarLarge)
        awk::gdImageDestroy(avatar)
    } else {
        awk::gdImageFilledEllipse(im, avatarX + avatarSize/2, avatarCenterY, avatarSize, avatarSize, lightGray)
    }

    userFontSize = 36
    delete brect
    userX = avatarX + avatarSize + 20
    userY = avatarCenterY + userFontSize / 3
    userName = "@" github_user
    awk::gdImageStringFT(im, brect, darkGray, fontBold, userFontSize, 0, userX, userY, userName)

    brandFontSize = 36
    delete brect
    awk::gdImageStringFT(im, brect, accentYellow, fontBold, brandFontSize, 0, 0, 0, "AWKBLOG")
    brandWidth = brect[2] - brect[0]
    brandX = contentRight - brandWidth
    brandY = avatarCenterY + brandFontSize / 3
    delete brect
    awk::gdImageStringFT(im, brect, accentYellow, fontBold, brandFontSize, 0, brandX, brandY, "AWKBLOG")

    result = awk::gdImagePngName(im, output)
    if (result != 0) {
        print "Error: Failed to save image" > "/dev/stderr"
        awk::gdImageDestroy(im)
        return 1
    }

    awk::gdImageDestroy(im)
    return 0
}
