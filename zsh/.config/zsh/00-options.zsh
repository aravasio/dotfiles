# ── zsh behaviour ────────────────────────────────────────────
# History: big, shared, deduped, timestamped.
HISTFILE=${HISTFILE:-$HOME/.zsh_history}
HISTSIZE=200000
SAVEHIST=200000

setopt EXTENDED_HISTORY          # timestamps
setopt SHARE_HISTORY             # live-share between open shells
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE         # " cmd" stays out of history
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY               # expand !! before running

# Directory stack: `cd -<TAB>` browses recent dirs
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
DIRSTACKSIZE=20

# Globbing & misc
setopt EXTENDED_GLOB
setopt GLOB_DOTS                 # globs match dotfiles
setopt NUMERIC_GLOB_SORT
setopt NO_BEEP
setopt INTERACTIVE_COMMENTS
setopt LONG_LIST_JOBS
setopt PROMPT_SUBST

# Don't nag when a glob matches nothing (lets `ls *.md` fail softly)
setopt NO_NOMATCH

export EDITOR="${EDITOR:-nvim}"
export VISUAL="$EDITOR"
export PAGER="less"
export LESS="-R --mouse --wheel-lines=3"

# Colored man pages even without the OMZ plugin
export LESS_TERMCAP_mb=$'\e[1;38;2;255;45;111m'
export LESS_TERMCAP_md=$'\e[1;38;2;255;106;193m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_so=$'\e[1;38;2;22;22;26;48;2;255;220;61m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_us=$'\e[4;38;2;166;240;36m'
export LESS_TERMCAP_ue=$'\e[0m'
