<!-- ~/.claude/CLAUDE.md — GLOBAL, loaded every session in every project.
     Keep it dense: a bloated CLAUDE.md gets half-ignored. HTML comments like this
     are stripped before injection (zero tokens), so human notes live in them.
     Curated from Anthropic best-practices + the claude-code-kit token stack. -->

# Operating rules — every session, every repo

## 1 · Search, don't brute-force read
- Find code by MEANING with `grepai search "question"` (or the grepai MCP) BEFORE opening files.
- Find code by SHAPE with `ast-grep` / `sg -p 'pattern'` (e.g. `sg -p 'useEffect($$$)'`).
- Whole-repo view or token count → `repomix`. Reading files is the LAST resort.
- Wide/unscoped investigation → delegate to a **subagent** so its file reads never enter my context.
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
- Multi-file or unfamiliar work → plan first. One-line fix → just do it (skip planning overhead).
- Batch related edits; don't re-read a file I just edited.
- On `/compact`, ALWAYS preserve: the modified-file list, test/build commands, and open decisions.
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
