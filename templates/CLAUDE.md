<!-- ./CLAUDE.md — PROJECT-level. Token discipline lives in the global ~/.claude/CLAUDE.md
     (installed by claude-code-kit), so this file holds ONLY what's specific to THIS repo.
     Rule of thumb per line: "would removing this make Claude make a mistake?" If no, cut it.
     HTML comments like this are stripped before injection — zero tokens. -->

# <Project Name>

<One sentence: what this is. Prod URL if deployed.>

## Architecture (memorize — don't re-derive)
- **Stack**: <framework, language, DB, hosting>
- **Entry points**: <main files / pages / services>
- **Data model**: <core tables/collections and how they relate>
- **Key modules**: <lib/util files worth knowing by name>
- **Commands**: dev `<cmd>` · test `<cmd>` · build `<cmd>` · deploy `<cmd>`

## Rules (ALWAYS / NEVER — these override defaults)
- <Convention that differs from the language/framework default>
- NEVER <destructive/irreversible thing specific to this repo>
- <Non-obvious gotcha a fresh session would trip on>

## Deeper context
- Read `brain/_Home.md` for architecture, decisions, glossary, backlog.
<!-- For rarely-needed procedures, prefer .claude/skills/*/SKILL.md (loads on demand)
     or .claude/rules/*.md with `paths:` frontmatter (loads only when matching files are read)
     over adding prose here — both keep this always-loaded file small. -->
