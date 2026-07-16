#!/usr/bin/env node
// Keep .claude-plugin/plugin.json's version in sync with package.json.
// Changesets only bumps package.json + CHANGELOG; the Claude Code plugin manifest
// carries its own `version` that users see via `/plugin`. This script copies the
// package version into the manifest so the two never drift. It runs automatically
// as part of `yarn changeset:version` (and therefore in the release workflow), so
// never hand-edit the manifest's version.
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const REPO = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const { version } = JSON.parse(fs.readFileSync(path.join(REPO, "package.json"), "utf8"));

const manifestPath = path.join(REPO, ".claude-plugin", "plugin.json");
const manifest = fs.readFileSync(manifestPath, "utf8");

// Targeted replace of the first top-level "version" so formatting/key order stay intact.
const next = manifest.replace(/("version":\s*)"[^"]*"/, `$1"${version}"`);

if (next === manifest) {
  console.log(`plugin.json version already ${version}`);
} else {
  fs.writeFileSync(manifestPath, next);
  console.log(`synced plugin.json version -> ${version}`);
}
