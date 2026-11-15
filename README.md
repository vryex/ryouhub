# Ryou

Interfaz de cliente en Luau para PC y móvil. La pantalla de entrada presenta la marca Ryou. El panel usa navegación lateral en pantallas amplias e inferior en pantallas compactas.

Puedes cambiar el color de acento y el tamaño del panel, reducir el movimiento o mostrar un reloj al cerrar la ventana. El botón flotante se puede arrastrar. En PC, Shift derecho abre y cierra el panel.

## Montaje

Carga el módulo local desde tu proyecto y pásale el `PlayerGui` del cliente.

```lua
local Ryou = require(script.Parent.Ryou)
local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

local panel = Ryou.mount(playerGui, { openOnMount = false })
panel:Open()
```

`mount` reutiliza el panel si ya está montado en el mismo `PlayerGui`. El controlador expone `Open()`, `Close()` y `Destroy()`. Los ajustes duran mientras el panel siga montado. El módulo también acepta `displayName` para el saludo inicial.

**Creador** Ryou

**TikTok** @x0brxn
