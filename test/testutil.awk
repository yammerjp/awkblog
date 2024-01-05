function assertEqual(expected, needle) {
  if (expected == needle) {
    printf(".")
  } else {
    printf("expected: %s\nactual:   %s\n", expected, needle)
    exitcode = 1
  }
}

END {
  exit exitcode
}
