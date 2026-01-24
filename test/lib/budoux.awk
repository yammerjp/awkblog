@include "src/lib/budoux.awk"
@include "test/testutil.awk"

BEGIN {
    budoux::_init()
}

"parse empty string" {
    delete result
    count = budoux::parse("", result)
    assertEqual(0, count)
}

"parse single character" {
    delete result
    count = budoux::parse("あ", result)
    assertEqual(1, count)
    assertEqual("あ", result[1])
}

"parseToString simple sentence 1" {
    str = budoux::parseToString("今日は天気です", "|")
    assertEqual("今日は|天気です", str)
}

"parseToString simple sentence 2" {
    str = budoux::parseToString("これはテストです", "|")
    assertEqual("これは|テストです", str)
}

"parseToString simple sentence 3" {
    str = budoux::parseToString("吾輩は猫である", "|")
    assertEqual("吾輩は|猫である", str)
}

"parseToString with multiple breaks" {
    str = budoux::parseToString("AWKでBudouXを実装する", "|")
    assertEqual("AWKで|BudouXを|実装する", str)
}

"parseToString blog title 1" {
    str = budoux::parseToString("技術ブログを始めました", "|")
    assertEqual("技術ブログを|始めました", str)
}

"parseToString blog title 2" {
    str = budoux::parseToString("プログラミング言語AWKの魅力について", "|")
    assertEqual("プログラミング言語AWKの|魅力に|ついて", str)
}

"parseToString location sentence" {
    str = budoux::parseToString("私は東京に住んでいます", "|")
    assertEqual("私は|東京に|住んでいます", str)
}

"parseToString weather sentence" {
    str = budoux::parseToString("明日の天気は晴れでしょう", "|")
    assertEqual("明日の|天気は|晴れでしょう", str)
}

"parse returns correct count" {
    delete result
    count = budoux::parse("私は東京に住んでいます", result)
    assertEqual(3, count)
    assertEqual("私は", result[1])
    assertEqual("東京に", result[2])
    assertEqual("住んでいます", result[3])
}
