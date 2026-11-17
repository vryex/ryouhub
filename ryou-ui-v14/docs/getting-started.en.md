# Getting started

Ryou UI is a single-file visual library for Luau scripts running in a Roblox client with access to `Players.LocalPlayer` and `PlayerGui`.

For Roblox Studio, put [RyouUI.lua](../RyouUI.lua) in a ModuleScript named `RyouUI` under `StarterPlayerScripts`. Put [Minimal.client.lua](../examples/Minimal.client.lua) in a sibling LocalScript and press Play. Each `.client.lua` example can be run separately the same way.

```lua
local UI = require(script.Parent:WaitForChild("RyouUI"))
local window = UI:CreateWindow({ Title = "Tools", Motion = "Reduced" })
local tab = window:Tab({ Title = "Home", Icon = "home" })
tab:Button({ Title = "Check", Action = "Run", Callback = function()
    window:Notify({ Type = "success", Title = "Ready", Content = "The callback ran." })
end })
```

Hosts that provide both authenticated HTTPS transport (server certificate verification) and Luau compilation can use [DynamicLoader.lua](../examples/DynamicLoader.lua) with a commit-pinned official source URL. The loaded chunk still needs the Roblox client APIs. Standalone Luau has no Roblox renderer. Studio LocalScripts use `require`.

Set `Open = false` to register controls before opening. Call `window:Destroy()` when replacing the interface or unloading your client feature.

See the Spanish [API reference](api-reference.md), [icons](icons.md), [themes](themes.md), and [motion](animations.md).
