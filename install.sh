#!/usr/bin/env bash
# install.sh — restore these dotfiles onto a running system.
#
# Layout is GNU-stow compatible (each package mirrors $HOME-relative paths),
# but stow is NOT required: this script symlinks everything itself and backs
# up anything it replaces to <path>.pre-dotfiles.<timestamp>.
#
# Usage:
#   ./install.sh            # install all packages
#   ./install.sh i3 kitty   # install only some packages
#   DRY_RUN=1 ./install.sh  # show what would happen, change nothing
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${TARGET:-$HOME}"
TS="$(date +%Y%m%d-%H%M%S)"
DRY_RUN="${DRY_RUN:-0}"

ALL_PACKAGES=(i3 kitty picom rofi dunst zsh starship git tmux gtk x bin opencode theme-forge machine-facts claude codex wallpapers env local)
if [ $# -gt 0 ]; then
  PACKAGES=("$@")
else
  PACKAGES=("${ALL_PACKAGES[@]}")
fi

link_one() {
  local src="$1" dst="$2"
  # already correct?
  if [ -L "$dst" ] && [ "$(readlink -f "$dst")" = "$(readlink -f "$src")" ]; then
    return 0
  fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    echo "  backup: $dst -> $dst.pre-dotfiles.$TS"
    [ "$DRY_RUN" = 1 ] || mv "$dst" "$dst.pre-dotfiles.$TS"
  fi
  echo "  link:   $dst -> $src"
  if [ "$DRY_RUN" != 1 ]; then
    mkdir -p "$(dirname "$dst")"
    ln -sfn "$src" "$dst"
  fi
}

for pkg in "${PACKAGES[@]}"; do
  [ -d "$DOTFILES_DIR/$pkg" ] || { echo "!! unknown package: $pkg"; exit 1; }
  echo "== $pkg =="
  # files and symlinks, file-level linking (dirs stay real directories)
  while IFS= read -r -d '' src; do
    rel="${src#"$DOTFILES_DIR/$pkg/"}"
    link_one "$src" "$TARGET/$rel"
  done < <(find "$DOTFILES_DIR/$pkg" \( -type f -o -type l \) -print0)
done

echo
echo "Done. Backups use suffix .pre-dotfiles.$TS"
echo "Remember: secrets are NOT in this repo — create ~/.zshrc.local (see AGENTS.md)."
