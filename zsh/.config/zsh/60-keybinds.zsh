# ── keybindings ──────────────────────────────────────────────
bindkey -e   # emacs mode

# History substring search on up/down (falls back to plain history search)
if (( $+widgets[history-substring-search-up] )); then
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
  bindkey '^P'   history-substring-search-up
  bindkey '^N'   history-substring-search-down
fi

# Word-wise movement
bindkey '^[[1;5C' forward-word          # ctrl+right
bindkey '^[[1;5D' backward-word         # ctrl+left
bindkey '^[[1;3C' forward-word          # alt+right
bindkey '^[[1;3D' backward-word         # alt+left
bindkey '^[^?'    backward-kill-word    # alt+backspace
bindkey '^H'      backward-kill-word    # ctrl+backspace

# Line editing
bindkey '^[[H'  beginning-of-line
bindkey '^[[F'  end-of-line
bindkey '^[[3~' delete-char
bindkey '^U'    backward-kill-line
bindkey '^K'    kill-line

# Edit the current command line in $EDITOR: ctrl+x ctrl+e
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

# Accept the autosuggestion with ctrl+space (right-arrow still works)
if (( $+functions[_zsh_autosuggest_widget_accept] )); then
  bindkey '^ ' autosuggest-accept
  bindkey '^[^M' autosuggest-execute   # alt+enter: accept and run
fi

# Fuzzy directory jump on ctrl+g
_fcd_widget() { fcd; zle reset-prompt; }
zle -N _fcd_widget
bindkey '^G' _fcd_widget

# Insert the last argument of the previous command: alt+.
bindkey '^[.' insert-last-word

# Word chars: treat / and . as separators so word-jumps land on path segments
WORDCHARS='*?_-[]~&;!#$%^(){}<>'
