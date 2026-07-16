---
"skills": patch
---

Keep `.claude-plugin/plugin.json`'s `version` in sync with `package.json`. Changesets only bumps `package.json`, so the plugin manifest's version — the one `/plugin` users see — had drifted (stuck at `1.0.0` while the package was `1.6.0`). Add `scripts/sync-plugin-version.mjs`, wire it into `changeset:version` (so every release, local and in CI, updates the manifest automatically), and bump the manifest to the current version. The manifest's `version` is now derived — never hand-edited.
