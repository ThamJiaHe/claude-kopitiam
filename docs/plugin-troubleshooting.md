# Plugin Hook Troubleshooting

Common plugin issues beyond the Windows startup hook errors covered in
[`windows-hook-audit.md`](windows-hook-audit.md).

---

## Duplicate Hook Registration

**Symptom:** Same hook fires twice. Example: two identical `SessionStart` context injections in
every session, or a Stop hook running twice.

**Cause:** The same plugin is enabled from two different marketplaces simultaneously.

```json
"superpowers@superpowers-marketplace": true,
"superpowers@claude-plugins-official": true   ← duplicate
```

Both register the same hooks. Both fire on every event.

**Diagnosis:** Run the diagnostic script from `windows-hook-audit.md` and look for duplicate
commands across different plugin keys.

**Fix:** Disable the older marketplace entry. Prefer the source marketplace over
`claude-plugins-official` for plugins that exist in both — the source marketplace version
is always equal or newer.

---

## Hook Script Not Found

**Symptom:** `hook error` with exit code 2 or 127 on a specific hook type.

**Cause:** The plugin's `hooks.json` references a script that wasn't included in the installed version.

**Diagnosis:**
```python
import json, os
installed = json.load(open(os.path.expanduser("~/.claude/plugins/installed_plugins.json")))
# For the failing plugin, check the hooks.json commands against the filesystem
```

**Fix:** Disable the plugin. Report the missing script to the plugin maintainer as a bug.

---

## `${CLAUDE_PLUGIN_ROOT}` Path Resolution Failures

**Symptom:** Hook error with "No such file or directory" mentioning a Windows path.

**Cause:** On Windows, `CLAUDE_PLUGIN_ROOT` is set to a Windows-style path
(`C:\Users\...`). When hooks run through bash, the backslashes may be misinterpreted
as escape characters, yielding an invalid path.

**Affected pattern:** Hook commands of the form `"${CLAUDE_PLUGIN_ROOT}/script.sh"` where:
- No `bash` prefix is present, AND
- The script does NOT have a `.sh` extension (Claude Code auto-prepends `bash` for `.sh` files)

**Fix options:**
1. If the hook uses `.cmd` or `.ps1` — it should work correctly via Windows CMD
2. If the hook uses `.sh` — Claude Code auto-prepends `bash` on Windows, which converts the path
3. If neither — disable the plugin and report the issue to the maintainer

---

## Hook Timeout / Async Missing

**Symptom:** Claude Code hangs at startup with no error message. Terminal appears frozen.

**Cause:** A synchronous `SessionStart` hook is making a slow network request (fetching rules,
checking for updates, connecting to an MCP server) without `async: true` in its declaration.

**Diagnosis:**
```python
import json
hooks_file = "~/.claude/plugins/cache/<plugin>/<version>/hooks/hooks.json"
d = json.load(open(hooks_file))
for group in d.get("hooks", {}).get("SessionStart", []):
    for h in group.get("hooks", []):
        if not h.get("async", False):
            print(f"Sync hook: {h.get('command', '')}")
```

**Fix:** Disable the plugin or add `"async": true` to the hook entry in the cached `hooks.json`.
Note: the fix will be overwritten on next plugin update — re-apply after updates.

---

## Hook Fires on Wrong Events

**Symptom:** A hook that should only run on "startup" also runs on "compact" (or vice versa).

**Cause:** The hook's `matcher` field is `"*"` (matches all events) instead of a specific
event type like `"startup|resume"`.

**Context:** SessionStart fires with different `type` values:
- `startup` — fresh new session
- `resume` — session resumed
- `compact` — context compacted and session continuing
- `clear` — context cleared

If a hook does expensive work that only makes sense on startup (e.g., loading session state),
a `"*"` matcher causes it to run on every compact as well.

This is a plugin bug, not a user configuration issue. Report it to the maintainer.

---

## Checking Plugin Health After Updates

Claude Code auto-updates plugins. After any update, re-run the diagnostic:

```bash
# Quick check: count SessionStart hooks
python3 -c "
import json, os, glob
for f in glob.glob(os.path.expanduser('~/.claude/plugins/cache/**/hooks/hooks.json'), recursive=True):
    try:
        d = json.load(open(f))
        if 'SessionStart' in d.get('hooks', {}):
            print(f.replace(os.path.expanduser('~'), '~'))
    except: pass
"
```

Any new entries since your last check are candidates for testing.
