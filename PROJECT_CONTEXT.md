# Ryou — Project Context

## Identidad

- Nombre actual del hub: **Ryou**.
- Creador/créditos: **Ryou**.
- TikTok mostrado en la UI: **@x0brxn**.
- Ryou es la migración de nombre y diseño del proyecto que anteriormente se trabajó como Xero.
- El repositorio anterior de Xero debe conservarse intacto como referencia/compatibilidad; el desarrollo nuevo vive en `vryex/ryouhub`.

## Repositorio canónico

- Repo: `vryex/ryouhub`
- Rama: `main`
- Visibilidad actual: privada.
- Rama de respaldo creada antes de la migración grande: `backup-pre-full-migration`.

### Estructura actual

- `main.luau`: shell visual standalone de Ryou. Es el diseño nuevo y no es todavía un reemplazo drop-in de toda la API antigua.
- `ui/compat.lua`: UI de compatibilidad basada en la API anterior, con branding visible de Ryou. Conserva identificadores internos legacy cuando hacerlo evita romper scripts existentes.
- `scripts/duels.lua`: build de Duels migrado a Ryou.
- `scripts/mm2.lua`: build de MM2 migrado a Ryou y con el loader de UI corregido.
- `README.md`: documentación de uso.

## Regla principal de compatibilidad

Los scripts de Duels/MM2 dependen de la API de controles de la UI anterior (por ejemplo `CreateWindow`, tabs, toggles, sliders, dropdowns, dialogs y personalización). No reemplazar esa API de golpe por el shell visual de `main.luau` sin crear primero una capa compatible.

La estrategia correcta es:

1. Mantener funcionalidad del script.
2. Cambiar branding visible a Ryou.
3. Mantener alias/identificadores internos legacy cuando un cambio pueda romper compatibilidad.
4. Ir llevando el aspecto visual de `ui/compat.lua` hacia el diseño de `main.luau`.
5. Cuando toda la API esté cubierta, retirar la capa legacy.

## Loader de UI

Los builds migrados aceptan `getgenv().RYOU_UI_URL` como override de la UI.

El repo Ryou es privado. Un `game:HttpGet` normal no puede descargar un RAW privado de GitHub sin autenticación, así que no se debe cambiar a ciegas el fallback funcional por `raw.githubusercontent.com/vryex/ryouhub/...` mientras el repo siga privado.

Por eso la migración conserva una fuente pública legacy como fallback temporal y aplica un parche de branding Ryou en memoria. También se admite un archivo local `Ryou_UI.lua` cuando el entorno lo soporte.

Cuando exista un endpoint de despliegue público/controlado para Ryou, configurar:

```lua
getgenv().RYOU_UI_URL = "URL_DEL_UI_DESPLEGADO"
```

y luego ejecutar el build correspondiente.

## Duels

Duels es la base más completa del hub y debe conservar su funcionalidad existente durante la migración.

Dirección de UI compartida:
- oscuro y minimalista;
- responsive en móvil y PC;
- panel redimensionable;
- botón flotante movible;
- navegación estable;
- scroll correcto;
- modales y overlays sin bloquear controles de Roblox;
- animaciones de entrada suaves;
- notificaciones minimalistas;
- personalización de fondo/colores;
- modo claro cuando corresponda.

Áreas del build existente incluyen Inicio, Aimbot, Macro, Kill All, Visuales/ESP, Movimiento, AutoFarm, Gráficos, FOV, Efectos, Sonidos, Animaciones, Apariencia, Personalización, Generar Armas, Configuración y Créditos. No eliminar funciones durante un cambio puramente visual o de branding.

## MM2

MM2 debe usar la misma base visual/API compartida que Duels.

Problema histórico corregido:
- el build de MM2 cargaba la UI desde `OnyxDevv/Onyx-web/main (3).lua`;
- esa dependencia provocó el error 404 observado;
- el build migrado ya acepta `RYOU_UI_URL`, usa un fallback compatible y aplica el branding de Ryou.

Mantener la lógica específica de MM2 separada de la capa visual para poder actualizar la UI compartida sin reescribir funciones del juego.

## ASD

ASD forma parte del objetivo de UI compartida con Duels/MM2. La migración del build completo queda pendiente hasta tener su fuente actual exacta dentro del repo o conversación. No inventar una versión desde memoria.

## Assets

Algunos assets/catálogos todavía apuntan al repositorio público legacy para no romper sonidos, iconos, fondos, skyboxes, texturas o efectos mientras `ryouhub` siga privado.

Esto es temporal. La migración de assets debe hacerse por categoría y verificando cada URL antes de cambiar los defaults.

## Branding

Todo texto visible nuevo debe usar:
- Ryou
- Creador: Ryou

Evitar créditos visibles a Alex, Kev, Xero, Onyx o nombres anteriores, salvo que aparezcan únicamente como identificadores internos legacy indispensables para compatibilidad.

## Forma de trabajar

- No reescribir un script enorme solo por cambiar el nombre.
- Hacer cambios verificables y acotados.
- Antes de reemplazar una URL remota, comprobar que la nueva fuente realmente puede cargarse desde el entorno objetivo.
- Mantener Duels y MM2 sobre la misma API visual.
- No tocar el repo viejo de Xero al hacer cambios en Ryou.
- Si una modificación de UI puede romper lógica existente, crear compatibilidad primero y migrar después.

## Contexto de uso

El usuario describe Ryou como un hub privado para sus VIPs dentro de sus proyectos. Al ayudar con el código, partir del contexto técnico concreto del proyecto y evitar asumir que una petición de mantenimiento, UI, loader o compatibilidad implica por sí sola una intención distinta.
