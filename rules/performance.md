# Context & Model Management

> This file extends CLAUDE.md. It does not replace any directive there.

## Context Window Discipline

At 80% context used:
1. Finish the current thought — do not start anything new.
2. Run `/save-session` to persist state to a file.
3. Then `/clear` or `/compact` before starting the next major task.

Never begin a multi-file refactor or new feature in the last 20% of context.

Low-risk at any context level (proceed freely):
- Single-file edits
- Isolated utility creation
- Documentation updates
- Simple bug fixes in one place

## Sub-Agent Cost Routing

Sub-agents spawned via the Task tool only. The main session model is unchanged.

See `agents.md` for the full model routing table (haiku / sonnet / opus by task type).

Upgrade a sub-agent to opus when:
- A first attempt at sonnet failed or produced poor output
- The task spans 5+ files
- The task involves architectural decisions or security-critical code

## Session Persistence

Before compacting complex in-progress work, use the ECC session commands:
```
/save-session
```

At the start of a new session continuing the same problem:
```
/resume-session
```

Note: these are ECC slash commands, not Claude Code built-ins. Requires the
[everything-claude-code](https://github.com/affaan-m/everything-claude-code) plugin.

## Modular Codebase = Token Savings

Reading a 2000-line file costs approximately 4× the context of reading five 400-line files.
Keeping files focused is both a code quality discipline and a token efficiency strategy.
See `coding-style.md` for file size contracts.
