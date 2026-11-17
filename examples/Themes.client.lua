local storage = game:GetService("ReplicatedStorage")
local UI = require(storage:WaitForChild("RyouUI"))

local window = UI:CreateWindow({
    Title = "Temas",
    Theme = "Ryou",
    Accent = Color3.fromRGB(101,158,139),
    Radius = 10,
    Spacing = 14,
    BackgroundImage = script:GetAttribute("BackgroundAssetId"),
})
local tab = window:Tab({Title = "Paleta", Icon = "palette"})
tab:Dropdown({
    Title = "Tema", Values = {"Ryou", "Blanco"}, Default = "Ryou", Searchable = false,
    Callback = function(theme) window:SetTheme(theme) end,
})
