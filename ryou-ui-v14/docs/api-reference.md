# Referencia de API · 14.0.0

Las llamadas usan `:`. Los nombres `UI`, `w`, `t` y `c` de los ejemplos representan la biblioteca, la ventana, una pestaña y un control. Los ejemplos de cada fila se pueden combinar con la [instalación](getting-started.md). Las operaciones de configuración son iguales en móvil y PC. Las diferencias de interacción se explican por componente.

## Biblioteca

| Firma | Parámetros y valor inicial | Devuelve y ejemplo |
| --- | --- | --- |
| `UI:CreateWindow(options?)` | Tabla de [opciones](#opciones-de-ventana). Reemplaza la ventana vigente de esta instancia de UI. Requiere cliente Roblox. | `Window`. `local w = UI:CreateWindow({ Title = "Archivo" })` |
| `UI:SetTheme(config)` | Nombre o tabla con `Name`, `Background` y `Accent`. Aplica a la ventana y a creaciones futuras. | `UI`. `UI:SetTheme("Light")` |
| `UI:GetCurrentTheme()` | Nombre canónico de la ventana vigente o del tema inicial. | `"Dark" \| "Light"`. `print(UI:GetCurrentTheme())` |
| `UI:GetThemes()` | Sin argumentos. Devuelve definiciones simples con campo `Name`. | Tabla de temas. `print(UI:GetThemes().Dark.Name)` |
| `UI:RegisterIcon(name, asset)` | Nombre libre y URL `rbxassetid://` válida. Registra para los controles que se creen después. | `UI`. `UI:RegisterIcon("perfil", assetURL)` |
| `UI:GetIcons()` | Sin argumentos. Incluye nombres internos, alias y nombres registrados. | Lista ordenada de strings. `print(table.concat(UI:GetIcons(), ", "))` |
| `UI:Notify(options?)` | [Opciones de aviso](#avisos). Requiere una ventana vigente. | Aviso o `nil`. `UI:Notify({Title = "Listo"})` |

`UI.Version` identifica la distribución. `UI.Window` es la ventana viva del objeto de biblioteca o `nil`.

## Opciones de ventana

| Campo | Tipo | Inicial y restricciones |
| --- | --- | --- |
| `Title` | string | `"Ryou UI"` |
| `Subtitle`, `Author` | string | `"Created by Ryou"`. Si se reciben ambos, usa `Subtitle`. |
| `Size` | Vector2 o UDim2 | 710 × 435 px; para UDim2 usa offsets positivos. |
| `Position` | Vector2 | Centro del área segura. El punto representa el centro de la ventana. |
| `Open` | boolean | `true`; la apertura se difiere hasta después de la creación. |
| `Theme` | string o tabla | Tema configurado en UI o `Dark`. |
| `Motion` | string | `Full`; acepta `Full`, `Reduced` y `Off`. |
| `Launcher` | boolean | `true`; aparece al cerrar. |
| `OpenButton` | tabla | Opcional. Campos `Enabled` y `Ghosted` booleanos. |
| `Resizable` | boolean | `true`; muestra el control de esquina. |
| `ToggleKey` | Enum.KeyCode | `RightShift`. Cambia a `nil` después de crear para inhabilitar. |
| `Radius`, `Spacing` | number | 8 y 9 px. Rango 4–16. |
| `Font`, `BoldFont` | Enum.Font | `Gotham` y `GothamBold`. |

## Ventana

| Firma | Parámetros y comportamiento | Devuelve y ejemplo |
| --- | --- | --- |
| `w:Tab(options?)` | Tabla con `Title` (Pestaña), `Id` (título), `Desc`, `Icon` (grid); acepta también solo el título. | `Tab`. `local t = w:Tab({Title = "Inicio", Icon = "home"})` |
| `w:Section(options?)`, `w:Group(options?)` | `Title` o string, por defecto vacío. Inserta encabezado en el orden de invocación. | Grupo. `local group = w:Group("Panel")` |
| `group:Tab(options?)` | Misma firma que `w:Tab`. | `Tab`. `group:Tab({Title = "Opciones"})` |
| `group:Open()`, `group:Close()` | Muestra u oculta el encabezado del grupo. | Grupo. `group:Close():Open()` |
| `w:SelectTab(which)` | Objeto, título, ID o índice desde 1. | `Tab?`. `w:SelectTab("Inicio")` |
| `w:Open()`, `w:Close()`, `w:Toggle()` | Cambia el estado de la ventana. | `Window`. `w:Close():Open()` |
| `w:SetTitle(text)` | Nuevo título; `nil` limpia el texto. | `Window`. `w:SetTitle("Archivo 2")` |
| `w:SetAuthor(text)`, `w:SetSubtitle(text)` | Nuevo subtítulo; `nil` limpia el texto. | `Window`. `w:SetSubtitle("Preferencias")` |
| `w:SetTheme(config)`, `w:GetTheme()` | Nombre o tabla de [tema](themes.md). El getter devuelve el nombre canónico. | `Window` / string. `w:SetTheme("Light"):GetTheme()` |
| `w:SetMotion(mode)` | `Full`, `Reduced` u `Off`. | `Window`. `w:SetMotion("Off")` |
| `w:SetSize(size)`, `w:GetSize()` | Vector2 o UDim2 de offsets. El getter devuelve el tamaño solicitado. | `Window` / Vector2. `w:SetSize(UDim2.fromOffset(640, 360)):GetSize()` |
| `w:SetPosition(position)`, `w:SetToTheCenter()` | Vector2 de centro en el cliente o `nil` para centrar. El centro se limita al área visible. | `Window`. `w:SetToTheCenter()` |
| `w:SetResizable(enabled)` | `false` oculta el control de esquina; `nil` lo habilita. | `Window`. `w:SetResizable(false)` |
| `w:SetToggleKey(key)` | Enum.KeyCode o `nil`. Atajo para clientes con teclado. | `Window`. `w:SetToggleKey(Enum.KeyCode.F8)` |
| `w:SetOpenButtonVisible(enabled)` | `false` oculta el símbolo al cerrar; `nil` lo habilita. | `Window`. `w:SetOpenButtonVisible(true)` |
| `w:SetOpenButtonGhosted(enabled)` | `true` atenúa el fondo del símbolo. | `Window`. `w:SetOpenButtonGhosted(true)` |
| `w:EditOpenButton(config)` | Tabla con `Enabled` y `Ghosted` opcionales. | `Window`. `w:EditOpenButton({Ghosted = true})` |
| `w:OnOpen(fn)`, `w:OnClose(fn)`, `w:OnDestroy(fn)` | `fn(window)`, se registran hasta destruir la ventana. | `Window`. `w:OnClose(function() print("Cerró") end)` |
| `w:Notify(options?)` | Crea un [aviso](#avisos). | Aviso o `nil` si destruida. `local n = w:Notify({Type = "info"})` |
| `w:Destroy()` | Libera los elementos y eventos propios. Segunda llamada sin efecto. | Sin valor. `w:Destroy()` |

`w.Opened` indica la intención actual de visibilidad. `w.ScreenGui` identifica el contenedor de Roblox. Consulta [ventanas](windows.md) y [pestañas](tabs.md) para el comportamiento táctil.

## Pestaña y controles

Los constructores aceptan una tabla. Los campos comunes son `Title`, `Desc` (alias `Description` y `Content`), `Icon`, `IconSize` (17 px, rango 12–24) y `Callback`. Por defecto no hay contenido, icono ni callback. Todos los controles devuelven un objeto `Control`. Un callback recibe el valor tras la modificación; el botón no envía argumentos.

| Firma | Opciones específicas, valores iniciales y uso móvil | Ejemplo |
| --- | --- | --- |
| `t:Select()` | Selecciona la pestaña. Devuelve Tab. | `t:Select()` |
| `t:Section(options?)` | `Title` o string. Devuelve Tab. | `t:Section("Sesión")` |
| `t:LockAll()`, `t:UnlockAll()` | Bloquea o restaura la interacción de los controles. Devuelve Tab. | `t:LockAll():UnlockAll()` |
| `t:Button(options?)` | `Action = "Ejecutar"`. Puede tocarse en móvil. | `t:Button({Title = "Guardar", Callback = print})` |
| `t:Toggle(options?)` | `Value` o `Default` booleano; inicia en `false`. Toca para alternar. | `t:Toggle({Title = "Activo", Value = true})` |
| `t:Slider(options?)` | `Min = 0`, `Max = 100`, `Step = 1`, `Value` o `Default = Min`; admite tabla V12 con `Value.Min/Max/Default`. Arrastra el área horizontal. | `t:Slider({Min = 1, Max = 20, Default = 8})` |
| `t:Input(options?)` | `Value` o `Default = ""`, `Placeholder`, `Live = false`. Usa teclado y foco nativos. | `t:Input({Title = "Nombre", Placeholder = "Escribe"})` |
| `t:Dropdown(options?)` | `Values = {}`, `Multi` o `MultiSelect = false`, `Value` o `Default = nil` (simple) o `{}` (múltiple). Usa búsqueda y desplazamiento. | `t:Dropdown({Values = {"A", "B"}, Default = "A"})` |
| `t:Colorpicker(options?)`, `t:ColorPicker(options?)` | `Value` o `Default` Color3; inicia con el acento. Usa gesto horizontal HSV o HEX con teclado. | `t:Colorpicker({Value = Color3.fromHex("84F1C6")})` |
| `t:Paragraph(options?)` | Solo lectura visual y sin callback de usuario. | `t:Paragraph({Title = "Estado", Desc = "Listo"})` |

### Métodos del control

| Firma | Parámetros y restricciones | Devuelve y ejemplo |
| --- | --- | --- |
| `c:Set(value, silent?)`, `c:SetValue(value, silent?)` | Bool, número, string, valor/lista dropdown o Color3 según el control. `silent = false`. En Paragraph actualiza la descripción. Button carece de estado. | `Control`. `toggle:SetValue(true, true)` |
| `dropdown:Set(value, silent?, force?)` | `force = true` emite el callback incluso si el estado es igual, salvo con `silent = true`. | `Control`. `dropdown:Set("A", false, true)` |
| `c:Get()` | Lee el valor. Copia la lista múltiple. Button y Paragraph devuelven `nil`. | Valor. `print(toggle:Get())` |
| `c:SetTitle(text)`, `c:SetDesc(text)` | Actualiza la etiqueta o descripción. | `Control`. `c:SetTitle("Nuevo"):SetDesc("Detalle")` |
| `c:SetVisible(enabled)`, `c:Show()`, `c:Hide()` | Afecta la fila completa. | `Control`. `c:Hide():Show()` |
| `c:Lock()`, `c:Unlock()` | Bloquea entrada de usuario. | `Control`. `c:Lock():Unlock()` |
| `c:Destroy()` | Desconecta eventos y elimina el control. | Sin valor. `c:Destroy()` |
| `dropdown:Refresh(values)` | Sustituye las opciones sin cambiar el valor actual. | `Control`. `dropdown:Refresh({"B", "C"})` |
| `dropdown:Open()`, `color:Open()` | Alterna el dropdown o abre el colorpicker sin alternar. | `Control`. `dropdown:Open()` |
| `dropdown:Close(instant?)`, `color:Close(instant?)` | `instant = false`; `true` omite la transición. | `Control`. `color:Close(true)` |

### Avisos

`Notify` acepta `Title = "Ryou"`, `Type = "info"`, `Content = ""` y `Duration = 3` s. `Desc` y `Description` son alias para el contenido. `notice:Dismiss()` anima su retirada y no devuelve valor. El comportamiento y el límite de avisos activos se describen en [notificaciones](notifications.md).

```lua
local notice = w:Notify({ Title = "Archivo guardado", Type = "success", Duration = 3 })
if notice then notice:Dismiss() end
```
