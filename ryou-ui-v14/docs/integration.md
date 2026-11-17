# Integrar Ryou UI en un script

1. Elige un commit de la biblioteca y guarda su SHA. Instala el archivo como módulo o usa el cargador dinámico con las capacidades documentadas en [Primeros pasos](getting-started.md).
2. Crea la ventana con `Open = false`. Registra pestañas e iconos usando identificadores estables y declara valores iniciales desde tu estado.
3. Conecta callbacks que actualicen ese estado. Usa `control:Set(value, true)` para reflejar actualizaciones externas sin reescribir datos en el callback.
4. Muestra la interfaz con `window:Open()`. Registra `OnDestroy` para limpiar también cualquier conexión que tu script abrió por su cuenta.
5. Llama `Destroy()` antes de descargar tu integración. Fija un nuevo SHA para actualizar y vuelve a correr las pruebas de tus callbacks y controles.

[Integration.lua](../examples/Integration.lua) recibe el objeto `UI`, una tabla de preferencias y la función ordinaria que guarda cambios. Puedes almacenarlo en un `ModuleScript` hermano y ejecutarlo con:

```lua
local UI = require(script.Parent.RyouUI)
local mount = require(script.Parent.Integration)
local state = { light = false }
local window = mount(UI, state, function(saved) print(saved.light) end)
-- window:Destroy() al desmontar
```

Mantén las operaciones de red y guardado dentro de tu aplicación. La biblioteca solo representa controles y notificaciones.
