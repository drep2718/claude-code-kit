<!-- ~/.claude/CLAUDE.md — GLOBAL, loaded every session in every project.
     Keep it dense: a bloated CLAUDE.md gets half-ignored. HTML comments like this
     are stripped before injection (zero tokens), so human notes live in them.
     Curated from Anthropic best-practices + the claude-code-kit token stack. -->

# Operating rules — every session, every repo

## 1 · Explore with SUBAGENTS that LEARN — the #1 token rule (standing user directive)
- ANY exploration/investigation ("how does X work", "where is Y", "find all Z", tracing a bug, understanding an unfamiliar area) → use the **`explore` skill**: spawn a subagent to do it.
- **Cache first:** before exploring, check `brain/Exploration.md` (and `grepai search`). If it's already answered there, use that — do NOT re-explore.
- The subagent reads files in ITS OWN context and returns only a short structured summary (question · where it looked · findings w/ file:line · gotchas). Those reads never enter my window — when it finishes, those tokens are gone for good.
- **Then cache it:** append the subagent's summary to `brain/Exploration.md` so the next time is a near-free hit. Use the summary and CONTINUE; never re-read what it covered.
- I do NOT need to ask permission to spawn an exploration subagent — standing-authorized. Prefer `Explore`/`general-purpose` on Haiku (`CLAUDE_CODE_SUBAGENT_MODEL=haiku`).
- Only read files directly in the main context when I already know the exact file+lines to edit.

## 1b · Search, don't brute-force read
- Find code by MEANING with `grepai search "question"` (or the grepai MCP) BEFORE opening files.
- Find code by SHAPE with `ast-grep` / `sg -p 'pattern'` (e.g. `sg -p 'useEffect($$$)'`).
- Whole-repo view or token count → `repomix`. Reading files is the LAST resort.
- NEVER cat lockfiles, logs, `node_modules`, build output, or binaries. Filter or `rtk` them.

## 2 · Read the brain first
- If `brain/` exists, read `brain/_Home.md` before exploring — it's the map (architecture, decisions, glossary, backlog) that saves re-deriving the project.
- When something structural changes, update the right brain note (or `cckit note "…"`). Cheap now, saves every future session.

## 3 · Spend output tokens like they cost money
- Lead with the answer/result; keep any reasoning short and after it.
- NO preamble ("I'll now…"), NO filler ("Great question"), NO restating the task back.
- NO unsolicited summaries, suggestions, or "next steps" unless asked. Match length to the question.
- Skip safety/hedging disclaimers unless there is genuine risk.

## 4 · Compress command output
- Prefix noisy commands with `rtk`: `rtk npm run build`, `rtk git diff`, `rtk cargo test` (same exit codes, 60–90% fewer tokens).
- Or filter: `<cmd> 2>&1 | grep -E 'FAIL|ERROR|warning' | head -50`.

## 5 · Manage context aggressively
- **New project or multi-file/unfamiliar work → ALWAYS use plan mode first** (explore via subagents, then a written plan, then implement). One-line fix / exact known edit → just do it, skip planning.
- **Proactively tell the user to `/compact` once context reaches ~60%** (the statusline turns yellow at 60%, red at 85%). Don't wait for the limit. When I notice a session getting long or right after heavy exploration, say so explicitly: "Context ~60% — good time to `/compact`; I'll preserve modified files, commands, and open decisions."
- On `/compact`, ALWAYS preserve: the modified-file list, test/build commands, and open decisions.
- Batch related edits; don't re-read a file I just edited.
- Between unrelated tasks, tell the user to `/clear`. After 2 failed corrections, suggest a fresh session.

## 6 · Verify, then stop — never assert success
- Every change gets a check I can run: tests, build, lint, or a browser screenshot. Show the output as evidence.

## 7 · Model routing (raise when it saves money)
- Haiku: file reads, log scans, boilerplate, subagents. · Sonnet: default coding. · Opus: architecture & hard multi-file bugs.
- `CLAUDE_CODE_SUBAGENT_MODEL=haiku` makes subagents cheap.

# Per-repo bootstrap
<!-- The SessionStart hook (~/.claude/ensure-token-stack.sh) already auto-starts ollama +
     grepai watch, indexes real projects, and scaffolds brain/. If any is missing, do it: -->
- Not indexed for grepai → `grepai init` then `grepai watch &`.
- No `brain/` yet → `cckit brain` (creates the Obsidian vault; never clobbers).
- Audit the whole stack → `cckit dashboard` (real measured savings + system status).

# Machine has (all local, all free)
<!-- grepai=semantic · sg/ast-grep=structural · repomix=pack+count · rtk=output compressor
     · cckit=dashboard/brain/note · Obsidian=brain editor. Kit: github.com/drep2718/claude-code-kit -->
