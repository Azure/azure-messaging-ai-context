---
name: ctest-guidelines
description: Review rules for C tests written with ctest, c-testrunnerswitcher and umock-c in the Azure Messaging C repositories (TEST_FUNCTION, PARAMETERIZED_TEST_FUNCTION, Tests_SRS tags). Loaded by Agency Review as a guideline source.
---

# ctest test guidelines

Rules for unit and integration tests in the Azure Messaging C repositories
(c-pal, c-util, ELS, EBS, zrpc and the other repos built on ctest). The rules
are in `reference/*.guidelines.md`; this file gives reviewers the context they
need to apply them.

## Test framework

Tests use the c-testrunnerswitcher macros, which map to ctest:
`TEST_FUNCTION` is `CTEST_FUNCTION`, and `PARAMETERIZED_TEST_FUNCTION` is
`CTEST_PARAMETERIZED_TEST_FUNCTION`. Mocks use umock-c
(`STRICT_EXPECTED_CALL`, `umock_c_get_expected_calls` and so on).

`PARAMETERIZED_TEST_FUNCTION` defines one test body and instantiates it once
per `CASE`:

```c
PARAMETERIZED_TEST_FUNCTION(base_name,
    ARGS(type1, param1, type2, param2),
    CASE((value1, value2), suffix1),
    CASE((value3, value4), suffix2))
{
    // test body using param1 and param2
}
```

Each `CASE` becomes its own test named `base_name_suffix`, so cases still
pass, fail and filter individually. `ARGS` can't vary a parameter's type.

## Repository conventions the rules rely on

Repo validation requires `// arrange`, `// act` and `// assert` comments in
every test body.

Tests carry the requirements they cover as `Tests_SRS_<MODULE>_<NN>_<NNN>`
comments immediately above the test. The traceability check
(`traceabilitytool -buildcheck`) matches them against the `Codes_SRS_...` tags
in the code and the requirements documents. `// no-srs` marks a test that
intentionally covers no requirement.
