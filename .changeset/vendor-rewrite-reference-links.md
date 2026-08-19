---
"skills": patch
---

`vendor-skills.sh` now rewrites cross-links in every markdown file of a vendored skill, not just its `SKILL.md`. A link from `references/patterns.md` to a sibling skill was left pointing at the repo's nested layout and dangled in the flattened destination. Files in a skill's subfolder also get one extra `../` so the rewritten path resolves from their own depth.
