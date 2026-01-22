@include "src/lib/logger.awk"
@include "src/lib/shell.awk"
@include "src/lib/environ.awk"
@include "src/lib/error.awk"
@include "src/lib/github.awk"
@include "test/testutil.awk"

"isValidUsername: valid simple username" {
    assertEqual(1, github::isValidUsername("yammerjp"))
}

"isValidUsername: valid with numbers" {
    assertEqual(1, github::isValidUsername("user123"))
}

"isValidUsername: valid with hyphen" {
    assertEqual(1, github::isValidUsername("user-name"))
}

"isValidUsername: valid single char" {
    assertEqual(1, github::isValidUsername("a"))
}

"isValidUsername: valid 39 chars (max)" {
    assertEqual(1, github::isValidUsername("a23456789012345678901234567890123456789"))
}

"isValidUsername: invalid empty" {
    assertEqual(0, github::isValidUsername(""))
}

"isValidUsername: invalid 40 chars (too long)" {
    assertEqual(0, github::isValidUsername("a234567890123456789012345678901234567890"))
}

"isValidUsername: invalid starts with hyphen" {
    assertEqual(0, github::isValidUsername("-invalid"))
}

"isValidUsername: invalid ends with hyphen" {
    assertEqual(0, github::isValidUsername("invalid-"))
}

"isValidUsername: invalid consecutive hyphens" {
    assertEqual(0, github::isValidUsername("in--valid"))
}

"isValidUsername: invalid special chars" {
    assertEqual(0, github::isValidUsername("user@name"))
}

"isValidUsername: invalid underscore" {
    assertEqual(0, github::isValidUsername("user_name"))
}

"isValidUsername: invalid dot" {
    assertEqual(0, github::isValidUsername("user.name"))
}
