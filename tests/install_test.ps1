# Runs install.ps1 against throwaway dirs. Usage: pwsh tests/install_test.ps1
$ErrorActionPreference = 'Stop'
$Repo = Split-Path -Parent $PSScriptRoot
$Installer = Join-Path $Repo 'install.ps1'

function New-Sandbox {
    $t = Join-Path ([IO.Path]::GetTempPath()) ([guid]::NewGuid())
    New-Item -ItemType Directory -Path (Join-Path $t 'proj dir') -Force | Out-Null
    return $t
}
function Assert($cond, $name) { if (-not $cond) { throw "FAIL: $name" } }

# project_all (path with spaces)
$T = New-Sandbox; $P = Join-Path $T 'proj dir'
& $Installer -Dir $P | Out-Null
Assert (Test-Path (Join-Path $P '.claude/skills/sdd-specify/SKILL.md')) 'project_all_claude'
Assert (Test-Path (Join-Path $P '.agents/skills/sdd-verify/templates/verify.md')) 'project_all_agents'
Assert ((Get-Content -Raw (Join-Path $P 'AGENTS.md')) -match 'astromesh-sdd:start') 'project_all_agents_md'
Write-Host 'ok project_all (path_with_spaces)'

# global
$T = New-Sandbox
$env:ASTROMESH_SDD_HOME = $T
& $Installer -Global -Target agents | Out-Null
Remove-Item Env:\ASTROMESH_SDD_HOME
Assert (Test-Path (Join-Path $T '.agents/skills/sdd/SKILL.md')) 'global'
Assert (-not (Test-Path (Join-Path $T '.claude'))) 'global_only_target'
Write-Host 'ok global'

# alias
$T = New-Sandbox; $P = Join-Path $T 'proj dir'
& $Installer -Dir $P -Target kimi | Out-Null
Assert (Test-Path (Join-Path $P '.agents/skills/sdd-plan')) 'alias'
Write-Host 'ok alias'

# dry_run changes nothing
$T = New-Sandbox; $P = Join-Path $T 'proj dir'
$out = & $Installer -Dir $P -DryRun | Out-String
Assert (@(Get-ChildItem -Force $P).Count -eq 0) 'dry_run_wrote'
Assert ($out -match '\.claude[\\/]skills[\\/]sdd') 'dry_run_output'
Write-Host 'ok dry_run'

# rerun_preserves_user_files
$T = New-Sandbox; $P = Join-Path $T 'proj dir'
Set-Content (Join-Path $P 'AGENTS.md') '# My rules'
& $Installer -Dir $P -Init | Out-Null
Set-Content (Join-Path $P '.sdd/config.yaml') 'language: es'
Set-Content (Join-Path $P '.claude/skills/sdd/STALE') 'stale'
& $Installer -Dir $P -Init | Out-Null
$agents = Get-Content -Raw (Join-Path $P 'AGENTS.md')
Assert ($agents -match '# My rules') 'rerun_agents_md_user_part'
Assert (([regex]::Matches($agents, 'astromesh-sdd:start')).Count -eq 1) 'rerun_block_duplicated'
Assert ((Get-Content -Raw (Join-Path $P '.sdd/config.yaml')) -match 'language: es') 'rerun_sdd_overwritten'
Assert (-not (Test-Path (Join-Path $P '.claude/skills/sdd/STALE'))) 'rerun_not_replaced'
Write-Host 'ok rerun_preserves_user_files'

# link_warns (symlinks need Developer Mode on Windows; checked on macOS/Linux)
if (-not $IsWindows) {
    $T = New-Sandbox; $P = Join-Path $T 'proj dir'
    $warn = & $Installer -Dir $P -Target claude -Link 3>&1 | Out-String
    Assert ((Get-Item (Join-Path $P '.claude/skills/sdd')).LinkType -eq 'SymbolicLink') 'link_not_symlink'
    Assert ($warn -match 'Link points at') 'link_warns'
    Write-Host 'ok link_warns'
}

# bad_args
$T = New-Sandbox
pwsh -NoProfile -File $Installer -Target nope -Dir $T *> $null
Assert ($LASTEXITCODE -eq 2) 'bad_args'
$global:LASTEXITCODE = 0
Write-Host 'ok bad_args'

# exactly seven skills
$T = New-Sandbox; $P = Join-Path $T 'proj dir'
& $Installer -Dir $P -Target claude | Out-Null
Assert (@(Get-ChildItem (Join-Path $P '.claude/skills')).Count -eq 7) 'exactly_seven_skills'
Write-Host 'ok exactly_seven_skills'

# broken_block_refused
$T = New-Sandbox; $P = Join-Path $T 'proj dir'; $f = Join-Path $P 'AGENTS.md'
Set-Content -LiteralPath $f "# Mine`n<!-- astromesh-sdd:start -->`nkeep me" -NoNewline
$before = Get-Content -Raw -LiteralPath $f
pwsh -NoProfile -File $Installer -Dir $P -Target agents-md *> $null
Assert ($LASTEXITCODE -ne 0) 'broken_block_exit_code'
$global:LASTEXITCODE = 0
Assert ((Get-Content -Raw -LiteralPath $f) -ceq $before) 'broken_block_modified'
Write-Host 'ok broken_block_refused'

# crlf_block_replaced
$T = New-Sandbox; $P = Join-Path $T 'proj dir'; $f = Join-Path $P 'AGENTS.md'
Set-Content -LiteralPath $f "# Mine`r`n<!-- astromesh-sdd:start -->`r`nOLD BLOCK`r`n<!-- astromesh-sdd:end -->`r`nafter`r`n" -NoNewline
& $Installer -Dir $P -Target agents-md | Out-Null
$text = Get-Content -Raw -LiteralPath $f
Assert ($text -notmatch 'OLD BLOCK') 'crlf_old_block_kept'
Assert (([regex]::Matches($text, 'astromesh-sdd:start')).Count -eq 1) 'crlf_block_duplicated'
Assert ($text -match 'after') 'crlf_user_text_lost'
Write-Host 'ok crlf_block_replaced'

# symlinked_agents_md (symlinks need Developer Mode on Windows)
if (-not $IsWindows) {
    $T = New-Sandbox; $P = Join-Path $T 'proj dir'
    Set-Content -LiteralPath (Join-Path $P 'CLAUDE.md') '# Claude rules'
    New-Item -ItemType SymbolicLink -Path (Join-Path $P 'AGENTS.md') -Target (Join-Path $P 'CLAUDE.md') | Out-Null
    & $Installer -Dir $P -Target agents-md | Out-Null
    & $Installer -Dir $P -Target agents-md | Out-Null
    Assert ((Get-Item -LiteralPath (Join-Path $P 'AGENTS.md')).LinkType -eq 'SymbolicLink') 'symlink_replaced'
    $c = Get-Content -Raw -LiteralPath (Join-Path $P 'CLAUDE.md')
    Assert (([regex]::Matches($c, 'astromesh-sdd:start')).Count -eq 1) 'symlink_target_block'
    Assert ($c -match '# Claude rules') 'symlink_target_user_text'
    Write-Host 'ok symlinked_agents_md'
}
Write-Host 'ALL PASS'
