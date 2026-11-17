# Instalación

**Roblox Studio.** Abre una experiencia de prueba y crea un `ModuleScript` llamado `RyouUI` en `ReplicatedStorage`. Usa el contenido de [RyouUI.lua](../ui/RyouUI.lua). En `StarterPlayer > StarterPlayerScripts`, crea un `LocalScript` y usa [Minimal.client.lua](../examples/Minimal.client.lua). Ejecuta **Play** para crear un cliente. El módulo monta dos `ScreenGui` en `PlayerGui`.

**Rojo.** Desde el checkout, abre Studio, inicia `rojo serve` y conecta el plugin de Rojo. [default.project.json](../default.project.json) sincroniza el módulo y `Complete.client.lua`. También puedes ejecutar `rojo build -o RyouUI-Demo.rbxlx` y abrir el resultado en Studio.

Activa un solo ejemplo por sesión. `CreateWindow` destruye la ventana que el mismo módulo creó antes. Si quieres reproducir un build concreto, conserva una copia del módulo de ese commit junto con los ejemplos del mismo commit.

Para conectar estado externo, captura el control devuelto, inicialízalo mediante `Default` o `Value`, y pasa una función `Callback`. Usa `control:Set(valor, true)` para sincronizar cambios sin volver a disparar el callback. Puedes registrar limpieza extra con `window:OnDestroy(fn)`. Consulta [Integration.client.lua](../examples/Integration.client.lua).
