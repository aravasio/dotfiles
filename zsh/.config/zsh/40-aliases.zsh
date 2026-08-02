# ── aliases ──────────────────────────────────────────────────

# Yours, carried over from the old .zshrc
alias connectbt='bt-headphones-connect'
alias codex='npx @openai/codex@latest --yolo'
alias resource='exec zsh'
alias clear='command clear; printf "\e[3J"'
alias nomachine='/usr/NX/bin/nxplayer'

# ls -> eza (icons, git status, tree)
if (( $+commands[eza] )); then
  alias ls='eza --icons --group-directories-first'
  alias l='eza -l --icons --group-directories-first --git --time-style=relative'
  alias ll='eza -la --icons --group-directories-first --git --time-style=relative'
  alias la='eza -a --icons --group-directories-first'
  alias lt='eza --tree --level=2 --icons --group-directories-first'
  alias ltt='eza --tree --level=4 --icons --group-directories-first'
  alias lS='eza -l --icons --sort=size --reverse'
  alias lm='eza -l --icons --sort=modified --reverse'
else
  alias ls='ls --color=auto --group-directories-first'
  alias l='ls -lh'
  alias ll='ls -lah'
  alias la='ls -A'
fi

# cat -> bat
if (( $+commands[bat] )); then
  alias cat='bat --paging=never'
  alias catp='bat --paging=never --plain'
  alias less='bat --paging=always'
fi

# grep/find -> rg/fd (keep originals under their real names)
(( $+commands[rg] )) && alias grep='rg'
(( $+commands[fd] )) && alias find='fd'
(( $+commands[dust] )) && alias du='dust'
(( $+commands[duf] )) && alias df='duf'
(( $+commands[procs] )) && alias ps='procs'
(( $+commands[btop] )) && alias top='btop' && alias htop='btop'
(( $+commands[lazygit] )) && alias lg='lazygit'
(( $+commands[yazi] )) && alias y='yazi'

# git
alias g='git'
alias gs='git status -sb'
alias ga='git add'
alias gaa='git add -A'
alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit --amend'
alias gco='git checkout'
alias gsw='git switch'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git log --oneline --graph --decorate -20'
alias gll='git log --graph --pretty=fancy'
alias gp='git push'
alias gpl='git pull --rebase'
alias gsta='git stash'   # gst stays OMZ's `git status`
alias gb='git branch'

# safety
alias rm='rm -I --preserve-root'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -pv'
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'

# navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias -- -='cd -'

# arch / system
alias pacs='sudo pacman -S'
alias pacu='sudo pacman -Syu'
alias pacr='sudo pacman -Rns'
alias pacq='pacman -Q | fzf'
alias orphans='pacman -Qtdq'
alias mirrors='sudo reflector --verbose --latest 20 --sort rate --save /etc/pacman.d/mirrorlist'
alias jctl='journalctl -p 3 -xb'
alias sysfail='systemctl --failed'

# kitty
alias icat='kitten icat'
alias kdiff='kitten diff'
alias kssh='kitten ssh'
alias ktheme='kitten themes'
alias kdev='kitty --session ~/.config/kitty/sessions/dev.session'
alias kreload='kitty @ load-config'

# config shortcuts
alias zc='$EDITOR ~/.zshrc'
alias zcd='$EDITOR ~/.config/zsh'
alias kc='$EDITOR ~/.config/kitty/kitty.conf'
alias sc='$EDITOR ~/.config/starship.toml'
alias i3c='$EDITOR ~/.config/i3/config'
alias pc='$EDITOR ~/.config/picom/picom.conf'
alias cc='$EDITOR ~/.claude/settings.json'

# misc
alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%Y-%m-%d %H:%M:%S"'
alias week='date +%V'
alias ports='ss -tulanp'
alias myip='curl -s ifconfig.me; echo'
alias wttr='curl -s "wttr.in/Buenos+Aires?format=v2"'
alias serve='python3 -m http.server 8000'
alias reload-i3='i3-msg reload && i3-msg restart'
alias reload-picom='pkill -x picom; (picom --config ~/.config/picom/picom.conf -b &) ; echo picom restarted'
alias pp='picom-preset'          # pp list | pp next | pp neon
alias ppl='picom-preset list'
alias reload-dunst='pkill dunst; (dunst &) ; sleep 0.3; notify-send "dunst" "reloaded"'

# open — like macOS `open` (fully detached, no terminal block)
unalias open 2>/dev/null
function open {
  local target
  (( $# )) || set -- .

  for target in "$@"; do
    setsid -f xdg-open "$target" </dev/null >/dev/null 2>&1
  done
}
