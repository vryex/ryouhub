# Dropdowns inline

```lua
local picker = tab:Dropdown({
    Title = "Capas visibles",
    Values = {"Guías", "Texto", "Fondo"},
    Multi = true,
    Default = {"Texto"},
    Callback = function(values)
        print(table.concat(values, ", "))
    end,
})

picker:Refresh({"Guías", "Texto", "Fondo", "Máscara"})
picker:Set({"Texto", "Máscara"}, true)
```

Usa valores de tipo string o número. `MultiSelect = true` es alias de `Multi`. El modo individual devuelve el valor seleccionado. El modo múltiple entrega una copia del arreglo al callback. En modo individual, pulsar una opción confirma y cierra, incluso si vuelves a seleccionar la misma. Al actualizar las opciones con `Refresh`, la selección anterior permanece hasta que la cambies con `Set`.

La búsqueda está activa de forma predeterminada. `Searchable = false` sirve para listas cortas. La lista elimina etiquetas duplicadas por texto normalizado y muestra hasta 180 coincidencias por filtro. Se abre dentro de la lista de controles con scroll propio para las opciones. Solo se expande un dropdown a la vez.

`Open()` abre, `Close(instant?)` cierra y `Toggle()` alterna ambos estados. Esc también puede cerrar el selector cuando el cuadro de texto no tiene foco.
