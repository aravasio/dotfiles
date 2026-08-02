#!/usr/bin/env bash
set -euo pipefail

latest_cfg="$(ls -1t "$HOME/.config/i3/backups"/config.*.bak 2>/dev/null | head -n1 || true)"
latest_blocks="$(ls -1t "$HOME/.config/i3/backups"/i3blocks.conf.*.bak 2>/dev/null | head -n1 || true)"

if [[ -z "$latest_cfg" || -z "$latest_blocks" ]]; then
  echo "No backups found in ~/.config/i3/backups"
  exit 1
fi

cp "$latest_cfg" "$HOME/.config/i3/config"
cp "$latest_blocks" "$HOME/.config/i3/i3blocks.conf"

i3-msg restart >/dev/null 2>&1 || true
echo "Rolled back using:"
echo "  $latest_cfg"
echo "  $latest_blocks"
