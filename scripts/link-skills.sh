#!/usr/bin/env bash
set -euo pipefail

# Links every skill in this repo into the local skill directories used by each
# agent harness:
#   - ~/.claude/skills  — Claude Code
#   - ~/.agents/skills  — Codex and other Agent Skills-compatible harnesses
# Each entry is a symlink into this repo, so a `git pull` keeps installed skills
# current. Adapted from mattpocock/skills.

REPO="$(cd "$(dirname "$0")/.." && pwd)"
DESTS=("$HOME/.claude/skills" "$HOME/.agents/skills")

# Collect the repo's skills once. Name each symlink after the SKILL.md `name:`
# frontmatter (unique across the repo) rather than the folder basename — leaf
# folder names repeat across categories (e.g. two `performance/` leaves), so
# basenames would collide and silently drop a skill.
names=()
srcs=()
while IFS= read -r -d '' skill_md; do
  src="$(dirname "$skill_md")"
  name="$(sed -n 's/^name:[[:space:]]*//p' "$skill_md" | head -1)"
  [ -n "$name" ] || name="$(basename "$src")"
  names+=("$name")
  srcs+=("$src")
done < <(find "$REPO/skills" -name SKILL.md -not -path '*/node_modules/*' -not -path '*/deprecated/*' -print0)

for DEST in "${DESTS[@]}"; do
  # If $DEST is a symlink that resolves into this repo, we'd write the per-skill
  # symlinks back into the repo's own skills/ tree. Detect and bail out.
  if [ -L "$DEST" ]; then
    resolved="$(readlink -f "$DEST")"
    case "$resolved" in
      "$REPO"|"$REPO"/*)
        echo "error: $DEST is a symlink into this repo ($resolved)." >&2
        echo "Remove it (rm \"$DEST\") and re-run; the script will recreate it as a real dir." >&2
        exit 1
        ;;
    esac
  fi

  mkdir -p "$DEST"

  # Prune stale symlinks that point back into this repo so renames and removals
  # don't leave orphans. Non-repo skills the user installed are left untouched.
  for entry in "$DEST"/*; do
    [ -L "$entry" ] || continue
    tgt="$(readlink -f "$entry" 2>/dev/null || true)"
    case "$tgt" in "$REPO"/*) rm -f "$entry" ;; esac
  done

  for i in "${!names[@]}"; do
    name="${names[$i]}"
    src="${srcs[$i]}"
    target="$DEST/$name"

    if [ -e "$target" ] && [ ! -L "$target" ]; then
      rm -rf "$target"
    fi

    ln -sfn "$src" "$target"
    echo "linked $name -> $src ($DEST)"
  done
done
