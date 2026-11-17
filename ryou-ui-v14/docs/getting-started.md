# Primeros pasos

Ryou UI se distribuye como un solo archivo [RyouUI.lua](../RyouUI.lua). El código usa servicios de Roblox y requiere un cliente con `Players.LocalPlayer` y `PlayerGui`. Un intérprete Luau de terminal puede compilar el archivo, pero no renderiza la interfaz.

**En una experiencia propia.** Crea un `ModuleScript` llamado `RyouUI` en `StarterPlayerScripts`. Usa el contenido de `RyouUI.lua` en el módulo. Crea un `LocalScript` hermano con [Minimal.client.lua](../examples/Minimal.client.lua) y ejecuta **Play**.

**En un host Luau compatible.** El [cargador dinámico](../examples/DynamicLoader.lua) acepta una función del host que descarga texto por HTTPS, otra que lo compila y una URL oficial fijada a un commit de 40 caracteres. Ejecuta el chunk en el cliente que dispone de los servicios de Roblox. Studio admite la ruta de `ModuleScript` desde un `LocalScript`. El ejemplo dinámico requiere capacidades adicionales del host.

```lua
local UI = require(script.Parent:WaitForChild("RyouUI"))
local w = UI:CreateWindow({ Title = "Ajustes", Subtitle = "Created by Ryou" })
local t = w:Tab({ Title = "Inicio", Icon = "home" })
t:Button({ Title = "Comprobar", Callback = function()
    w:Notify({ Type = "success", Title = "Listo" })
end })
```

Registra las pestañas de forma síncrona después de crear la ventana para incluirlas en la animación inicial. También puedes pasar `Open = false`, terminar de registrar la interfaz y llamar `w:Open()`.

Sigue con [ventanas](windows.md), [pestañas](tabs.md) y [componentes](components.md).
