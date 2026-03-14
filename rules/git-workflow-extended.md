# Git Workflow Extensions

> This file extends CLAUDE.md. It does not replace any directive there.
> CLAUDE.md rules still apply: no --no-verify, no force-push to main, no .env commits, use gh CLI.

## Conventional Commit Type Prefixes

Extends any existing "imperative mood" commit rule by adding type prefixes for machine-readable changelogs.

**Format:** `<type>(<optional scope>): <imperative verb> <description>`

| Type | When to use |
|---|---|
| `feat` | New user-facing feature |
| `fix` | Bug fix |
| `refactor` | Code change without new feature or bug fix |
| `docs` | Documentation only |
| `test` | Adding or updating tests |
| `chore` | Build, CI, tooling, dependency updates |
| `perf` | Performance improvement |
| `ci` | CI/CD pipeline changes only |

**Examples:**
```
feat(auth): add JWT refresh token rotation
fix(api): handle null response from payment gateway
test(cart): add integration tests for checkout flow
refactor(user): extract email validation to shared util
chore: upgrade pnpm to 9.x
```

**Breaking changes:** append `!` after type — `feat!:` or `fix!:`

Note: branch names use `feature/`, `fix/`, `chore/` prefixes. Commit type prefixes
(`feat`, `fix`, `refactor`, etc.) are separate — they apply to commit messages, not branch names.

## Git Worktrees for Parallel Claude Instances

When running two or more Claude Code sessions on the same repository simultaneously:

```bash
# Create isolated worktrees per feature
git worktree add ../project-feature-a feature/feature-a
git worktree add ../project-feature-b feature/feature-b

# Each worktree gets its own Claude instance — no file conflicts
cd ../project-feature-a && claude
```

Label each terminal window with the branch name so you know which Claude instance owns which branch.

**Merge discipline:** complete one worktree's branch fully (tests passing, lint clean, reviewed) before merging.
Never merge two worktree branches to main simultaneously.

## PR Scope Discipline

One PR = one logical change.
If you discover an unrelated fix while implementing a feature, open a separate branch for it.
Mixed-concern PRs make `git bisect` and rollbacks painful.
