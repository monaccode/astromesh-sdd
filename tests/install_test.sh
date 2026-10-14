#!/bin/sh
# Runs install.sh against throwaway dirs. Usage: sh tests/install_test.sh
set -eu
REPO=$(cd "$(dirname "$0")/.." && pwd)
SH=${SH:-sh}  # SH=dash to test another shell
fail() { echo "FAIL: $1"; exit 1; }
new() { d=$(mktemp -d); mkdir -p "$d/proj dir"; echo "$d"; }

# project_all
T=$(new); P="$T/proj dir"
$SH "$REPO/install.sh" --dir "$P" >/dev/null
[ -f "$P/.claude/skills/sdd-specify/SKILL.md" ] || fail project_all_claude
[ -f "$P/.agents/skills/sdd-verify/templates/verify.md" ] || fail project_all_agents
grep -q "astromesh-sdd:start" "$P/AGENTS.md" || fail project_all_agents_md
echo "ok project_all (path_with_spaces)"

# global
T=$(new)
HOME="$T" $SH "$REPO/install.sh" --global --target agents >/dev/null
[ -f "$T/.agents/skills/sdd/SKILL.md" ] || fail global
[ ! -e "$T/.claude" ] || fail global_only_target
echo "ok global"

# alias
T=$(new); P="$T/proj dir"
$SH "$REPO/install.sh" --dir "$P" --target kimi >/dev/null
[ -d "$P/.agents/skills/sdd-plan" ] || fail alias
echo "ok alias"

# dry_run changes nothing
T=$(new); P="$T/proj dir"
out=$($SH "$REPO/install.sh" --dir "$P" --dry-run)
[ -z "$(ls -A "$P")" ] || fail dry_run_wrote
echo "$out" | grep -q ".claude/skills/sdd" || fail dry_run_output
echo "ok dry_run"

# rerun_preserves_user_files
T=$(new); P="$T/proj dir"
printf '# My rules\n' > "$P/AGENTS.md"
$SH "$REPO/install.sh" --dir "$P" --init >/dev/null
printf 'language: es\n' > "$P/.sdd/config.yaml"
echo stale > "$P/.claude/skills/sdd/STALE"
$SH "$REPO/install.sh" --dir "$P" --init >/dev/null
grep -q "# My rules" "$P/AGENTS.md" || fail rerun_agents_md_user_part
[ "$(grep -c 'astromesh-sdd:start' "$P/AGENTS.md")" = 1 ] || fail rerun_block_duplicated
grep -q "language: es" "$P/.sdd/config.yaml" || fail rerun_sdd_overwritten
[ ! -e "$P/.claude/skills/sdd/STALE" ] || fail rerun_not_replaced
echo "ok rerun_preserves_user_files"

# link_warns
T=$(new); P="$T/proj dir"
err=$($SH "$REPO/install.sh" --dir "$P" --target claude --link 2>&1 >/dev/null)
[ -L "$P/.claude/skills/sdd" ] || fail link_not_symlink
echo "$err" | grep -qi "warning" || fail link_warns
echo "ok link_warns"

# bad_args
T=$(new)
set +e; $SH "$REPO/install.sh" --target nope --dir "$T" >/dev/null 2>&1; rc=$?; set -e
[ "$rc" = 2 ] || fail bad_args
echo "ok bad_args"

# template skill is never installed
T=$(new); P="$T/proj dir"
$SH "$REPO/install.sh" --dir "$P" --target claude >/dev/null
[ "$(find "$P/.claude/skills" -mindepth 1 -maxdepth 1 | wc -l | tr -d ' ')" = 7 ] || fail exactly_seven_skills
echo "ok exactly_seven_skills"

# broken_block_refused: start marker without end marker must not eat the user's file
T=$(new); P="$T/proj dir"
printf '# Mine\n<!-- astromesh-sdd:start -->\nkeep me\n' > "$P/AGENTS.md"
cp "$P/AGENTS.md" "$T/before"
set +e; $SH "$REPO/install.sh" --dir "$P" --target agents-md >/dev/null 2>&1; rc=$?; set -e
[ "$rc" != 0 ] || fail broken_block_exit_code
cmp -s "$P/AGENTS.md" "$T/before" || fail broken_block_modified
echo "ok broken_block_refused"

# crlf_block_replaced: a block saved with Windows line endings is still found and replaced
T=$(new); P="$T/proj dir"
printf '# Mine\r\n<!-- astromesh-sdd:start -->\r\nOLD BLOCK\r\n<!-- astromesh-sdd:end -->\r\nafter\r\n' > "$P/AGENTS.md"
$SH "$REPO/install.sh" --dir "$P" --target agents-md >/dev/null
grep -q "OLD BLOCK" "$P/AGENTS.md" && fail crlf_old_block_kept
[ "$(grep -c 'astromesh-sdd:start' "$P/AGENTS.md")" = 1 ] || fail crlf_block_duplicated
grep -q "after" "$P/AGENTS.md" || fail crlf_user_text_lost
echo "ok crlf_block_replaced"

# symlinked_agents_md: AGENTS.md -> CLAUDE.md stays a link and the target gets the block
T=$(new); P="$T/proj dir"
printf '# Claude rules\n' > "$P/CLAUDE.md"
ln -s CLAUDE.md "$P/AGENTS.md"
$SH "$REPO/install.sh" --dir "$P" --target agents-md >/dev/null
$SH "$REPO/install.sh" --dir "$P" --target agents-md >/dev/null
[ -L "$P/AGENTS.md" ] || fail symlink_replaced
[ "$(grep -c 'astromesh-sdd:start' "$P/CLAUDE.md")" = 1 ] || fail symlink_target_block
grep -q "# Claude rules" "$P/CLAUDE.md" || fail symlink_target_user_text
echo "ok symlinked_agents_md"
echo "ALL PASS"
