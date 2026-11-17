local storage = game:GetService("ReplicatedStorage")
local UI = require(storage:WaitForChild("RyouUI"))

local window = UI:CreateWindow({Title = "Avisos"})
local tab = window:Tab({Title = "Notificaciones", Icon = "bell"})
local lastNotice
for _, kind in ipairs({"info", "success", "warning", "error"}) do
    tab:Button({Title = kind, Callback = function()
        lastNotice = UI:Notify({Title = "Evento", Content = kind, Type = kind, Duration = 6})
    end})
end
tab:Button({Title = "Cerrar último aviso", Callback = function()
    if lastNotice then lastNotice.Close() end
end})
