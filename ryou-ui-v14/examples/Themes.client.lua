local UI = require(script.Parent:WaitForChild("RyouUI"))
local window = UI:CreateWindow({ Theme = "Light", Radius = 6, Spacing = 11 })
local tab = window:Tab({ Title = "Temas", Icon = "palette" })
tab:Dropdown({ Title = "Paleta", Values = { "Dark", "Light", "Lavanda" }, Default = "Light",
    Callback = function(value)
        window:SetTheme(value == "Lavanda"
            and { Name = "Dark", Accent = Color3.fromRGB(206, 176, 253) }
            or value)
    end })
