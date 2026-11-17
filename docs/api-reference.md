# API de referencia

Los ejemplos presuponen que `UI` es el módulo importado, `w` la ventana y `tab` una pestaña. Llama con `:` salvo el método `Close` de los objetos de aviso y diálogo, que también se puede llamar con punto.

## Biblioteca

| Método | Parámetros y retorno | Ejemplo |
| --- | --- | --- |
| `CreateWindow(config?)` | Recibe la configuración de abajo, devuelve la ventana y reemplaza la instancia anterior del mismo módulo. Se usa en cliente. | `local w = UI:CreateWindow({Title="Editor"})` |
| `RegisterIcon(name, asset)` | Nombre y número o URI Roblox. Devuelve la biblioteca. Los controles nuevos usan el registro. | `UI:RegisterIcon("marca", approvedAssetId)` |
| `GetIconAsset(name)` | Nombre registrado, ID o URI. Devuelve el URI o `nil`; los dibujos nativos no tienen ID. | `local uri = UI:GetIconAsset("marca")` |
| `PreloadIcon(name, callback?)` | Devuelve la biblioteca; el callback recibe el URI cargado o `nil`. Solo precarga un asset de imagen. | `UI:PreloadIcon("marca", print)` |
| `SetTheme(name)` | Cambia el tema sin aviso. Devuelve `{Name, Accent, Background, Text}`. | `local palette = UI:SetTheme("Blanco")` |
| `GetCurrentTheme()` | Devuelve la clave de tema vigente. | `print(UI:GetCurrentTheme())` |
| `GetThemes()` | Devuelve una tabla de nombres y alias admitidos. | `print(UI:GetThemes().Ryou.Name)` |
| `Notify(config?)` | Presenta un aviso en cliente. Devuelve un objeto con `Close()` o `nil` si no hay ventana. | `UI:Notify({Title="Guardado",Type="success"})` |

Opciones de `CreateWindow` y valores iniciales.

| Opción | Tipo y valor inicial |
| --- | --- |
| `Title`, `Subtitle`, `Author` | Strings. `RyouHub`, sin subtítulo explícito, `por Ryou`. |
| `Size`, `Position`, `MinSize` | `UDim2` de offsets `680 × 430`, `UDim2` centrado y `Vector2(390,320)`. El viewport limita los tres. |
| `LauncherPosition`, `OpenButton` | `UDim2` de offset `(12,12)` y tabla con `Enabled=true`, `Ghosted=false`, `Title=""`. |
| `Resizable`, `Opened` | Booleanos, ambos `true`. |
| `ToggleKey`, `UIScale` | `Enum.KeyCode.RightShift` y `1`. |
| `Theme`, `Accent`, `BackgroundImage` | Tema vigente, acento del tema y sin imagen. Aceptan string, Color3 e ID o URI. |
| `Font`, `Radius`, `Spacing`, `Motion` | Builder Sans, `8`, `12` y `"full"`. |

## Ventana, grupo y pestaña

| Método | Parámetros y retorno | Ejemplo |
| --- | --- | --- |
| `Tab(config?)` | En ventana y grupo. String o tabla con `Title="Pestaña"`, `Desc=""`, `Icon` opcional. Devuelve una pestaña. | `local tab=w:Tab({Title="Inicio",Icon="home"})` |
| `w:Section(config?)` | String o tabla con `Title=""`. Devuelve grupo con `Tab`; `Open` y `Close` son alias sin efecto visual. | `local group=w:Section("Editor")` |
| `w:SelectTab(which)` | Índice desde 1, título exacto u objeto. Devuelve la pestaña seleccionada o `nil`. | `w:SelectTab(1)` |
| `tab:Select()` | Selecciona y devuelve esa pestaña. | `tab:Select()` |
| `tab:LockAll()`, `tab:UnlockAll()` | Sin argumentos ni valor devuelto. | `tab:LockAll()` |
| `w:SetTitle(text)`, `w:SetAuthor(text)` | Reciben texto y devuelven la ventana. | `w:SetTitle("Proyecto"):SetAuthor("por Ryou")` |
| `w:SetSize(size)`, `w:GetSize()` | UDim2 de offsets y retorno de ventana; el getter devuelve Vector2 del tamaño solicitado. | `w:SetSize(UDim2.fromOffset(600,400)); print(w:GetSize())` |
| `w:SetResizable(value)`, `w:SetToTheCenter()` | El booleano activa los bordes de resize. El segundo método centra. Ambos devuelven la ventana. | `w:SetResizable(false):SetToTheCenter()` |
| `w:SetUIScale(value)`, `w:GetUIScale()` | Valor entre 0.7 y 1.4. Devuelven ventana o número, respectivamente. | `w:SetUIScale(1.1); print(w:GetUIScale())` |
| `w:SetToggleKey(key)` | Enum.KeyCode para teclado, devuelve ventana. | `w:SetToggleKey(Enum.KeyCode.F4)` |
| `w:SetOpenButtonVisible(value)`, `w:SetOpenButtonGhosted(value)` | Booleanos. Ghosted deja un acceso transparente. Devuelven ventana. | `w:SetOpenButtonVisible(true):SetOpenButtonGhosted(false)` |
| `w:EditOpenButton(config)` | Recibe `Enabled`, `Ghosted` y `Title` opcionales. Devuelve ventana. | `w:EditOpenButton({Title="Editor"})` |
| `w:SetTheme(name, silent?)`, `w:GetTheme()` | Actualiza el tema y devuelve la ventana. El getter devuelve `Xero` o `Blanco`. | `w:SetTheme("Blanco",true); print(w:GetTheme())` |
| `w:SetMotion(mode)`, `w:GetMotion()` | Cambia entre `full`, `reduced` y `off`. Devuelven ventana o string. | `w:SetMotion("reduced"); print(w:GetMotion())` |
| `w:Open()`, `w:Close()`, `w:Toggle()` | Cambian visibilidad y devuelven ventana. | `w:Close():Open()` |
| `w:OnOpen(fn)`, `w:OnClose(fn)`, `w:OnDestroy(fn)` | Registran funciones sin argumentos que se ejecutan tras cambiar estado. Devuelven ventana. | `w:OnClose(function() print("Minimizado") end)` |
| `w:Destroy()` | Limpia instancias y conexiones. No devuelve valor. | `w:Destroy()` |
| `w:Dialog(config?)` | `Title="Ryou"`, `Content` o `Desc`, `Buttons={{Title="Aceptar"}}`. Cada botón admite callback sin argumentos. Devuelve manejador con `Close()` cuando la ventana está abierta. | `w:Dialog({Title="Salir",Buttons={{Title="Cerrar",Callback=function() w:Destroy() end}}})` |
| `w:Notify(config?)` | Alias sobre la ventana activa para `UI:Notify`. `Title="Ryou"`, `Content` o `Desc`, `Type="info"`, `Duration=3`. | `w:Notify({Type="warning",Title="Sin conexión"})` |

En móvil el launcher reemplaza al atajo de teclado. La navegación compacta usa los mismos objetos de pestaña, con iconos y scroll.

## Controles

Cada método devuelve un control. Opciones comunes. `Title` usa el nombre del control, `Desc=""`, `Icon` opcional, `IconSize=16` y `Locked=false`. Los controles usan `Activated` para toque o mouse. La escritura utiliza TextBox de Roblox.

| Método | Parámetros específicos y valor | Ejemplo |
| --- | --- | --- |
| `tab:FooterButton(config?)` | Acción fija debajo del scroll. `Title="Aplicar"`, `Locked=false`, `Callback()`. Devuelve un manejador con `SetTitle`, `Lock`, `Unlock` y `Destroy`. Reemplaza la acción fija anterior de la pestaña. | `tab:FooterButton({Title="Aplicar",Callback=print})` |
| `tab:Section(config?)` | String o tabla de título. Encabezado sin valor. | `tab:Section("Personaje")` |
| `tab:Paragraph(config?)` | Descripción opcional, `Image` Roblox, `ImageSize=32`, `ImageAlign="right"`, `CircleImage=false`, `Gothic=false`. `Set` actualiza la descripción. | `tab:Paragraph({Title="Estado", Desc="Listo"})` |
| `tab:Button(config?)` | `Callback()` opcional. | `tab:Button({Title="Guardar",Callback=function() print("Guardado") end})` |
| `tab:Toggle(config?)` | `Value=false`; `Callback(boolean)`. | `tab:Toggle({Title="Vista previa",Value=true,Callback=print})` |
| `tab:Slider(config?)` | `Min=0`, `Max=100`, `Step=1`, `Default=Min`; admite `Value={Min, Max, Default}` o un valor inicial numérico. `Callback(number)`. | `tab:Slider({Title="Zoom",Min=25,Max=150,Default=75,Callback=print})` |
| `tab:Input(config?)` | `Value` o `Default=""`, `Placeholder="Escribe aquí…"`, `Live=false`, `Callback(string)`. | `tab:Input({Title="Nombre",Default="Editor",Callback=print})` |
| `tab:Dropdown(config?)` | `Values={}`, `Value` o `Default`, `Multi=false`, `Searchable=true`. Callback recibe la selección o un arreglo de selecciones. | `tab:Dropdown({Title="Modo", Values={"Ver","Editar"}, Default="Ver"})` |
| `tab:Colorpicker(config?)` | `Default` o `Value` de tipo Color3, acento del tema como fallback. `Callback(Color3)`. | `tab:Colorpicker({Title="Fondo",Default=Color3.fromRGB(27,29,33)})` |

| Método del control | Parámetros y retorno | Ejemplo |
| --- | --- | --- |
| `Get()`, `Set(value, silent?)`, `SetValue(value, silent?)` | Getter en controles con valor. Setters devuelven control y aceptan `silent=true` para omitir callback. | `toggle:SetValue(false,true); print(toggle:Get())` |
| `SetTitle(text)`, `SetDesc(text)` | Actualizan texto y devuelven control. | `control:SetTitle("Estado"):SetDesc("Actualizado")` |
| `SetVisible(value)`, `Show()`, `Hide()` | Cambian visibilidad y devuelven control. | `control:SetVisible(true)` |
| `Lock()`, `Unlock()` | Cambian disponibilidad y devuelven control. | `control:Lock()` |
| `Destroy()` | Destruye la fila. No devuelve valor. | `control:Destroy()` |
| `Dropdown:Refresh(values)` | Sustituye opciones. Devuelve el dropdown. | `picker:Refresh({"A","B"})` |
| `Dropdown:Open()`, `Close(instant?)`, `Toggle()` | Controlan expansión inline. Devuelven dropdown. | `picker:Open():Close(true)` |
| `Colorpicker:Open()` | Abre el selector cuando está habilitado. No devuelve valor. | `color:Open()` |
