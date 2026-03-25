# claude-kopitiam ☕

> *Kopitiam* (kopi = coffee, tiam = shop in Hokkien) — the neighbourhood coffee shop where Singaporeans pull up a chair, share what they know, and leave a bit better informed. This is that, for Claude Code.

An **always-on intelligent workflow layer** for Claude Code. Seven rules files that make Claude behave like a disciplined senior engineer on every task — not just when you remember to ask.

---

## The Companion Knowledge Layer

These rules reference agents and skills documented in the **[Claude Prompt Engineering Guide](https://github.com/ThamJiaHe/claude-prompt-engineering-guide)** — the full reference for prompt patterns, MCP, Skills, Claude Code best practices, and the complete Claude 4.x ecosystem.

[![Claude Prompt Engineering Guide](https://img.shields.io/badge/Companion_Docs-Claude_Prompt_Engineering_Guide-E94560?style=for-the-badge&logo=github&logoColor=white)](https://github.com/ThamJiaHe/claude-prompt-engineering-guide)

Install kopitiam for the always-on behaviour layer. Read the guide for the deep knowledge behind it.

---

## The Problem

Most developers are using Claude Code at a fraction of its capability.

Not because the tools are missing. Because Claude has no standing context about *how you want it to behave*.

Plugins add tools you call explicitly. Slash commands (`/skills`) give on-demand encyclopedias. But neither fires automatically. You still have to know which agent to invoke, which skill to load, which pattern to follow. Most developers don't — so they get generic responses from a system capable of senior-engineer-level discipline.

**claude-kopitiam closes that gap.**

---

## How It Works in Practice

Seven markdown files live in `~/.claude/rules/`. Claude reads them before every single response. Not on-demand. Always-on.

| Scenario | Without kopitiam | With kopitiam |
|---|---|---|
| You write a Python function | Generic response | `router.md` triggers `python-reviewer` automatically |
| You start planning a feature | Claude dives into implementation | Routes to `brainstorming` → `writing-plans` first |
| You touch auth or tokens | No security context unless you ask | `security.md` is in context — guards fire by default |
| You write a commit message | Any format accepted | `git-workflow-extended.md` enforces conventional commits |
| You hit 85% context usage | Session degrades silently | `performance.md` triggers save + compact discipline |
| You pull a CLAUDE.md template update | Your personal rules get overwritten | Rules files are separate — survive every update |

**vs. Plugins:** Plugins add tools and hooks you invoke. Rules files shape behaviour you never have to ask for.

**vs. Skills.md `/slash` commands:** Skills are on-demand depth. Rules files are always-on defaults. Together they're complete coverage.

**vs. editing CLAUDE.md directly:** CLAUDE.md gets overwritten on every template merge. Rules files live separately and survive any update, forever.

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

The installers also check for known broken plugin states and tell you exactly what to fix before you encounter the errors.

---

## What's Inside

### `rules/` — The Seven Rules Files

Each file declares itself an *extension* of your existing `CLAUDE.md`, not a replacement. CLAUDE.md always wins on any conflict.

| File | What it does |
|---|---|
| `router.md` | **Two-tier dispatch table** — routes execution tasks to specialist agents (Tier 1), auto-loads domain knowledge for React, Postgres, LLM apps and more (Tier 2) |
| `agents.md` | 5-phase orchestration: Research → Plan → Implement → Review → Verify. Sub-agent model routing: haiku for exploration, sonnet for standard coding, opus for architecture |
| `security.md` | Always-on guards: blocks writes to SSH keys, AWS creds, GPG keys. Detects prompt injection patterns in tool results and web fetches |
| `testing-discipline.md` | 80% coverage floor, TDD Red→Green→Refactor discipline enforced before every commit, integration tests over mocks |
| `coding-style.md` | File size contracts (800-line hard limit), immutability defaults, feature-based organisation |
| `git-workflow-extended.md` | Conventional commits (`feat/fix/refactor/docs/test/chore/perf/ci`), git worktrees for parallel Claude sessions |
| `performance.md` | 80% context window discipline, ECC `/save-session` triggers, sub-agent cost routing |

### The Two-Tier Router

`router.md` gives Claude a fast-lookup dispatch table it consults before responding to any prompt.

**Tier 1 — Agent Dispatch** (execution tasks — Claude delegates the work):
```
Planning a new feature        → superpowers:brainstorming → superpowers:writing-plans
Code just written or changed  → everything-claude-code:code-reviewer
Build failing / type errors   → everything-claude-code:build-error-resolver
Auth / tokens / crypto        → everything-claude-code:security-reviewer
SQL / migrations / schema     → everything-claude-code:database-reviewer
Bug with multiple hypotheses  → superpowers:systematic-debugging
```

**Tier 2 — Skill Auto-Load** (knowledge enrichment — Claude pulls current patterns before answering):
```
React, Next.js, Tailwind      → frontend-mobile-development:nextjs-app-router-patterns
PostgreSQL, query optimisation → database-design:postgresql
LLM apps, RAG, embeddings     → llm-application-dev:rag-implementation
GitHub Actions, CI/CD         → cicd-automation:github-actions-templates
Security audit / threat model → security-scanning:stride-analysis-patterns
```

Unlike model-level routers (which proxy to different LLMs), this routes within a single Claude session — dispatching to specialist *agents and skills* inside Claude Code itself.

---

## How the Rules Layer Loads

```
Claude Code starts
       │
       ▼
~/.claude/CLAUDE.md          ← YOUR file, never modified
       │
       ▼
~/.claude/rules/*.md         ← kopitiam's 7 files auto-loaded here
  agents.md                    Each file opens with:
  security.md                  "> This file extends CLAUDE.md.
  performance.md                 It does not replace any directive there."
  coding-style.md
  testing-discipline.md
  git-workflow-extended.md
  router.md
       │
       ▼
.claude/CLAUDE.md            ← project-level rules (highest priority)
```

**Conflict resolution:** `Project CLAUDE.md > User CLAUDE.md > rules/*.md`

Rules files fill gaps. They never override.

---

## Windows Plugin Hook Fix

If you're on Windows, the installers also surface this: some enabled plugins fire broken startup hooks on every session.

**Symptoms:**
```
SessionStart:startup hook error
SessionStart:startup hook error
UserPromptSubmit hook error
```

**Quick fix** — in `~/.claude/settings.json`:
```json
"semgrep@claude-plugins-official": false,
"qodo-skills@claude-plugins-official": false,
"superpowers@claude-plugins-official": false
```

**Why this happens and the full diagnostic:** → [`docs/windows-hook-audit.md`](docs/windows-hook-audit.md)

This covers the three root causes behind open Anthropic issues [#18610](https://github.com/anthropics/claude-code/issues/18610), [#16116](https://github.com/anthropics/claude-code/issues/16116), and [#351](https://github.com/anthropics/claude-plugins-official/issues/351) — currently the only published diagnosis and fix.

---

## Requirements

- Claude Code v2.x
- For full agent/skill dispatch: [everything-claude-code](https://github.com/affaan-m/everything-claude-code) plugin + [superpowers](https://github.com/obra/superpowers) plugin
- Rules files work without any plugins — routing simply degrades gracefully if target agents/skills aren't installed
- For Windows hook diagnostics: Python 3.x

---

## docs/

- **[`architecture.md`](docs/architecture.md)** — Loading order, extension pattern, conflict resolution, graceful degradation table
- **[`windows-hook-audit.md`](docs/windows-hook-audit.md)** — Root cause analysis, diagnostic scripts, manual test procedure
- **[`plugin-troubleshooting.md`](docs/plugin-troubleshooting.md)** — Duplicate hooks, missing scripts, path resolution failures, async timing issues

---

## Contributing

Contributions welcome. See [CONTRIBUTING.md](CONTRIBUTING.md).

Good first contributions:
- New `rules/*.md` files for domains not covered (mobile, data engineering, Rust, Go)
- Hook failure reports and fixes for plugins not yet documented
- Installer improvements

Use the issue templates — there's a dedicated one for hook failures with a diagnostic checklist.

---

## Compatibility

Tested on:
- Windows 11 with Git Bash + Claude Code v2.1.76
- macOS (rules layer only — no Windows-specific issues apply)

---

## License

MIT — see [LICENSE](LICENSE).

---

*Built in Singapore. Kopi-O kosong, no sugar. Just clean config.*
