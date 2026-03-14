# Windows Plugin Hook Audit Guide

> Fixes for the three open Anthropic issues that have no published solution.

## Symptoms

At every Claude Code startup you see one or more of:

```
SessionStart:startup hook error
SessionStart:startup hook error
UserPromptSubmit hook error
PreToolUse hook error
```

These appear because one or more enabled plugins have startup hooks that fail on Windows.

---

## Root Causes

### Root Cause 1: Plugin not installed but still enabled

**Affected plugin:** `semgrep@claude-plugins-official`

The semgrep plugin registers two `SessionStart` hooks that run on every startup:
1. `semgrep mcp -k inject-secure-defaults` — exits 127 if `semgrep` is not installed
2. `check_version.sh` — exits 1 when semgrep is missing (intentional detection, wrong for startup)

**Fix:** Disable the plugin if semgrep is not installed:
```json
"semgrep@claude-plugins-official": false
```

Re-enable it after installing semgrep: `scoop install semgrep` or [semgrep.dev/docs/getting-started](https://semgrep.dev/docs/getting-started).

---

### Root Cause 2: Plugin with missing hook script

**Affected plugin:** `qodo-skills@claude-plugins-official`

Version 0.3.0 registers a `SessionStart` hook pointing to `scripts/fetch-qodo-rules.py` which
does not exist in the installed package. Exits with code 2 on every startup.

**Fix:**
```json
"qodo-skills@claude-plugins-official": false
```

---

### Root Cause 3: Duplicate plugin registration

**Affected plugin:** `superpowers`

If both `superpowers@superpowers-marketplace` and `superpowers@claude-plugins-official` are enabled,
both register identical `SessionStart` hooks. On a fresh startup event, both fire. On Windows, the
`${CLAUDE_PLUGIN_ROOT}/hooks/run-hook.cmd` path resolves differently depending on how the shell
expands the variable, leading to intermittent failures.

**Fix:** Keep only one — the marketplace version is always newer:
```json
"superpowers@claude-plugins-official": false
```

---

## Diagnostic Procedure

### Step 1: Enumerate all SessionStart hooks for enabled plugins

```python
import json, os

installed = json.load(open(os.path.expanduser("~/.claude/plugins/installed_plugins.json")))
settings = json.load(open(os.path.expanduser("~/.claude/settings.json")))
enabled = settings.get("enabledPlugins", {})

for plugin_key, info_list in installed.get("plugins", {}).items():
    if not enabled.get(plugin_key, False):
        continue
    for info in info_list:
        path = info.get("installPath", "").replace("\\", "/")
        hooks_file = path + "/hooks/hooks.json"
        if not os.path.exists(hooks_file):
            continue
        hooks_data = json.load(open(hooks_file))
        if "SessionStart" in hooks_data.get("hooks", {}):
            for group in hooks_data["hooks"]["SessionStart"]:
                matcher = group.get("matcher", "*")
                for h in group.get("hooks", []):
                    print(f"{plugin_key} | matcher={matcher} | {h.get('command','')}")
```

### Step 2: Test each hook command manually

For each command found, set `CLAUDE_PLUGIN_ROOT` to the plugin's Windows install path and run
the command directly. Any non-zero exit code will appear as "hook error" in Claude Code.

```bash
# Example: test semgrep hook
semgrep mcp -k inject-secure-defaults; echo "Exit: $?"

# Example: test a Python hook
PLUGIN_ROOT="/c/Users/$USER/.claude/plugins/cache/<plugin>/<version>"
echo '{"hook_event_name":"SessionStart","session_id":"test","type":"startup"}' | \
  python3 "${PLUGIN_ROOT}/hooks/somehook.py" 2>&1; echo "Exit: $?"
```

### Step 3: Extend to all hook types

Repeat for `UserPromptSubmit`, `PreToolUse`, `PostToolUse`, `Stop`, `SessionEnd` by changing
the `hook_event_name` in the test JSON and iterating the hooks for each type.

---

## The `async: true` Issue (Issue #351)

Some Claude Code plugin hooks are missing `async: true` in their `hooks.json` declaration. On
Windows, synchronous hooks that take >100ms to respond can cause the startup sequence to hang
indefinitely. This was reported in [Anthropic/claude-plugins-official#351](https://github.com/anthropics/claude-plugins-official/issues/351) and is currently open.

**Workaround:** Disable the slow hook (usually a network call on startup) until the plugin
maintainer adds `async: true`.

**Identifying the culprit:** If Claude Code hangs at startup but you see no error message,
check for any `SessionStart` hook that makes a network request (fetching rules, checking versions,
connecting to an MCP server).

---

## Settings Template

Add this to `~/.claude/settings.json` under `"enabledPlugins"` to apply all fixes at once:

```json
{
  "enabledPlugins": {
    "semgrep@claude-plugins-official": false,
    "qodo-skills@claude-plugins-official": false,
    "superpowers@claude-plugins-official": false
  }
}
```

---

## Why This Keeps Happening

Claude Code auto-updates plugins. After an update:
- `semgrep` may still be missing on the machine
- `qodo-skills` may still ship without the hook script
- Both `superpowers` versions may be re-enabled

Check hook health after every `claude update` or `claude plugin update`.

---

## Related Issues

- [anthropics/claude-code#18610](https://github.com/anthropics/claude-code/issues/18610) — `/bin/bash` cannot resolve Windows paths in any format
- [anthropics/claude-code#16116](https://github.com/anthropics/claude-code/issues/16116) — `${CLAUDE_PLUGIN_ROOT}` path expansion fails on Windows (closed as duplicate)
- [anthropics/claude-plugins-official#351](https://github.com/anthropics/claude-plugins-official/issues/351) — `async: true` missing from hooks causes startup hang (OPEN)
