local storage = game:GetService("ReplicatedStorage")
local UI = require(storage:WaitForChild("RyouUI"))

local preferences = {Compact = false, Zoom = 100}
local window = UI:CreateWindow({Title = "Herramientas del proyecto"})
local tab = window:Tab({Title = "Configuración", Icon = "settings"})
local compact = tab:Toggle({Title = "Vista compacta", Value = preferences.Compact, Callback = function(value)
    preferences.Compact = value
end})
local zoom = tab:Slider({Title = "Zoom", Min = 50, Max = 150, Default = preferences.Zoom, Callback = function(value)
    preferences.Zoom = value
end})
tab:Button({Title = "Restaurar valores", Callback = function()
    preferences.Compact, preferences.Zoom = false, 100
    compact:Set(preferences.Compact, true)
    zoom:Set(preferences.Zoom, true)
end})
window:OnDestroy(function()
    print("Preferencias de la sesión", preferences.Compact, preferences.Zoom)
end)
script.Destroying:Connect(function() window:Destroy() end)
