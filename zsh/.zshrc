# ═══════════════════════════════════════════════════════════════
#  zsh — thin entrypoint. Real config lives in ~/.config/zsh/*.zsh
#  Old version: ~/.zshrc.bak.*  (restore with `cp ~/.zshrc.bak.<ts> ~/.zshrc`)
# ═══════════════════════════════════════════════════════════════

export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$PATH"

# ── Oh My Zsh ────────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"

# starship draws the prompt when installed; otherwise keep the old theme
if command -v starship >/dev/null 2>&1; then
  ZSH_THEME=""
else
  ZSH_THEME="robbyrussell"
fi

COMPLETION_WAITING_DOTS="%F{213}…%f"
zstyle ':omz:update' mode reminder

plugins=(
  git                 # aliases + prompt info
  sudo                # ESC ESC prefixes the last command with sudo
  colored-man-pages
  copypath copyfile   # copy $PWD / a file to the clipboard
  dirhistory          # alt+arrows walk the directory history
  web-search          # `google foo`, `ddg foo`
  safe-paste
  history-substring-search
  command-not-found
)

source $ZSH/oh-my-zsh.sh

# ── modular config ───────────────────────────────────────────
# 00 options · 10 plugins · 20 completion · 30 tools
# 40 aliases · 50 functions · 60 keybinds
for _mod in "$HOME"/.config/zsh/*.zsh(N); do
  source "$_mod"
done
unset _mod

# ── greeting ─────────────────────────────────────────────────
# Banner only in a fresh top-level shell — not in splits, tmux, or Claude Code.
if [[ -o interactive && $SHLVL -eq 1 && -z "$TMUX" && -z "$CLAUDECODE" ]]; then
  if command -v fastfetch >/dev/null 2>&1; then
    fastfetch
  fi
fi

# Machine-local additions go here, uncommitted (API keys live here too):
[[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
