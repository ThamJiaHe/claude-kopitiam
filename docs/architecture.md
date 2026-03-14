# Architecture: The Non-Destructive Rules Layer

## The Core Problem

Most Claude Code configuration guides tell you to edit `CLAUDE.md`. That works, but it has a cost:
every update from a template, every merge from a colleague's config, every upgrade requires you to
diff and re-merge your personal settings against the new content.

Claude Kopitiam takes a different approach.

---

## How Claude Code Loads Configuration

Claude Code loads configuration in a strict layered order:

```
1. ~/.claude/CLAUDE.md          (user scope — your personal config)
2. ~/.claude/rules/*.md         (user scope — automatically loaded alongside CLAUDE.md)
3. .claude/CLAUDE.md            (project scope — highest priority, wins all conflicts)
```

The `rules/` directory is loaded **automatically**. You do not reference it anywhere. Every `.md`
file in `~/.claude/rules/` becomes part of the active context on every session.

---

## The Extension Pattern

Every rules file in this repo opens with:

```markdown
> This file extends CLAUDE.md. It does not replace any directive there.
```

This isn't just documentation — it's an instruction to Claude. It means:

1. **CLAUDE.md wins.** If your CLAUDE.md says "never use TDD", and `testing-discipline.md` says
   "always apply TDD", Claude follows your CLAUDE.md.

2. **Rules files fill gaps.** If your CLAUDE.md doesn't address agent delegation, `agents.md`
   provides it. If your CLAUDE.md doesn't address commit message format, `git-workflow-extended.md`
   fills that gap.

3. **You never need to merge.** Update `testing-discipline.md` independently of your CLAUDE.md.
   Pull rule updates from this repo without touching your personal config.

---

## Conflict Resolution Priority

```
Project CLAUDE.md  >  User CLAUDE.md  >  rules/*.md files
```

Rules files are additive. They extend, not override.

---

## The Two-Tier Router

`router.md` is a lookup table that Claude consults before responding to any prompt. It has two tiers:

**Tier 1 — Agent Dispatch**
When a task matches a trigger pattern (e.g., "code just changed" → code-reviewer agent), Claude
dispatches to a specialist agent via the `Agent` tool before generating a response. The agent
does the work; Claude summarises and continues.

**Tier 2 — Skill Auto-Load**
When a domain matches (e.g., "React, Next.js, Tailwind" → nextjs-app-router-patterns skill),
Claude loads the relevant skill via the `Skill` tool before answering. The skill provides
current, opinionated patterns for that domain.

This is distinct from model-level routers (which proxy to different LLMs). The routing happens
within a single Claude session, dispatching to different specialists inside Claude Code.

---

## File Loading Order and Interactions

```
agents.md           ─┐
security.md          │
performance.md       ├── All loaded simultaneously into context
coding-style.md      │   Each reads others by name ("see agents.md")
testing-discipline.md│
git-workflow-extended│
router.md           ─┘
```

Cross-references between files work because all files are in context simultaneously.
`performance.md` says "see agents.md for model routing table" — that cross-reference resolves
because `agents.md` is also in context.

---

## What Happens Without the Recommended Plugins

The rules files are valid without any plugins installed. The behaviour degrades gracefully:

| Scenario | Behaviour |
|---|---|
| No plugins installed | Rules files load, Claude follows the written rules but has no `Agent` or `Skill` tools to use for dispatch |
| `everything-claude-code` only | Tier 1 agent dispatch works fully; Tier 2 skills partially (ECC provides many skills) |
| `superpowers` only | Brainstorming, writing-plans, systematic-debugging work; ECC-specific reviewers don't |
| Both plugins | Full two-tier routing operational |

---

## Adding Your Own Rules Files

Any `.md` file you add to `~/.claude/rules/` auto-loads. Convention:

1. Open with the extension preamble: `> This file extends CLAUDE.md. It does not replace any directive there.`
2. Keep it focused — one concern per file.
3. Keep it under 200 lines — context window efficiency.
4. Cross-reference other rules files by name, not by path.
