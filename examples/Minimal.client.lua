local storage = game:GetService("ReplicatedStorage")
local UI = require(storage:WaitForChild("RyouUI"))

local window = UI:CreateWindow({Title = "Ryou UI"})
local home = window:Tab({Title = "Inicio", Icon = "home"})
home:Button({
    Title = "Mostrar aviso",
    Callback = function()
        window:Notify({Title = "Hola", Content = "La ventana está lista."})
    end,
})
