# ── tool integrations (each guarded) ─────────────────────────

# LS_COLORS: vivid generates a full truecolor set; fall back to a hand-rolled one
if (( $+commands[vivid] )); then
  export LS_COLORS="$(vivid generate molokai 2>/dev/null || vivid generate snazzy)"
else
  export LS_COLORS='di=1;38;2;72;184;255:ln=1;38;2;70;217;240:so=38;2;255;121;210:pi=38;2;255;220;61:ex=1;38;2;166;240;36:bd=38;2;255;164;31;1:cd=38;2;255;164;31;1:su=38;2;253;253;240;48;2;255;45;111:sg=38;2;253;253;240;48;2;255;164;31:tw=38;2;22;22;26;48;2;166;240;36:ow=38;2;72;184;255;1:or=38;2;253;253;240;48;2;255;45;111:mi=38;2;255;45;111;1:*.tar=38;2;255;121;210:*.zip=38;2;255;121;210:*.gz=38;2;255;121;210:*.md=38;2;255;220;61:*.json=38;2;255;164;31:*.ts=38;2;72;184;255:*.tsx=38;2;72;184;255:*.js=38;2;255;220;61:*.py=38;2;166;240;36:*.rs=38;2;255;164;31:*.go=38;2;70;217;240:*.sh=38;2;166;240;36:*.png=38;2;174;129;255:*.jpg=38;2;174;129;255:*.mp4=38;2;174;129;255:*.pdf=38;2;255;45;111'
fi
export EZA_COLORS="uu=38;2;111;107;87:gu=38;2;111;107;87:da=38;2;111;107;87:ur=38;2;166;240;36:uw=38;2;255;164;31:ux=38;2;255;45;111:ue=38;2;255;45;111"

# zoxide — smarter cd, `z foo` jumps, `zi` fuzzy-picks
if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh)"
fi

# starship prompt
if (( $+commands[starship] )); then
  eval "$(starship init zsh)"
  export STARSHIP_CONFIG="$HOME/.config/starship.toml"
fi

# ── fzf ──────────────────────────────────────────────────────
if (( $+commands[fzf] )); then
  if (( $+commands[fd] )); then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git --exclude node_modules'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git --exclude node_modules'
  fi

  export FZF_DEFAULT_OPTS="
    --height=60% --layout=reverse --border=rounded --margin=0,1 --padding=0
    --info=inline-right --separator='─' --scrollbar='│'
    --prompt='  ' --pointer='' --marker=''
    --color=fg:#d8d8c8,bg:-1,hl:#ff2d6f
    --color=fg+:#fdfdf0,bg+:#232526,hl+:#ff5c8a
    --color=info:#ae81ff,prompt:#46d9f0,pointer:#ff6ac1
    --color=marker:#a6f024,spinner:#ffdc3d,header:#6f6b57
    --color=border:#ff6ac1,label:#ae81ff,query:#fdfdf0
    --bind='ctrl-/:toggle-preview'
    --bind='ctrl-u:preview-page-up,ctrl-d:preview-page-down'
    --bind='ctrl-a:select-all,ctrl-x:deselect-all'
    --bind='ctrl-y:execute-silent(printf %s {} | kitten clipboard)+abort'
    --bind='alt-enter:print-query'
  "

  export FZF_CTRL_T_OPTS="
    --preview '[[ -d {} ]] && (eza -T -L2 --icons --color=always {} 2>/dev/null || ls -la {}) || bat -n --color=always --line-range=:300 {} 2>/dev/null || cat {}'
    --preview-window=right,60%,border-left
    --header='ENTER open · CTRL-/ preview · CTRL-Y copy'
  "
  export FZF_ALT_C_OPTS="
    --preview 'eza -T -L2 --icons --color=always {} 2>/dev/null || ls -la {}'
    --preview-window=right,55%,border-left
    --header='jump to directory'
  "
  export FZF_CTRL_R_OPTS="
    --preview 'echo {}' --preview-window=down,4,wrap,border-top
    --header='CTRL-Y copy command · ENTER run'
  "

  # keybindings + completion (paths differ across distros)
  for _f in /usr/share/fzf/key-bindings.zsh /usr/share/zsh/site-functions/fzf-key-bindings.zsh; do
    [[ -r $_f ]] && source $_f && break
  done
  for _f in /usr/share/fzf/completion.zsh /usr/share/zsh/site-functions/fzf-completion.zsh; do
    [[ -r $_f ]] && source $_f && break
  done
  unset _f
fi

# bat as the man pager, with syntax coloring
if (( $+commands[bat] )); then
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
  export MANROFFOPT="-c"
  export BAT_THEME="${BAT_THEME:-Monokai Extended}"
fi

# atuin — full-text, synced shell history (ctrl+r takeover)
if (( $+commands[atuin] )); then
  eval "$(atuin init zsh --disable-up-arrow)"
fi

# Rust/Node niceties if present
(( $+commands[rustup] )) && export CARGO_TERM_COLOR=always
export FORCE_COLOR=1              # colored output from node CLIs
export CLICOLOR=1
