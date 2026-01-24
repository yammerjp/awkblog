@include "src/lib/logger.awk"
@include "src/lib/shell.awk"
@include "src/lib/environ.awk"
@include "src/lib/error.awk"
@include "src/lib/github.awk"
@include "src/lib/utf8.awk"
@include "src/vendor/budoux_model_ja.awk"
@include "src/lib/budoux.awk"
@include "src/lib/ogp.awk"
@include "test/testutil.awk"

# truncate: ASCII only - short string (no truncation needed)
"truncate: ASCII short" {
    assertEqual("Hello", ogp::truncate("Hello", 30))
}

# truncate: ASCII only - exact limit
"truncate: ASCII exact" {
    assertEqual("abcdefghijklmnopqrstuvwxyz78901", ogp::truncate("abcdefghijklmnopqrstuvwxyz78901", 30))
}

# truncate: ASCII only - over limit
"truncate: ASCII over" {
    # 30 / 0.9 = 33 chars, so 40 chars should be truncated
    result = ogp::truncate("abcdefghijklmnopqrstuvwxyz7890123456789X", 30)
    # Should end with ellipsis and not contain "X"
    assertEqual(1, result ~ /…$/)
    assertEqual(0, result ~ /X/)
}

# truncate: Japanese only - short string
"truncate: Japanese short" {
    assertEqual("日本語", ogp::truncate("日本語", 30))
}

# truncate: Japanese only - exact limit (14 chars = 28 width, fits in 30-2=28)
"truncate: Japanese exact 14" {
    # 14 Japanese chars = 28 width, fits exactly when 2 is reserved for ellipsis
    assertEqual("あいうえおかきくけこさしすせ", ogp::truncate("あいうえおかきくけこさしすせ", 30))
}

# truncate: Japanese only - over limit
"truncate: Japanese over" {
    result = ogp::truncate("あいうえおかきくけこさしすせそたちつてと", 30)
    assertEqual(1, result ~ /…$/)
    assertEqual(0, result ~ /と/)
}

# truncate: Mixed - Japanese then ASCII
"truncate: Mixed JP then ASCII" {
    result = ogp::truncate("日本語ABCDEFGHIJKLMNOPタイトル", 30)
    assertEqual(1, result ~ /…$/)
}

# truncate: Mixed - ASCII then Japanese
"truncate: Mixed ASCII then JP" {
    result = ogp::truncate("Hello World こんにちは世界テスト", 30)
    assertEqual(1, result ~ /…$/)
}

# truncate: Empty string
"truncate: empty" {
    assertEqual("", ogp::truncate("", 30))
}

# truncate: Single ASCII char
"truncate: single ASCII" {
    assertEqual("A", ogp::truncate("A", 30))
}

# truncate: Single Japanese char
"truncate: single Japanese" {
    assertEqual("あ", ogp::truncate("あ", 30))
}

# ============================================
# _visualWidth tests
# ============================================

# _visualWidth: ASCII string
"_visualWidth: ASCII" {
    # "Hello" = 5 chars * 0.9 = 4.5
    width = ogp::_visualWidth("Hello")
    assertEqual(1, width >= 4 && width <= 5)
}

# _visualWidth: Japanese string
"_visualWidth: Japanese" {
    # "日本語" = 3 chars * 2 = 6
    width = ogp::_visualWidth("日本語")
    assertEqual(6, width)
}

# _visualWidth: Mixed string
"_visualWidth: mixed" {
    # "Aあ" = 0.9 + 2 = 2.9
    width = ogp::_visualWidth("Aあ")
    assertEqual(1, width >= 2 && width <= 3)
}

# _visualWidth: Empty string
"_visualWidth: empty" {
    assertEqual(0, ogp::_visualWidth(""))
}

# ============================================
# wrapTitle tests
# ============================================

# wrapTitle: Empty string
"wrapTitle: empty" {
    assertEqual("", ogp::wrapTitle("", 30, 4))
}

# wrapTitle: Short string (no wrapping needed)
"wrapTitle: short" {
    assertEqual("短いタイトル", ogp::wrapTitle("短いタイトル", 30, 4))
}

# wrapTitle: Short ASCII string (no wrapping needed)
"wrapTitle: short ASCII" {
    assertEqual("Hello", ogp::wrapTitle("Hello", 30, 4))
}

# wrapTitle: Japanese text wraps correctly
"wrapTitle: Japanese wrap" {
    title = "これはとても長いタイトルで複数行に分割されるべきテストです"
    result = ogp::wrapTitle(title, 30, 4)
    # Should have multiple lines
    n = split(result, lines, "\n")
    assertEqual(1, n > 1)
    # Each line should not exceed max width (approximately)
    assertEqual(1, length(lines[1]) <= 20)
}

# wrapTitle: ASCII text wraps at spaces
"wrapTitle: ASCII wrap" {
    title = "This is a very long title that should wrap across multiple lines"
    result = ogp::wrapTitle(title, 30, 4)
    n = split(result, lines, "\n")
    # Should have multiple lines
    assertEqual(1, n > 1)
    # Lines should not start with space (trimmed)
    assertEqual(0, lines[2] ~ /^ /)
}

# wrapTitle: Mixed text wraps correctly
"wrapTitle: mixed wrap" {
    title = "Hello World こんにちは世界 This is a test"
    result = ogp::wrapTitle(title, 30, 4)
    n = split(result, lines, "\n")
    assertEqual(1, n >= 1)
}

# wrapTitle: Respects maxLines limit
"wrapTitle: maxLines limit" {
    # Very long title that would need more than 4 lines
    title = "これは非常に長いタイトルで四行以上必要になるはずのテストタイトルです。さらに長くしてみます。"
    result = ogp::wrapTitle(title, 30, 4)
    n = split(result, lines, "\n")
    # Should not exceed 4 lines
    assertEqual(1, n <= 4)
}

# wrapTitle: Truncates last line when exceeding maxLines
"wrapTitle: truncate last line" {
    # Very long title
    title = "一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十一二三四五六七八九十"
    result = ogp::wrapTitle(title, 30, 4)
    n = split(result, lines, "\n")
    # Last line should end with ellipsis if truncated
    assertEqual(1, n <= 4)
}

# wrapTitle: Single line maxLines=1
"wrapTitle: maxLines 1" {
    title = "これは長いタイトルですが一行に制限されます"
    result = ogp::wrapTitle(title, 30, 1)
    n = split(result, lines, "\n")
    assertEqual(1, n)
}

# wrapTitle: Handles newlines in input (splits on existing newlines)
"wrapTitle: preserves structure" {
    title = "短い"
    result = ogp::wrapTitle(title, 30, 4)
    # Should remain single line
    n = split(result, lines, "\n")
    assertEqual(1, n)
}

# wrapTitle: should not break if width allows
"wrapTitle: no unnecessary break" {
    # "複数行に" (width 8) + "分割される" (width 10) = 18, fits in 30
    # Should NOT break between these chunks
    title = "複数行に分割される"
    result = ogp::wrapTitle(title, 30, 4)
    n = split(result, lines, "\n")
    # Should be one line since total width is 18 < 30
    assertEqual(1, n)
}

# wrapTitle: combine chunks on same line when possible
"wrapTitle: combine chunks" {
    # Even if BudouX splits into multiple chunks, they should stay on same line if they fit
    title = "これはテスト"  # Width = 12
    result = ogp::wrapTitle(title, 30, 4)
    n = split(result, lines, "\n")
    assertEqual(1, n)
    assertEqual("これはテスト", result)
}
