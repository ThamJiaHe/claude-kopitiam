# Code Discipline

> This file extends CLAUDE.md. It does not replace any directive there.

## File Size Contracts

| File size | Required action |
|---|---|
| < 400 lines | Target. No action needed. |
| 400–800 lines | Add `# TODO: split by concern` at the top. Split at next opportunity. |
| > 800 lines | Split before merging the PR. No exceptions. |

**Exempt from these limits:** generated files, migrations, test fixtures, lock files, vendored code.

## Immutability Defaults

**TypeScript:** `const` over `let`. Never `var`. `readonly` on interfaces and class properties by default.

**Kotlin:** `val` over `var`. Use `data class` + `.copy()` for mutations.

**Python:** `dataclasses(frozen=True)` for value objects. `tuple` over `list` when contents are fixed after creation.

## Feature-Based Organisation

Split code by feature cohesion, not by technical type:

```
✓  src/features/auth/{model,service,viewmodel,test}
✗  src/models/   src/controllers/   src/services/
```

Exception: if the existing codebase uses type-based organisation, follow that pattern. Don't restructure unilaterally.

## Interface-First at Module Boundaries

- Export interfaces and types at module boundaries.
- Consumers depend on the interface, not the concrete implementation.
- Keep concrete implementations internal. They are swappable without breaking consumers.
- Three uses of a pattern justify an abstraction. Fewer than three: inline it.
