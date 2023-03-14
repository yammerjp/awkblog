function assertEqual(expected, needle) {
  if (expected == needle) {
    printf(".")
  } else {
    printf("expected: %s, needle: %s\n", expected, needle)
    exit(1)
  }
}
