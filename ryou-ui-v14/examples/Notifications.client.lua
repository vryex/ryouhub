local UI = require(script.Parent:WaitForChild("RyouUI"))
local window = UI:CreateWindow({ Title = "Notificaciones" })
local tab = window:Tab({ Title = "Mensajes", Icon = "info" })
for _, kind in ipairs({ "info", "success", "warning", "error" }) do
    tab:Button({ Title = kind, Icon = kind, Callback = function()
        window:Notify({ Type = kind, Title = "Mensaje de prueba", Desc = "Tipo: " .. kind, Duration = 4 })
    end })
end
