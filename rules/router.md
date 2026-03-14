# Auto-Router

> This file extends CLAUDE.md and agents.md. It does not replace any directive there.
> Read this before acting on any prompt. It is a fast-lookup dispatch table.

## How to Use This

Before responding to any prompt, scan the trigger column.
If a row matches, dispatch to that agent or invoke that skill first.
If multiple rows match, pick the most specific one.
If nothing matches, use normal Claude behavior — do not force a dispatch.

## Tier 1 — Agent Dispatch (execution tasks)

These are tasks where a specialist agent should do the work.

| If the prompt is about... | Dispatch to |
|---|---|
| Planning a new feature, system, or refactor | `superpowers:brainstorming` → `superpowers:writing-plans` |
| Implementing a planned feature | `superpowers:executing-plans` + `everything-claude-code:tdd-guide` |
| Code just written or changed | `everything-claude-code:code-reviewer` |
| Build failing or type errors showing | `everything-claude-code:build-error-resolver` |
| Auth, sessions, tokens, crypto, secrets | `everything-claude-code:security-reviewer` |
| SQL, migrations, schema changes | `everything-claude-code:database-reviewer` |
| Python code written or changed | `everything-claude-code:python-reviewer` |
| Go code written or changed | `everything-claude-code:go-reviewer` |
| Bug with multiple possible causes | `superpowers:systematic-debugging` |
| E2E tests needed or broken | `everything-claude-code:e2e-runner` |
| Dead code, unused imports, bloated files | `everything-claude-code:refactor-cleaner` |
| Documentation needs updating | `everything-claude-code:doc-updater` |
| Reviewing a pull request | `superpowers:requesting-code-review` |

## Tier 2 — Skill Auto-Load (knowledge enrichment)

These are knowledge domains where a skill should be loaded before answering.

| If the prompt touches... | Load skill |
|---|---|
| Django views, models, ORM, Celery | `everything-claude-code:django-patterns` |
| FastAPI, async Python, Pydantic | `python-development:async-python-patterns` |
| React, Next.js, Tailwind | `frontend-mobile-development:nextjs-app-router-patterns` |
| Kotlin, Compose, Android | `everything-claude-code:android-clean-architecture` |
| PostgreSQL, query optimisation | `database-design:postgresql` |
| Docker, containers, compose | `everything-claude-code:docker-patterns` |
| GitHub Actions, CI/CD | `cicd-automation:github-actions-templates` |
| Terraform, IaC | `cloud-infrastructure:terraform-module-library` |
| LLM apps, RAG, embeddings, agents | `llm-application-dev:rag-implementation` |
| Security audit or threat model | `security-scanning:stride-analysis-patterns` |
| API design (REST or GraphQL) | `everything-claude-code:api-design` |
| Testing patterns or coverage | `everything-claude-code:python-testing` or `javascript-typescript:javascript-testing-patterns` |

## Fallback Rules

1. If no row matches and the task is non-trivial (>1 file, >30 min), run the 5-phase orchestration from `agents.md`.
2. If a sub-agent returns poor output, escalate model to opus (see `agents.md`).
3. If unsure whether to dispatch, dispatch — it costs less than a wrong answer.

## Scope Reminder

Agents run via the Agent tool. Skills run via the Skill tool.
Never invoke an agent or skill that is already running in the current context.
