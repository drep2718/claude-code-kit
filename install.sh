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
  claude mcp list 2>/dev/null | grep -q "^grepai:" || claude mcp add --scope user grepai -- grepai mcp
fi

# ── 6. Drop in CLAUDE.md + permissions templates (never overwrites) ─────────
[ -f CLAUDE.md ] || { cp "$KIT_DIR/templates/CLAUDE.md" CLAUDE.md; echo "    review CLAUDE.md and fill in your project specifics"; }
mkdir -p .claude
[ -f .claude/settings.json ] || cp "$KIT_DIR/templates/settings.json" .claude/settings.json

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

# ── 8. Create starter memory vault ─────────────────────────────────────────
MEM_DIR="$PROJECT/.claude/memory"
mkdir -p "$MEM_DIR"
[ -f "$MEM_DIR/starter.md" ] || cat > "$MEM_DIR/starter.md" <<'EOF'
# Project Setup

Project indexed with grepai. Token savings measured by `cckit status`.
View full dashboard with `cckit dashboard`.
EOF

echo ""
echo "✅ Done. Open a NEW Claude Code session in $PROJECT and it will:"
echo "   - search code semantically via grepai (MCP + CLI) instead of reading files"
echo "   - compress command output through rtk"
echo "   - load your CLAUDE.md project brain instead of re-exploring"
echo ""
echo "📊 Token dashboard: run 'cckit dashboard' in $PROJECT to see real savings + system status."
echo "📝 Add notes: cckit note \"architecture decision\""
echo ""
echo "Keep 'grepai watch' running while you work (auto-reindexes on save)."
