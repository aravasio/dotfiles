# Monokai Boosted — canonical palette

Single source of truth. Defined in
`~/.config/kitty/kitty-themes/themes/Monokai_Boosted.conf`; everything else
on the machine derives from these hexes.

## Base tokens

| Token | Hex | Role |
|---|---|---|
| `bg` | `#16161a` | window/terminal background (warm charcoal, never pure black) |
| `bg-alt` | `#232526` | panels, inactive tabs, i3 black |
| `fg` | `#d8d8c8` | default text (warm off-white) |
| `fg-bright` | `#fdfdf0` | titles, focused text |
| `muted` | `#a6a696` | inactive text, secondary info |
| `muted-deep`| `#3d3f3a` | selection bg, inactive borders, separators |
| `muted-mauve`| `#4a3f52` | unfocused i3 borders |

## Accent tokens

| Token | Hex | Role | Used today in |
|---|---|---|---|
| `accent1` (pink) | `#ff6ac1` | **dominant**: focus, selected | i3 focused border, kitty active border/tab, dunst normal frame, picom shadow, rofi border/selected, starship OS block |
| `accent2` (purple) | `#ae81ff` | support | starship dir block, dunst ram widget, rofi active rows |
| `success` (green) | `#a6f024` | ok / done | i3bar focused workspace border, dunst done, net widget |
| `info` (blue) | `#48b8ff` | information | i3 `$lightblue`, dunst cpu widget, starship languages |
| `cyan` | `#46d9f0` | secondary info | kitty url_color, dunst gpu widget |
| `warn` (orange) | `#ffa41f` | attention needed | bell borders, dunst "needs you", i3blocks disk |
| `yellow` | `#ffdc3d` | highlight | i3blocks window title, i3 urgent indicator |
| `error` (red) | `#ff2d6f` | urgent / critical | i3 client.urgent, dunst critical, i3blocks power |
| `lime` | `#c7ff4d` | bright-green variant | i3 `$lime`, fps block |

## ANSI map (kitty color0–15)

```
0  #232526  black        8  #6f6b57  bright black
1  #ff2d6f  red          9  #ff5c8a
2  #a6f024  green       10  #c7ff4d
3  #ffa41f  yellow      11  #ffdc3d   (yellow slot carries ORANGE — Monokai style)
4  #48b8ff  blue        12  #7ad4ff
5  #ae81ff  magenta     13  #ff79d2
6  #46d9f0  cyan        14  #86f4ff
7  #d8d8c8  white       15  #fdfdf0
```

Notes: ANSI slots are **de-duplicated** on purpose (stock Monokai Soda maps
magenta==red and bright==normal, which flattens TUI output). `color4` is a
true blue so links/info separate from purple keywords.

## How to derive a new palette

1. Keep the **token structure** (same roles), rotate the hues.
2. bg: pick a dark tint of the theme's dominant hue, ~6–10% lightness.
3. fg: warm or cool off-white matching bg temperature, ≥ 12:1 contrast vs bg.
4. `accent1`: ONE saturated hue that pops against bg (this is the theme's soul — borders, selections, glows all come from it).
5. `accent2`: analogous or complementary to accent1, similar saturation.
6. Semantics: red/orange/green/blue may shift (e.g. a frost theme's red can go raspberry) but must remain instantly readable as error/warn/ok/info.
7. muted: fg at ~55% saturation against bg. muted-deep: bg lifted ~8%.
8. Write the kitty theme first (it's the most constrained: 16 ANSI slots + UI chrome), then spread the same hexes to the other surfaces per the map in `AGENTS.md`.
