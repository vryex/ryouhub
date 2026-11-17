local UI = require(script.Parent:WaitForChild("RyouUI"))
local window = UI:CreateWindow({ Title = "Catálogo de iconos" })
local tab = window:Tab({ Title = "Iconos", Icon = "grid" })
local customAsset = script:GetAttribute("CustomIcon")
if typeof(customAsset) == "string" then
    UI:RegisterIcon("proyecto", customAsset)
end
for _, name in ipairs(UI:GetIcons()) do
    tab:Paragraph({ Title = name, Icon = name, IconSize = 20 })
end
