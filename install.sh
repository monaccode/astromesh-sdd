#!/bin/sh
# astromesh-sdd installer. https://github.com/monaccode/astromesh-sdd
set -eu
SRC=$(cd "$(dirname "$0")" && pwd)
TARGET=all SCOPE=project DIR=$PWD LINK=0 DRY=0 INIT=0
START='<!-- astromesh-sdd:start -->' END='<!-- astromesh-sdd:end -->'

usage() {
  cat <<'USAGE'
Usage: install.sh [--target T] [--project|--global] [--dir PATH] [--link] [--dry-run] [--init]
  T: claude | agents | agents-md | all (default)
     codex | opencode | kimi | gemini | copilot  (aliases of agents)
  --project   install into the project at --dir (default: current directory)
  --global    install into your home directory, for every project
  --link      symlink to this clone instead of copying (updates with git pull)
  --dry-run   print what would change, change nothing
  --init      also create an example .sdd/ settings folder (never overwrites)
USAGE
}

while [ $# -gt 0 ]; do
  case $1 in
    --target) TARGET=${2:?--target needs a value}; shift ;;
    --project) SCOPE=project ;;
    --global) SCOPE=global ;;
    --dir) DIR=${2:?--dir needs a value}; shift ;;
    --link) LINK=1 ;;
    --dry-run) DRY=1 ;;
    --init) INIT=1 ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; exit 2 ;;
  esac
  shift
done

case $TARGET in
  codex|opencode|kimi|gemini|copilot) TARGET=agents ;;
  claude|agents|agents-md|all) ;;
  *) echo "unknown target: $TARGET" >&2; usage >&2; exit 2 ;;
esac
if [ "$SCOPE" = global ]; then BASE=$HOME; else BASE=$DIR; fi

run() { if [ "$DRY" = 1 ]; then echo "would: $*"; else "$@"; fi; }

install_skills() {  # $1 = destination skills dir
  run mkdir -p "$1"
  for s in "$SRC"/skills/*/; do
    name=$(basename "$s")
    run rm -rf "${1:?}/$name"
    if [ "$LINK" = 1 ]; then run ln -s "${s%/}" "$1/$name"; else run cp -R "${s%/}" "$1/$name"; fi
    echo "installed $name -> $1/$name"
  done
}

install_agents_md() {  # project scope only
  f="$DIR/AGENTS.md"
  if [ "$DRY" = 1 ]; then echo "would: update astromesh-sdd block in $f"; return; fi
  block="$f.block"
  { echo "$START"; cat "$SRC/AGENTS.md"; echo "$END"; } > "$block"
  if [ -f "$f" ] && grep -qF "$START" "$f"; then
    # block is read from a file: awk -v would mangle backslashes in the content
    awk -v s="$START" -v e="$END" -v bf="$block" '
      $0==s {while ((getline l < bf) > 0) print l; skip=1; next}
      $0==e {skip=0; next} !skip' "$f" > "$f.tmp"
    mv "$f.tmp" "$f"
  else
    if [ -f "$f" ]; then echo >> "$f"; fi
    cat "$block" >> "$f"
  fi
  rm -f "$block"
  echo "updated $f"
}

if [ "$LINK" = 1 ]; then
  echo "warning: --link points at $SRC; moving or deleting that folder breaks the skills" >&2
fi
case $TARGET in claude|all) install_skills "$BASE/.claude/skills" ;; esac
case $TARGET in agents|all) install_skills "$BASE/.agents/skills" ;; esac
case $TARGET in agents-md|all)
  if [ "$SCOPE" = project ]; then install_agents_md; fi ;;
esac
if [ "$INIT" = 1 ]; then
  if [ -e "$BASE/.sdd" ]; then echo "kept existing $BASE/.sdd"
  else run cp -R "$SRC/examples/.sdd" "$BASE/.sdd"; echo "created $BASE/.sdd"; fi
fi
