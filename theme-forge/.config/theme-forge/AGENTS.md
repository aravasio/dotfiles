# theme-forge — AGENTS.md

Instructions for any agent building/modifying a desktop theme here.
Complement to `~/.config/machine-facts/AGENTS.md` (machine-level facts) —
read that too. Machine state (freeze watch etc.) lives in `STATUS.md`.

## Theme architecture map

A "theme" on this machine spans **8 surfaces**. A proper theme touches all
of them; a partial theme must say so explicitly.

### 1. i3 (window borders, bar colors)
- **File per theme:** `~/.config/i3/themes/<name>.conf`
- **Contract:** must define EVERY variable the config references (17):
  `$darkbluetrans $darkblue $lightblue $urgentred $orange $teal $lime
  $white $black $purple $green $focusaccent $mutedpurple $darkgrey $grey
  $mediumgrey $yellowbrown`.
  Aliasing is fine (`set $orange $yellowbrown` — see `neon.conf`).
- **Apply:** contents replace the block between `# THEME BLOCK START/END`
  in `~/.config/i3/config`. `~/.config/i3/scripts/random-theme` does this
  but is **currently disabled** (exec line commented in config). Do the
  block replacement manually with a script, then `i3-msg reload`.
- **Validate:** `i3 -C -c ~/.config/i3/config`
- ⚠️ Any i3 reload/restart re-runs `exec_always` → **restarts picom and
  dunst**. Expected, not a bug.
- Trap: `~/.config/i3/theme.conf` is an orphan, included by nothing.
  `ultra-candy.conf` is a test file (garish on purpose).

### 2. kitty (terminal colors)
- **File per theme:** `~/.config/kitty/kitty-themes/themes/<Name>.conf`
- **Contract:** filename MUST match `*[mM]onokai*.conf` or the cycling
  keybinds (`ctrl+shift+]/[`) won't see it. Use `Monokai_Boosted.conf` as
  the key template (bg/fg/selection/cursor/color0-15/borders/tabs/marks).
- **Never** put color directives in `kitty.conf` (they'd override cycling).
- **Preview:** `kitty @ set-colors --all <file>` (needs a kitty with remote
  control; can't be driven from a sandboxed shell — ask the user).
- **Make default:** `ln -sfn <file> ~/.config/kitty/theme.conf`
- **Per-window random pool:** `~/.config/kitty/theme-pool/*.conf` (symlinks).
  `$mod+Return` = `kitty-randtheme` (random theme per window);
  `$mod+Shift+Return` = plain kitty with the global theme.
- **Validate:** `kitty +runpy 'from kitty.config import load_config; load_config("'$HOME'/.config/kitty/kitty.conf")'`

### 3. picom (compositor: dim, blur, shadows, animations)
- **File per preset:** `~/.config/picom/presets/NN-name.conf` (NN orders cycling)
- **Header contract (parsed by `picom-preset`):** line 2 `#  picom preset: <Title>`, line 3 `#  <one-line description>`.
- **Standalone files:** libconfig rejects duplicate keys — no base+override layering. **Never add a `rules` block** (silently disables all the standalone excludes).
- **Activate:** `picom-preset <name>` (self-validates before applying);
  cycle `$mod+]`/`[`, menu `$mod+Shift+p`.
- ⚠️ **CONFIRMED 2026-07-26:** the picom v12 `animations = (...)` engine caused repeated full-desktop freezes on this box (GLX + NVIDIA 590) — 3/3 crash boots with it, 0 without. It is **stripped from all presets**. Do NOT add an `animations` block to any preset unless the user explicitly asks and a fresh A/B test is run (details in `STATUS.md`).
- **Validate:** `picom --config <file> --diagnostics 2>&1 | grep -iE "error|invalid"`

### 4. dunst (notifications)
- **File:** `~/.config/dunst/dunstrc` (single file, all themes)
- **Theme surface:** `[urgency_*]` bg/fg/frame + per-app `frame_color` rules at the bottom (widget color-coding: cpu blue, ram purple, gpu cyan, net green…).
- **Reload:** `pkill dunst; dunst &` (or interactive zsh alias `reload-dunst`). i3 restarts it on reload anyway.

### 5. rofi (menus)
- **Theme file:** `~/.local/share/rofi/themes/<name>.rasi`, enabled by the `@theme` line in `~/.config/rofi/config.rasi`.
- **Validate:** `rofi -dump-theme -config ~/.config/rofi/rofidmenu.rasi >/dev/null`
- Note: `rofidmenu.rasi` has a hardcoded pink `border-color` on `window {}` — when shipping a theme, update that line too or move it into the theme file.

### 6. i3blocks (status bar blocks)
- **File:** `~/.config/i3/i3blocks.conf` — per-block `color=#……`.
- Current coding: title yellow, disk orange, cpu blue, gpu cyan, fps lime, net green, time white, power red.
- **Reload:** `i3-msg restart` (restarts the bar; re-runs exec_always, see i3 trap).

### 7. starship (shell prompt)
- **File:** `~/.config/starship.toml` — hexes inline in `format` + `[palettes]`.
- **Validate:** `python3 -c "import tomllib; tomllib.load(open('$HOME/.config/starship.toml','rb'))"`

### 8. wallpaper
- **Generator:** `~/.local/bin/gen-wallpaper [--seed N] [--size WxH] [--out FILE] [--grain 0..1]` — palette is **hardcoded in the script** (Monokai aurora). For a new theme either accept it or edit the script's palette.
- **Apply:** referenced from `~/.config/i3/config` (`feh --bg-fill …`); update that line if the filename changes.
- Optional surface: `~/.config/cava/config` gradient.

## Design rules (the house style)

1. **One palette per theme, tokenized first.** Define 10–12 tokens with roles BEFORE touching files (see `PALETTE.md`). No orphan hexes scattered in configs.
2. **Roles over hues:** `bg`, `fg`, `accent1` (dominant: focus/selected/active), `accent2` (support), `muted` (inactive), `selection`, and semantics `success/warn/error/info`. Semantic hues may rotate per theme but **roles stay**: error/urgent must always scream.
3. **60-30-10:** bg dominates, muted supports, accent1 appears only on focus/selection/active elements.
4. **bg is never pure black** — always tinted (Monokai bg is `#16161a`, warm charcoal). fg is never pure white.
5. **Chrome constants:** radius 14 (picom) / 10 (dunst/rofi), borders 2–3px, font JetBrainsMono Nerd Font, dim levels: quiet ≈ .15 · sleek ≈ .28–.35 · spotlight ≈ .45.
6. **Contrast floor:** kitty has `text_fg_override_threshold 3` — keep fg/bg contrast high enough that it never triggers.
7. **Everything degrades gracefully** (per machine AGENTS.md): no hard dependency on tools that may be absent.

## New-theme checklist

1. [ ] Tokens defined (roles + hexes) — propose to user BEFORE writing files.
2. [ ] `i3/themes/<name>.conf` (all 17 vars) → `i3 -C` after block swap.
3. [ ] kitty theme file (glob-compatible name) → kitty +runpy validate.
4. [ ] picom preset (base: any current preset — all are animation-free since the 2026-07-26 freeze purge; respect the header contract) → `picom --diagnostics`.
5. [ ] dunst hexes → restart dunst.
6. [ ] rofi theme + `@theme` line + rofidmenu border → `rofi -dump-theme`.
7. [ ] i3blocks colors.
8. [ ] starship hexes → tomllib validate.
9. [ ] wallpaper (gen-wallpaper or edited palette) + feh line.
10. [ ] **Ask user before activating anything.** Propose activation order: kitty preview → picom-preset → i3 reload → dunst.
11. [ ] Append the theme to `STATUS.md` history.
