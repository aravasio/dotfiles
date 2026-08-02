# ── plugins (all optional; nothing breaks if a package is missing) ──
# Load order matters: fzf-tab -> autosuggestions -> syntax-highlighting
#                     -> history-substring-search

_zload() {
  local p
  for p in "$@"; do
    if [[ -r "$p" ]]; then
      source "$p"
      return 0
    fi
  done
  return 1
}

# fzf-tab: replaces the completion menu with fzf (AUR: fzf-tab-git)
_zload /usr/share/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh \
       /usr/share/fzf-tab/fzf-tab.plugin.zsh \
       "$HOME/.oh-my-zsh/custom/plugins/fzf-tab/fzf-tab.plugin.zsh"

# Autosuggestions
if _zload /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh \
          "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"; then
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#5c5a4b'
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)
  ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
  ZSH_AUTOSUGGEST_MANUAL_REBIND=1
fi

# Syntax highlighting — Monokai Boosted
if _zload /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
          "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"; then

  ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern regexp)

  typeset -gA ZSH_HIGHLIGHT_STYLES
  ZSH_HIGHLIGHT_STYLES[default]='fg=#d8d8c8'
  ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#ff2d6f,bold'
  ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#ff79d2,bold'
  ZSH_HIGHLIGHT_STYLES[alias]='fg=#a6f024'
  ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=#a6f024,underline'
  ZSH_HIGHLIGHT_STYLES[global-alias]='fg=#a6f024'
  ZSH_HIGHLIGHT_STYLES[builtin]='fg=#a6f024'
  ZSH_HIGHLIGHT_STYLES[function]='fg=#a6f024,bold'
  ZSH_HIGHLIGHT_STYLES[command]='fg=#a6f024'
  ZSH_HIGHLIGHT_STYLES[precommand]='fg=#a6f024,underline'
  ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#ff79d2'
  ZSH_HIGHLIGHT_STYLES[hashed-command]='fg=#a6f024'
  ZSH_HIGHLIGHT_STYLES[path]='fg=#d8d8c8,underline'
  ZSH_HIGHLIGHT_STYLES[path_pathseparator]='fg=#ff6ac1'
  ZSH_HIGHLIGHT_STYLES[globbing]='fg=#48b8ff'
  ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=#ae81ff'
  ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#ffa41f'
  ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#ffa41f'
  ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=#46d9f0'
  ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#ffdc3d'
  ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#ffdc3d'
  ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#ffdc3d'
  ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=#46d9f0'
  ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]='fg=#46d9f0'
  ZSH_HIGHLIGHT_STYLES[assign]='fg=#ae81ff'
  ZSH_HIGHLIGHT_STYLES[redirection]='fg=#ffa41f,bold'
  ZSH_HIGHLIGHT_STYLES[comment]='fg=#6f6b57,italic'
  ZSH_HIGHLIGHT_STYLES[named-fd]='fg=#46d9f0'
  ZSH_HIGHLIGHT_STYLES[numeric-fd]='fg=#46d9f0'
  ZSH_HIGHLIGHT_STYLES[arg0]='fg=#a6f024'

  # Rainbow nesting
  ZSH_HIGHLIGHT_STYLES[bracket-level-1]='fg=#ff6ac1,bold'
  ZSH_HIGHLIGHT_STYLES[bracket-level-2]='fg=#a6f024,bold'
  ZSH_HIGHLIGHT_STYLES[bracket-level-3]='fg=#48b8ff,bold'
  ZSH_HIGHLIGHT_STYLES[bracket-level-4]='fg=#ffdc3d,bold'
  ZSH_HIGHLIGHT_STYLES[bracket-level-5]='fg=#ae81ff,bold'
  ZSH_HIGHLIGHT_STYLES[cursor-matchingbracket]='standout'

  # Loud warning for destructive commands, before you hit enter
  typeset -gA ZSH_HIGHLIGHT_PATTERNS
  ZSH_HIGHLIGHT_PATTERNS+=('rm -rf *' 'fg=#fdfdf0,bg=#ff2d6f,bold')
  ZSH_HIGHLIGHT_PATTERNS+=('sudo rm *' 'fg=#fdfdf0,bg=#ff2d6f,bold')
  ZSH_HIGHLIGHT_PATTERNS+=('--force' 'fg=#ffa41f,bold')
  ZSH_HIGHLIGHT_PATTERNS+=('--hard' 'fg=#ffa41f,bold')

  # URLs and IPs pop out of long command lines
  typeset -ga ZSH_HIGHLIGHT_REGEXP
  ZSH_HIGHLIGHT_REGEXP+=('https?://[^ ]*' 'fg=#46d9f0,underline')
fi

# Up/down search through history by what you already typed.
# Oh My Zsh vendors this plugin; only load the standalone package if OMZ didn't.
(( $+widgets[history-substring-search-up] )) || \
  _zload /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=#ff6ac1,fg=#16161a,bold'
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='bg=#ff2d6f,fg=#fdfdf0,bold'
HISTORY_SUBSTRING_SEARCH_FUZZY=1
