local storage = game:GetService("ReplicatedStorage")
local UI = require(storage:WaitForChild("RyouUI"))

local assetId = script:GetAttribute("IconAssetId")
if type(assetId) == "number" and assetId >= 1 and assetId % 1 == 0 then
    UI:RegisterIcon("proyecto", assetId)
end

local window = UI:CreateWindow({Title = "Iconos"})
local available = UI:GetIconAsset("proyecto")
local tab = window:Tab({Title = "Proyecto", Icon = available and "proyecto" or "grid"})
tab:Paragraph({Title = "Incluido", Icon = "layers", Desc = "Icono dibujado con Frames."})
if available then
    tab:Paragraph({Title = "Registrado", Icon = "proyecto", IconSize = 22})
end
