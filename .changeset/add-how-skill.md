---
"skills": minor
---

Add the `how` skill (`skills/shared/how`), taken verbatim from [cursor/plugins](https://github.com/cursor/plugins/tree/main/pstack/skills/how) (MIT), together with its four `references/` prompt templates. It answers "how does X work": parallel explorers map a subsystem, an explainer turns that into an onboarding-level mental model, and an optional critique mode spawns independent architectural critics. It is the companion `teach` calls alongside `why`.

The subagent config is retargeted from Cursor's agent types and model ids to Claude Code's: explorers run as the built-in read-only `Explore` agent, the explainer and synthesizer run as `deep-reasoner` on Fable, and the critique panel is `fable` / `opus` / `sonnet` on `general-purpose`. Cursor's `readonly` flag has no Claude Code equivalent, so the read-only posture is stated in the prompt instead. Everything else, including the four `references/` prompts, is verbatim.

`scripts/gen-openai-yaml.mjs` and `scripts/gen-readmes.mjs` now unescape backslash escapes inside a double-quoted YAML `description:` scalar.
