# Documentation roles and language

| Document | Role | Language |
|----------|------|----------|
| `AGENTS.md` | Single agent entry point and routing | English allowed |
| `docs/rules/`, action skills | How to work | English or Korean |
| Plans, troubleshooting, archives, ADRs | User-reviewed intent, evidence and decisions | Korean |
| Issues, PRs, commit summaries | User-reviewed work record | Korean |
| Templates | Produce the corresponding artifact | Korean headings/instructions for user-reviewed artifacts |

- Keep detailed policies in rule documents; entry points and skills link to them rather than redefining them.
- Preserve platform-specific implementation, build, deployment and security policies. Use [platform.md](platform.md) to route to them.
- Common policies: `git.md`, `plan.md`, `testing.md`, `documentation.md`, `adr.md`. Keep the same paths and policy meaning in Web/iOS/Android. When changing one, inspect the other repositories and record which need the corresponding update; do not silently edit outside the authorized scope.
- Each repository is self-contained; there is no external common runtime, mandatory central checkout or automatic synchronization.
- Preserve old artifacts and ADRs in their original language. New records and material additions meant for user review are Korean; identifiers, commands, paths and quotations retain their original spelling.
- Define trigger, required action and exceptions explicitly. Examples are not extra mandatory steps.
- Read the relevant rule/template before editing. Inspect local links, examples and affected mechanical checks after changes.
