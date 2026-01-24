@load "gd"
@namespace "ogp"

# Calculate visual width of a string for OGP title rendering
# ASCII = width 0.9, non-ASCII UTF-8 = width 2
# Uses utf8:: functions to work correctly in POSIX locale
function _visualWidth(str,    charCount, width, i, c) {
    utf8::_init()
    charCount = utf8::strlen(str)
    width = 0
    for (i = 1; i <= charCount; i++) {
        c = utf8::charAt(str, i)
        width += utf8::isAscii(c) ? 0.9 : 2
    }
    return width
}

# Truncate string based on visual width, adding "…" if truncated
# ASCII = width 0.9, non-ASCII UTF-8 = width 2
# maxWidth is the maximum visual width (e.g., 30 for ~14 Japanese chars or ~31 ASCII)
# Uses utf8:: functions to work correctly in POSIX locale
function truncate(str, maxWidth,    charCount, width, cutPos, i, c, cw, result) {
    utf8::_init()
    charCount = utf8::strlen(str)
    if (charCount == 0) return ""

    width = 0
    cutPos = 0

    for (i = 1; i <= charCount; i++) {
        c = utf8::charAt(str, i)
        cw = utf8::isAscii(c) ? 0.9 : 2

        if (width + cw > maxWidth - 2) {
            cutPos = i - 1
            break
        }

        width += cw
    }

    if (cutPos > 0) {
        result = ""
        for (i = 1; i <= cutPos; i++) {
            result = result utf8::charAt(str, i)
        }
        return result "…"
    }
    return str
}

# Split a BudouX chunk further by spaces (for ASCII text)
# Returns the number of sub-chunks, stores them in result array
function _splitBySpace(chunk, result,    n, i, parts, partCount) {
    # Split by space, keeping spaces at word boundaries
    partCount = split(chunk, parts, " ")
    n = 0
    for (i = 1; i <= partCount; i++) {
        if (parts[i] != "") {
            n++
            # Add space back except for first part
            if (i > 1) {
                result[n] = " " parts[i]
            } else {
                result[n] = parts[i]
            }
        }
    }
    return n
}

# Wrap title into multiple lines using BudouX for word segmentation
# Returns title with newlines inserted, up to maxLines lines
# Each line limited to maxWidth visual width
function wrapTitle(title, maxWidth, maxLines,
    chunks, chunkCount, lines, lineCount, currentLine, currentWidth, i, j, chunkWidth, result,
    subChunks, subChunkCount) {

    # Initialize BudouX
    budoux::_init()

    # Parse title into chunks
    chunkCount = budoux::parse(title, chunks)
    if (chunkCount == 0) return ""

    # Build lines from chunks
    lineCount = 1
    currentLine = ""
    currentWidth = 0

    for (i = 1; i <= chunkCount; i++) {
        # For ASCII-heavy chunks, split further by spaces
        subChunkCount = _splitBySpace(chunks[i], subChunks)

        for (j = 1; j <= subChunkCount; j++) {
            chunkWidth = _visualWidth(subChunks[j])

            # Check if adding this chunk would exceed line width
            if (currentWidth > 0 && currentWidth + chunkWidth > maxWidth) {
                # Save current line and start new one
                lines[lineCount] = currentLine
                lineCount++

                # If we've reached max lines, truncate and finish
                if (lineCount > maxLines) {
                    # Truncate the last line if needed
                    lines[maxLines] = truncate(lines[maxLines] subChunks[j], maxWidth)
                    lineCount = maxLines
                    # Skip remaining chunks
                    i = chunkCount + 1
                    break
                }

                # Start new line (trim leading space if present)
                if (substr(subChunks[j], 1, 1) == " ") {
                    currentLine = substr(subChunks[j], 2)
                    currentWidth = _visualWidth(currentLine)
                } else {
                    currentLine = subChunks[j]
                    currentWidth = chunkWidth
                }
            } else {
                # Add chunk to current line
                currentLine = currentLine subChunks[j]
                currentWidth += chunkWidth
            }
        }
    }

    # Don't forget the last line
    if (lineCount <= maxLines && currentLine != "") {
        lines[lineCount] = currentLine
    }

    # Join lines with newlines
    result = lines[1]
    for (i = 2; i <= lineCount; i++) {
        result = result "\n" lines[i]
    }

    return result
}

function generateImage(title, github_user, output,
    fontBold, fontRegular, width, height, avatarSize,
    avatar_url, avatar_file, cmd, im, white, darkGray, lightGray, accentYellow,
    margin, radius, y, ratio, r, g, b, lineColor,
    topRatio, cornerTopR, cornerTopG, cornerTopB,
    bottomRatio, cornerBottomR, cornerBottomG, cornerBottomB,
    largeRadius, corner, bgColor,
    padding, contentLeft, contentRight, contentTop, contentBottom,
    titleSize, titleX, titleY, titleLineHeight, titleLineCount, titleLines, i, brect, wrappedTitle,
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

    # Wrap title using BudouX (max 4 lines, max width 30)
    wrappedTitle = wrapTitle(title, 30, 4)
    titleLineCount = split(wrappedTitle, titleLines, "\n")
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

# Generate OGP image and upload to S3
# Returns the public URL of the uploaded image, or empty string on failure
function generateAndUpload(title, github_user, accountId,
    tempFile, key, result, publicUrl) {

    tempFile = "/tmp/ogp_" accountId "_" awk::systime() "_" substr(http::getRequestId(), 1, 16) ".png"

    result = generateImage(title, github_user, tempFile)
    if (result != 0) {
        return ""
    }

    key = "ogp/" accountId "/" awk::systime() substr(http::getRequestId(), 1, 8) ".png"
    publicUrl = awss3::upload(tempFile, key, "image/png")

    system("rm " tempFile)

    return publicUrl
}
