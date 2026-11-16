# Agent Instructions

Respond to the user in Korean. Think and investigate thoroughly; keep reports concise.
This is the single agent entry point. Read the linked rules for the work; do not redefine them in tool-specific instruction files.

## Routing
| Work | Rules |
|------|-------|
| Issue, branch, commit, PR, hotfix | [Git workflow](docs/rules/git.md) |
| Plan, unresolved choices, troubleshooting, archive | [Work records](docs/rules/plan.md) |
| Verification and test selection | [Verification](docs/rules/testing.md) |
| Documents, templates, cross-repository policy | [Documentation](docs/rules/documentation.md) |
| Lasting decisions and ADR conflicts | [ADRs](docs/rules/adr.md), [ADR index](docs/adr/README.md) |
| Implementation, security, build, platform/release details | [Platform guidance](docs/rules/platform.md) |

## Working principles
- The user owns architecture, public interfaces, data models and security decisions. Ask only for unresolved significant choices; an agreed plan does not need repeated approval.
- Inspect relevant code/rules first. Preserve unrelated edits and existing behavior. Make the smallest change that satisfies the request; no speculative dependencies or abstraction.
- Treat current code as implementation evidence, not desired-behavior authority. Report rule/ADR conflicts separately before proceeding.
- Follow the verification policy; do not mandate TDD. Report actual results, failures and unverified items accurately.
- Local commits are allowed within the authorized task. Push requires explicit instruction; merge, deployment and history rewriting are separate permissions.
- Keep user-reviewed artifacts in Korean. Common rules use the same paths in all three repositories; inspect propagation needs when changing shared policy.
