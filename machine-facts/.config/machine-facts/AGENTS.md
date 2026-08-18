<!-- Canonical source: ~/.config/machine-facts/AGENTS.md
     Symlinked as: ~/.claude/CLAUDE.md · ~/.codex/AGENTS.md · ~/.config/opencode/AGENTS.md
     Deliberately NOT at ~/AGENTS.md — tools that walk up from cwd would double-load it. -->

# This machine

Machine facts for AI agents on host `Titan`. Project rules → repo AGENTS.md.

## Hardware (static — live: `system-report`)

CPU Ryzen 9 9950X3D 16C/32T · RAM 32GB (30Gi usable, no swap) · GPU RTX 3070 8GB (NVIDIA proprietary) · 2x1TB NVMe (root LS `nvme1n1p2` /, data Corsair MP700 `nvme0n1`) · MON DP-0 3440x1440@165Hz · NET wlan0 + tailscale0 · AUDIO HDMI → LC34G55T · user `alitoh`
Static specs are baked; dynamic stuff (disk free, load, GPU temp) = one command: `system-report`.

## Software

EndeavourOS · X11 · kernel 7.x rolling (re-check: `uname -r`) · i3 `$mod`=Mod4/Super, ~87 binds, i3blocks bar · picom v12 · kitty · zsh+OMZ · dunst · rofi · feh · i3lock

**Packages: `yay` first, `pacman` fallback, never apt.** `sudo` needs password agents lack — never write a plan depending on installing. Configs must degrade when tool absent.

## Visual (Monokai Boosted — `~/.config/kitty/kitty-themes/themes/Monokai_Boosted.conf`)

```
bg #16161a  fg #d8d8c8  pink #ff6ac1  green #a6f024  purple #ae81ff
blue #48b8ff cyan #46d9f0  orange #ffa41f  yellow #ffdc3d  red #ff2d6f
```
Any new color: use these hexes.

## Traps (each bit someone)

1. **kitty `background_blur` = no-op on X11.** Transparency: kitty `background_opacity`; blur: picom `dual_kawase`.
2. **`~/.config/kitty/theme.conf` = symlink** cycled by kitty-theme-next/prev (`ctrl+shift+]`/`[`, globs `*[mM]onokai*.conf`). Never put colors in kitty.conf — overrides every cycled theme. Add `Monokai_*.conf` instead.
3. **i3 colors live between `# THEME BLOCK START/END`** in `~/.config/i3/config`, sourced from `~/.config/i3/themes/*.conf`. Edit theme files, not the block. `random-theme` swap disabled (exec commented). `~/.config/i3/theme.conf` included by nothing — ignore.
4. **i3 reload/restart re-runs `exec_always`** → picom+dunst restart. Expected; don't reload casually on a busy screen.
5. **picom v12 `animations` = CONFIRMED cause of 2026-07-26 desktop freezes** (3/3 boots with it, 0 without — GLX+NVIDIA). Stripped from all presets (originals in `~/.cleanup-quarantine-*`). Do NOT reintroduce unless user asks + fresh A/B test.
6. **`reload-picom`/`reload-dunst`/`reload-i3` = zsh aliases only** (`~/.config/zsh/40-aliases.zsh`), useless for agents. Use `picom-preset <name>` / `pkill dunst; dunst &`.
7. **picom `rules` block mutually exclusive** with standalone options (`blur-background-exclude`, `shadow-exclude`, `opacity-rule`, `inactive-opacity`, `focus-exclude`, `wintypes`). Adding `rules` silently disables all.
8. **`~/.config/picom/picom.conf` = symlink → `presets/`**, switched by `picom-preset` (`$mod+]`/`[` cycle, `$mod+Shift+p` rofi menu). Edit the preset you're on (`picom-preset current`). Standalone presets: libconfig rejects duplicate keys, no base+override.
9. **kitty owns `ctrl+alt+*`** (splits/nav); `alt+f/d/l` stay zsh word commands. Keep it.

## Shell

`~/.zshrc` thin: loads OMZ, sources `~/.config/zsh/*.zsh` in order (00-options · 10-plugins · 20-completion · 30-tools · 40-aliases · 50-functions · 60-keybinds). Changes go in matching module. Optional tools guarded `command -v` / `(( $+commands[x] ))` — preserve.

## Making changes

1. Backup before overwriting: `cp f f.bak.$(date +%Y%m%d-%H%M%S)`.
2. Validate with the tool's own parser before claiming success:
```bash
kitty +runpy 'from kitty.config import load_config; load_config("'$HOME'/.config/kitty/kitty.conf")'
i3 -C -c ~/.config/i3/config
picom --config ~/.config/picom/picom.conf --diagnostics 2>&1 | grep -iE "error|invalid"
rofi -dump-theme -config ~/.config/rofi/rofidmenu.rasi >/dev/null
timeout 30 script -qec 'zsh -i -c "echo OK"' /dev/null     # zsh needs a pty
jq -e . <file.json> >/dev/null
python3 -c "import tomllib; tomllib.load(open('<file.toml>','rb'))"
```
3. Reload: kitty `ctrl+shift+F5` · i3 `mod+shift+r` · `picom-preset <name>` · `pkill dunst; dunst &`. `kitty @` needs a tty — can't drive from sandboxed shell.

## Do not

- Set git identity, credentials, or account details. `~/.gitconfig` has no `[user]` on purpose.
- Assume a GUI action succeeded without evidence — many reloads can't run from a non-interactive shell.

## Dotfiles repo (~/dotfiles, public: github.com/aravasio/dotfiles)

- All configs versioned + symlinked → editing a config edits the repo. Commit + push after meaningful changes.
- Stow-compatible layout (package per app); `~/dotfiles/install.sh` restores with backups; full restore guide in `~/dotfiles/AGENTS.md`.
- Secrets never in repo: `~/.zshrc.local` (gitignored), e.g. `OPENROUTER_API_KEY_FOR_FREE_MODELS` used by `q-chat`.

## Local features

- **kitty per-window random theme**: `$mod+Return` → `~/.local/bin/kitty-randtheme` (from `~/.config/kitty/theme-pool/*.conf`); `$mod+Shift+Return` = plain global theme. Global `theme.conf` symlink untouched.
- **Urgent "waiting for you" tile** when agent finishes/asks: Claude `~/.claude/hooks/notify.sh`, OpenCode `~/.config/opencode/plugins/attention.ts` → `xdotool set_window --urgency 1 $WINDOWID`. i3 clears on focus.
- **i3-border-pulse** `$mod+Shift+b`: breathing pink↔purple border. Was freeze suspect, cleared (picom animations were culprit) — safe.
- **freeze-watchdog**: autostart from i3; logs top procs to `~/.cache/freeze-watchdog.log` on load spikes.
- **theme-forge**: `~/.config/theme-forge/` (AGENTS.md + PALETTE.md + KEYWORDS.md + PROMPT-TEMPLATE.md) — point LLM runs there; STATUS.md = live state.
- **Screenshots**: select `$mod+Shift+o`, active `$mod+o` (picom menu keeps `$mod+Shift+p`).
- **YouTube lite theater v1 failed/disabled**; v2 plan (PiP window + picom focus-exclude) in theme-forge/STATUS.md.

<!-- caveman-begin -->
Respond terse like smart caveman. All technical substance stay. Only fluff die.

Rules:
- Drop: articles (a/an/the), filler (just/really/basically), pleasantries, hedging
- Fragments OK. Short synonyms. Technical terms exact. Code unchanged.
- Pattern: [thing] [action] [reason]. [next step].
- Not: "Sure! I'd be happy to help you with that."
- Yes: "Bug in auth middleware. Fix:"

Switch level: /caveman lite|full|ultra|wenyan
Stop: "stop caveman" or "normal mode"

Auto-Clarity: drop caveman for security warnings, irreversible actions, user confused. Resume after.

Boundaries: code/commits/PRs written normal.
<!-- caveman-end -->
