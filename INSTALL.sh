#!/usr/bin/env bash
# claude-kopitiam installer — macOS / Linux / Git Bash on Windows
# Usage: bash INSTALL.sh

set -euo pipefail

RULES_DIR="${HOME}/.claude/rules"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "claude-kopitiam installer"
echo "========================="
echo "Target: ${RULES_DIR}"
echo ""

# Create rules directory if missing
mkdir -p "${RULES_DIR}"

# Copy rules files
INSTALLED=0
SKIPPED=0

for src in "${REPO_DIR}/rules/"*.md; do
    filename="$(basename "${src}")"
    dest="${RULES_DIR}/${filename}"

    if [[ -f "${dest}" ]]; then
        echo "  [SKIP]  ${filename} (already exists — not overwritten)"
        SKIPPED=$((SKIPPED + 1))
    else
        cp "${src}" "${dest}"
        echo "  [OK]    ${filename}"
        INSTALLED=$((INSTALLED + 1))
    fi
done

echo ""
echo "Done. Installed: ${INSTALLED}  Skipped: ${SKIPPED}"
echo ""

# Plugin health check
echo "Checking plugin settings..."
SETTINGS="${HOME}/.claude/settings.json"

if [[ ! -f "${SETTINGS}" ]]; then
    echo "  [WARN] settings.json not found at ${SETTINGS}"
    echo "         Start Claude Code once to generate it, then re-run this script."
    exit 0
fi

# Check for known-bad plugin states using Python
python3 - <<'PYEOF'
import json, os, sys

settings_path = os.path.expanduser("~/.claude/settings.json")
try:
    settings = json.load(open(settings_path))
except Exception as e:
    print(f"  [WARN] Could not read settings.json: {e}")
    sys.exit(0)

enabled = settings.get("enabledPlugins", {})

issues = []

# semgrep: exits 127 if semgrep binary not installed
if enabled.get("semgrep@claude-plugins-official", False):
    import shutil
    if not shutil.which("semgrep"):
        issues.append(("semgrep@claude-plugins-official", "semgrep binary not found — hook exits 127"))

# qodo-skills: v0.3.0 missing fetch-qodo-rules.py
if enabled.get("qodo-skills@claude-plugins-official", False):
    installed_path = os.path.expanduser("~/.claude/plugins/installed_plugins.json")
    try:
        installed = json.load(open(installed_path))
        for info in installed.get("plugins", {}).get("qodo-skills@claude-plugins-official", []):
            script = os.path.join(info.get("installPath", ""), "scripts", "fetch-qodo-rules.py")
            if not os.path.exists(script):
                issues.append(("qodo-skills@claude-plugins-official", "fetch-qodo-rules.py missing from installation"))
    except Exception:
        pass

# superpowers: duplicate registration
sp_mp = enabled.get("superpowers@superpowers-marketplace", False)
sp_off = enabled.get("superpowers@claude-plugins-official", False)
if sp_mp and sp_off:
    issues.append(("superpowers@claude-plugins-official", "duplicate — both marketplace and official enabled"))

if issues:
    print("\n  [WARN] Problematic plugins detected:")
    for plugin, reason in issues:
        print(f"    {plugin}: {reason}")
    print("\n  Recommended fix — add to ~/.claude/settings.json under 'enabledPlugins':")
    for plugin, _ in issues:
        print(f"    \"{plugin}\": false")
    print("")
else:
    print("  [OK]  No known hook failure patterns detected.")
PYEOF

echo ""
echo "Restart Claude Code for the rules to take effect."
