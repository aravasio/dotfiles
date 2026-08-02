# ── completion styling ───────────────────────────────────────
zmodload zsh/complist 2>/dev/null

# Case-insensitive, then partial-word, then substring matching
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' \
  'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

zstyle ':completion:*' menu no                     # fzf-tab handles the menu
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' verbose yes
zstyle ':completion:*' group-name ''
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"
zstyle ':completion:*' rehash true

# Colored section headers in the completion list
zstyle ':completion:*:*:*:*:descriptions' format $'\e[1;38;2;255;106;193m  %d\e[0m'
zstyle ':completion:*:*:*:*:corrections'  format $'\e[1;38;2;255;164;31m  %d (errors: %e)\e[0m'
zstyle ':completion:*:messages'           format $'\e[1;38;2;174;129;255m  %d\e[0m'
zstyle ':completion:*:warnings'           format $'\e[1;38;2;255;45;111m  no matches\e[0m'

# Nicer process completion for kill
zstyle ':completion:*:*:kill:*:processes' list-colors \
  '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;38;5;244=0=01;38;5;199'
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:*:kill:*' force-list always

# man pages grouped by section
zstyle ':completion:*:manuals' separate-sections true

# ── fzf-tab ──────────────────────────────────────────────────
if (( $+functions[fzf-tab-complete] )); then
  zstyle ':fzf-tab:*' fzf-command fzf
  zstyle ':fzf-tab:*' fzf-flags --height=50% --layout=reverse --border=rounded \
    --color=fg:#d8d8c8,bg:-1,hl:#ff2d6f,fg+:#fdfdf0,bg+:#232526,hl+:#ff5c8a \
    --color=info:#ae81ff,prompt:#46d9f0,pointer:#ff6ac1,marker:#a6f024,border:#ff6ac1
  zstyle ':fzf-tab:*' switch-group ',' '.'
  zstyle ':fzf-tab:*' prefix ''
  zstyle ':fzf-tab:*' continuous-trigger '/'
  zstyle ':fzf-tab:*' fzf-bindings 'ctrl-/:toggle-preview'

  # Previews: directories as a colored tree, files through bat
  if (( $+commands[eza] )); then
    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --icons --color=always --group-directories-first $realpath'
    zstyle ':fzf-tab:complete:z:*'  fzf-preview 'eza -1 --icons --color=always --group-directories-first $realpath'
    zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza -1 --icons --color=always $realpath'
  fi
  if (( $+commands[bat] )); then
    zstyle ':fzf-tab:complete:*:*' fzf-preview \
      '[[ -d $realpath ]] && ls --color=always $realpath || bat --color=always --style=numbers --line-range=:200 $realpath 2>/dev/null'
  fi
  # systemctl / env / man previews
  zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word'
  zstyle ':fzf-tab:complete:(-command-|export|unset|expand):*' \
    fzf-preview 'echo ${(P)word}'
  zstyle ':fzf-tab:complete:(\\|*/|)man:*' fzf-preview 'man $word 2>/dev/null | col -bx | bat -l man -p --color=always 2>/dev/null || man $word'
fi
