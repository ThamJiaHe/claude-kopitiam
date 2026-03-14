# Testing Discipline

> This file extends CLAUDE.md and defers to it for any TestSprite or testing-tool workflow.
> It does not replace any directive there.

## Coverage Floor

Minimum 80% coverage for non-trivial logic.

**Trivial (exempt from 80% floor):**
- Pure data mapping with no conditional logic
- Generated code
- Single-line wrappers
- Getters and setters with no side effects

**Non-trivial (must reach 80%):**
- Business logic
- State transitions
- Error paths and edge cases
- Algorithms
- Any code with branching

## TDD for New Features — Red → Green → Refactor

After the research and planning phases (see `agents.md`), apply TDD for every feature:

1. Write a failing test that describes the desired behaviour. Run it. Confirm it fails. **(Red)**
2. Write the minimum code to make the test pass. Run it. Confirm it passes. **(Green)**
3. Refactor with all tests still green. **(Refactor)**

Never write an implementation before a test exists for the happy path.
Never skip the "run and confirm it fails" step — a test that passes before the implementation is wrong.

## Test Type Hierarchy

Use the lowest-cost sufficient test:

| Type | When to use |
|---|---|
| unit | Pure functions, isolated logic, no I/O, no DB |
| integration | DB interactions, API calls, file system, message queues |
| E2E | Full user-facing flows — use `everything-claude-code:e2e-runner` |

## Integration Tests Over Mocks for I/O

Prefer hitting a real test database over mocking repositories or ORMs.
Mock at the outer boundary only: HTTP clients, third-party payment APIs, external services.
Never mock internal collaborators — that tests the mock, not the code.
