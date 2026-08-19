---
"skills": minor
---

Add the `teach` skill (`skills/shared/teach`), taken verbatim from [cursor/plugins](https://github.com/cursor/plugins/tree/main/pstack/skills/teach) (MIT). It explains a change or subsystem so it actually lands: pick the few things the reader should walk away with, let `why` do the digging, start with a plain definition, and build diagrams up one part at a time instead of dropping one crowded picture at the end. It is user-invoked only (`disable-model-invocation: true`).

`scripts/gen-openai-yaml.mjs` and `scripts/gen-readmes.mjs` now strip the quotes from a quoted YAML `description:` scalar, and the OpenAI config honours `disable-model-invocation` by emitting `allow_implicit_invocation: false`.
