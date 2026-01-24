@include "src/lib/logger.awk"
@include "src/lib/shell.awk"
@include "src/lib/environ.awk"
@include "src/lib/error.awk"
@include "src/lib/github.awk"
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
