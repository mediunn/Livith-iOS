# Agent Instructions
- All user-facing responses must be written in Korean.

## Purpose
- Use this file as the entry point for project-specific guidance.
- Read the relevant rule documents before making changes.

## Rule Documents
- Planning multi-step work and troubleshooting records: `docs/rules/plan.md`
- Tests and behavior changes: `docs/rules/tdd.md`
- Security-sensitive work, secrets, config, external input, and logging: `docs/rules/security.md`
- Architecture, module boundaries, dependency direction, MVI, repositories, coordinators, and DI: `docs/rules/architecture.md`
- Swift file edits, file structure, `MARK` sections, access control, `typed throws`, and control flow: `docs/rules/code-convention.md`
- Git branches, commits, PRs, merges, and release flow: `docs/rules/git.md`

## Workflow Reminder
- Choose the relevant rule document before editing code, tests, or documents.
- If multiple rule documents apply, follow all of them.
- If a selected rule document references `docs/templates/*.md`, follow the referenced template as well.
- For read-only exploration or analysis involving sensitive files or values, follow `docs/rules/security.md`.
- Keep detailed standards in `docs/rules/*.md`; this file is only the entry point.
