local UI = require(script.Parent:WaitForChild("RyouUI"))
local window = UI:CreateWindow({ Size = Vector2.new(340, 220) })
local tab = window:Tab({ Title = "Pantalla", Icon = "monitor" })
tab:Button({ Title = "Tamaño amplio", Callback = function() window:SetSize(Vector2.new(720, 440)) end })
tab:Button({ Title = "Tamaño compacto", Callback = function() window:SetSize(UDim2.fromOffset(340, 220)) end })
for index = 1, 14 do
    local item = window:Tab({ Title = "Sección " .. index, Icon = "layers" })
    item:Input({ Title = "Texto de sección " .. index })
end
