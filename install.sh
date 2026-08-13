#!/bin/bash
# claude-code-kit — one-command setup for token-efficient Claude Code sessions.
# Usage:  ./install.sh [path-to-your-project]   (defaults to current directory)
set -e

PROJECT="${1:-$(pwd)}"
KIT_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "==> Setting up token-efficient Claude Code for: $PROJECT"

# ── 1. rtk — compresses noisy command output 60–90% ─────────────────────────
if ! command -v rtk >/dev/null 2>&1; then
  echo "==> Installing rtk (output compressor)..."
  if command -v brew >/dev/null 2>&1; then brew install rtk
  else cargo install rtk 2>/dev/null || { echo "!! install Homebrew or Rust first"; exit 1; }
  fi
else echo "    rtk already installed ✓"; fi

# ── 2. grepai — semantic code search (up to 97% fewer input tokens) ─────────
if ! command -v grepai >/dev/null 2>&1; then
  echo "==> Installing grepai (semantic search)..."
  if command -v brew >/dev/null 2>&1; then brew install yoanbernabeu/tap/grepai
  else curl -sSL https://raw.githubusercontent.com/yoanbernabeu/grepai/main/install.sh | sh
  fi
else echo "    grepai already installed ✓"; fi

# ── 2b. ast-grep — structural (AST) code search, precise & token-light ──────
if ! command -v ast-grep >/dev/null 2>&1; then
  echo "==> Installing ast-grep (structural search)..."
  command -v brew >/dev/null 2>&1 && brew install ast-grep || cargo install ast-grep 2>/dev/null || echo "    (skip ast-grep — install brew or cargo)"
else echo "    ast-grep already installed ✓"; fi

# ── 2c. repomix — pack a repo into one AI-friendly file + count tokens ───────
if ! command -v repomix >/dev/null 2>&1; then
  echo "==> Installing repomix (repo packer + token counter)..."
  command -v brew >/dev/null 2>&1 && brew install repomix || npm install -g repomix 2>/dev/null || echo "    (skip repomix — install brew or npm)"
else echo "    repomix already installed ✓"; fi

# ── 3. Ollama + local embedding model (grepai runs 100% locally) ────────────
if ! command -v ollama >/dev/null 2>&1; then
  echo "==> Installing Ollama..."
  brew install ollama 2>/dev/null || { echo "!! install Ollama from ollama.com"; exit 1; }
fi
pgrep -x ollama >/dev/null || (nohup ollama serve >/tmp/ollama.log 2>&1 & sleep 3)
ollama list 2>/dev/null | grep -q nomic-embed-text || ollama pull nomic-embed-text

# ── 4. Index the project ────────────────────────────────────────────────────
cd "$PROJECT"
[ -d .grepai ] || grepai init
pgrep -f "grepai watch" >/dev/null || (nohup grepai watch >/tmp/grepai-watch.log 2>&1 & echo "    grepai indexing started")

# ── 5. Register grepai as an MCP tool for Claude Code ───────────────────────
if command -v claude >/dev/null 2>&1; then
  claude mcp list 2>/dev/null | grep -q "^grepai:" || claude mcp add --scope user grepai -- grepai mcp-serve
fi

# ── 6. Drop in CLAUDE.md + permissions templates (never overwrites) ─────────
[ -f CLAUDE.md ] || { cp "$KIT_DIR/templates/CLAUDE.md" CLAUDE.md; echo "    review CLAUDE.md and fill in your project specifics"; }
mkdir -p .claude
[ -f .claude/settings.json ] || cp "$KIT_DIR/templates/settings.json" .claude/settings.json

# ── 6b. Install the maxed-out GLOBAL CLAUDE.md (token discipline, every session)
mkdir -p ~/.claude
if [ ! -f ~/.claude/CLAUDE.md ]; then
  cp "$KIT_DIR/templates/CLAUDE.global.md" ~/.claude/CLAUDE.md
  echo "    installed ~/.claude/CLAUDE.md (global token-discipline rules)"
else
  echo "    ~/.claude/CLAUDE.md exists — compare with templates/CLAUDE.global.md to merge"
fi

# ── 6c. Install skills user-scope (load in EVERY session: explore, handoff,
#        design, optimize, ed-migration)
if [ -d "$KIT_DIR/skills" ]; then
  mkdir -p ~/.claude/skills
  for s in "$KIT_DIR"/skills/*/; do
    name="$(basename "$s")"
    [ -d ~/.claude/skills/"$name" ] || cp -R "$s" ~/.claude/skills/"$name"
  done
  echo "    installed skills → ~/.claude/skills ($(ls -1 "$KIT_DIR"/skills | tr '\n' ' '))"
fi

# ── 6d. Statusline: live context-usage bar so you never hit the limit by surprise
[ -f "$KIT_DIR/templates/statusline.sh" ] && cp "$KIT_DIR/templates/statusline.sh" ~/.claude/statusline.sh
echo "    (add \"statusLine\": {\"type\":\"command\",\"command\":\"bash ~/.claude/statusline.sh\"} to ~/.claude/settings.json)"

# ── 7. Symlink cckit CLI to PATH ────────────────────────────────────────────
if [ -f "$KIT_DIR/cckit" ]; then
  BIN_PATH="${HOME}/.local/bin"
  mkdir -p "$BIN_PATH"
  ln -sf "$KIT_DIR/cckit" "$BIN_PATH/cckit"
  if [[ ":$PATH:" != *":$BIN_PATH:"* ]]; then
    echo "    Add $BIN_PATH to your PATH: export PATH=$BIN_PATH:\$PATH"
  fi
  chmod +x "$KIT_DIR/cckit"
fi

# ── 8. Scaffold the Obsidian project brain (never clobbers) ─────────────────
"$KIT_DIR/cckit" brain || true

# ── 9. Install the SessionStart hook script (keeps daemons alive every session)
cp "$KIT_DIR/templates/ensure-token-stack.sh" ~/.claude/ensure-token-stack.sh 2>/dev/null || true
if [ -f ~/.claude/settings.json ] && ! grep -q "ensure-token-stack.sh" ~/.claude/settings.json 2>/dev/null; then
  echo ""
  echo "⚙️  To auto-start ollama + grepai watch on EVERY session, add this to ~/.claude/settings.json:"
  echo '   "hooks": { "SessionStart": [ { "hooks": [ { "type": "command", "command": "bash ~/.claude/ensure-token-stack.sh" } ] } ] }'
fi

echo ""
echo "✅ Done. Open a NEW Claude Code session in $PROJECT and it will:"
echo "   - search code semantically via grepai (MCP + CLI) instead of reading files"
echo "   - use ast-grep for precise structural matches, repomix to pack/count when needed"
echo "   - compress command output through rtk"
echo "   - load your CLAUDE.md + brain/ instead of re-exploring"
echo ""
echo "🧠 Project brain: brain/_Home.md  (open the brain/ folder in Obsidian)"
echo "📊 Token dashboard: run 'cckit dashboard' to see real savings + system status."
echo "📝 Add notes: cckit note \"architecture decision\"   ·   scaffold more: cckit brain"
echo ""
echo "Keep 'grepai watch' running while you work (auto-reindexes on save)."
