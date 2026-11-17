# Migrar de V12 a V14

V12 fue revisada en la rama `ryou-ui-v12-crafted`, archivo `ui/compat.lua`. Ryou UI V14 vive en `ryou-ui-v14/RyouUI.lua` y devuelve la tabla de la biblioteca visual.

| V12 | V14 |
| --- | --- |
| `CreateWindow({Title, Author, Size, Theme, OpenButton})` | Conservados. `Subtitle` equivale a `Author`. `Size` admite además `Vector2`. |
| `Window:Tab`, `Window:Section`, `Tab:Section` | Conservados; `Window:Group` es alias. `SelectTab` admite índice, objeto, título o ID. |
| `Button`, `Toggle`, `Slider`, `Input`, `Dropdown`, `Colorpicker`, `Paragraph` | Conservan las firmas de tabla, `Title`, `Desc`, `Icon` y los callbacks ordinarios. |
| `Toggle.Value`, `Slider.Value = { Min, Max, Default }`, `Input.Value` | Conservados. `Default` es alias para los valores iniciales. |
| `Dropdown.Multi`, `MultiSelect`, `Set(value, silent, force)`, `Refresh`, `Open/Close` | Conservados. Las listas admiten strings y números. Una entrada duplicada se identifica por tipo y valor. |
| `SetTheme("Xero")` o `SetTheme("Blanco")` | Resuelven a `Dark` o `Light`. Actualiza las comparaciones si lees el nombre de retorno. `UI:SetTheme` devuelve UI. |
| `Notify({Title, Content, Duration})` | Conservado; agrega `Type` y devuelve un aviso descartable. |
| `Open`, `Close`, `Destroy` | Conservados. El estado de apertura inicial se resuelve en una tarea diferida para admitir el montaje de pestañas. |
| `EditOpenButton({ Enabled, Ghosted, Title })` | Conserva `Enabled` y `Ghosted`. El launcher de V14 usa símbolo sin título. |
| Recursos PNG y caché de V12 | Los nombres históricos se resuelven a glifos de V14. Para recursos propios usa `RegisterIcon` con URL Roblox. |

Algunos consumidores de V12 tocaban instancias internas y opciones específicas de esa versión. V14 no implementa `Dialog`, `GetIconAsset`, `PreloadIcon`, `SetUIScale`, el arreglo interno `UIElements`, estilos locales por tarjeta como `LightColor`, ni carga de PNG mediante funciones ajenas a Roblox. Modifica consumidores que dependan de esos detalles para usar los métodos de V14. La estructura de los hijos de `ElementFrame` puede cambiar.

Las comprobaciones cubren la biblioteca visual y la API documentada. No se probó como sustitución directa de un consumidor concreto de V12.
