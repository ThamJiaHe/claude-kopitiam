# Contributing to claude-kopitiam

Terima kasih — thank you for helping keep this kopi hot.

---

## What Belongs Here

This repo has three contribution areas:

| Area | Examples |
|---|---|
| **Rules files** | New rule domains, improvements to existing rules |
| **Windows hook fixes** | New plugin failures discovered, fixes for known-broken hooks |
| **Docs** | Architecture explanations, troubleshooting guides |

**Out of scope:** Plugin code, Claude Code forks, anything that modifies `~/.claude/CLAUDE.md` directly.

---

## Rules File Standards

Every rules file must:

1. Open with the extension preamble:
   ```
   > This file extends CLAUDE.md. It does not replace any directive there.
   ```
2. Stay under 200 lines (context window budget).
3. Cover one concern per file. Security in `security.md`. Testing in `testing-discipline.md`.
4. Not reference absolute paths. Use `~/.claude/` or describe the concept.
5. Cross-reference other rules files by filename only (`see agents.md`).

---

## Reporting a Plugin Hook Failure

Use the **Hook Failure** issue template. Include:

- Plugin name and version (`~/.claude/plugins/installed_plugins.json`)
- Hook type that fails (`SessionStart`, `PreToolUse`, etc.)
- Exit code (from manual test — see `docs/windows-hook-audit.md`)
- OS and shell (Windows/WSL/macOS, bash version)
- Claude Code version (`claude --version`)

The more specific the report, the faster it lands in `docs/windows-hook-audit.md`.

---

## Pull Request Process

1. Fork and create a branch: `feature/my-rules-file`, `fix/plugin-name-hook`
2. Keep PRs focused — one logical change per PR (see `rules/git-workflow-extended.md`)
3. Test rules files by installing them to `~/.claude/rules/` and starting a Claude Code session
4. Test hook fixes with the diagnostic script in `docs/windows-hook-audit.md`
5. Update `docs/windows-hook-audit.md` if you've found a new plugin root cause

---

## Commit Format

Follow the same conventional commits format used in the rules:

```
feat(rules): add docker-patterns rules file
fix(hooks): disable qodo-skills when script missing
docs(troubleshooting): add async-hook hang diagnosis
```

Types: `feat`, `fix`, `docs`, `refactor`, `chore`

---

## Code of Conduct

Be direct and constructive. No sycophancy. If something is wrong, say so clearly with a fix or suggestion attached.

---

*Kopi diam diam, shiok sendiri.* (Good coffee speaks for itself.)
