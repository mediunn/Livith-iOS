# Planning and work records

## When to plan
Write a plan when implementation needs prior judgment: open design choices affecting behavior/security/UX, contract or domain-model changes, or changes spanning responsibility boundaries. File count alone is not a trigger. Mechanical edits and a local bug/layout correction without open design choices can proceed without a plan.

Use `docs/plans/<issue>-<slug>.md` and [the plan template](../templates/plan.md). Confirm the issue from the current branch. Multiple plans for an issue are allowed. Track active plans in `docs/plans/README.md`.

## Authority and confirmation
- A plan's goals, invariants and scope are the current desired behavior for that work. The issue supplies background and summary. Without a plan, the issue's goal/scope/criteria are the task contract.
- Work items describe execution, not a second source of requirements. Current code proves existing implementation, not intended behavior.
- Ask before implementing unresolved user-owned architecture, public interface, data model, security or scope choices. A plan documenting an already agreed decision needs no additional approval.
- Update the plan before following an agreed change. Do not silently broaden scope.
- A plan does not override existing rules or ADRs. Report a conflict and obtain a separate decision to change the rule/ADR or grant a scoped exception, even if the plan was approved.
- Define expected verification signals and record actual outcomes using [testing.md](testing.md).

## Troubleshooting
Record failed attempts, corrective feedback and a changed approach when they affect the result or explain a reusable trap. Use `docs/troubleshooting/<issue>-<slug>.md` and [the troubleshooting template](../templates/troubleshooting.md). Capture symptom, cause, action and verification when the event occurs; do not expose sensitive values. Do not turn routine status messages into a log.

## Archive cycle
- If plans or troubleshooting documents were created for the work, archive them before PR. Simple work without either needs only its issue/PR record.
- Keep **one archive per GitHub issue** at `docs/archive/<issue>-<slug>.md`. Locate an existing archive for the issue before creating one; append later work under `추가 기록` rather than creating a second archive.
- Consolidate completed work for that issue across plans/troubleshooting. Do not delete another active plan merely because its issue number matches; keep active work and distinguish partial closure from issue completion.
- Preserve goals/scope, durable decisions, verification evidence, lessons, unresolved items and follow-ups. Use [the archive template](../templates/archive.md); do not copy long logs or duplicate what code already explains.
- After checking preservation, save the archive and delete only the consolidated source documents in the same commit. No separate archive/deletion approval is needed. Update the active-plan index.
- Promote a reusable lesson only when code cannot explain it and the existing rule does not already cover it. Rule changes require separate user confirmation; record unapproved proposals as follow-ups rather than applying them automatically.
- Update engineering notes/status only if there is new durable knowledge or changed verification status. No changes are required merely to fill a compounding checklist.
- Important lasting tradeoffs belong in an ADR under [adr.md](adr.md). Not every issue needs an ADR.
- Keep historical naming/language/layout unchanged unless a separate migration is authorized. Do not revive archived source plans for minor follow-ups; write a new plan only when planning criteria apply again.
- An explicit user instruction may defer an archive for a particular PR; record the reason and pending work. It is not a permanent exception.
