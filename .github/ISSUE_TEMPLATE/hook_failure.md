---
name: Plugin Hook Failure
about: Report a plugin hook that causes errors at Claude Code startup or during a session
title: "[hook] <plugin-name>: <hook type> error on <OS>"
labels: hook-failure, windows
assignees: ''
---

## Hook Error Message

Paste the exact error from Claude Code (e.g. `SessionStart:startup hook error`):

```
[paste here]
```

## Plugin Details

- **Plugin name and key:** (e.g. `semgrep@claude-plugins-official`)
- **Plugin version:** (from `~/.claude/plugins/installed_plugins.json`)
- **Hook type:** (SessionStart / UserPromptSubmit / PreToolUse / PostToolUse / Stop / SessionEnd)
- **Exit code:** (run hook manually — see `docs/windows-hook-audit.md` for how)

## Environment

- **OS:** (Windows 11 / macOS / Linux)
- **Shell:** (Git Bash / PowerShell / bash / zsh)
- **Claude Code version:** (`claude --version`)

## Diagnostic Output

Run the diagnostic script from `docs/windows-hook-audit.md` Step 1 and paste the relevant line:

```
[paste here]
```

## Manual Hook Test

Run the failing hook command directly (Step 2 of the diagnostic) and paste the output:

```bash
# command you ran
# output + exit code
```

## Proposed Fix

If you know the fix (disable the plugin, add `async: true`, etc.), describe it here.

---

*The more detail here, the faster this lands in the troubleshooting docs.*
