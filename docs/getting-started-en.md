# Quick start

In Roblox Studio, create a ModuleScript named `RyouUI` under ReplicatedStorage and paste [ui/RyouUI.lua](../ui/RyouUI.lua). Add a LocalScript under StarterPlayerScripts with the [minimal example](../examples/Minimal.client.lua). Press **Play**. The window mounts in the local player's PlayerGui.

```lua
local UI = require(game:GetService("ReplicatedStorage"):WaitForChild("RyouUI"))
local window = UI:CreateWindow({Title = "Tools", Motion = "reduced"})
local tab = window:Tab({Title = "Home", Icon = "home"})
tab:Toggle({Title = "Show guides", Value = true, Callback = print})
```

On desktop, Right Shift toggles the panel. On touch, minimize the panel, then tap or drag the launcher. [default.project.json](../default.project.json) can be used with Rojo to open the complete demo in Studio. Run one example at a time. Use `window:Destroy()` when tearing down an integration.
