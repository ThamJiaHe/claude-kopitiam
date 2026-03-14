# claude-kopitiam ☕

> *Kopitiam* (kopi = coffee, tiam = shop in Hokkien) — the neighbourhood coffee shop where Singaporeans gather, share knowledge, and get things done. This is that, for Claude Code.

A **non-destructive global rules layer** for Claude Code — 7 plug-in-ready `~/.claude/rules/*.md` files that extend your existing `CLAUDE.md` without touching it, plus **the only published fix for Windows plugin hook failures**.

---

## Why This Exists

| Problem | Status in the Ecosystem |
|---|---|
| Windows plugin startup hook errors (`${CLAUDE_PLUGIN_ROOT}` path failures, `semgrep` not found, duplicate hooks) | Open issues #351, #16116, #18610 — no published fix |
| Non-destructive rules extension (add rules without rewriting CLAUDE.md) | Documented mechanism, zero published implementations |
| Markdown-based two-tier agent/skill dispatch table | Model routers exist; agent/skill dispatch tables do not |

Claude Kopitiam fills all three gaps.

---

## Install in 30 Seconds

**macOS / Linux / Git Bash on Windows:**
```bash
git clone https://github.com/ThamJiaHe/claude-kopitiam
cd claude-kopitiam
bash INSTALL.sh
```

**Windows PowerShell:**
```powershell
git clone https://github.com/ThamJiaHe/claude-kopitiam
cd claude-kopitiam
.\INSTALL.ps1
```

That's it. Restart Claude Code. Your `CLAUDE.md` is untouched.

---

## What's Inside

### `rules/` — The Rules Layer

Seven files auto-loaded by Claude Code from `~/.claude/rules/`. Each declares itself as an extension of your existing `CLAUDE.md` — not a replacement.

| File | Purpose |
|---|---|
| `agents.md` | 5-phase orchestration (Research→Plan→Implement→Review→Verify), trigger-to-agent map, sub-agent model routing (haiku/sonnet/opus) |
| `security.md` | Sensitive path guard (SSH keys, AWS creds, GPG), prompt injection detection, secrets hygiene |
| `performance.md` | 80% context window discipline, session persistence with ECC `/save-session` |
| `coding-style.md` | File size contracts (800-line hard limit), immutability defaults, feature-based organisation |
| `testing-discipline.md` | 80% coverage floor, TDD Red→Green→Refactor discipline, integration tests over mocks |
| `git-workflow-extended.md` | Conventional commits (`feat/fix/refactor/docs/test/chore/perf/ci`), git worktrees for parallel sessions |
| `router.md` | **Two-tier dispatch table**: Tier 1 routes to specialist agents, Tier 2 auto-loads domain skills |

### `docs/` — The Windows Fix (The Main Event)

- **[`windows-hook-audit.md`](docs/windows-hook-audit.md)** — Step-by-step audit to find and fix every broken plugin hook on Windows. Root cause analysis for the three open Anthropic issues.
- **[`architecture.md`](docs/architecture.md)** — How the rules layer works, loading order, design principles.
- **[`plugin-troubleshooting.md`](docs/plugin-troubleshooting.md)** — Duplicate hooks, missing scripts, path resolution failures.

---

## How the Rules Layer Works

```
Claude Code starts
       │
       ▼
~/.claude/CLAUDE.md          ← YOUR file, never modified
       │
       ▼
~/.claude/rules/*.md         ← kopitiam's 7 files auto-loaded here
  agents.md                  Each file opens with:
  security.md                "> This file extends CLAUDE.md.
  performance.md               It does not replace any directive there."
  coding-style.md
  testing-discipline.md
  git-workflow-extended.md
  router.md
       │
       ▼
.claude/CLAUDE.md            ← project-level rules (last, highest priority)
```

**Conflict resolution:** CLAUDE.md always wins. Rules files defer to it by design.

---

## The Two-Tier Router

`router.md` gives Claude a fast-lookup dispatch table to consult before responding to any prompt.

**Tier 1 — Agent Dispatch** (execution tasks):
```
Planning a new feature        → superpowers:brainstorming → superpowers:writing-plans
Code just written or changed  → everything-claude-code:code-reviewer
Build failing / type errors   → everything-claude-code:build-error-resolver
Auth / tokens / crypto        → everything-claude-code:security-reviewer
SQL / migrations / schema     → everything-claude-code:database-reviewer
...
```

**Tier 2 — Skill Auto-Load** (knowledge enrichment):
```
React, Next.js, Tailwind      → frontend-mobile-development:nextjs-app-router-patterns
PostgreSQL, query optimisation → database-design:postgresql
LLM apps, RAG, embeddings     → llm-application-dev:rag-implementation
...
```

Unlike model-level routers (which proxy to different LLMs), this routes to specialist *agents and skills* within Claude Code itself.

---

## Windows Plugin Hook Fix

**Symptoms:**
```
SessionStart:startup hook error
SessionStart:startup hook error
UserPromptSubmit hook error
```

**Root cause (short version):** Some enabled plugins have startup hooks that reference `semgrep` (not installed), missing Python scripts, or register the same hook twice via duplicate plugin entries across two marketplaces.

**Full diagnosis + fix:** → [`docs/windows-hook-audit.md`](docs/windows-hook-audit.md)

**Quick fix for the most common case:**

In `~/.claude/settings.json`, set these to `false`:
```json
"semgrep@claude-plugins-official": false,
"qodo-skills@claude-plugins-official": false,
"superpowers@claude-plugins-official": false
```

Restart Claude Code. The errors should be gone.

---

## Requirements

- Claude Code v2.x
- For full agent/skill dispatch: [everything-claude-code](https://github.com/affaan-m/everything-claude-code) plugin + [superpowers](https://github.com/obra/superpowers) plugin
- For Windows hook fixes: Git Bash (for `.sh` hooks), Python 3.x (for hookify hooks)

Rules files work without any plugins — the router.md simply won't dispatch if the target agents/skills aren't installed.

---

## Contributing

Contributions welcome. See [CONTRIBUTING.md](CONTRIBUTING.md).

**Good contributions:**
- New `rules/*.md` files for domains not covered (mobile, data engineering, etc.)
- Additional Windows/Linux hook fixes for other plugins
- Documentation improvements
- Install script improvements

**Opening an issue:** Use the templates — there's a dedicated one for hook failures with a diagnostic checklist.

---

## Compatibility

Tested on:
- Windows 11 with Git Bash + Claude Code v2.1.76
- macOS (rules layer only — no Windows-specific issues)

---

## License

MIT — see [LICENSE](LICENSE).

---

*Built in Singapore. Kopi-O kosong, no sugar. Just clean config.*
