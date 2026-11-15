# Ryou

Hub en Luau para PC y móvil. **Creador: Ryou.**

Este repositorio contiene la migración del proyecto anterior hacia la identidad Ryou sin romper de golpe la API que usan los builds existentes.

## Archivos principales

- `main.luau` — shell visual standalone del nuevo diseño Ryou.
- `ui/compat.lua` — capa visual compatible con la API usada por los builds existentes.
- `scripts/duels.lua` — Duels migrado a branding Ryou.
- `scripts/mm2.lua` — MM2 migrado a branding Ryou, con el loader de UI corregido.
- `PROJECT_CONTEXT.md` — contexto técnico y reglas de migración para continuar el proyecto en cualquier chat/sesión.

## UI remota

Los scripts admiten:

```lua
getgenv().RYOU_UI_URL = "https://tu-endpoint/ryou-ui.lua"
```

antes de ejecutar el build.

Los builds y assets ya apuntan a este repositorio. Para que `game:HttpGet` y los loadstrings RAW funcionen sin autenticación, el repositorio debe estar en visibilidad pública.

## Desarrollo

El objetivo es mantener una sola base de UI para Duels, MM2 y ASD, con diseño oscuro/minimalista, soporte móvil/PC, resize, botón flotante, animaciones y personalización.

Consulta `PROJECT_CONTEXT.md` antes de hacer cambios grandes.

**Creador:** Ryou  
**TikTok:** @x0brxn


## Loadstrings

Duels:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/vryex/ryouhub/refs/heads/main/scripts/duels.lua"))()
```

MM2:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/vryex/ryouhub/refs/heads/main/scripts/mm2.lua"))()
```

La UI compartida vive en `ui/compat.lua` y todos los assets runtime están alojados en este mismo repositorio.
