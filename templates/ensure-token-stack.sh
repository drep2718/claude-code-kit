#!/bin/bash
# Claude Code SessionStart hook — keeps the token-saving daemons alive on every
# session. Silent + fast: heavy work is backgrounded so it never delays startup.
# Install: copy to ~/.claude/ensure-token-stack.sh and add to ~/.claude/settings.json:
#   "hooks": { "SessionStart": [ { "hooks": [
#     { "type": "command", "command": "bash ~/.claude/ensure-token-stack.sh" } ] } ] }
LOG=~/.claude/token-stack.log
have() { command -v "$1" >/dev/null 2>&1; }

{
  echo "--- $(date '+%F %T') session start in $(pwd) ---"
  # Ollama must be up for grepai embeddings.
  if have ollama && ! pgrep -f "ollama serve" >/dev/null 2>&1; then
    nohup ollama serve >/tmp/ollama.log 2>&1 &
    echo "started ollama serve"
  fi
  # Keep an indexed project's search fresh (never inits random directories).
  if have grepai && [ -d .grepai ] && ! pgrep -f "grepai watch" >/dev/null 2>&1; then
    nohup grepai watch >/tmp/grepai-watch.log 2>&1 &
    echo "started grepai watch for $(pwd)"
  fi
} >>"$LOG" 2>&1 &

exit 0
