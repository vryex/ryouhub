local storage = game:GetService("ReplicatedStorage")
local UI = require(storage:WaitForChild("RyouUI"))

local window = UI:CreateWindow({Title = "Responsive", Size = UDim2.fromOffset(700, 460)})
local home = window:Tab({Title = "Inicio", Icon = "home"})
home:Button({
    Title = "Cambiar a 390 × 320",
    Callback = function() window:SetSize(UDim2.fromOffset(390, 320)):SetToTheCenter() end,
})
home:Button({
    Title = "Cambiar a 700 × 460",
    Callback = function() window:SetSize(UDim2.fromOffset(700, 460)):SetToTheCenter() end,
})
for index, name in ipairs({"layers","user","grid","palette","bell","info","sliders","check","warning","search","home","grid","layers"}) do
    local tab = window:Tab({Title = "Panel " .. index, Icon = name})
    tab:Paragraph({Title = "Área de prueba", Desc = "El desplazamiento de la navegación es independiente."})
end
