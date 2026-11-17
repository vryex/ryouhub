# Ventanas

```lua
local window = UI:CreateWindow({
    Title = "Herramientas",
    Subtitle = "Mapa",
    Author = "por Ryou",
    Size = UDim2.fromOffset(760, 440),
    Position = UDim2.fromScale(.5, .5),
    ToggleKey = Enum.KeyCode.F4,
})
window:OnClose(function() print("Panel minimizado") end)
```

`Size` se expresa en offsets lógicos. `Position` indica el centro de la ventana dentro del área segura. El tamaño solicitado puede ser mayor que el área real, el panel se ajusta al viewport. En anchos pequeños la barra lateral conserva los iconos y oculta sus etiquetas. El launcher se puede arrastrar y se mantiene dentro del área disponible.

`Open`, `Close` y `Toggle` cambian el estado y conservan controles y valores. `Destroy` elimina la UI, cierra selectores y desconecta listeners. `Opened = false` muestra el launcher desde el arranque. Si también ocultas el launcher, conserva una acción externa para abrir el panel en móvil. La tecla configurada se ignora mientras hay un campo de texto enfocado.
