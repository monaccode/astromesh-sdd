#Requires -Version 7.0
# astromesh-sdd installer for Windows, macOS and Linux (PowerShell 7+: run with pwsh). https://github.com/monaccode/astromesh-sdd
[CmdletBinding()]
param(
    [string]$Target = 'all',
    [switch]$Global,
    [string]$Dir = (Get-Location).Path,
    [switch]$Link,
    [switch]$DryRun,
    [switch]$Init
)
$ErrorActionPreference = 'Stop'
$Src = $PSScriptRoot
$Start = '<!-- astromesh-sdd:start -->'
$End = '<!-- astromesh-sdd:end -->'

$Usage = @'
Usage: install.ps1 [-Target T] [-Global] [-Dir PATH] [-Link] [-DryRun] [-Init]
  T: claude | agents | agents-md | all (default)
     codex | opencode | kimi | gemini | copilot  (aliases of agents)
'@

if ($Target -in 'codex', 'opencode', 'kimi', 'gemini', 'copilot') { $Target = 'agents' }
if ($Target -notin 'claude', 'agents', 'agents-md', 'all') {
    [Console]::Error.WriteLine("unknown target: $Target`n$Usage")
    exit 2
}

if ($Global) {
    $Base = if ($env:ASTROMESH_SDD_HOME) { $env:ASTROMESH_SDD_HOME }
            else { [Environment]::GetFolderPath('UserProfile') }
} else {
    $Base = $Dir
}

function Install-Skills([string]$Dest) {
    if ($DryRun) { Write-Output "would: create $Dest" }
    else { New-Item -ItemType Directory -Path $Dest -Force | Out-Null }
    foreach ($s in Get-ChildItem -Directory (Join-Path $Src 'skills')) {
        $to = Join-Path $Dest $s.Name
        if ($DryRun) { Write-Output "would: install $($s.Name) -> $to"; continue }
        if (Test-Path $to) { Remove-Item -Recurse -Force $to }
        if ($Link) {
            try { New-Item -ItemType SymbolicLink -Path $to -Target $s.FullName | Out-Null }
            catch { throw "could not create a symlink at $to; drop -Link or enable Developer Mode" }
        } else {
            Copy-Item -Recurse $s.FullName $to
        }
        Write-Output "installed $($s.Name) -> $to"
    }
}

function Update-AgentsMd {
    $f = Join-Path $Dir 'AGENTS.md'
    if ($DryRun) { Write-Output "would: update astromesh-sdd block in $f"; return }
    $block = "$Start`n" + (Get-Content -Raw (Join-Path $Src 'AGENTS.md')).TrimEnd() + "`n$End"
    $text = if (Test-Path $f) { Get-Content -Raw $f } else { '' }
    # markers may end with CR when the file was saved with Windows line endings
    $s = ([regex]::Matches($text, '(?m)^' + [regex]::Escape($Start) + '\r?$')).Count
    $e = ([regex]::Matches($text, '(?m)^' + [regex]::Escape($End) + '\r?$')).Count
    if ($s -eq 1 -and $e -eq 1) {
        $pattern = '(?ms)^' + [regex]::Escape($Start) + '\r?$.*?^' + [regex]::Escape($End) + '\r?$'
        # MatchEvaluator: the block is inserted literally, '$' in it is not a substitution
        $text = [regex]::Replace($text, $pattern, { param($m) $block })
        Set-Content -Path $f -Value $text -NoNewline
    } elseif ($s -eq 0 -and $e -eq 0) {
        $prefix = if (Test-Path $f) { "`n" } else { '' }
        Add-Content -Path $f -Value ($prefix + $block)
    } else {
        [Console]::Error.WriteLine("error: $f has a broken astromesh-sdd block (start/end markers found: $s $e).`n       Fix or remove the block by hand, then run the installer again.")
        exit 1
    }
    Write-Output "updated $f"
}

if ($Link) { Write-Warning "-Link points at $Src; moving or deleting that folder breaks the skills" }
if ($Target -in 'claude', 'all') { Install-Skills (Join-Path $Base '.claude/skills') }
if ($Target -in 'agents', 'all') { Install-Skills (Join-Path $Base '.agents/skills') }
if (($Target -in 'agents-md', 'all') -and -not $Global) { Update-AgentsMd }
if ($Init) {
    $sdd = Join-Path $Base '.sdd'
    if (Test-Path $sdd) { Write-Output "kept existing $sdd" }
    elseif ($DryRun) { Write-Output "would: create $sdd" }
    else { Copy-Item -Recurse (Join-Path $Src 'examples/.sdd') $sdd; Write-Output "created $sdd" }
}
