# AGENTS.md — instructions for any AI agent restoring or maintaining these dotfiles

This repo is the full desktop configuration of user `alitoh`
(EndeavourOS / Arch, X11, i3 + picom + kitty + zsh, Monokai Boosted palette
everywhere). It is meant to be cloned and symlinked onto a running system.

## Layout

GNU-stow-compatible: each top-level package mirrors paths relative to `$HOME`.
Example: `i3/.config/i3/config` → `~/.config/i3/config`.

| Package       | Installs to | What it is |
|---------------|-------------|------------|
| `i3`          | `~/.config/i3` | i3 WM config, i3blocks bar, all bar/launcher scripts, themes |
| `kitty`       | `~/.config/kitty` | kitty terminal + theme collection + theme-pool (per-window random themes) |
| `picom`       | `~/.config/picom` | compositor presets 01–09; `picom.conf` symlink switches preset |
| `rofi`        | `~/.config/rofi` | launchers, powermenu, keyhint themes |
| `dunst`       | `~/.config/dunst` | notifications |
| `zsh`         | `~/.zshrc` + `~/.config/zsh` | modular zsh config (00–60 modules) |
| `starship`    | `~/.config/starship.toml` | prompt |
| `git`         | `~/.gitconfig`, `~/.gitignore_global` | delta + Monokai diff theme. NO `[user]` section on purpose |
| `tmux`        | `~/.config/tmux` | |
| `gtk`         | `~/.config/gtk-3.0`, `~/.gtkrc-2.0` | |
| `x`           | `~/.xprofile`, `~/.Xresources`, `~/.fehbg` | X11 session bits |
| `bin`         | `~/.local/bin` | custom scripts: `q`, `q-chat`, `q-ask`, `picom-preset*`, `kitty-randtheme`, `i3-border-pulse`, `freeze-watchdog`, screenshots, etc. |
| `opencode`    | `~/.config/opencode` | OpenCode agents/commands/skills/plugins + opencode.json |
| `theme-forge` | `~/.config/theme-forge` | docs to generate full desktop themes from keywords |
| `machine-facts` | `~/.config/machine-facts` | canonical machine AGENTS.md (symlinked by claude/codex/opencode configs) |
| `claude`      | `~/.claude` | settings.json, hooks (urgent-window notify), statusline, keybindings |
| `codex`       | `~/.codex` | config.toml + AGENTS.md symlink |
| `wallpapers`  | `~/Pictures` | wallpaper referenced by `.fehbg` |
| `env`         | `~/.config/environment.d` | session env vars |

## Restore on a fresh/running system

```bash
git clone <this-repo> ~/dotfiles
cd ~/dotfiles
./install.sh            # or: ./install.sh i3 kitty   (subset)
DRY_RUN=1 ./install.sh  # preview first
```

`install.sh` symlinks every file into `$HOME` and moves any pre-existing file
to `<path>.pre-dotfiles.<timestamp>` — nothing is destroyed. GNU stow also
works (`stow -d ~/dotfiles -t ~ i3 kitty ...`) but is not required.

### After install — REQUIRED manual steps

1. **Secrets**: create `~/.zshrc.local` (mode 600). Minimum content:
   ```bash
   export OPENROUTER_API_KEY_FOR_FREE_MODELS="sk-or-v1-..."   # used by ~/.local/bin/q-chat and q-ask
   ```
   This file is gitignored and must never be committed.
2. **Git identity**: `~/.gitconfig` intentionally has no `[user]` section:
   ```bash
   git config --global user.name "..." && git config --global user.email "..."
   ```
3. **Oh My Zsh** must exist at `~/.oh-my-zsh` (`.zshrc` sources it).
4. Optional tools the configs expect (all degrade gracefully if absent):
   `starship delta fastfetch feh rofi dunst picom kitty i3blocks jq glow nvim xdotool`.
5. `q`/`q-chat` need a local Ollama (`localhost:11434`) and/or the OpenRouter key above.

### Validate after restore (from machine-facts AGENTS.md)

```bash
i3 -C -c ~/.config/i3/config
kitty +runpy 'from kitty.config import load_config; load_config("'$HOME'/.config/kitty/kitty.conf")'
picom --config ~/.config/picom/picom.conf --diagnostics 2>&1 | grep -iE "error|invalid"
rofi -dump-theme -config ~/.config/rofi/rofidmenu.rasi >/dev/null
timeout 30 script -qec 'zsh -i -c "echo OK"' /dev/null
```

Reload: i3 `mod+shift+r` · kitty `ctrl+shift+F5` · `picom-preset <name>` · `pkill dunst; dunst &`

## Traps (learned the hard way — read before editing)

- **kitty `background_blur` does nothing on X11.** Transparency: kitty
  `background_opacity`; blur: picom `dual_kawase`.
- **`~/.config/kitty/theme.conf` is a symlink** cycled by `kitty-theme-next/prev`.
  Never put color directives in `kitty.conf`; add `Monokai_*.conf` files instead.
- **i3 colors live between `# THEME BLOCK START/END`** in the config, sourced
  from `~/.config/i3/themes/*.conf`. Edit theme files, not the block.
  `~/.config/i3/theme.conf` is not included by anything — ignore it.
- **Any i3 reload/restart re-runs `exec_always`** → picom and dunst restart. Expected.
- **picom v12 `animations` engine caused full-desktop freezes (2026-07-26, GLX + NVIDIA).**
  It is stripped from all presets. Do NOT reintroduce an `animations` block
  unless the user explicitly asks and a fresh A/B test is run.
- **picom `rules` block is mutually exclusive** with the standalone exclude/opacity
  options these presets use. Adding `rules` silently disables all of them.
- **`~/.config/picom/picom.conf` is a symlink** into `presets/`, switched by
  `picom-preset`. Each preset is standalone (libconfig rejects duplicate keys).
- **kitty owns `ctrl+alt+*`**; `alt+f/d/l` stay with zsh word commands. Keep it.
- zsh: put changes in the right `~/.config/zsh/*.zsh` module, not in `.zshrc`.
- `reload-picom`/`reload-dunst`/`reload-i3` are interactive zsh aliases — scripts
  must use `picom-preset <name>` / `pkill dunst; dunst &` instead.
- Back up before overwriting: `cp file file.bak.$(date +%Y%m%d-%H%M%S)`.

## What is deliberately NOT in this repo

- Secrets/API keys (`~/.zshrc.local`), `~/.ssh`, `~/.gnupg`, `~/.config/gh`
- App state/caches: `~/.claude/{projects,sessions,cache,history.jsonl}`, `~/.codex/{auth.json,log,cache,*.sqlite*}`, browser profiles
- `*.bak*` files, `__pycache__`, `node_modules`
- picom animated-presets backup tarball (kept locally only)
