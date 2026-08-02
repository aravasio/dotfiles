<!-- Canonical source: ~/.config/machine-facts/AGENTS.md
     Symlinked as: ~/.claude/CLAUDE.md · ~/.codex/AGENTS.md · ~/.config/opencode/AGENTS.md
     Deliberately NOT at ~/AGENTS.md — tools that walk up from cwd would double-load it. -->

# This machine

Instructions for any AI agent operating on this host. Machine facts only — no
project-specific opinions. Project rules belong in each repo's own AGENTS.md.

## What it is

- **EndeavourOS** (Arch-based), kernel 6.18, **X11**
- **i3** window manager, `$mod` = Mod4/Super, ~110 keybindings, i3blocks status bar
- **picom** v12.5 compositor · **kitty** terminal · **zsh + Oh My Zsh** · **dunst** · **rofi** · **feh** · **i3lock**
- NVIDIA RTX 3070 (proprietary driver), single 3440x1440 ultrawide
- User: `alitoh`

**Package management: `yay` first, `pacman` only as fallback** (user
preference; never apt). `sudo` requires a password that agents do not have —
never write a plan that depends on installing something. Configuration must
degrade gracefully when a tool is absent.

## Visual configuration

All colors derive from one palette, **Monokai Boosted**, defined in
`~/.config/kitty/kitty-themes/themes/Monokai_Boosted.conf`:

```
bg #16161a   fg #d8d8c8   pink #ff6ac1   green #a6f024   purple #ae81ff
blue #48b8ff  cyan #46d9f0  orange #ffa41f  yellow #ffdc3d  red #ff2d6f
```

Anything new that shows color should use these hexes.

### Traps — each of these has bitten someone here

- **kitty's `background_blur` does nothing on X11** (Wayland-only). Transparency
  comes from kitty (`background_opacity`), blur from picom (`dual_kawase`).
- **`~/.config/kitty/theme.conf` is a symlink** cycled by `kitty-theme-next`/`prev`
  (`ctrl+shift+]`/`[`), which globs `*[mM]onokai*.conf`. Never put color
  directives in `kitty.conf` — they would override every cycled theme. Add a new
  `Monokai_*.conf` file instead.
- **i3 colors live between `# THEME BLOCK START/END`** in `~/.config/i3/config`,
  from `~/.config/i3/themes/*.conf`. `~/.config/i3/scripts/random-theme` can
  swap the block on login but is **currently disabled** (its exec line is
  commented). Edit the theme files, not the block.
  `~/.config/i3/theme.conf` exists but is **not** included by anything — ignore it.
- **Any i3 reload/restart re-runs `exec_always`** → picom and dunst restart.
  Expected side effect, not a bug — but don't reload i3 casually on a busy screen.
- **picom's v12 `animations` engine is the CONFIRMED cause of the 2026-07-26
  full-desktop freezes** (3/3 crash boots with it, 0 without — GLX + NVIDIA 590).
  It is stripped from all presets (originals in
  `~/.config/picom/presets-animated-backup-*.tgz`). Do NOT reintroduce an
  `animations` block unless the user explicitly asks and a fresh A/B test is run.
- **`reload-picom` / `reload-dunst` / `reload-i3` are zsh aliases**
  (`~/.config/zsh/40-aliases.zsh`) — they exist only in interactive shells,
  not for agents. Use `picom-preset <name>` and `pkill dunst; dunst &` instead.
- **picom's `rules` block is mutually exclusive** with `blur-background-exclude`,
  `shadow-exclude`, `opacity-rule`, `inactive-opacity`, `focus-exclude` and
  `wintypes`. These configs use the standalone options; adding `rules` silently
  disables all of them.
- **`~/.config/picom/picom.conf` is a symlink** into `~/.config/picom/presets/`,
  switched by `picom-preset` (`$mod+]`/`[` to cycle, `$mod+Shift+p` for a rofi
  menu). Edit the preset file you are actually on — `picom-preset current` tells
  you which. Each preset is standalone because libconfig rejects duplicate keys,
  so there is no base-plus-override layering.
- **kitty owns `ctrl+alt+*`** for splits and window navigation, deliberately
  leaving `alt+f` / `alt+d` / `alt+l` to zsh's word commands. Keep it that way.

## Shell

`~/.zshrc` is a thin entrypoint: it loads Oh My Zsh, then sources
`~/.config/zsh/*.zsh` in order (`00-options`, `10-plugins`, `20-completion`,
`30-tools`, `40-aliases`, `50-functions`, `60-keybinds`). Put changes in the
matching module, not in `.zshrc`. Every optional tool is guarded with
`command -v` / `(( $+commands[x] ))` — preserve that pattern.

## Making changes

1. Back up anything you overwrite (`cp file file.bak.$(date +%Y%m%d-%H%M%S)`).
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

3. Reload: kitty `ctrl+shift+F5` · i3 `mod+shift+r` · `reload-picom` · `reload-dunst`.
   Note that `kitty @` needs a tty, so it cannot be driven from a sandboxed shell.

## Do not

- Set git identity, credentials, or account details. There is intentionally no
  `[user]` section in `~/.gitconfig`.
- Assume a GUI action succeeded without evidence — many reloads cannot be
  triggered from a non-interactive shell.

## Dotfiles repo (added 2026-08)

- All configs are versioned in **~/dotfiles** (public:
  github.com/aravasio/dotfiles) and symlinked into `$HOME` — editing a config
  edits the repo. Commit + push after meaningful changes.
- Layout is stow-compatible (package per app); `~/dotfiles/install.sh`
  restores everything with backups. `~/dotfiles/AGENTS.md` has the full
  restore guide for a fresh system.
- **Secrets never go in the repo**: they live in `~/.zshrc.local`
  (gitignored), e.g. `OPENROUTER_API_KEY_FOR_FREE_MODELS` used by `q-chat`.

## Local features (added 2026-07)

- **kitty per-window random theme**: `$mod+Return` runs
  `~/.local/bin/kitty-randtheme` (random theme from
  `~/.config/kitty/theme-pool/*.conf`, symlinks); `$mod+Shift+Return` = plain
  kitty with the global theme. The global `theme.conf` symlink is untouched.
- **"Waiting for you" tile indicator**: Claude Code (`~/.claude/hooks/notify.sh`)
  and OpenCode (`~/.config/opencode/plugins/attention.ts`, auto-loaded) mark
  the terminal **urgent** (red i3 border + workspace button) and the kitty tab
  orange when the agent finishes or asks something. i3 auto-clears on focus.
  Mechanism: `xdotool set_window --urgency 1 $WINDOWID`.
- **i3-border-pulse** (`$mod+Shift+b`, toggle): breathing pink↔purple on the
  focused border. Was a freeze suspect, later cleared (picom animations were
  the culprit) — safe to use.
- **freeze-watchdog**: autostarts from i3; logs top processes to
  `~/.cache/freeze-watchdog.log` when load spikes.
- **theme-forge**: `~/.config/theme-forge/` — docs to generate full desktop
  themes from keywords (AGENTS.md + PALETTE.md + KEYWORDS.md +
  PROMPT-TEMPLATE.md). Point future LLM runs there. STATUS.md = live state.
- **Keybind changes**: screenshot-select moved `$mod+Shift+p` → `$mod+Print`
  (it was duplicated with the picom preset menu, which keeps `$mod+Shift+p`).
- **YouTube lite theater-mode**: v1 (userContent.css) failed, disabled.
  v2 plan (PiP window + picom focus-exclude) in theme-forge/STATUS.md.

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
