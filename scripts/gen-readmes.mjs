#!/usr/bin/env node
// Generate a README.md index in every grouping folder under skills/.
// A grouping folder is a directory that does NOT directly contain a SKILL.md
// (leaf skills document themselves via SKILL.md). Run with `yarn readmes`.
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const REPO = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const SKILLS = path.join(REPO, "skills");
const SPECIAL = { ui: "UI", gsap: "GSAP", skills: "Skills", reanimated: "Reanimated" };

const title = (name) =>
  SPECIAL[name] ??
  name.split("-").map((w) => w.charAt(0).toUpperCase() + w.slice(1)).join(" ");

const listDirs = (dir) =>
  fs
    .readdirSync(dir, { withFileTypes: true })
    .filter((e) => e.isDirectory())
    .map((e) => path.join(dir, e.name))
    .sort();

const hasSkill = (dir) => fs.existsSync(path.join(dir, "SKILL.md"));

const walk = (dir) => {
  const out = [dir];
  for (const child of listDirs(dir)) out.push(...walk(child));
  return out;
};

const countSkills = (dir) => walk(dir).filter(hasSkill).length;

const readFrontmatter = (file) => {
  const txt = fs.readFileSync(file, "utf8");
  const m = txt.match(/^---\s*\n([\s\S]*?)\n---/);
  if (!m) return { name: "", description: "" };
  const block = m[1];
  const nameM = block.match(/^name:\s*(.+)$/m);
  const descM = block.match(/^description:\s*(.*)$/m);
  let description = "";
  if (descM) {
    const first = descM[1].trim();
    if (["|", ">", "|-", ">-", ""].includes(first)) {
      // block scalar — gather following indented lines
      const after = block.slice(descM.index + descM[0].length).split("\n");
      const lines = [];
      for (const ln of after) {
        if (ln.trim() === "" && lines.length === 0) continue;
        if (/^\s+\S/.test(ln) || ln.trim() === "") lines.push(ln.trim());
        else break;
      }
      description = lines.filter(Boolean).join(" ");
    } else {
      description = first;
    }
  }
  return { name: nameM ? nameM[1].trim() : "", description };
};

// Keep the "what — details" lead; drop the "Use ..." / "Triggers on:" tails.
// No sentence-splitting (would break on "vs." / "e.g.").
const short = (desc) => {
  let s = desc.split(/\bTriggers on:/)[0].split(/\.\s+Use\b/)[0];
  s = s.trim().replace(/\.+$/, "").trim();
  return s.length > 140 ? s.slice(0, 137).trimEnd() + "…" : s;
};

const gen = (folder) => {
  const name = path.basename(folder);
  const lines = [`# ${title(name)}`, ""];

  const relpath = folder === SKILLS ? "skills" : "skills/" + path.relative(SKILLS, folder);
  const n = countSkills(folder);
  lines.push(`\`${relpath}\` — ${n} skill${n === 1 ? "" : "s"}.`, "");
  for (const child of listDirs(folder)) {
    const cname = path.basename(child);
    if (hasSkill(child)) {
      const fm = readFrontmatter(path.join(child, "SKILL.md"));
      lines.push(`- [**${fm.name || cname}**](${cname}/SKILL.md) — ${short(fm.description)}`);
    } else {
      const cn = countSkills(child);
      lines.push(`- [**${cname}/**](${cname}/) — ${cn} skill${cn === 1 ? "" : "s"}`);
    }
  }
  return lines.join("\n") + "\n";
};

const written = [];
for (const dir of walk(SKILLS)) {
  if (hasSkill(dir)) continue; // leaf skill — documented by its SKILL.md
  fs.writeFileSync(path.join(dir, "README.md"), gen(dir));
  written.push(path.relative(REPO, path.join(dir, "README.md")));
}

console.log(`generated ${written.length} folder READMEs`);
for (const w of written.sort()) console.log("  " + w);
