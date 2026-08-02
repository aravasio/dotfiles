# ── functions ────────────────────────────────────────────────

# mkdir + cd
mkcd() { mkdir -p "$1" && cd "$1"; }

# Up N directories: `up 3`
up() { local n=${1:-1}; local p=""; for _ in $(seq $n); do p="../$p"; done; cd "$p"; }

# Fuzzy-kill a process
fkill() {
  local pid
  pid=$(ps -eo pid,ppid,%cpu,%mem,comm,args --sort=-%cpu | sed 1d |
    fzf -m --header='select process(es) to kill' \
        --preview='echo {}' --preview-window=down,3,wrap | awk '{print $1}')
  [[ -n "$pid" ]] && echo "$pid" | xargs kill -${1:-15} && echo "killed: $pid"
}

# Fuzzy cd into any subdirectory
fcd() {
  local dir
  dir=$(fd --type d --hidden --exclude .git ${1:-.} 2>/dev/null |
    fzf --preview 'eza -T -L2 --icons --color=always {} 2>/dev/null || ls -la {}') \
    && cd "$dir"
}

# Ripgrep -> fzf -> open in $EDITOR at the matching line
frg() {
  local file line
  IFS=: read -r file line _ < <(
    rg --line-number --no-heading --color=always --smart-case "${*:-}" 2>/dev/null |
    fzf --ansi --delimiter=: \
        --preview 'bat --color=always --highlight-line {2} --style=numbers {1}' \
        --preview-window='right,60%,+{2}+3/3,border-left'
  )
  [[ -n "$file" ]] && ${EDITOR} "+${line}" "$file"
}

# Browse git log with a live diff preview
fgl() {
  git log --graph --color=always --format='%C(auto)%h %C(blue)%an %C(green)%cr%C(reset) %s' "$@" |
  fzf --ansi --no-sort --reverse --tiebreak=index \
      --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | head -1 |
                 xargs -I@ sh -c "git show --color=always @ | delta 2>/dev/null || git show --color=always @"' \
      --preview-window=right,60%,border-left \
      --bind='enter:execute(grep -o "[a-f0-9]\{7,\}" <<< {} | head -1 | xargs -I@ sh -c "git show --color=always @ | less -R")'
}

# Switch branches, with the branch log as preview
fgb() {
  local branch
  branch=$(git branch -a --color=always --sort=-committerdate |
    grep -v HEAD | fzf --ansi --preview 'git log --oneline --color=always --graph -20 $(sed "s/^[* ]*//;s#remotes/[^/]*/##" <<< {})' |
    sed 's/^[* ]*//;s#remotes/[^/]*/##')
  [[ -n "$branch" ]] && git switch "$branch"
}

# Interactive history search that puts the command on the prompt
fh() {
  print -z -- "$(fc -rl 1 | fzf --tac --no-sort --header='pick a command' | sed 's/ *[0-9]* *//')"
}

# Extract any archive
extract() {
  [[ -f "$1" ]] || { echo "no such file: $1"; return 1; }
  case "$1" in
    *.tar.bz2|*.tbz2) tar xjf "$1"   ;;
    *.tar.gz|*.tgz)   tar xzf "$1"   ;;
    *.tar.xz)         tar xJf "$1"   ;;
    *.tar.zst)        tar --zstd -xf "$1" ;;
    *.tar)            tar xf "$1"    ;;
    *.bz2)            bunzip2 "$1"   ;;
    *.gz)             gunzip "$1"    ;;
    *.zip)            unzip "$1"     ;;
    *.7z)             7z x "$1"      ;;
    *.rar)            unrar x "$1"   ;;
    *.zst)            unzstd "$1"    ;;
    *) echo "don't know how to extract $1" ;;
  esac
}

# Hyperlinked ripgrep — click a result in kitty to open it in your editor
rgh() { kitten hyperlinked-grep "$@"; }

# Show every color the terminal can do — useful when tuning a palette
colortest() {
  print -P "\n%B ANSI 16 %b"
  local i
  for i in {0..15}; do
    printf "\e[48;5;${i}m  \e[0m"
    (( (i+1) % 8 == 0 )) && echo
  done
  print -P "\n%B 256 cube %b"
  for i in {16..231}; do
    printf "\e[48;5;${i}m \e[0m"
    (( (i-15) % 36 == 0 )) && echo
  done
  echo
  print -P "\n%B truecolor gradient %b"
  local r g b
  for i in {0..79}; do
    r=$(( 255 - i*3 )); g=$(( i*3 )); b=$(( 128 + (i%2)*60 ))
    printf "\e[48;2;${r};${g};${b}m \e[0m"
  done
  echo "\n"
  print -P "%B styles %b: \e[1mbold\e[0m \e[2mdim\e[0m \e[3mitalic\e[0m \e[4munderline\e[0m \e[4:3;58;2;255;45;111mundercurl\e[0m \e[9mstrike\e[0m \e[7mreverse\e[0m\n"
}

# Nerd Font smoke test
nerdtest() {
  echo "        "
  echo "        "
  echo "  ─  ─  ─  (powerline)"
  echo "  󰊤 󰊕 󰅬 󰈙 󰉋  (material)"
}

# Weather, one-liner
forecast() { curl -s "wttr.in/${1:-Buenos+Aires}"; }

# What's taking up space here
biggest() { du -ah . 2>/dev/null | sort -rh | head -${1:-20}; }

# Backup a file with a timestamp
bak() { cp -a "$1" "$1.bak.$(date +%Y%m%d-%H%M%S)" && echo "backed up -> $1.bak.$(date +%Y%m%d-%H%M%S)"; }

# Pretty-print JSON from clipboard or stdin
jqp() { jq -C . "${@:--}" | less -R; }

# Claude Code helpers
cl()  { claude "$@"; }
clr() { claude --resume; }
clc() { claude --continue; }

# caffeine-ng 4.3.2 spews two upstream warnings (libayatana-appindicator
# deprecation + a GTK3 gdk_window_thaw_toplevel_updates assert). Both cosmetic,
# neither fixable locally. Drop just those lines, keep real errors.
if (( $+commands[caffeine] )); then
  caffeine() {
    command caffeine "$@" 2>&1 >&2 \
      | grep -vE 'libayatana-appindicator is deprecated|gdk_window_thaw_toplevel_updates'
  }
fi
