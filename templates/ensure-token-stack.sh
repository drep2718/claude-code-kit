#!/bin/bash
# Claude Code SessionStart hook (user-scope). Keeps the token stack alive AND
# bootstraps every new real repo: indexes it for grepai + scaffolds its brain.
# Silent + fast: all heavy work is backgrounded so it never delays the session.
# Logs to ~/.claude/token-stack.log
LOG=~/.claude/token-stack.log
have() { command -v "$1" >/dev/null 2>&1; }

# A "real project" = has git or a known manifest, and is not $HOME itself.
is_project() {
  [ "$(pwd)" != "$HOME" ] || return 1
  [ -d .git ] && return 0
  ls package.json Cargo.toml go.mod pyproject.toml requirements.txt \
     CMakeLists.txt pom.xml build.gradle Gemfile 2>/dev/null | grep -q . && return 0
  [ -d .grepai ] && return 0
  return 1
}

{
  echo "--- $(date '+%F %T') session start in $(pwd) ---"

  # 1. Ollama must be up for grepai embeddings.
  if have ollama && ! pgrep -f "ollama serve" >/dev/null 2>&1; then
    nohup ollama serve >/tmp/ollama.log 2>&1 &
    echo "started ollama serve"
  fi

  if is_project; then
    # 2. Index this project for grepai the first time we see it, then keep it fresh.
    if have grepai && [ ! -d .grepai ]; then
      ( grepai init >/tmp/grepai-init.log 2>&1 && nohup grepai watch >/tmp/grepai-watch.log 2>&1 ) &
      echo "grepai: indexing new project $(pwd)"
    elif have grepai && [ -d .grepai ] && ! pgrep -f "grepai watch" >/dev/null 2>&1; then
      nohup grepai watch >/tmp/grepai-watch.log 2>&1 &
      echo "grepai watch resumed for $(pwd)"
    fi

    # 3. Scaffold the Obsidian brain the first time (never clobbers existing notes).
    if have cckit && [ ! -d brain ]; then
      cckit brain >/tmp/cckit-brain.log 2>&1 &
      echo "brain scaffolded for $(pwd)"
    fi
  fi
} >>"$LOG" 2>&1 &

# Never block or pollute the session; the hook returns immediately.
exit 0
