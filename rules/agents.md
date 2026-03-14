# Agent Delegation

> This file extends CLAUDE.md. It does not replace any directive there.

## Orchestration Phases

For any non-trivial feature (touches more than 1 file, or more than ~30 minutes of work):

1. RESEARCH  → superpowers:brainstorming
2. PLAN      → superpowers:writing-plans
3. IMPLEMENT → everything-claude-code:tdd-guide
4. REVIEW    → everything-claude-code:code-reviewer (invoke after every code change)
5. VERIFY    → everything-claude-code:build-error-resolver (only if build fails)

Never skip phases. Each phase produces a file that becomes the next phase's input.

## Trigger-to-Agent Map

| Trigger | Agent |
|---|---|
| Planning a new feature or system | superpowers:brainstorming → superpowers:writing-plans |
| Build fails or type errors appear | everything-claude-code:build-error-resolver |
| After writing or modifying any code | everything-claude-code:code-reviewer |
| Auth, sessions, tokens, crypto, user input to DB/shell | everything-claude-code:security-reviewer |
| SQL queries, schema changes, migrations | everything-claude-code:database-reviewer |
| Python code written or modified | everything-claude-code:python-reviewer |
| Go code written or modified | everything-claude-code:go-reviewer |
| Dead code, unused imports, bloated files | everything-claude-code:refactor-cleaner |
| E2E test creation or execution | everything-claude-code:e2e-runner |
| Complex bug with multiple hypotheses | superpowers:systematic-debugging |
| Documentation updates needed | everything-claude-code:doc-updater |

## Sub-Agent Model Routing

Applies ONLY to agents spawned via the Task tool. Does not affect the main session.

| Task type | Model |
|---|---|
| File search, grep, exploration, doc generation | haiku |
| Single-file edits, standard coding, PR descriptions | sonnet |
| Architecture decisions, security analysis, complex debugging | opus |

Upgrade a sub-agent to opus when:
- A first attempt at sonnet failed or produced poor output
- The task spans 5+ files
- The task involves architectural decisions or security-critical code

## Iterative Retrieval

Evaluate every sub-agent return before accepting it.
Ask a follow-up question if the summary is insufficient or ambiguous.
Maximum 3 retrieval cycles per sub-agent. If still unclear after 3, bring it back to the main session.
