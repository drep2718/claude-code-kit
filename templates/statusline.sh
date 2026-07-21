#!/bin/bash
# Claude Code statusline — surfaces context-window usage so you never hit the
# limit by surprise. Reads the session JSON on stdin.
input="$(cat)"

j() { printf '%s' "$input" | jq -r "$1" 2>/dev/null; }

model="$(j '.model.display_name')"; [ -z "$model" ] && model="?"
dir="$(j '.workspace.current_dir')"; dir="${dir##*/}"; [ -z "$dir" ] && dir="~"
cost="$(j '.cost.total_cost_usd')"

# Context window: prefer an explicit used-tokens field if present, else the
# 200k-exceeded flag. Field names have shifted across versions, so try several.
used="$(j '.context.used_tokens // .cost.total_tokens // .usage.total_tokens // empty')"
window="$(j '.context.window_tokens // .model.context_window // empty')"
exceeds="$(j '.exceeds_200k_tokens // false')"

ctx=""
if [ -n "$used" ] && [ -n "$window" ] && [ "$window" -gt 0 ] 2>/dev/null; then
  pct=$(( used * 100 / window ))
  bar=""; filled=$(( pct / 10 ))
  for i in $(seq 1 10); do [ "$i" -le "$filled" ] && bar="${bar}█" || bar="${bar}·"; done
  # color + call-to-action: green <60, yellow 60-85 (compact soon), red 85+ (compact NOW)
  if [ "$pct" -ge 85 ]; then
    c=$'\e[1;31m'; cta=" ⚠ /compact NOW"
  elif [ "$pct" -ge 60 ]; then
    c=$'\e[1;33m'; cta=" → /compact"
  else
    c=$'\e[32m'; cta=""
  fi
  ctx=" · ${c}ctx ${bar} ${pct}%${cta}\e[0m"
elif [ "$exceeds" = "true" ]; then
  ctx=" · \e[31mctx >200k — /compact soon\e[0m"
fi

# grepai watch dot (green = fresh index working for you)
if pgrep -f "grepai watch" >/dev/null 2>&1; then gp=$'\e[32m●\e[0m'; else gp=$'\e[90m○\e[0m'; fi

coststr=""; [ -n "$cost" ] && [ "$cost" != "null" ] && coststr=" · \$$(printf '%.2f' "$cost" 2>/dev/null)"

printf "%b" "\e[36m${model}\e[0m  \e[90m${dir}\e[0m ${gp}${ctx}${coststr}"
