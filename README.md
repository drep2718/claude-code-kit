# claude-code-kit ⚡

One-command setup that makes Claude Code sessions **last dramatically longer** by cutting token waste at its three biggest sources.

```bash
git clone https://github.com/drep2718/claude-code-kit.git
cd your-project
~/path/to/claude-code-kit/install.sh
```

That's it. Open a new Claude Code session and it's active.

## What it sets up (all free, all local)

| Tool | What it fixes | Typical savings |
|---|---|---|
| **[grepai](https://github.com/yoanbernabeu/grepai)** | Claude opening dozens of files to find code. Semantic search returns just the relevant snippets. Runs 100% locally (Ollama embeddings), registered as an MCP tool. | up to 90%+ of exploration input tokens |
| **[rtk](https://github.com/rtk-rs)** (`brew install rtk`) | Noisy terminal output (builds, diffs, test runs) flooding context. rtk compresses/dedupes it before Claude sees it. | 60–90% of command-output tokens |
| **CLAUDE.md template** | Claude re-deriving your architecture every session. A tight project brain it loads once. | 10–30% overall |
| **Permissions allowlist** | Approval round-trips for safe read-only commands. | time, mostly |

## Honest notes

- Savings are **not additive** and depend heavily on project size. Small repos: expect ~10–30% overall. Large repos with heavy exploration: much more.
- The single highest-value item is a **good CLAUDE.md**. The template forces the sections that matter: token discipline, architecture-you-shouldn't-re-derive, and hard rules.
- Tools some blog posts recommend that we could **not verify exist** (e.g. "Repowise") are deliberately excluded. Everything here installs from Homebrew or official taps.
- `grepai watch` must be running to keep the index fresh: the installer starts it, but after a reboot run it again (or add it to your shell profile / login items).

## Dashboard: See your actual token savings

Run this from your project after install:

```bash
cckit dashboard          # opens a visual dashboard showing:
                         # • Real measured token savings (from grepai stats)
                         # • System status (grepai/ollama/rtk/MCP running?)
                         # • Files indexed, search count, efficiency %
                         # • Memory vault (your project notes)
```

The dashboard is self-contained HTML (no network needed) and regenerates each time you run it — it always shows live data.

Quick status check: `cckit status`

Add notes to your memory vault: `cckit note "why we use this pattern"`

## What's in the box

```
claude-code-kit/
├── install.sh              # idempotent, never overwrites your files
├── cckit                   # dashboard CLI (symlinked to ~/.local/bin on install)
├── dashboard/
│   └── template.html       # self-contained dashboard template (injected with live data)
└── templates/
    ├── CLAUDE.md           # project-brain template (fill in the <blanks>)
    └── settings.json       # safe read-only permissions allowlist
```

## Manual usage after install

```bash
grepai search "where do we validate auth tokens"   # semantic search
rtk git diff                                       # compressed diff
rtk npm run build                                  # compressed build output
```

Claude Code picks these up automatically via the CLAUDE.md instructions and the grepai MCP registration.

## Requirements

macOS with [Homebrew](https://brew.sh) (Linux works if you install grepai/rtk/ollama manually first — the script detects existing installs and skips them).
