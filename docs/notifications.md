# Notificaciones

Usa un tipo entre `info`, `success`, `warning` y `error`.

```lua
local notice = window:Notify({
    Title = "Presets",
    Content = "Se guardó el preset principal.",
    Type = "success",
    Duration = 4,
})
if notice then notice.Close() end
```

`UI:Notify(config)` envía el mismo aviso a la ventana actual. Usa títulos breves, el cuerpo visible ocupa hasta dos líneas. La duración se limita a 1–12 segundos. La pila muestra hasta dos avisos y reduce el límite a uno si el área de cliente tiene menos de 430 px de alto. El aviso se puede cerrar con `Close()` mientras sigue visible.
