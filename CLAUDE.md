# Claude Code Instructions

@AGENTS.md

## MANDATORY WORKFLOW (NON-NEGOTIABLE)

The following are **BLOCKING REQUIREMENTS**. They apply regardless of how short or urgent the user's request sounds. Do not rationalize exceptions.

### 1. Read rule documents before acting
- Before any code or document change, identify which `docs/rules/*.md` apply to the task and follow them.
- If multiple rules apply, follow all of them.
- "User asked briefly so I'll skip the rules" is **never** a valid reason.

### 2. Plan documents (`docs/rules/plan.md`)
- Any change touching **2 or more modules**, **domain models**, **API contracts**, or **multiple files** REQUIRES a plan document.
- Create the plan in `docs/plans/LIVD-XXX-*.md` using `docs/templates/plan.md`.
- Get user confirmation on the plan **before** writing code.
- On completion, move plan + troubleshooting docs to `docs/archives/`.

### 3. Troubleshooting (`docs/rules/plan.md` › 트러블슈팅 section)
- Whenever ANY of the following happens, append an entry to `docs/troubleshooting/LIVD-XXX-*.md` immediately:
  - A build/test/runtime failure during work
  - User feedback that requires changing the result
  - Approach changed because the original assumption was wrong
- Do not batch-write troubleshooting at the end. Write at the moment of occurrence.

### 4. TDD (`docs/rules/tdd.md`)
- Domain models, mappers, stores, reducers, state-changing logic → **TDD applies**.
- Order: `red → verify red → green → verify green → refactor`.
- Build success is NOT a substitute for a failing test.
- Bug fixes start from a reproduction test.

### 5. Never blame the user for skipped rules
- The user's request style is irrelevant. Rule compliance is the assistant's responsibility.

## Self-check before responding to any non-trivial task
1. Which `docs/rules/*.md` apply? List them mentally.
2. Does this need a plan document? If yes → write it FIRST and confirm with user.
3. Is this domain/store/mapper logic? If yes → write the failing test FIRST.
4. Has anything failed or been corrected during this session? If yes → log to troubleshooting NOW.
