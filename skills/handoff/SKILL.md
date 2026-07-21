---
name: handoff
description: Write a session handoff file so you can continue in a fresh session with zero context loss. Use when context is high (statusline red / ~85%), when switching sittings, or when the user says "handoff".
disable-model-invocation: true
---
# Session handoff

A handoff file is far cheaper than carrying a long conversation. When context is nearly full, dump state to disk and start fresh instead of `/compact`-ing repeatedly.

1. Write **`HANDOFF.md`** at the repo root:
   - **Goal** — what we're trying to achieve
   - **Done** — changes made so far (explicit modified-files list)
   - **Next** — the immediate next steps, in order
   - **Run/Test** — dev / test / build commands
   - **Open decisions & gotchas** — anything unresolved or non-obvious
2. Also append a one-line entry to `brain/Sessions.md` (dated) so the brain stays current.
3. If the user wants a checkpoint and this is a git repo: `git add -A && git commit -m "wip: handoff"`.
4. Tell the user: **start a new session and say "Read HANDOFF.md and continue."** The fresh session has clean context focused entirely on the remaining work.
