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
# Cross-links: skills reference siblings with the repo's nested relative paths
# (../gestures/SKILL.md, ../../type-safety/SKILL.md). Flattening breaks those, so
# each copied SKILL.md has its links rewritten to the flattened sibling names
# (../mobile-animations-reanimated-gestures/SKILL.md). The repo source is never
# touched — its nested links stay correct for the plugin/skills.sh channel, where
# the nested tree is preserved.
#
# Usage:
#   cd <your-project> && bash /path/to/skills/scripts/vendor-skills.sh
#   bash scripts/vendor-skills.sh                    # -> ./.claude/skills (cwd)
#   bash scripts/vendor-skills.sh <path-to-project>  # -> <project>/.claude/skills
#   bash scripts/vendor-skills.sh <path-to-project> <dest-subdir>
#   bash scripts/vendor-skills.sh --only web         # only web skills
#   bash scripts/vendor-skills.sh --only mobile,shared
#
# The target project defaults to the CURRENT directory, so the common flow is to
# cd into the consumer project and run the script — it always writes to
# ./.claude/skills there. Pass an explicit path only to target another project.
#
# --only <platform[,platform...]> vendors just the chosen top-level platforms
# (shared | mobile | web); omit it to vendor everything. A filtered run only
# prunes stale folders of the SAME platforms, so vendoring web then mobile
# leaves the web skills in place.
#
# Re-running refreshes previously vendored skills and prunes ones that were
# renamed or removed in this repo. Only folders this script created (marked with
# a hidden .vendored-from file) are ever touched — the project's own skills are
# left alone.

REPO="$(cd "$(dirname "$0")/.." && pwd)"
ROOT="$REPO/skills"
MARKER=".vendored-from-hzblj-skills"

# Rewrite a vendored SKILL.md's cross-links from the repo's nested layout
# (../sibling/SKILL.md) to the flattened sibling folder names. Each link is
# resolved against the ORIGINAL source dir, so arbitrary ../ depth and cross-
# platform links map correctly; #anchors are preserved (the token match stops
# before '#', so the anchor rides along untouched). Pure bash — no perl/sed
# dependency, and safe on bash 3.2. Never edits repo sources, only the copy.
links_rewritten=0
rewrite_links() {
  local src_dir="$1" file="$2"
  local tokens token linkdir resolved rel flat new content changed=0

  tokens="$(grep -oE '\]\(\.\.[^)#]*SKILL\.md' "$file" 2>/dev/null | sed 's/^](//' | sort -u || true)"
  [ -n "$tokens" ] || return 0

  # Read once, preserving trailing newlines (the printf x / %x guard), replace in
  # memory, write once. Tokens contain no glob metachars (* ? [), so ${//} is a
  # literal replacement; the leading ../ makes each token an unambiguous match.
  content="$(cat "$file"; printf x)"; content="${content%x}"

  while IFS= read -r token; do
    [ -n "$token" ] || continue
    linkdir="$(dirname "$token")"
    resolved="$(cd "$src_dir/$linkdir" 2>/dev/null && pwd || true)"
    case "$resolved" in
      "$ROOT"/*) ;;
      *) echo "warn: unresolved link '$token' in ${src_dir#"$REPO"/}/SKILL.md" >&2; continue ;;
    esac
    rel="${resolved#"$ROOT"/}"
    flat="${rel//\//-}"
    new="../$flat/SKILL.md"
    [ "$new" = "$token" ] && continue
    # Unquoted on purpose: inside ${//} there is no word-splitting, and bash 3.2
    # inserts LITERAL quotes if $token/$new are double-quoted here. Tokens carry
    # no glob metachars (* ? [), so the match stays literal.
    content="${content//$token/$new}"
    changed=$((changed + 1))
    links_rewritten=$((links_rewritten + 1))
  done <<< "$tokens"

  [ "$changed" -gt 0 ] && printf '%s' "$content" > "$file"
  return 0
}

# Separate flags from positional args so --only can appear anywhere.
PLATFORMS=""
positional=()
while [ "$#" -gt 0 ]; do
  case "$1" in
    --only) PLATFORMS="${2:-}"; shift 2 ;;
    --only=*) PLATFORMS="${1#--only=}"; shift ;;
    -h|--help)
      sed -n '4,40p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *) positional+=("$1"); shift ;;
  esac
done
if [ "${#positional[@]}" -gt 0 ]; then set -- "${positional[@]}"; else set --; fi

PROJECT="${1:-.}"
SUBDIR="${2:-.claude/skills}"

if [ ! -d "$PROJECT" ]; then
  echo "error: project directory not found: $PROJECT" >&2
  exit 1
fi

# Resolve which top-level platform dirs to walk. Empty selected[] means "all".
selected=()
roots=()
if [ -n "$PLATFORMS" ]; then
  IFS=',' read -ra requested <<< "$PLATFORMS"
  for p in "${requested[@]}"; do
    p="${p//[[:space:]]/}"
    [ -n "$p" ] || continue
    if [ ! -d "$ROOT/$p" ]; then
      echo "error: unknown platform '$p' (expected: shared, mobile, web)" >&2
      exit 1
    fi
    selected+=("$p")
    roots+=("$ROOT/$p")
  done
fi
if [ "${#roots[@]}" -eq 0 ]; then roots=("$ROOT"); fi

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
done < <(find "${roots[@]}" -name SKILL.md \
  -not -path '*/node_modules/*' -not -path '*/deprecated/*' -print0)

mkdir -p "$DEST"

# Prune stale vendored skills (renamed/removed upstream) so re-runs stay clean.
# Only prune folders WE created — detected by the marker file — never the
# project's own skills. When filtering by platform, scope the prune to the same
# platforms so a web-only run leaves vendored mobile-*/shared-* folders alone.
for entry in "$DEST"/*; do
  [ -d "$entry" ] || continue
  [ -f "$entry/$MARKER" ] || continue
  base="$(basename "$entry")"

  if [ "${#selected[@]}" -gt 0 ]; then
    segment="${base%%-*}"
    in_scope=false
    for p in "${selected[@]}"; do
      [ "$p" = "$segment" ] && { in_scope=true; break; }
    done
    "$in_scope" || continue
  fi

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
  rewrite_links "$src" "$target/SKILL.md"
  echo "vendored $name -> $target"
done

echo "done: ${#names[@]} skills vendored into $DEST ($links_rewritten cross-links rewritten)"
