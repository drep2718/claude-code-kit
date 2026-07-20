# <Project Name> — Project Guide

<One sentence: what this project is. Link to prod URL if deployed.>

## Token discipline (read first)
- **Search semantically before opening files**: `grepai search "your query"` returns the relevant files/snippets — use it instead of grep/glob exploration.
- **Prefix noisy commands with `rtk`**: `rtk git diff`, `rtk npm test`, `rtk npx tsc --noEmit`. Same exit codes, 60–90% fewer output tokens.
- Don't re-read files you just edited. Never cat lockfiles, logs, or binary assets.
- Plan before editing; batch related edits; summarize instead of re-reading.

## Architecture (memorize, don't re-derive)
- **Stack**: <framework, language, DB, hosting>
- **Entry points**: <main files / pages / services>
- **Data model**: <core tables/collections and how they relate>
- **Key modules**: <lib/util files worth knowing by name>
- **Commands**: dev `<cmd>` · test `<cmd>` · build `<cmd>` · deploy `<cmd>`

## Rules
- <Convention 1 — e.g. "semantic design tokens only, no raw hex in components">
- <Convention 2 — e.g. "never commit .env*; secrets are server-only">
- <Convention 3 — e.g. "verify UI changes in browser before pushing">
- <Things NEVER to do — e.g. destructive migrations, force pushes>
