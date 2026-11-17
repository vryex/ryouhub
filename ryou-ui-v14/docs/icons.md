# Iconos

Consulta el [catálogo gráfico](../assets/icon-catalog.svg). Los glifos nativos usan segmentos Luau y funcionan sin assets de Roblox. Puedes asignar el nombre en `Icon` al crear pestañas y controles. Usa `UI:GetIcons()` para consultar nombres y alias registrados.

| Área | Nombres |
| --- | --- |
| Marca | `ryou` |
| Navegación | `home`, `sliders`, `grid`, `palette`, `user`, `image`, `layers` |
| Estados | `info`, `success`, `warning`, `error` |
| Indicadores | `chevron`, `arrow`, `grip` |

Para un icono propio, sube un PNG monocromo con fondo transparente a Roblox y registra la URL real devuelta para tu recurso con `UI:RegisterIcon("mi-icono", assetURL)`. Luego pasa `Icon = "mi-icono"`. También se acepta la URL `rbxassetid://` directamente. Revisa la moderación y permisos del asset en cada experiencia. Usa un lienzo cuadrado de 64 px o mayor para visualizarlo normalmente a 17–24 px. Roblox aplica el tinte de la interfaz al recurso.

Los nombres de `icons/` V12 se resuelven como alias semánticos. V14 usa geometría propia; un alias puede usar un glifo distinto del PNG histórico. Los nombres reservados no se sobrescriben. Un nombre desconocido usa `grid`. SVG es el formato editable del catálogo, y el símbolo se exporta también como [PNG](../assets/ryou-mark.png).
