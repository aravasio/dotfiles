# theme-forge

Everything needed to design and ship a new desktop theme on this machine,
in one place. Built so a future LLM session can be pointed here with:

> "Mirá `~/.config/theme-forge/` y haceme un theme con estas keywords: …"

## Contents

| File | What it is |
|---|---|
| `AGENTS.md` | **Start here.** Architecture map: every file a theme touches, how to validate it, how to activate it, and the traps. |
| `PALETTE.md` | The canonical Monokai Boosted palette with semantic roles + ANSI map. The reference for building any new palette. |
| `KEYWORDS.md` | How to translate mood keywords ("selva neón", "papel crema") into concrete design tokens. With worked examples. |
| `PROMPT-TEMPLATE.md` | Copy-paste prompt (es) to hand to a future LLM run. Fill in the keywords, send. |
| `STATUS.md` | Live session state: what's done, what's pending, the picom-animations freeze watch. Update it when you change things. |

## Quickstart (for a human)

1. Read `PALETTE.md` to see how a palette is structured (roles, not just hexes).
2. Pick keywords, run them through `KEYWORDS.md` to get tokens.
3. Follow the checklist in `AGENTS.md` — it touches i3, kitty, picom, dunst,
   rofi, i3blocks, starship and the wallpaper, in that order, with a
   validation command per file.
4. Never activate without asking the user first.
