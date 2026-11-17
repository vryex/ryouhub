# Componentes

Pasa `Title`, `Desc`, `Icon` y opcionalmente `IconSize` en el constructor del control. `Callback` se invoca al cambiar un valor o activar un botón. Los valores iniciales se registran en silencio.

```lua
local info = tab:Paragraph({ Title = "Estado", Desc = "En espera" })
tab:Button({ Title = "Guardar", Action = "Guardar", Callback = function() info:SetDesc("Guardado") end })
local enabled = tab:Toggle({ Title = "Activo", Default = true })
tab:Slider({ Title = "Escala", Value = { Min = 50, Max = 150, Default = 100 }, Step = 5 })
tab:Input({ Title = "Nombre", Placeholder = "Mi perfil", Callback = print })
tab:ColorPicker({ Title = "Acento", Default = Color3.fromRGB(132, 241, 198), Callback = print })
enabled:Set(false, true)
```

`Toggle:Set` espera un booleano. `Slider:Set` limita y redondea al paso más cercano a partir del mínimo. `Input` confirma al perder el foco o propaga cada edición con `Live = true`. `Colorpicker` acepta `Color3`, incluye barras HSV, entrada HEX de seis dígitos y tres muestras. `Paragraph:Set(text)` cambia la descripción. Para leer controles con estado usa `Get()`.

`Lock()` deshabilita la interacción del usuario. Todavía puedes sincronizar el estado programáticamente. Usa `Hide()` y `Show()` para visibilidad, y `Destroy()` para retirar un control. Se recomienda mantener callbacks cortos y agregar manejo de errores en la capa que escribe datos o hace solicitudes.

Consulta [Dropdowns](dropdowns.md) para selección múltiple y catálogos dinámicos.
