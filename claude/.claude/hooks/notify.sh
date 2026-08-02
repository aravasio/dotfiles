#!/usr/bin/env bash
# Claude Code -> dunst notification + sound + kitty tab color.
# Wired to the Notification and Stop hooks in ~/.claude/settings.json.
# Never fails the turn: always exits 0.

set -uo pipefail

# Skip notifications when you're already looking at this kitty window.
SKIP_IF_FOCUSED=1

input=$(cat 2>/dev/null || echo '{}')
j() { jq -r "$1 // empty" <<<"$input" 2>/dev/null; }

event=$(j '.hook_event_name')
message=$(j '.message')
cwd=$(j '.cwd')
project=$(basename "${cwd:-$PWD}")

# ── is this window in the foreground? ─────────────────────────
is_focused() {
  [[ -n "${KITTY_LISTEN_ON:-}" && -n "${KITTY_WINDOW_ID:-}" ]] || return 1
  kitten @ --to "$KITTY_LISTEN_ON" ls 2>/dev/null | jq -e \
    --arg wid "$KITTY_WINDOW_ID" \
    '[.[] | select(.is_focused == true) | .tabs[] | select(.is_focused == true)
      | .windows[] | select((.id|tostring) == $wid)] | length > 0' >/dev/null 2>&1
}

tab_color() {  # tab_color <active_bg|NONE>
  [[ -n "${KITTY_LISTEN_ON:-}" ]] || return 0
  if [[ -n "${KITTY_WINDOW_ID:-}" ]]; then
    kitten @ --to "$KITTY_LISTEN_ON" set-tab-color \
      --match "window_id:$KITTY_WINDOW_ID" "active_bg=$1" >/dev/null 2>&1 || true
  fi
}

ding() {  # ding <sound-file>
  [[ -r "$1" ]] || return 0
  (paplay "$1" >/dev/null 2>&1 &) || true
}

# Mark the whole i3 tile urgent (border + workspace button go red).
# i3 clears the flag by itself when the window gains focus.
set_urgent() {  # set_urgent <0|1>
  [[ -n "${WINDOWID:-}" ]] || return 0
  DISPLAY="${DISPLAY:-:0}" xdotool set_window --urgency "$1" "$WINDOWID" >/dev/null 2>&1 || true
}

SOUNDS=/usr/share/sounds/freedesktop/stereo

case "$event" in
  Notification)
    # Claude is blocked on you: permission prompt, question, idle input.
    tab_color "#ffa41f"
    set_urgent 1
    if (( SKIP_IF_FOCUSED )) && is_focused; then exit 0; fi
    notify-send -a "Claude Code" -u critical \
      -i dialog-question \
      "󰭹  Claude needs you" "${message:-waiting for input} — $project"
    ding "$SOUNDS/message.oga"
    ;;

  Stop)
    # Turn finished.
    tab_color NONE
    set_urgent 0
    if (( SKIP_IF_FOCUSED )) && is_focused; then exit 0; fi
    notify-send -a "Claude Code" -u normal \
      -i dialog-information \
      "  Claude done" "$project"
    ding "$SOUNDS/complete.oga"
    ;;

  *)
    : ;;
esac

exit 0
