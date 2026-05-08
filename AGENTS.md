# Agent Instructions
- All user-facing responses must be written in Korean.

## Purpose
- Use this file as the entry point for project-specific guidance.
- Read the relevant rule documents before making changes.

## Core Rules
- These rules bias toward caution over speed; use judgment for trivial tasks.
- Think Before Coding: For non-trivial work, state assumptions, known ambiguities, tradeoffs, and verification criteria before implementing.
- Simplicity First: Prefer the smallest implementation that satisfies the current requirement; do not add speculative abstraction, configuration, or features.
- Surgical Changes: Every changed line should trace directly to the request; match the surrounding style and clean up only artifacts introduced by the current change.
- Goal-Driven Execution: For bug fixes and behavior changes, define or reproduce the expected behavior first, then verify with focused tests or an equivalent check.

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
