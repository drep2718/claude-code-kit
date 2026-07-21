---
name: explore
description: Investigate how code works, where something lives, or trace a flow across files — any codebase "how/where/why" question before implementing. Explores in a subagent (so file reads never touch the main window) and caches findings to brain/Exploration.md so the same ground is never covered twice.
---
# Explore with a learning subagent

Answer codebase questions **without burning main-window tokens**, and **remember the answer** so it's free next time.

## Protocol (always, in this order)
1. **Cache first — don't re-explore what's known.**
   - If `brain/Exploration.md` exists, read it (or `grepai search "<the question>"`).
   - If it already answers the question, use that and skip to step 4. This is the payoff: a prior exploration is a near-zero-token cache hit.
2. **Explore in a subagent** (Explore or general-purpose, on Haiku via `CLAUDE_CODE_SUBAGENT_MODEL=haiku`). The subagent reads files in ITS OWN context; those tokens are discarded when it returns. Instruct it to return a tight report with exactly these fields:
   - **Question** — what it answered
   - **Where it looked** — dirs, key files, grepai/ast-grep queries tried, and dead-ends (so we never retry them)
   - **Findings** — the answer, with `file:line` references
   - **Gotchas** — non-obvious things worth remembering
3. **Cache the result.** Append the subagent's report to `brain/Exploration.md` under a new heading `## <YYYY-MM-DD> — <question>`. Keep it terse (it's an index, not a transcript). Create the file if missing.
4. **Continue** using only the returned summary. Do NOT re-read files the subagent already covered.

## Why this saves tokens
The heavy reading happens in a throwaway context and vanishes. Only a short structured summary enters your window — and it's written down, so the *next* question about that area costs almost nothing.
