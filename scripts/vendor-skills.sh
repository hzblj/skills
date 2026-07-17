#!/usr/bin/env bash
set -euo pipefail

# Vendors every skill in this repo into a target project's `.claude/skills/` as
# real copies (unlike link-skills.sh, which symlinks into ~/.claude for local
# use). Use this when you want the skills committed INTO a project so teammates
# get them too.
#
# Why copies and not the nested tree: Claude Code's project-skill auto-scan only
# looks ~1-2 levels deep for `<skill>/SKILL.md`. This repo nests skills 3-4
# levels (skills/mobile/animations/reanimated/core), so a raw copy of skills/
# would be invisible. We flatten each skill to a single level.
#
# Naming: the destination folder is the skill's path under skills/ joined with
# dashes (e.g. mobile/animations/reanimated/core -> mobile-animations-reanimated-core),
# so the platform/category domain stays visible at the root and leaf basenames
# that repeat across categories (two `performance/` leaves) never collide. The
# SKILL.md `name:` frontmatter is left untouched — that is the real identifier
# Claude uses; the folder name is just for human browsing.
#
# Usage:
#   cd <your-project> && bash /path/to/skills/scripts/vendor-skills.sh
#   bash scripts/vendor-skills.sh                    # -> ./.claude/skills (cwd)
#   bash scripts/vendor-skills.sh <path-to-project>  # -> <project>/.claude/skills
#   bash scripts/vendor-skills.sh <path-to-project> <dest-subdir>
#
# The target project defaults to the CURRENT directory, so the common flow is to
# cd into the consumer project and run the script — it always writes to
# ./.claude/skills there. Pass an explicit path only to target another project.
#
# Re-running refreshes previously vendored skills and prunes ones that were
# renamed or removed in this repo. Only folders this script created (marked with
# a hidden .vendored-from file) are ever touched — the project's own skills are
# left alone.

REPO="$(cd "$(dirname "$0")/.." && pwd)"
ROOT="$REPO/skills"
MARKER=".vendored-from-hzblj-skills"

PROJECT="${1:-.}"
SUBDIR="${2:-.claude/skills}"

if [ ! -d "$PROJECT" ]; then
  echo "error: project directory not found: $PROJECT" >&2
  exit 1
fi

DEST="$(cd "$PROJECT" && pwd)/$SUBDIR"

# Guard against vendoring into this repo's own skills/ tree.
case "$DEST" in
  "$ROOT"|"$ROOT"/*)
    echo "error: refusing to vendor into this repo's own skills/ tree ($DEST)." >&2
    exit 1
    ;;
esac

# Collect the repo's skills and their domain-prefixed names.
names=()
srcs=()
while IFS= read -r -d '' skill_md; do
  src="$(dirname "$skill_md")"
  rel="${src#"$ROOT"/}"       # mobile/animations/reanimated/core
  name="${rel//\//-}"         # mobile-animations-reanimated-core
  names+=("$name")
  srcs+=("$src")
done < <(find "$ROOT" -name SKILL.md \
  -not -path '*/node_modules/*' -not -path '*/deprecated/*' -print0)

mkdir -p "$DEST"

# Prune stale vendored skills (renamed/removed upstream) so re-runs stay clean.
# Only prune folders WE created — detected by the marker file — never the
# project's own skills.
for entry in "$DEST"/*; do
  [ -d "$entry" ] || continue
  [ -f "$entry/$MARKER" ] || continue
  base="$(basename "$entry")"
  keep=false
  for name in "${names[@]}"; do
    [ "$name" = "$base" ] && { keep=true; break; }
  done
  "$keep" || { rm -rf "$entry"; echo "pruned $base"; }
done

for i in "${!names[@]}"; do
  name="${names[$i]}"
  src="${srcs[$i]}"
  target="$DEST/$name"

  # A pre-existing folder WITHOUT our marker is the project's own skill — never
  # clobber it. Warn and skip so a name clash is loud, not silent.
  if [ -d "$target" ] && [ ! -f "$target/$MARKER" ]; then
    echo "warn: skipping $name — a non-vendored folder already exists at $target" >&2
    continue
  fi

  rm -rf "$target"
  mkdir -p "$target"
  cp -R "$src/." "$target/"
  printf '%s\n' "${src#"$REPO"/}" > "$target/$MARKER"
  echo "vendored $name -> $target"
done

echo "done: ${#names[@]} skills vendored into $DEST"
