# Componentes

Todos se crean desde una pestaña. `Title` nombra el control, `Desc` agrega contexto y `Icon` es opcional. `Locked = true` deshabilita la interacción inicial. Puedes usar `Lock()`, `Unlock()`, `SetTitle()`, `SetDesc()`, `Show()`, `Hide()` o `Destroy()` sobre el control devuelto.

| Control | Interacción | Ejemplo |
| --- | --- | --- |
| `Button` | Toca el título o la flecha. | `tab:Button({Title="Guardar", Callback=save})` |
| `Toggle` | Toca el interruptor. | `tab:Toggle({Title="Guías", Value=true, Callback=print})` |
| `Slider` | Arrastra la barra o escribe el valor. | `tab:Slider({Title="Zoom", Min=25, Max=150, Step=5, Default=75, Callback=print})` |
| `Input` | Abre el teclado nativo al tocar el campo. | `tab:Input({Title="Nombre", Placeholder="Escribe aquí", Callback=print})` |
| `Dropdown` | Expande opciones en la misma fila. | `tab:Dropdown({Title="Modo", Values={"Editar","Ver"}, Default="Editar"})` |
| `Colorpicker` | Toca la muestra para abrir el selector. | `tab:Colorpicker({Title="Color", Default=Color3.fromRGB(150,234,201), Callback=print})` |
| `Paragraph` | Muestra título y descripción. | `tab:Paragraph({Title="Estado", Desc="Listo", Icon="info"})` |
| `Section` | Inserta un encabezado en la lista. | `tab:Section("Ajustes")` |

`Input` confirma al perder foco. Con `Live = true`, entrega cambios al escribir. `Slider` recibe límites y paso numéricos. En `Colorpicker`, arrastra saturación/brillo y tono, escribe seis dígitos HEX o toca un color rápido. La zona del selector tiene scroll cuando necesita más altura. `Paragraph` admite una miniatura Roblox con `Image`, `ImageSize`, `ImageAlign` y `CircleImage`.

Los controles con valor exponen `Get()`, `Set(value, silent?)` y el alias `SetValue`. Inicializar un control nunca ejecuta el callback. En general, cambiar un valor sí lo ejecuta. Un botón entrega cero argumentos. Los errores de callbacks aparecen en Output.

## Acción fija

`tab:FooterButton({Title="Aplicar", Locked=true, Callback=apply})` reserva una franja inferior en la pestaña. Desbloquéala al seleccionar una opción. Permanece disponible mientras el resto del contenido se desplaza. [El ejemplo de outfits](../examples/Outfits.client.lua) lee un Folder `Catalog` del LocalScript. Agrega un StringValue por outfit. Usa el nombre como título, el valor como ID y los atributos opcionales `User` y `PreviewAssetId`. Si agregas un BindableEvent hijo llamado `OutfitSelected`, el botón envía ahí el ID para que la experiencia gestione la acción.
