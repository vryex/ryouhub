local storage = game:GetService("ReplicatedStorage")
local UI = require(storage:WaitForChild("RyouUI"))

local window = UI:CreateWindow({
    Title = "Ryou UI",
    Subtitle = "Editor de interfaz",
    Author = "por Ryou",
    Size = UDim2.fromOffset(760, 480),
})
local workspaceGroup = window:Section("Espacio de trabajo")
local home = workspaceGroup:Tab({
    Title = "Inicio",
    Icon = "home",
    Desc = "Ajustes del espacio de trabajo.",
})
local prefs = workspaceGroup:Tab({Title = "Preferencias", Icon = "sliders"})
local events = window:Section("Actividad"):Tab({Title = "Avisos", Icon = "bell"})

home:Section("Lienzo")
local preview = home:Paragraph({Title = "Vista previa", Desc = "Lienzo · 75% · Cuadrícula visible", Icon = "layers", Gothic = true})
local state = {Name = "Lienzo", Zoom = 75, Grid = true, Color = Color3.fromRGB(150,234,201)}
local function update()
    preview:SetDesc(string.format("%s · %d%% · #%s", state.Name, state.Zoom, state.Color:ToHex():upper()))
    preview:SetVisible(state.Grid)
end

home:Input({Title = "Nombre", Default = state.Name, Placeholder = "Nombre del lienzo", Callback = function(value)
    state.Name = value ~= "" and value or "Lienzo"
    update()
end})
home:Toggle({Title = "Mostrar vista previa", Value = state.Grid, Callback = function(value)
    state.Grid = value
    update()
end})
home:Slider({Title = "Zoom", Min = 25, Max = 150, Step = 5, Default = state.Zoom, Callback = function(value)
    state.Zoom = value
    update()
end})
home:Colorpicker({Title = "Color del lienzo", Default = state.Color, Callback = function(value)
    state.Color = value
    update()
end})
home:Button({Title = "Abrir preferencias", Icon = "settings", Callback = function() prefs:Select() end})

prefs:Section("Interfaz")
prefs:Dropdown({
    Title = "Tema", Values = {"Oscuro", "Claro"}, Default = "Oscuro", Searchable = false,
    Callback = function(value) window:SetTheme(value, true) end,
})
prefs:Dropdown({
    Title = "Movimiento", Values = {"full", "reduced", "off"}, Default = "full", Searchable = false,
    Callback = function(value) window:SetMotion(value) end,
})
local shortcuts = prefs:Paragraph({Title = "Atajos activos", Desc = "Navegación"})
prefs:Dropdown({
    Title = "Atajos", Values = {"Navegación", "Edición", "Guías", "Vista previa"}, Multi = true,
    Default = {"Navegación"},
    Callback = function(values) shortcuts:SetDesc(#values > 0 and table.concat(values, ", ") or "Ninguno") end,
})

for _, item in ipairs({
    {Title = "Información", Type = "info"}, {Title = "Correcto", Type = "success"},
    {Title = "Advertencia", Type = "warning"}, {Title = "Error", Type = "error"},
}) do
    events:Button({Title = item.Title, Callback = function()
        window:Notify({Title = item.Title, Type = item.Type, Content = "Ejemplo de aviso del espacio de trabajo."})
    end})
end
