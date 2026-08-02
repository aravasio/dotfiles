# STATUS — sesión themes/features (2026-07-26)

Notas de contexto por si la sesión se corta. Leer esto antes de seguir.

## Objetivo original
Auditoría de estilos/configs + features "zarpadas" (bordes animados, más dim,
theater-mode YouTube, indicador "terminal esperando input", theme random por
terminal, docs para generar themes por keywords).

## HECHO y en disco
- `~/.claude/hooks/notify.sh` — agregado `set_urgent()` (xdotool urgency en
  Notification/Stop). Backup: `notify.sh.bak.20260726-*`.
- `~/.config/opencode/plugins/attention.ts` — NUEVO. urgency+tab-color+notify
  en session.idle / permission.asked / question.asked; limpia en busy.
  **NO verificado que opencode lo cargue.** Logs: `~/.local/share/opencode/log/`.
- `~/.local/bin/kitty-randtheme` — NUEVO, chmod +x, probado OK sintaxis.
  Pool: `~/.config/kitty/theme-pool/*.conf` (symlinks a los 10 Monokai).
- `~/.config/i3/config` — `$mod+Return` → kitty-randtheme; `$mod+Shift+Return`
  → kitty plano. Fix duplicado: screenshot-select movido de `$mod+Shift+p`
  (chocaba con picom-preset-menu) a `$mod+Print`. Backup: `config.bak.20260726-*`.
  **i3 recargado, validado con `i3 -C`.**
- `~/.mozilla/firefox/youtube-app/chrome/userContent.css` — v1 falló
  (overlay/stacking, "todo pálido"); v2 implementada (sección abajo).
- `~/.config/picom/presets/08-spotlight.conf` — focus-exclude += 'YouTube'
  (parte del theater v2); animations eliminadas post-forense.
- `~/.local/bin/i3-border-pulse` — versión demonizada OK (toggle, restaura
  colores al salir).

## PENDIENTE (no hecho)
- ~~Docs theme-forge~~ → HECHO 05:45 (README/AGENTS/PALETTE/KEYWORDS/PROMPT-TEMPLATE).
- ~~Update machine-facts AGENTS.md~~ → HECHO (random-theme corregido, traps
  nuevos, sección "Local features 2026-07").
- Plugin opencode: carga OK (verificado en logs). Falta prueba funcional real
  (que dispare session.idle y ver el tile rojo). El mecanismo urgency ya fue
  probado manualmente: FUNCIONA (i3 tree reportó urgent=true y limpió).
- Theater-mode YouTube v2 → IMPLEMENTADO (sección abajo).
- i3-border-pulse: keybind `$mod+Shift+b`. Liberado post-forense.
- freeze-watchdog: ahora también en autostart de i3 (exec).
- Limpieza menor pendiente: ultra-candy.conf (test), example.picom.conf (decoy).

## HALLAZGOS AUDITORÍA (pre-freeze)
- Bug: `$mod+Shift+p` duplicado (picom menu vs screenshot-select) → FIX aplicado.
- kitty theme activo es Monokai_Pro, NO Monokai_Boosted (paleta oficial).
- random-theme: AGENTS.md dice que corre on login; está comentado en i3/config.
- `~/.config/i3/themes/ultra-candy.conf` es un archivo de TEST (colores locos).
- `~/.config/example.picom.conf` suelto, puede confundir.
- i3/config autostart abre firefox con URL de docs EndeavourOS cada login
  (línea ~504) — legacy, candidato a borrar.

## FREEZE — RESUELTO (2026-07-26 06:40)
CULPABLE CONFIRMADO: motor `animations` de picom v12 (GLX + NVIDIA 590.48.01).
Evidencia: 3/3 boots con animations murieron a los 10–47 min (journal corta,
Xorg "system too slow", wireplumber "out of buffers"); boot de control SIN
animations: 1h10m+, 0 eventos, watchdog log vacío, picom 2.9% CPU.
Descartados: plugin attention.ts (carga limpia), i3-border-pulse (no corría
en boot -1), userContent.css (no estaba cargado), múltiples picom (siempre 1),
OOM (31GB libres), driver per se (16h estables con el mismo driver antes del
preset animado).

REMEDIACIÓN: bloque `animations` eliminado de TODOS los presets (01-06, 08).
Backup originales animados:
~/.config/picom/presets-animated-backup-20260726-063732.tgz
`09-spotlight-safe` (grupo de control) eliminado por redundancia.
Preset activo: 08-spotlight (mismo look: glow rosa, dim .28, blur, fades)
SIN animations. Todos validados con picom --diagnostics.
REGLA PERMANENTE: no reintroducir `animations` sin pedido explícito del
usuario + nuevo A/B. Si se reintroduce: solo triggers open/close (nunca
geometry ni saved-image-blend, los más pesados).
freeze-watchdog queda permanente (autostart i3).
i3-border-pulse liberado para uso normal (no era el culpable).

## CAMINO A RECUPERAR ANIMACIONES (research 2026-07-26)
El usuario QUIERE animaciones de vuelta; deshabilitarlas es subóptimo.
Hallazgos:
- **Update disponible en Arch**: picom 12.5-3 → **13-2**, nvidia 590.48.01 →
  **610.43.03**, kernel 6.18.7 → **7.1.4** (`checkupdates` lo confirma).
- **picom v13 (2026-02-07) + v13-rc1 changelog**: fixes justo en las features
  de nuestra config animada: frame-opacity+saved-image-blend, 3x sombras
  escaladas (#1389), "request too big" subiendo shadow images (ultrawide +
  shadow-radius 26), crash por blur-opacity negativo, geometry→size/position.
- Issue yshui/picom#1397 ("occasional freezes", misma build v12.5 a456d43):
  síntoma idéntico PERO era bug de driver AMDGPU (page-flip), se arregló con
  kernel. NUESTROS logs NO muestran page-flip failures → mecanismo distinto,
  picom-side (CPU spin) más probable → v13 es la candidata a fix.
- Lección del #1397: el compositor puede ser solo el gatillo → actualizar
  TAMBIÉN nvidia+kernel (está todo disponible).

PLAN (pendiente, requiere sudo del usuario):
1. `yay -Syu` (trae picom 13-2, nvidia 610, kernel 7.1.4 — el usuario prefiere
   yay primero, pacman solo como fallback) + REBOOT.
2. Verificar: `pacman -Q picom nvidia-utils linux`.
3. Activar preset de prueba: `picom-preset 09-spotlight-anim`
   (ya creado y validado: 08 + animations + focus-exclude YouTube).
4. Observar 2-3 días con freeze-watchdog:
   - Estable → restaurar animations en TODOS los presets desde
     ~/.config/picom/presets-animated-backup-20260726-063732.tgz y borrar 09.
   - Freeze → `picom-preset 08-spotlight` y reportar upstream (yshui/picom)
     con: build a456d43/v13, NVIDIA 610, kernel, config 09, watchdog log.

## YouTube theater v2 — IMPLEMENTADO (2026-07-26 ~06:00)
Espec del usuario: el VIDEO nunca dimmeado; todo lo demás sigue reglas
normales. PiP RECHAZADO por el usuario (no le gustó como solución).

Por qué falló v1 (overlay html::after + z-index):
1. El overlay vive en el stacking context raíz; YouTube envuelve al player
   en ancestros con stacking contexts propios (transforms/will-change) →
   un z-index hijo nunca supera al overlay raíz. Elevar el ancestro raíz
   elevaría también sidebar/comentarios (= no dimmea nada). Callejón CSS.
2. backdrop-filter: caro (resamplea viewport por frame) y, al no estar el
   player realmente arriba, también lo lavaba → "todo pálido".

v2 (activo): SIN overlay. userContent.css aplica
`filter: brightness(0.5) saturate(0.75)` DIRECTO a las regiones
(#masthead-container, #secondary, #below, #guide, ytd-mini-guide-renderer)
solo en páginas con player (`body:has(#movie_player)`). El video nunca está
en esas regiones → nunca se dimmea. Hover despierta la región (borrable).
+ picom 09-spotlight-safe focus-exclude += 'YouTube' → el tile nunca lo
dimmea picom (video vivo siempre); el chrome de la página lo apaga el CSS.
OJO: userContent.css carga SOLO al arrancar Firefox → reiniciar la app
(cerrar ventana YouTube + $mod+y).
