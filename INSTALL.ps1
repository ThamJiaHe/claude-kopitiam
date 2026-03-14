# claude-kopitiam installer — Windows PowerShell
# Usage: .\INSTALL.ps1
# Run from the repo root directory.

$ErrorActionPreference = "Stop"

$rulesDir = Join-Path $env:USERPROFILE ".claude\rules"
$repoDir  = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "claude-kopitiam installer"
Write-Host "========================="
Write-Host "Target: $rulesDir"
Write-Host ""

# Create rules directory if it doesn't exist
if (-not (Test-Path $rulesDir)) {
    New-Item -ItemType Directory -Path $rulesDir | Out-Null
}

# Copy rules files (no overwrite)
$installed = 0
$skipped   = 0

Get-ChildItem -Path "$repoDir\rules\*.md" | ForEach-Object {
    $dest = Join-Path $rulesDir $_.Name
    if (Test-Path $dest) {
        Write-Host "  [SKIP]  $($_.Name) (already exists — not overwritten)"
        $skipped++
    } else {
        Copy-Item $_.FullName -Destination $dest
        Write-Host "  [OK]    $($_.Name)"
        $installed++
    }
}

Write-Host ""
Write-Host "Done. Installed: $installed  Skipped: $skipped"
Write-Host ""

# Plugin health check
Write-Host "Checking plugin settings..."
$settingsPath = Join-Path $env:USERPROFILE ".claude\settings.json"

if (-not (Test-Path $settingsPath)) {
    Write-Host "  [WARN] settings.json not found at $settingsPath"
    Write-Host "         Start Claude Code once to generate it, then re-run this script."
    exit 0
}

$settings = Get-Content $settingsPath | ConvertFrom-Json
$enabled  = $settings.enabledPlugins

$issues = @()

# semgrep: exits 127 if binary not installed
if ($enabled.'semgrep@claude-plugins-official' -eq $true) {
    if (-not (Get-Command semgrep -ErrorAction SilentlyContinue)) {
        $issues += [PSCustomObject]@{ Plugin = "semgrep@claude-plugins-official"; Reason = "semgrep binary not found -- hook exits 127" }
    }
}

# qodo-skills: v0.3.0 missing fetch-qodo-rules.py
if ($enabled.'qodo-skills@claude-plugins-official' -eq $true) {
    $installedPath = Join-Path $env:USERPROFILE ".claude\plugins\installed_plugins.json"
    if (Test-Path $installedPath) {
        $installedPlugins = Get-Content $installedPath | ConvertFrom-Json
        $qodoInfos = $installedPlugins.plugins.'qodo-skills@claude-plugins-official'
        if ($qodoInfos) {
            foreach ($info in $qodoInfos) {
                $script = Join-Path $info.installPath "scripts\fetch-qodo-rules.py"
                if (-not (Test-Path $script)) {
                    $issues += [PSCustomObject]@{ Plugin = "qodo-skills@claude-plugins-official"; Reason = "fetch-qodo-rules.py missing from installation" }
                    break
                }
            }
        }
    }
}

# superpowers: duplicate registration
$spMp  = $enabled.'superpowers@superpowers-marketplace' -eq $true
$spOff = $enabled.'superpowers@claude-plugins-official' -eq $true
if ($spMp -and $spOff) {
    $issues += [PSCustomObject]@{ Plugin = "superpowers@claude-plugins-official"; Reason = "duplicate -- both marketplace and official are enabled" }
}

if ($issues.Count -gt 0) {
    Write-Host ""
    Write-Host "  [WARN] Problematic plugins detected:"
    foreach ($issue in $issues) {
        Write-Host "    $($issue.Plugin): $($issue.Reason)"
    }
    Write-Host ""
    Write-Host '  Recommended fix -- add to ~/.claude/settings.json under "enabledPlugins":'
    foreach ($issue in $issues) {
        Write-Host "    `"$($issue.Plugin)`": false"
    }
    Write-Host ""
} else {
    Write-Host "  [OK]  No known hook failure patterns detected."
}

Write-Host ""
Write-Host "Restart Claude Code for the rules to take effect."
