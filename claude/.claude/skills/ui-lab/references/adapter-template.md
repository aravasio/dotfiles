# Plantilla del adaptador (`docs/ui-lab.md` del proyecto)

El adaptador es corto y concreto: lo que la skill genérica no puede adivinar. Escribirlo en el idioma
del proyecto. Poner un puntero de una línea en `AGENTS.md`/`CLAUDE.md`:
"Modo UI (front first): `<comando>`. Reglas: skill `ui-lab` + `docs/ui-lab.md`."

```markdown
# Modo UI — <proyecto>

Adaptador de la skill `ui-lab`. Lo de acá manda sobre lo genérico de la skill.

## Arrancar
- Comando: `<npm run dev:ui>` → <URL / simulador>.
- Qué neutraliza: <servicios y keys vaciadas>.
- Redirecciones externas reemplazadas: <checkout falso en /ui-lab/checkout, OAuth falso…>.
- Puede correr junto al modo normal: <sí/no, puerto/carpeta>.
- Guardas de producción: <dónde y qué test las cubre>.

## Escenarios
| id | Qué simula |
|---|---|
| ok | … |
| lento | … |
| <errores del negocio> | … |
Lista viva: <archivo>. Cómo elegirlos: <?mock= / menú / toolbar>.

## Zonas
- Se toca: <carpetas de UI, estilos, textos, tokens, mocks, sandbox>.
- No se toca: <back, servidor, base, infra, env>.

## Dónde están las cosas
| Qué | Dónde |
|---|---|
| Mocks y escenarios | … |
| Tests de contrato | … |
| Sandbox de prototipos | … |
| Helpers para tests de promoción | … (ej. `mockScenario(page, id)`) |
| Capturas | <comando/script> |

## Reglas del producto que la UI no puede romper
- <textos: idioma, tono>; <datos que nunca se inventan>; <design system / theme a preservar>…

## Trampas
- <pantallas que no pasan por los mocks, estado en localStorage, recargas al cambiar escenario…>
```
