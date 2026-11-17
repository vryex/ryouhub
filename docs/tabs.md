# Pestañas y grupos

```lua
local group = window:Section("Editor")
local overview = group:Tab({Title = "Inicio", Desc = "Estado del editor.", Icon = "home"})
local style = group:Tab({Title = "Estilo", Icon = "palette"})
overview:Button({Title = "Ver estilo", Callback = function() style:Select() end})
window:SelectTab("Inicio")
```

`window:Tab(config)` también admite pestañas sin grupo. Agrega las pestañas de cada grupo inmediatamente después de su encabezado, en el orden de lectura. `window:Section` etiqueta la navegación, mientras que `tab:Section` separa controles en el contenido. Cada pestaña tiene scroll de contenido y la navegación tiene su propio scroll.

`SelectTab` recibe la pestaña, su título exacto o su índice desde 1. La primera pestaña queda seleccionada al crearla. Usa títulos distintos para seleccionar por nombre. El buscador del encabezado, en ventanas de al menos 470 px lógicos, filtra título, descripción y sección del control. En anchos menores puedes desplazarte por toda la lista.
