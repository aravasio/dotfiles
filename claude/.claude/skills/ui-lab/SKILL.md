---
name: ui-lab
description: Modo UI / front first — explorar y prototipar interfaz con todo el back simulado (mocks con escenarios), en cualquier stack (web, React Native, design system, etc.). Usar cuando el usuario pide "modo UI", "ui-lab", "explorar una idea de front", "prototipar una pantalla", "mockear el back", "solo UI", o quiere iterar la interfaz sin tocar back/middleware. No usar para arreglar bugs del back, datos o infraestructura.
---

# ui-lab — modo UI, front first

En este modo **solo se trabaja la interfaz**. Todo lo que está detrás de la UI (APIs, auth, pagos,
base, servicios de terceros) responde desde **mocks con escenarios**. Lo que la UI necesita y no
existe, se mockea y queda como **contrato** para el back, que se hace después en otra tarea.

El método es el mismo en cualquier stack; lo que cambia por proyecto (cómo se arranca, dónde se corta
el back, qué se puede tocar) vive en el **adaptador** del proyecto.

## 0. Encontrar o crear el adaptador

1. Buscar el adaptador: `docs/ui-lab.md`, o una sección "ui-lab" / "modo UI" en `AGENTS.md`,
   `CLAUDE.md` o el README. Si existe, **manda sobre lo genérico** de esta skill: seguirlo.
2. Si no existe, el proyecto no tiene modo UI todavía. Antes de escribir código:
   - Detectar el stack (`package.json`, `app.json`/`app.config.*`, `pubspec.yaml`, Storybook, monorepo…),
     cómo habla la UI con el back (fetch/axios, cliente generado, GraphQL, tRPC, SDKs de terceros) y
     qué servicios externos hay (pagos, auth, analytics, mails).
   - Elegir el corte según `references/stacks.md` y proponérselo al usuario en pocas líneas (es infra
     nueva en su repo). Con su OK, montarlo cumpliendo **todas** las propiedades de abajo, con TDD.
   - Escribir el adaptador con `references/adapter-template.md` y poner un puntero de una línea en
     el `AGENTS.md`/`CLAUDE.md` del proyecto.

### Propiedades obligatorias del modo UI (cualquier stack)

- **Un comando** para arrancarlo (`npm run dev:ui`, `expo start` con una variable, `storybook`…).
- **Corte en el borde de red o del cliente de API**, no adentro de los componentes: la UI no sabe que
  está mockeada y no se llena de `if (mock)`.
- **Escenarios** elegibles en caliente (query param, cookie, menú de dev, toolbar de Storybook):
  como mínimo `ok`, `lento` (latencia para las pantallas de carga), errores reales del negocio y estados
  vacíos. Latencia realista por defecto.
- **Respuestas con la forma real**: mismos campos, status y códigos de error. Si hay tipos o esquemas
  compartidos, los mocks los usan.
- **Un endpoint sin mock falla fuerte** (501 o error claro que dice dónde agregarlo), nunca sale a la red real.
- **Servicios externos neutralizados**: keys vaciadas al arrancar; redirecciones externas (checkout,
  OAuth, deep links) reemplazadas por pantallas falsas locales con sus resultados posibles.
- **Imposible en producción**: el build o release con el modo encendido falla, y el código del modo
  responde 404/no-op fuera de dev. Con un test.
- **Tests de contrato**: cada endpoint que llama la UI tiene mock; cada mock no `pendiente` corresponde
  a algo real en el back (si el back está en el mismo repo).

## 1. Reglas mientras se explora

1. **Zonas.** Se toca solo la capa de UI (componentes, pantallas, estilos, textos, tokens, mocks,
   sandbox de prototipos). No se toca back, lógica de servidor, base, infraestructura ni variables
   reales. Las zonas exactas, en el adaptador. Si la UI parece necesitar un cambio de back, **se
   mockea** y se anota; no se "arregla de paso".
2. **Falta un dato o endpoint → TDD del contrato.** El mock modela una regla del negocio:
   1. tests primero, con nombres que lean como reglas ("pago agotado: 409 runs_exhausted"), para la
      respuesta OK y cada error que importa;
   2. correrlos y **verlos fallar**;
   3. recién ahí el mock, marcado `pendiente` (endpoint nuevo) o con `// pendiente: <qué>` (campo nuevo).
3. **Prototipos descartables** en un sandbox que no existe en producción (ruta `/ui-lab/<idea>` en web,
   pantalla de dev en mobile, stories en un design system). Variantes lado a lado o por parámetro.
4. **Design system primero.** Si hay DS o tokens, usarlos; no inventar primitivas nuevas. Si una idea
   necesita una pieza que el DS no tiene, se prototipa y se anota como propuesta para el DS. Respetar el
   tono y el idioma de los textos del proyecto. Si hay skills de diseño (impeccable, frontend-design,
   web-design-guidelines…), usarlas.
5. **Mirar lo que se hace.** Nunca decir "quedó" sin ver una captura: Playwright en web (desktop y
   mobile, claro/oscuro si aplica); simulador en mobile (`xcrun simctl io booted screenshot`,
   `adb exec-out screencap -p`); Storybook/Chromatic en un DS. Recorrer los escenarios que afectan la
   pantalla: como mínimo `ok`, `lento` y uno de error.
6. **Explorar no lleva TDD.** Todavía no se sabe qué se quiere; un test fija una decisión que no se
   tomó, y lo visual se juzga con capturas. Mientras se explora: lint + typecheck y listo. Los tests
   llegan con el contrato (regla 2) y al pasar la idea a la UI real (cierre).
7. Iterar rápido. No commitear salvo que el usuario lo pida.

## 2. Cerrar (cuando el usuario aprueba una idea)

1. **Handoff** en `docs/ui-lab/<slug>.md`: qué cambió (con capturas), escenarios revisados y
   **contrato para el back**: cada mock `pendiente` / campo `// pendiente` con método, ruta, body,
   respuesta OK, errores (status + código) y qué reglas del producto toca.
2. **Pasar el prototipo a la UI real con TDD.** Ahora sí es un cambio de comportamiento:
   1. tests de UI que lean como reglas del negocio, uno por escenario que cambia la pantalla, **contra
      los mismos mocks** (e2e con intercepción de red, Testing Library con el mismo servidor de mocks,
      Detox/Maestro en mobile, interaction tests en Storybook);
   2. correrlos contra la UI vieja y **verlos fallar**;
   3. llevar el prototipo a los componentes reales hasta verde y borrar el prototipo.
   Mostrarle al usuario el rojo y el verde.
3. Seguir el camino normal del proyecto (verify, PR, CI). Si quedó algo `pendiente`, **no se mergea**
   hasta que exista el back: en producción esas llamadas fallarían.

## Referencias

- `references/stacks.md` — dónde cortar el back y cómo elegir escenarios en cada stack.
- `references/adapter-template.md` — qué tiene que decir el adaptador de un proyecto.
