# Dónde cortar el back, por stack

Regla general: cortar **lo más afuera posible** (red o cliente de API) para que la UI no cambie, y
**reusar lo que el proyecto ya tiene** antes de sumar dependencias. Orden de preferencia:

1. El proyecto ya tiene un seam (cliente de API único, capa de servicios, providers inyectables,
   handlers de MSW para tests) → enchufar los mocks ahí.
2. Intercepción de red (MSW o equivalente) → no toca el código de la app.
3. Servidor/ruta de mocks del propio framework (rewrites, proxy de dev).
4. Último recurso: una implementación mock del cliente de API elegida por variable de entorno.

Los handlers y escenarios viven en **un solo módulo** (`src/mocks/` o similar) que sirve a la vez al
modo UI y a los tests (contrato y promoción). Mismos mocks en todos lados.

## Web

| Stack | Corte recomendado | Escenario en caliente |
|---|---|---|
| Next.js (App Router) | `rewrites.beforeFiles` de `/api/*` a un catch-all `app/api/<mock>/[...path]` cuando `UI_MOCK=1`; o MSW en el navegador si las llamadas van directo a otro dominio | `?mock=<id>` → cookie, leída por el route de mocks |
| Next.js con Server Components que leen datos directo (no por HTTP) | Esos datos no pasan por la red: mockear el módulo de acceso a datos detrás de la misma variable, o prototipar esa pantalla en el sandbox | idem |
| Vite / CRA / SPA | MSW (`setupWorker`) arrancado en `main.tsx` solo si `import.meta.env.VITE_UI_MOCK`; o `server.proxy` a un mini servidor de mocks | `?mock=` → `localStorage`/cookie, leído por los handlers |
| Remix / React Router framework | MSW en el servidor (`setupServer`) en el entry de dev + MSW en el navegador | cookie |
| SvelteKit / Nuxt | `hooks.server` / server middleware de dev que responde los mocks | cookie |
| GraphQL (Apollo/urql/Relay) | Handlers `graphql.query/mutation` de MSW, o un link/exchange mock; los tipos del codegen dan la forma | variable de operación o cookie |
| tRPC | Link mock en el cliente o handlers HTTP de MSW sobre el endpoint de tRPC | cookie |

Guarda de producción web: el build falla si la variable del modo está encendida (chequeo en el config
del bundler/framework) y el código del modo responde 404 fuera de `development`.

Capturas: Playwright (`page.screenshot`), desktop 1280 y mobile 390.

## Mobile

| Stack | Corte recomendado | Escenario en caliente |
|---|---|---|
| React Native / Expo | MSW para React Native (`msw/native`, requiere polyfills según versión) o un cliente de API mock elegido por `EXPO_PUBLIC_UI_MOCK` | menú de dev propio (botón flotante o gesto) que guarda el escenario en AsyncStorage y recarga; o deep link `myapp://ui-lab?mock=<id>` |
| Flutter | Implementación mock del repositorio/servicio inyectada por flavor o `--dart-define=UI_MOCK=1` | pantalla de debug |
| Nativo (Swift/Kotlin) | Protocolo/interfaz del cliente con implementación mock por build configuration | menú de debug |

Guarda de producción mobile: el flag solo existe en builds de dev (perfil de EAS, flavor, build
configuration); el build de release falla o ignora el flag, con un test.

Pagos in-app, login social, push y deep links externos: pantallas falsas locales con sus resultados
(aprobado, cancelado, pendiente, error).

Capturas: `xcrun simctl io booted screenshot out.png`, `adb exec-out screencap -p > out.png`, o Maestro
(`takeScreenshot`).

Tests de promoción: Testing Library de RN contra los mismos handlers; Maestro/Detox para flujos.

## Design system / librería de componentes

- El "lab" es Storybook (o Ladle/Histoire): cada idea es una story; los escenarios son `args` o
  `globals` del toolbar.
- Componentes que piden datos: `msw-storybook-addon` con los mismos handlers.
- No hay "back" que mockear en sentido estricto: el contrato es la **API del componente** (props,
  estados, tokens). El handoff lista props nuevas, estados y tokens propuestos.
- Tests de promoción: interaction tests (`play`) + regresión visual si el proyecto la tiene.

## Monorepo con back en el mismo repo

El test de contrato puede verificar ambos sentidos: cada llamada de la UI tiene mock, y cada mock no
`pendiente` corresponde a una ruta/handler real. Si el back está en otro repo, el contrato es solo el
handoff + los tests de los mocks (y, si hay OpenAPI/GraphQL schema, validar los mocks contra el esquema).
