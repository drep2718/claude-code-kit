---
name: optimize
description: Reduce token/context usage or diagnose why a session is burning tokens. Use when the user asks to save tokens, mentions hitting limits, or context is filling up.
---
# Token optimize

- Run `/context` to see where tokens actually go; call out the biggest consumers.
- Push all exploration to subagents (see the `explore` skill) — file reads there don't touch this window.
- Prefer `grepai search` / `ast-grep` over reading files. Prefix noisy commands with `rtk`.
- Suggest `/clear` between unrelated tasks; after 2 failed corrections, a fresh session beats a polluted one.
- At ~60% context (statusline yellow) recommend `/compact`; preserve modified files, commands, and open decisions. Near the limit, prefer the `handoff` skill.
- `cckit dashboard` shows measured savings + system status.
- Trim unused MCP servers — each costs ~10–20k tokens of schema every session.
