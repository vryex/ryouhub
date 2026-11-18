# Personalización

Usa opciones del constructor para fijar la composición inicial. Las propiedades que cambian durante el uso tienen métodos específicos en [la referencia](api-reference.md).

| Parámetro | Inicial | Uso |
| --- | --- | --- |
| `Radius` | 8 px | Radio de controles. Se limita a 4–16 px. |
| `Spacing` | 9 px | Separación vertical de la página. Se limita a 4–16 px. |
| `Font` | `Enum.Font.Gotham` | Texto y campos editables. |
| `BoldFont` | `Enum.Font.GothamBold` | Marca, títulos y acciones. |
| `Size` | 1040 × 615 px | `Vector2` o `UDim2` de offsets. |
| `Position` | centrada | Centro en píxeles dentro del área de cliente. |
| `Launcher` | `true` | Muestra el símbolo al cerrar. |
| `Theme` | `Dark` | Tema o configuración de tema. |
| `Motion` | `Full` | Intensidad de movimiento. |

La escala visual usa 21 px en la marca, 19 px en encabezados de página, 14 px en acciones y campos, 13 px para descripciones y valores y 12 px para rótulos de organización. Los controles de interacción primaria tienen áreas de 44 px; el launcher mide 70 × 70 px. Prueba fuentes nativas alternativas con textos largos y en el emulador de dispositivo.


## Neo Sidebar V7: apariencia en vivo

La API admite estos presets: Menta Ryou, Medianoche, Violeta, Carmesí, Azul hielo, Rosa, Ámbar y Perla (claro). Los métodos funcionan sobre la ventana existente, sin destruirla.

```lua
local win = UI:CreateWindow({Title="Ryou", ThemePreset="Violeta", AnimationSpeed=1.3})
win:SetThemePreset("Medianoche")
win:SetAccent(Color3.fromRGB(190, 110, 255))
win:SetBackgroundColor(Color3.fromRGB(12, 16, 25))
win:SetFontStyle("Gotham")        -- Gotham, SourceSans, Arial
win:SetAnimationSpeed(1.5)       -- 0.5x ... 2.0x (2 = más rápido)
win:SetSurfaceTransparency(.15)  -- 0 ... .35
win:SetMotion("Reduced")          -- Full, Reduced, Off
local data = win:ExportAppearance()   -- tabla JSON segura
win:ImportAppearance(data)             -- restaura campos válidos
```

`UI:GetThemePresets()`, `UI:GetThemes()` y `UI:GetFontStyles()` permiten construir controles de configuración. Los métodos `GetAccent`, `GetBackgroundColor`, `GetFontStyle`, `GetAnimationSpeed` y `GetSurfaceTransparency` devuelven los valores actuales.

La biblioteca **no escribe archivos automáticamente**. La aplicación puede guardar `HttpService:JSONEncode(win:ExportAppearance())` usando las API que tenga disponibles. Esta decisión evita dependencias obligatorias y escritura constante en Android.

**Rendimiento:** la transparencia se limita a 35 %, no añade desenfoques ni nuevos ciclos de renderizado. `SetMotion("Off")` elimina el tiempo de tween; `SetDecorationIntensity(0)` oculta efectos decorativos. Las pruebas táctiles en un Android real siguen pendientes.
