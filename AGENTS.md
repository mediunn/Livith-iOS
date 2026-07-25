# Agent Instructions
- All user-facing responses must be written in Korean.

## Purpose
- Use this file as the entry point for project-specific guidance.
- Write this file in English only. Keep Korean normative detail in `docs/rules/*.md`.
- Read the relevant rule documents before making changes.
- The source of truth for whether to write a plan, and for archive/compounding, is `docs/rules/plan.md`.

## Hard Gates
- Before changing code or docs, read and follow the applicable `docs/rules/*.md` files.
- If `docs/rules/plan.md` requires a plan, write the plan and get user confirmation before changing code.
- For domain, Store, Mapper, and state-changing logic, follow red → green → refactor in `docs/rules/tdd.md`.
- On failure, user correction feedback, or a change of approach, append to `docs/troubleshooting/` immediately.
- Do not read the body of sensitive config files (`docs/rules/security.md`).
- When the user declares the feature complete, run the compounding gate in `docs/rules/plan.md`. Before opening a PR, also check that no matching-slug plan/troubleshooting files remain.

## Core Rules
- These rules bias toward caution over speed; use judgment for trivial tasks.
- Think Before Coding: For non-trivial work, state assumptions, known ambiguities, tradeoffs, and verification criteria before implementing.
- Simplicity First: Prefer the smallest implementation that satisfies the current requirement; do not add speculative abstraction, configuration, or features.
- Surgical Changes: Every changed line should trace directly to the request; match the surrounding style and clean up only artifacts introduced by the current change.
- Goal-Driven Execution: For bug fixes and behavior changes, define or reproduce the expected behavior first, then verify with focused tests or an equivalent check.
- Conciseness: User-facing responses only. Drop filler (just/really/basically), pleasantries (sure/certainly/of course), and hedging. Be direct. Technical accuracy over verbosity. Analysis and planning remain thorough.
- If goal, scope, or completion criteria are unclear, use `.agents/skills/deep-interview/SKILL.md`. Do not fill load-bearing decisions with a “reasonable default.”

## Rule Documents

| Work type | Required rules |
|-----------|----------------|
| Store / Mapper / domain / state logic | `tdd.md`, `architecture.md`, `code-convention.md` |
| Navigation / module boundaries / DI | `architecture.md` |
| Swift file shape · MARK · naming | `code-convention.md` |
| Commit / branch / PR | `git.md` |
| tuist / xcodebuild test | `project-operations.md` |
| xcconfig · tokens · push · deeplink | `security.md` |
| 2+ modules · API/domain contracts · open design choices | `plan.md` (+ rules above as applicable) |
| Feature complete · archive · lesson promotion | `plan.md`, `docs/templates/archive.md` |

- Planning multi-step or cross-module changes, troubleshooting, compounding archive: `docs/rules/plan.md`
- Test-driven development: `docs/rules/tdd.md`
- Security-sensitive work: `docs/rules/security.md`
- Architecture, module boundaries, MVI, repositories, DI: `docs/rules/architecture.md`
- Swift file conventions: `docs/rules/code-convention.md`
- Git branches, commits, PRs: `docs/rules/git.md`
- Tuist generate, build, test: `docs/rules/project-operations.md`

## Workflow Reminder
- Choose the relevant rule document before editing code, tests, or documents.
- If multiple rule documents apply, follow all of them.
- If a selected rule document references `docs/templates/*.md`, follow the referenced template as well.
- For read-only exploration or analysis involving sensitive files or values, follow `docs/rules/security.md`.
- Keep detailed standards in `docs/rules/*.md`; this file is only the entry point.
