# Prompt template — generar un theme por keywords

Copiá esto en una sesión futura de cualquier LLM (Claude Code, OpenCode, Codex),
completando los campos entre `<…>`:

```text
Mirá ~/.config/theme-forge/ — empezá por AGENTS.md (mapa de superficies y
reglas) y PALETTE.md (estructura de tokens). Si STATUS.md menciona una
vigilia de freezes de picom, respetá la restricción de animations.

Quiero un theme nuevo para todo el escritorio.

Keywords:        <3–6 palabras: mood, época, textura, energía.
                  ej: "selva nocturna, neón húmedo, vapor">
Nombre (opc.):   <kebab-case, o proponé vos>
Acento (opc.):   <hex o descripción: "un turquesa eléctrico">
Base:            oscuro | claro        <elegí>
Energía:         quieta | sleek | viva <elegí>
Dim inactivas:   suave | medio | spotlight <elegí>

Entregables, siguiendo el checklist de AGENTS.md:
1. PRIMERO proponeme la tabla de tokens (roles + hexes) y frená ahí hasta
   que la apruebe. No escribas archivos antes de ese OK.
2. Después: archivos para TODAS las superficies del mapa (i3, kitty, picom,
   dunst, rofi, i3blocks, starship, wallpaper).
3. Validá cada archivo con su propio comando (están en AGENTS.md).
4. NO actives nada sin mi confirmación. Al final proponeme el orden de
   activación paso a paso.

Restricciones duras:
- Nada de bloque `animations` en picom (culpable CONFIRMADO de los freezes
  del 2026-07-26; solo se reintroduce si lo pido explícitamente).
- Colores SOLO en los archivos de theme: nunca en kitty.conf, nunca sueltos
  en i3/config fuera del THEME BLOCK.
- Un solo acento dominante. Rojo/naranja/verde conservan su rol semántico.
```

## Por qué está así

- **Tokens primero, archivos después** — el error típico de un LLM es salir
  escribiendo configs con hexes sueltos. El paso 1 fuerza la paleta.
- **Keywords → tokens** no es magia: la guía de traducción está en
  `KEYWORDS.md` (el LLM la lee desde el template).
- **"No actives nada"** — aplicar un theme toca proceso de compositor y
  reloads de i3; eso siempre lo confirma el usuario.
- Las **restricciones duras** son las trampas que ya mordieron a alguien
  (ver "Traps" en AGENTS.md y machine-facts).
