# dsh-base: secret scanner (ASCII-only, works in Windows PowerShell 5.1+ and pwsh).
# Usage:  .\check-secrets.ps1 [-Path .]
# Exit 1 if secrets found (blocks push). Exit 0 if clean.

param(
    [string]$Path = (Split-Path -Parent $MyInvocation.MyCommand.Path)
)

$ErrorActionPreference = 'Stop'

# Secret patterns: API keys, tokens, passwords, private keys, connection strings.
$patterns = @(
    'sk-[A-Za-z0-9]{20,}',                    # OpenAI / DeepSeek style keys
    'sk-ant-[A-Za-z0-9\-_]{20,}',             # Anthropic API key
    'github_pat_[A-Za-z0-9_]{20,}',           # GitHub fine-grained PAT
    'ghp_[A-Za-z0-9]{20,}',                   # GitHub classic PAT
    'gho_[A-Za-z0-9]{20,}',                   # GitHub OAuth
    'ghu_[A-Za-z0-9]{20,}',                   # GitHub user-to-server
    'AKIA[0-9A-Z]{16}',                       # AWS access key
    'AIza[0-9A-Za-z\-_]{30,}',                # Google API key
    'xox[baprs]-[0-9A-Za-z\-]{10,}',          # Slack tokens
    'xoxe.xoxp-[0-9A-Za-z\-]{10,}',           # Slack legacy
    '-----BEGIN (RSA |EC |OPENSSH |PGP )?PRIVATE KEY-----',  # private keys
    'eyJ[A-Za-z0-9_\-]{10,}\.[A-Za-z0-9_\-]{10,}\.[A-Za-z0-9_\-]{10,}', # JWT
    'mongodb(\+srv)?://[^\s]{10,}',           # MongoDB URI
    'postgres(ql)?://[^\s]{10,}',             # Postgres URI
    'redis://[^\s]{10,}'                      # Redis URI
)

$files = Get-ChildItem -Path $Path -Recurse -File |
    Where-Object {
        $_.FullName -notmatch '\\\.git\\' -and
        $_.FullName -notmatch '\\node_modules\\' -and
        $_.Name -ne 'check-secrets.ps1' -and
        $_.Name -notmatch '^(package-lock|pnpm-lock|yarn.lock)\.json$'
    }

$found = @()
foreach ($f in $files) {
    $content = Get-Content -Path $f.FullName -Raw -ErrorAction SilentlyContinue
    if (-not $content) { continue }
    foreach ($p in $patterns) {
        if ($content -match $p) {
            $found += "$($f.FullName) : pattern $p"
            break
        }
    }
}

if ($found.Count -gt 0) {
    Write-Host "!!! SECRETS FOUND - PUSH BLOCKED !!!" -ForegroundColor Red
    $found | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
    Write-Host "Remove secrets from files and re-run." -ForegroundColor Red
    exit 1
}

Write-Host "OK: no secrets found ($($files.Count) files checked)" -ForegroundColor Green
exit 0
