# Verification policy

- Do not mandate TDD or test-first ordering. Choose verification for the behavior, failure risk and implementation, using [platform.md](platform.md) for tools.
- Before changing behavior, identify expected outcomes and relevant failure cases. A focused test, reproduction or manual scenario can establish the baseline.
- Domain rules, mappings, repository branches and state transitions often benefit from automated behavioral tests. Use TDD when helpful; do not add tests that only mirror implementation.
- For a bug, reproduce the symptom when feasible and verify the same condition after the fix. Explain if reproduction is unavailable.
- Use existing frameworks and conventions. A new dependency, module or production interface is a user-owned decision; do not introduce it solely for test convenience without agreement.
- UI appearance, gestures, browser/device integration and deployment need suitable visual/manual/environment checks; build success alone does not prove them.
- Pure documentation changes need link/path/example and policy consistency checks, not an unrelated app build. Changes to mechanical scripts need representative passing and failing cases.
- Run focused verification for affected behavior. Broaden only for new failures, changes or unresolved risk; avoid repeated unrelated full-suite runs.
- Record command/tool, expected signal and actual result. Distinguish passed, failed, not run and pending manual checks. Build success is not test execution success.
- Separate pre-existing failures from regressions in the diff; report them without unrelated fixes. Never claim unexecuted checks passed.
