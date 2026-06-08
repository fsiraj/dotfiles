#!/usr/bin/env bash
# Claude Code status line

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
model=$(echo "$input" | jq -r '.model.id // ""')
ctx_used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
five_hr=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
resets_at=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
effort=$(echo "$input" | jq -r '.effort.level // empty')

# ANSI colors
accent='\033[38;2;217;119;87m' #d97757
yellow='\033[33m'
red='\033[31m'
reset='\033[0m'

# Replace $HOME with ~
[[ "$cwd" == "$HOME"* ]] && cwd="~${cwd#"$HOME"}"

# Color helper: only color when concerning
color_for_pct() {
  local pct="$1"
  local int_pct
  int_pct=$(printf '%.0f' "$pct" 2>/dev/null) || int_pct=0
  if [ "$int_pct" -ge 80 ]; then
    printf '%s' "$red"
  elif [ "$int_pct" -ge 50 ]; then
    printf '%s' "$yellow"
  fi
}

# cwd · model (with effort level if present)
model_label="$model"
[ -n "$effort" ] && model_label="${model}-${effort}"
parts="${accent}${model_label}${reset} · ${cwd}"

# ctx x%
if [ -n "$ctx_used" ]; then
  color=$(color_for_pct "$ctx_used")
  parts="${parts} · ${color}ctx $(printf '%.0f' "$ctx_used")%${reset}"
fi

# use x%
five_hr_int=0
if [ -n "$five_hr" ]; then
  color=$(color_for_pct "$five_hr")
  five_hr_int=$(printf '%.0f' "$five_hr")
  parts="${parts} · ${color}use ${five_hr_int}%${reset}"
fi

# resets Xh Ym
if [ -n "$resets_at" ]; then
  remaining=$((resets_at - $(date +%s)))
  if [ "$remaining" -gt 0 ]; then
    parts="${parts} · resets $((remaining / 3600))h $(((remaining % 3600) / 60))m"
  fi
fi

printf "%b\n" "$parts"
