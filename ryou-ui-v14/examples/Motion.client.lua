local UI = require(script.Parent:WaitForChild("RyouUI"))
local window = UI:CreateWindow({ Motion = "Full" })
local tab = window:Tab({ Title = "Movimiento", Icon = "sliders" })
tab:Dropdown({ Title = "Preferencia", Values = { "Full", "Reduced", "Off" }, Default = "Full",
    Callback = function(value) window:SetMotion(value) end })
tab:Button({ Title = "Contraer y reabrir desde el símbolo", Action = "Cerrar",
    Callback = function() window:Close() end })
