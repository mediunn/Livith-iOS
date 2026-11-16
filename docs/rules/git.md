# Git workflow

## Scope
Common solo-maintainer workflow. Platform build and release details: [platform.md](platform.md).

## Start work
1. Inspect status and preserve unrelated edits. Fetch and inspect the latest `origin/develop` before branching; do not overwrite an existing feature branch or pull unrelated work into it.
2. Create a GitHub issue using `.github/ISSUE_TEMPLATE/issue-template.md`: problem, goal, scope, observable acceptance criteria. Bugs include reproduction, actual result and expected result.
3. Create a work branch from the reviewed `develop` commit before editing.
4. Apply [plan.md](plan.md); implement, verify, archive when required, then open a PR to `develop`.

A trivial edit changes no execution behavior: documentation typos, broken documentation links, comments, or whitespace. It may skip the issue, but still needs a work branch and PR. Line/file count alone does not qualify. Logic, constants, dependencies, API/auth/state, build/deployment settings and hotfixes are not trivial edits.

## Names
| Item | With issue | Trivial edit without issue |
|------|------------|----------------------------|
| Branch | `type/#123-description` | `docs/fix-readme-typo` |
| Commit | `[Type] #123 - 한국어 요약` | `[Docs] 문서 오타 수정` |
| PR title | `[Type] 한국어 요약` | `[Docs] 문서 오타 수정` |

- Branch types: `add`, `feat`, `fix`, `refactor`, `style`, `setting`, `hotfix`, `chore`, `docs`, `test`; lowercase English slug with hyphens.
- Commit/PR types: `Add`, `Feat`, `Fix`, `Refactor`, `Style`, `Setting`, `Hotfix`, `Merge`, `Chore`, `Docs`, `Test`. Choose the type matching the change.
- Commit summaries are concise Korean, one line, normally within 50 characters, without a final period. One logical change per commit. No tool ads or `Co-Authored-By` trailer.
- Link the local issue in the PR body with `Resolved: #123`; use a full URL for another repository. Use `Refs:` when not closing an issue. Omit issue-closing text for issue-free work.

## Permissions
- Agents may create local commits within the authorized work after inspecting the diff and performing relevant verification.
- Push requires explicit user instruction, including the intended branch/scope. Commit permission does not authorize push, merge or deployment.
- History rewriting (amend, rebase of published history, force push) requires explicit instruction. Never force push shared branches.
- Do not implement or push directly on `develop` or `main`; the explicitly instructed emergency exception below is separate.

## PR and merge
- Use `.github/PULL_REQUEST_TEMPLATE.md`: connected issue, problem and resulting behavior, key changes and decision reasons, actual verification evidence.
- For many or complex acceptance criteria, add an optional criteria-to-evidence table based on the current plan (or issue if no plan). Do not duplicate checklists for routine work.
- Verify against the latest agreed goal/scope and criteria. A completed sub-plan does not by itself complete an issue. Report failures, skipped checks and pending manual confirmation separately; do not call them success.
- Update the PR description after follow-up changes. Describe the final implementation, not a file inventory or work diary.
- UI appearance changes include after screenshots and before screenshots when comparison is needed. Gesture, scroll, keyboard or animation changes include video/GIF and device/environment details.
- Use a focused Mermaid diagram when cross-environment flow, failure/retry paths or state transitions are needed to review the change. Skip diagrams for trivial edits.
- Complete the required archive cycle in [plan.md](plan.md) before opening a PR.
- Ordinary work uses a **merge commit**, preserving work commits; do not squash or rebase-merge ordinary PRs. The solo maintainer needs no external reviewer approval. Merge/deploy still require user authorization.
- Delete the remote work branch after an authorized successful merge. Follow platform-specific release branch lifetime rules.

## Hotfix
- Branch from the actual deployed revision, not automatically from the latest `develop`.
- Default: dedicated hotfix branch → PR and relevant verification → authorized deployment → reflect the fix into `develop`.
- Only an explicit emergency instruction may allow direct editing/pushing on the deployment branch. This does not grant standing bypass permission and does not waive verification or `develop` reconciliation.
- Preserve an issue/incident record; do not use the trivial-edit exception for hotfixes. For an explicitly authorized emergency without an issue yet, record it afterward.
- A project without a production release does not need a store hotfix/release gate in daily work.
