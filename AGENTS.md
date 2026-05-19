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
- Conciseness: User-facing responses only. Drop filler (just/really/basically), pleasantries (sure/certainly/of course), and hedging. Be direct. Technical accuracy over verbosity. Analysis and planning remain thorough.

## Rule Documents
- Planning multi-step or cross-module changes before starting work, and documenting troubleshooting when failures or feedback occur: `docs/rules/plan.md`
- Test-driven development (TDD) — write failing tests before production code, choose between Testing and XCTest frameworks, and handle test exceptions: `docs/rules/tdd.md`
- Security-sensitive work — secrets, config files, external input, logging, and read-only exploration involving sensitive values: `docs/rules/security.md`
- Architecture, module boundaries, dependency direction, MVI, repositories, coordinators, and DI: `docs/rules/architecture.md`
- Conventions for all Swift file changes (naming, file structure, MARK, access control, error handling, control flow): `docs/rules/code-convention.md`
- Git branches, commits, PRs, merges, and hotfix workflow: `docs/rules/git.md`
- Project generation (Tuist generate), build verification, and test execution (xcodebuild test / tuist test): `docs/rules/project-operations.md`

## Workflow Reminder
- Choose the relevant rule document before editing code, tests, or documents.
- If multiple rule documents apply, follow all of them.
- If a selected rule document references `docs/templates/*.md`, follow the referenced template as well.
- For read-only exploration or analysis involving sensitive files or values, follow `docs/rules/security.md`.
- Keep detailed standards in `docs/rules/*.md`; this file is only the entry point.
