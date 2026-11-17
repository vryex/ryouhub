local storage = game:GetService("ReplicatedStorage")
local UI = require(storage:WaitForChild("RyouUI"))

local window = UI:CreateWindow({Title = "Movimiento", Motion = "full"})
local tab = window:Tab({Title = "Preferencias", Icon = "sliders"})
tab:Dropdown({
    Title = "Movimiento", Values = {"full", "reduced", "off"}, Default = "full", Searchable = false,
    Callback = function(mode) window:SetMotion(mode) end,
})
tab:Button({Title = "Minimizar ventana", Callback = function() window:Close() end})
