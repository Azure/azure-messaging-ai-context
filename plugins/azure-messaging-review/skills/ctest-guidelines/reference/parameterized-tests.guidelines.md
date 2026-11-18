---
name: ctest-parameterized-tests
description: Replace repeated, near-identical ctest TEST_FUNCTIONs with one PARAMETERIZED_TEST_FUNCTION, and keep their Tests_SRS tags when converting.
applyTo:
  - "**/tests/**/*.c"
  - "**/tests/**/*.cpp"
---

# Parameterized ctest tests

These rules apply only to tests the pull request adds or changes. Don't flag
existing tests the pull request doesn't touch. When you report a finding, show
the refactored test written from the actual code in the pull request.

---
# CTEST-PARAM-001
- Title: Replace single-call wrapper TEST_FUNCTIONs with one PARAMETERIZED_TEST_FUNCTION
- Category: Maintainability
- Risk: Medium
- State: Enabled

  Flag two or more `TEST_FUNCTION`s whose whole body is one call to the same
  static helper function with different arguments. The wrappers duplicate
  scaffolding, every new case needs another wrapper, and the helper hides which
  values each test exercises.

  A `TEST_FUNCTION` with no `// arrange`, `// act` or `// assert` comments is
  almost always such a wrapper: repo validation requires those comments in every
  real test body.

  Don't flag wrappers that vary a parameter's type, because `ARGS` can't vary
  types, or invalid-argument tests where each wrapper changes *which* argument
  is invalid (for example `*_fails_when_<param>_is_NULL` for different
  parameters): parameterizing those needs a `switch` on the argument, which
  reads worse than separate tests.

  Fix: the helper's body becomes the body of one `PARAMETERIZED_TEST_FUNCTION`,
  each wrapper becomes a `CASE`, and the helper is deleted. The body must be the
  inlined helper code, not a call to the helper.

  ```c
  // Before: one helper and one wrapper per case
  static void test_send_complete(SEND_RESULT send_result, IO_SEND_RESULT io_result)
  {
      // arrange / act / assert ...
  }

  TEST_FUNCTION(send_complete_with_OK_calls_callback_with_OK)
  {
      test_send_complete(SEND_OK, IO_SEND_OK);
  }

  TEST_FUNCTION(send_complete_with_ERROR_calls_callback_with_ERROR)
  {
      test_send_complete(SEND_ERROR, IO_SEND_ERROR);
  }

  // After
  PARAMETERIZED_TEST_FUNCTION(send_complete_calls_callback,
      ARGS(SEND_RESULT, send_result, IO_SEND_RESULT, io_result),
      CASE((SEND_OK, IO_SEND_OK), with_OK),
      CASE((SEND_ERROR, IO_SEND_ERROR), with_ERROR))
  {
      // arrange / act / assert: the former helper body
  }
  ```

---
# CTEST-PARAM-002
- Title: Parameterize TEST_FUNCTIONs whose bodies differ only in literal values
- Category: Maintainability
- Risk: Medium
- State: Enabled

  Flag 3 or more `TEST_FUNCTION`s (or 2 with structurally identical bodies)
  whose bodies are identical except for literal values, such as enum values,
  sizes or expected results. They are often named in a pattern like
  `<test>_with_A`, `<test>_with_B`. Copies of the same body drift apart when one
  of them is fixed or extended and the others are not.

  Don't flag tests whose bodies differ in control flow, mock setup (the
  `STRICT_EXPECTED_CALL` sequence) or error handling, even if their names are
  similar, or tests that vary a parameter's type, because `ARGS` can't vary
  types.

  Fix: one `PARAMETERIZED_TEST_FUNCTION` whose `ARGS` are the values that vary,
  with one `CASE` per former test.

---
# CTEST-PARAM-003
- Title: Keep the Tests_SRS tags when converting tests to PARAMETERIZED_TEST_FUNCTION
- Category: Traceability
- Risk: High
- State: Enabled

  When the pull request replaces `TEST_FUNCTION`s with a
  `PARAMETERIZED_TEST_FUNCTION`, every `Tests_SRS_*` tag that was above the
  replaced tests must be kept, deduplicated, as comments immediately above the
  `PARAMETERIZED_TEST_FUNCTION`.

  Flag any tag that was dropped, left behind where the old tests were, or
  repeated, and any converted test marked `// no-srs` when the replaced tests
  had tags. A dropped tag leaves its requirement without a test, which the
  traceability check reports as untested.

  ```c
  /* Tests_SRS_FOO_42_042: [ If result is ERROR, the callback shall be called with ERROR. ] */
  /* Tests_SRS_FOO_42_043: [ If result is OK, the callback shall be called with OK. ] */
  PARAMETERIZED_TEST_FUNCTION(on_complete_calls_callback,
      ARGS(SOME_RESULT, result, EXPECTED_RESULT, expected),
      CASE((ERROR, EXPECTED_ERROR), with_ERROR),
      CASE((OK, EXPECTED_OK), with_OK))
  {
      // arrange / act / assert
  }
  ```
