# Dropdowns sobre la página

El panel se expande dentro del control. Busca por subcadena literal sin distinguir mayúsculas ASCII y muestra hasta 180 coincidencias por filtro. La lista tiene su propio scroll. La selección simple cierra al elegir. En selección múltiple el panel queda abierto y el callback recibe una copia de la lista en orden de selección.

```lua
local tags = tab:Dropdown({
    Title = "Etiquetas",
    Values = { "Boceto", "Entrega", "Archivo" },
    MultiSelect = true,
    Default = { "Boceto" },
    Callback = function(values) print(table.concat(values, ", ")) end,
})
tags:Refresh({ "Boceto", "Entrega", "Revisión" })
tags:Set({ "Revisión" }, true)
```

`Refresh` actualiza las opciones sin emitir el callback y conserva el valor anterior, incluso si se retiró del catálogo. Para invalidar un valor tras actualizar tus datos, llama `Set(nil, true)` en selección simple o `Set({}, true)` en selección múltiple. Las opciones admiten números y cadenas; valores duplicados del mismo tipo se muestran una vez.

`Open()` alterna el estado por compatibilidad con V12. `Close(true)` cierra inmediatamente; `Close()` anima el cierre. En pantallas bajas, desplaza la página para acceder a la lista expandida. En teclado móvil, confirma o quita el foco antes de continuar el scroll.
