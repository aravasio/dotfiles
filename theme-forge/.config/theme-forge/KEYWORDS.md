# Keywords → tokens

How to turn loose mood words into a concrete palette + behavior. Work the
keywords through these five dials, then read tokens off the result.

## The five dials

1. **Temperature** — words like *noche, frost, océano, bosque* → cool bg;
   *atardecer, papel, miel, café* → warm bg. Cool bg → cool fg; warm bg → warm fg.
2. **Saturation** — *neón, vapor, ácido, eléctrico* → accents at 90–100% sat;
   *niebla, piedra, zen, papel* → 40–65% sat. Saturation lives in the
   ACCENTS, never in bg (bg stays ~6–10% lightness, ≤ 25% sat).
3. **Energy** — maps to motion + focus feedback:
   - *quieta*: no animations, static border, dim ≈ .15
   - *sleek*: subtle fades, border breathing optional, dim ≈ .28–.35
   - *viva*: stronger fades, `i3-border-pulse` fits, dim ≈ .4–.45
   (During picom freeze watch: energy is expressed via COLOR CONTRAST, not motion.)
4. **Accent hue** — pick ONE dominant from the keyword's core image:
   selva→lime/emerald · océano→cyan/steel · atardecer→coral · neón→magenta ·
   miel→amber · hielo→ice-blue. `accent2` = neighbor on the wheel ±40°.
5. **Dim level** — *spotlight, cine, foco* → .4–.45 inactive-dim;
   *plano, uniforme* → .1–.2. Independent from energy: a theme can be loud
   in color and quiet in dim.

## Semantic guardrails (always)

error = red-family, warn = orange/amber, ok = green-family, info = blue/cyan.
They may shift hue to fit the theme (a forest theme's red can be raspberry)
but must stay instantly distinguishable from each other and from accent1.

## Worked example A — "selva nocturna, neón húmedo"

- Temperature: cool → bg `#0e1410` (green-tinted charcoal)
- Saturation: high → accents ~95%
- Accent hue: emerald `#3dffa2` (accent1) + teal `#2de2c8` (accent2)
- Energy: viva → dim .42, pulse fits
- fg `#d4e8d8`, muted `#7a947f`, error stays hot `#ff4d6d` (reads against green)
- picom: shadow-color = accent1 at low opacity; wallpaper: gen-wallpaper palette → deep green aurora

## Worked example B — "estudio crema, papel, calma" (light theme)

- Temperature: warm, LIGHT base → bg `#f4efe4`, bg-alt `#e5ddcc`
- Saturation: low-mid → accents ~55%
- Accent hue: terracotta `#c96f4a` (accent1) + steel blue `#4a7a96` (accent2)
- Energy: quieta → no animation, dim .12 (light themes need LESS dim: dimming
  a light window to grey looks dirty fast)
- fg `#2e2a24` (ink), muted `#8a8172`
- kitty: light themes flip the ANSI table — color0 becomes the ink, color8 a soft grey
- picom: shadows softer (shadow-opacity ≤ .35), inactive-opacity higher (.9)

## Anti-patterns (don't)

- Two dominant accents fighting (pink AND green both at 100% on borders).
- Saturated bg (a "purple theme" with `#2a0a2a` bg reads as a toy).
- Pure `#000` bg / pure `#fff` fg anywhere.
- Semantic collision: accent1 too close to error-red → urgent windows stop screaming.
- Per-app one-off hexes that don't come from the token table.
