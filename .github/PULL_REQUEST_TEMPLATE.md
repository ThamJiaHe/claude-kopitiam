## What does this PR do?

One paragraph. Lead with the change, not the motivation.

## Type of change

- [ ] New rules file
- [ ] Update to existing rules file
- [ ] New/updated hook fix in `docs/windows-hook-audit.md`
- [ ] Installer improvement (`INSTALL.sh` / `INSTALL.ps1`)
- [ ] Documentation
- [ ] Other: ___

## Testing

For rules changes:
- [ ] Installed the updated file to `~/.claude/rules/` locally
- [ ] Started a Claude Code session and confirmed the rule is active
- [ ] Confirmed it does not conflict with CLAUDE.md directives

For hook fixes:
- [ ] Ran the diagnostic script from `docs/windows-hook-audit.md`
- [ ] Tested the fix on the affected plugin manually
- [ ] Confirmed clean startup with no hook errors

## Rules file checklist (if applicable)

- [ ] Opens with `> This file extends CLAUDE.md. It does not replace any directive there.`
- [ ] Under 200 lines
- [ ] Covers a single concern
- [ ] No absolute paths
- [ ] Cross-references other files by name only

## Commit format

- [ ] Follows `<type>(<scope>): <verb> <description>` convention
- [ ] Under 72 characters
