#!/usr/bin/env bash
# Colorful powerline statusline for Claude Code.
# Palette matches Monokai Boosted (~/.config/kitty/kitty-themes/themes/Monokai_Boosted.conf).
# Requires: jq, a Nerd Font (JetBrainsMono Nerd Font).
#
# Segments (each appears only when it has something to say):
#   model+effort · dir · git · churn · context meter · 5h limit · cost · style · 200k

set -uo pipefail
input=$(cat)

j() { jq -r "$1 // empty" <<<"$input" 2>/dev/null; }

MODEL=$(j '.model.display_name')
EFFORT=$(j '.effort.level')
FAST=$(j '.fast_mode')
CWD=$(j '.workspace.current_dir')
PROJECT=$(j '.workspace.project_dir')
STYLE=$(j '.output_style.name')
COST=$(j '.cost.total_cost_usd')
LINES_ADD=$(j '.cost.total_lines_added')
LINES_DEL=$(j '.cost.total_lines_removed')
CTX_PCT=$(j '.context_window.used_percentage')
LIMIT_5H=$(j '.rate_limits.five_hour.used_percentage')
LIMIT_7D=$(j '.rate_limits.seven_day.used_percentage')
OVER200K=$(j '.exceeds_200k_tokens')

[ -z "$MODEL" ] && MODEL="Claude"
[ -z "$CWD" ] && CWD="$PWD"

# ── palette ────────────────────────────────────────────────
PINK="255;106;193"
PURPLE="174;129;255"
GREEN="166;240;36"
ORANGE="255;164;31"
YELLOW="255;220;61"
BLUE="72;184;255"
CYAN="70;217;240"
RED="255;45;111"
INK="22;22;26"
BG0="22;22;26"

SEP=$''

seg() { printf '\033[48;2;%sm\033[38;2;%sm\033[1m %s \033[0m' "$1" "$INK" "$2"; }
tip() { printf '\033[48;2;%sm\033[38;2;%sm%s\033[0m' "${2:-$BG0}" "$1" "$SEP"; }

# Green -> yellow -> orange -> red as a percentage climbs
heat() {
  local p=${1:-0}
  if   (( p >= 90 )); then printf '%s' "$RED"
  elif (( p >= 75 )); then printf '%s' "$ORANGE"
  elif (( p >= 50 )); then printf '%s' "$YELLOW"
  else                     printf '%s' "$GREEN"
  fi
}

# 5-cell meter: ▰▰▱▱▱
meter() {
  local p=${1:-0} cells=5 filled i out=""
  filled=$(( (p * cells + 50) / 100 ))
  (( filled > cells )) && filled=$cells
  for (( i = 0; i < cells; i++ )); do
    if (( i < filled )); then out+="▰"; else out+="▱"; fi
  done
  printf '%s' "$out"
}

# ── directory (project-relative, last 3 components) ────────
if [ -n "$PROJECT" ] && [ "$CWD" != "$PROJECT" ] && [[ "$CWD" == "$PROJECT"/* ]]; then
  dir_label="$(basename "$PROJECT")/${CWD#"$PROJECT"/}"
else
  dir_label="${CWD/#$HOME/\~}"
fi
IFS='/' read -ra parts <<<"$dir_label"
if [ "${#parts[@]}" -gt 3 ]; then
  dir_label="…/${parts[-3]}/${parts[-2]}/${parts[-1]}"
fi

# ── git ────────────────────────────────────────────────────
branch=""
git_bg="$GREEN"
if git -C "$CWD" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$CWD" branch --show-current 2>/dev/null)
  [ -z "$branch" ] && branch=$(git -C "$CWD" rev-parse --short HEAD 2>/dev/null)
  if [ -n "$(git -C "$CWD" status --porcelain 2>/dev/null)" ]; then
    git_bg="$ORANGE"
    branch="$branch ✱"
  fi
  ahead_behind=$(git -C "$CWD" rev-list --left-right --count @{upstream}...HEAD 2>/dev/null)
  if [ -n "$ahead_behind" ]; then
    behind=$(awk '{print $1}' <<<"$ahead_behind")
    ahead=$(awk '{print $2}' <<<"$ahead_behind")
    [ "${ahead:-0}" -gt 0 ] 2>/dev/null && branch="$branch ↑$ahead"
    [ "${behind:-0}" -gt 0 ] 2>/dev/null && branch="$branch ↓$behind"
  fi
fi

# ── model label: effort + fast mode ────────────────────────
model_label=$'\U000f0b21'"  $MODEL"
case "$EFFORT" in
  xhigh|max) model_label+=" ⚡" ;;
  high)      model_label+=" ▲"  ;;
  low)       model_label+=" ▽"  ;;
esac
[ "$FAST" = "true" ] && model_label+=" 󱐋"

# ── build ──────────────────────────────────────────────────
out=""
out+=$(seg "$PINK" "$model_label")

out+=$(tip "$PINK" "$PURPLE")
out+=$(seg "$PURPLE" $''"  $dir_label")
last="$PURPLE"

if [ -n "$branch" ]; then
  out+=$(tip "$last" "$git_bg")
  out+=$(seg "$git_bg" $''"  $branch")
  last="$git_bg"
fi

if [ "${LINES_ADD:-0}" != "0" ] || [ "${LINES_DEL:-0}" != "0" ]; then
  out+=$(tip "$last" "$CYAN")
  out+=$(seg "$CYAN" "+${LINES_ADD:-0} −${LINES_DEL:-0}")
  last="$CYAN"
fi

# context window meter
if [ -n "$CTX_PCT" ]; then
  ctx_bg=$(heat "$CTX_PCT")
  out+=$(tip "$last" "$ctx_bg")
  out+=$(seg "$ctx_bg" $''" $(meter "$CTX_PCT") ${CTX_PCT}%")
  last="$ctx_bg"
fi

# 5-hour rate limit (only once it's worth knowing about)
if [ -n "$LIMIT_5H" ] && [ "${LIMIT_5H:-0}" -ge 25 ] 2>/dev/null; then
  lim_bg=$(heat "$LIMIT_5H")
  label="5h ${LIMIT_5H}%"
  [ -n "$LIMIT_7D" ] && [ "${LIMIT_7D:-0}" -ge 60 ] 2>/dev/null && label+=" · 7d ${LIMIT_7D}%"
  out+=$(tip "$last" "$lim_bg")
  out+=$(seg "$lim_bg" $''" $label")
  last="$lim_bg"
fi

# cost
if [ -n "$COST" ]; then
  cost_fmt=$(printf '%.2f' "$COST" 2>/dev/null || echo "$COST")
  if [ "$cost_fmt" != "0.00" ]; then
    out+=$(tip "$last" "$BLUE")
    out+=$(seg "$BLUE" $''" $cost_fmt")
    last="$BLUE"
  fi
fi

# non-default output style
if [ -n "$STYLE" ] && [ "$STYLE" != "default" ] && [ "$STYLE" != "null" ]; then
  out+=$(tip "$last" "$GREEN")
  out+=$(seg "$GREEN" $''" $STYLE")
  last="$GREEN"
fi

# hard context warning
if [ "$OVER200K" = "true" ]; then
  out+=$(tip "$last" "$RED")
  out+=$(seg "$RED" $''" 200k+")
  last="$RED"
fi

out+=$(tip "$last" "")
printf '%s\n' "$out"
