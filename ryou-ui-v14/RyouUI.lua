-- Ryou UI 14.1.0 | Neo Sidebar V7 | Created by Ryou
--[[
MIT License

Copyright (c) 2026 Ryou

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]
local Players = game:GetService("Players")
local Input = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")

local UI = { Version = "14.1.0", Variant = "Neo Sidebar V7" }
local Window, Tab, Control = {}, {}, {}
Window.__index, Tab.__index, Control.__index = Window, Tab, Control

local rgb = Color3.fromRGB
local px = UDim2.fromOffset
local full = UDim2.fromScale(1, 1)
local centerAnchor = UDim2.fromScale(.5, .5)
local LEFT = Enum.TextXAlignment.Left
local VERTICAL = Enum.AutomaticSize.Y
local MOUSE, TOUCH = Enum.UserInputType.MouseButton1, Enum.UserInputType.Touch
local DARK = {
    Base = rgb(9, 15, 18), Rail = rgb(15, 22, 25), Field = rgb(23, 33, 37),
    Hover = rgb(29, 46, 47), Edge = rgb(45, 69, 68), Text = rgb(243, 249, 248),
    Muted = rgb(168, 183, 185), Disabled = rgb(116,136,132), Accent = rgb(73, 245, 184), Ink = rgb(4, 23, 17),
    Selected = rgb(16, 47, 41), Raised = rgb(26, 41, 42),
    Primary = rgb(73,245,184), PrimaryHover = rgb(124,255,207), HeroAccent = rgb(111,231,183), LightMint = rgb(181, 255, 225), Rim = rgb(80, 113, 107), SelectedText = rgb(198,255,230),
}
local LIGHT = {
    Base=rgb(231,239,237), Rail=rgb(220,232,228), Field=rgb(225,237,233),
    Hover=rgb(203,222,216), Edge=rgb(132,155,147), Text=rgb(20,41,34),
    Muted=rgb(63,87,78), Disabled=rgb(84,107,99), Accent=rgb(2,106,77), Ink=rgb(12,45,34),
    Selected=rgb(191,226,213), Raised=rgb(249,252,250),
    Primary=rgb(117,222,179), PrimaryHover=rgb(94,211,165), HeroAccent=rgb(3,108,77),
    LightMint=rgb(61,144,116), Rim=rgb(95,126,114), SelectedText=rgb(0,78,56),
}
-- Presets originales de Ryou. Los modos antiguos Dark/Light siguen disponibles.
local THEME_PRESETS = {
    ["Menta Ryou"] = { Base = "Dark", Accent = rgb(73,245,184) },
    ["Medianoche"] = { Base = "Dark", Accent = rgb(71,167,255) },
    ["Violeta"] = { Base = "Dark", Accent = rgb(175,118,255) },
    ["Carmesí"] = { Base = "Dark", Accent = rgb(252,92,124) },
    ["Azul hielo"] = { Base = "Dark", Accent = rgb(80,220,255) },
    ["Rosa"] = { Base = "Dark", Accent = rgb(255,134,189) },
    ["Ámbar"] = { Base = "Dark", Accent = rgb(255,191,94) },
    ["Perla"] = { Base = "Light", Accent = rgb(2,106,77) },
}
local THEME_ORDER = {"Menta Ryou","Medianoche","Violeta","Carmesí","Azul hielo","Rosa","Ámbar","Perla"}
local FONT_STYLES = {
    Gotham = { Enum.Font.Gotham, Enum.Font.GothamBold },
    SourceSans = { Enum.Font.SourceSans, Enum.Font.SourceSansBold },
    Arial = { Enum.Font.Arial, Enum.Font.ArialBold },
}
local MOTION = { Full = 1, Reduced = .34, Off = 0 }
local KEYBOARD = Enum.KeyCode.RightShift
local MIN_WIDTH, MIN_HEIGHT = 300, 196

local function make(class, parent, props)
    local item = Instance.new(class)
    if item:IsA("GuiObject") then
        item.BorderSizePixel = 0
        item.BackgroundTransparency = 1
    end
    for prop, value in pairs(props or {}) do
        item[prop] = value
    end
    item.Parent = parent
    return item
end

local function scope()
    return { connections = {}, children = {} }
end

local function listen(owner, signal, fn)
    local connection = signal:Connect(fn)
    table.insert(owner.connections, connection)
    return connection
end

local function childScope(owner)
    local child = scope()
    child.parent = owner
    owner.children[child] = true
    return child
end

local function clean(owner)
    for child in pairs(owner.children) do
        clean(child)
    end
    for _, connection in ipairs(owner.connections) do
        connection:Disconnect()
    end
    table.clear(owner.connections)
    if owner.parent then
        owner.parent.children[owner] = nil
    end
end

local function callback(fn, ...)
    if type(fn) == "function" then
        local ok, err = pcall(fn, ...)
        if not ok then warn("[Ryou UI] " .. tostring(err)) end
    end
end

local function copyText(value, fallback)
    if value == nil then return fallback or "" end
    return tostring(value)
end

local function label(w, parent, str, size, bold, role, props)
    local settings = {
        Text = str, TextSize = size, TextScaled = false, TextXAlignment = LEFT,
        Font = bold and w.boldFont or w.font, Size = UDim2.new(1, 0, 0, 20),
    }
    for key, value in pairs(props or {}) do settings[key] = value end
    local item = make("TextLabel", parent, settings)
    w:_bind(item, "TextColor3", role or "Text")
    w.fontNodes[item] = bold == true
    return item
end

local function corner(parent, radius)
    make("UICorner", parent, { CornerRadius = UDim.new(0, radius) })
end

local function edge(w, parent)
    local line = make("UIStroke", parent, { ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Thickness = 1 })
    w:_bind(line, "Color", "Edge")
    return line
end

local function pad(parent, horizontal, vertical)
    make("UIPadding", parent, {
        PaddingLeft = UDim.new(0, horizontal), PaddingRight = UDim.new(0, horizontal),
        PaddingTop = UDim.new(0, vertical), PaddingBottom = UDim.new(0, vertical),
    })
end

local function stack(parent, gap)
    return make("UIListLayout", parent, {
        SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, gap),
    })
end

local function surface(w, parent, role, props, radius)
    local frame = make("Frame", parent, props)
    frame.BackgroundTransparency = 0
    w:_bind(frame, "BackgroundColor3", role)
    if role == "Base" or role == "Rail" or role == "Field" or role == "Raised" then
        w.surfaceNodes[frame] = true
        frame.BackgroundTransparency = w.surfaceTransparency or 0
    end
    if radius then corner(frame, radius) end
    return frame
end

local function scroll(w, parent, props)
    local frame = make("ScrollingFrame", parent, props)
    frame.CanvasSize = px(0, 0)
    frame.AutomaticCanvasSize = VERTICAL
    frame.ScrollingDirection = Enum.ScrollingDirection.Y
    frame.ScrollBarThickness = 3
    frame.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
    frame.Active = true
    w:_bind(frame, "ScrollBarImageColor3", "Edge")
    return frame
end

-- Coordinates are on a 24 × 24 grid. Width is measured perpendicular to each segment.
local icons = {
    magnifier = {{4,9,6,5},{6,5,12,4},{12,4,16,8},{16,8,15,13},{15,13,11,16},{11,16,6,14},{6,14,4,9},{15,14,21,20}},
    minimize = {{5,12,19,12}},
    cloud = {{5,18,19,18},{5,18,3,15},{3,15,4,11},{4,11,8,11},{8,11,10,6},{10,6,15,6},{15,6,18,11},{18,11,21,12},{21,12,21,16},{21,16,19,18}},
    bell = {{4,17,20,17},{6,17,8,13},{8,13,8,7},{8,7,12,4},{12,4,16,7},{16,7,16,13},{16,13,18,17},{10,20,14,20}},
    activity = {{3,12,7,12},{7,12,10,5},{10,5,13,19},{13,19,16,11},{16,11,21,11}},
    home = {{3,11,12,3},{12,3,21,11},{6,10,6,21},{6,21,18,21},{18,21,18,10}},
    sliders = {{4,5,20,5},{4,12,20,12},{4,19,20,19},{8,2,8,8,4},{16,9,16,15,4},{11,16,11,22,4}},
    grid = {{4,7,20,7},{4,17,20,17},{7,4,7,20},{17,4,17,20}},
    palette = {{12,3,20,8},{20,8,20,15},{20,15,12,21},{12,21,4,17},{4,17,4,8},{4,8,12,3},{9,10,9,11,3},{14,8,14,9,3},{15,14,15,15,3}},
    info = {{12,10,12,20,2.5},{12,4,12,5,3}},
    success = {{4,12,9,17,2.5},{9,17,20,6,2.5}},
    warning = {{12,3,21,20},{21,20,3,20},{3,20,12,3},{12,9,12,13},{12,16,12,17}},
    error = {{5,5,19,19,2.5},{19,5,5,19,2.5}},
    chevron = {{5,9,12,16},{12,16,19,9}},
    arrow = {{4,12,20,12},{14,6,20,12},{20,12,14,18}},
    grip = {{9,21,21,9},{15,21,21,15}},
    user = {{8,4,16,4},{16,4,16,11},{16,11,8,11},{8,11,8,4},{5,21,5,16},{5,16,19,16},{19,16,19,21}},
    image = {{3,4,21,4},{21,4,21,20},{21,20,3,20},{3,20,3,4},{4,17,10,11},{10,11,15,16},{15,16,20,12}},
    layers = {{3,9,12,4},{12,4,21,9},{21,9,12,14},{12,14,3,9},{3,15,12,20},{12,20,21,15}},
}

local iconAliases = {
    ["badge-info"] = "info", ["circle-dot"] = "home", ["clock-3"] = "info", copy = "layers",
    crosshair = "sliders", eye = "image", ["folder-open"] = "layers", footprints = "user",
    keyboard = "grid", ["layout-grid"] = "grid", monitor = "image", ["moon-star"] = "home",
    ["mouse-pointer-2"] = "arrow", ["person-standing"] = "user", ["rotate-ccw"] = "arrow",
    save = "layers", scan = "grid", search = "sliders", settings = "sliders", shirt = "user",
    skull = "warning", ["sliders-horizontal"] = "sliders", ["volume-2"] = "info", zap = "warning",
}

function UI:RegisterIcon(name, asset)
    assert(type(name) == "string" and name ~= "", "Expected an icon name")
    assert(name ~= "ryou" and not icons[name] and not iconAliases[name], "This built-in icon name is reserved")
    assert(type(asset) == "string" and asset:match("^rbxassetid://%d+$"), "Expected an rbxassetid:// URL")
    self._assets = self._assets or {}
    self._assets[name] = asset
    return self
end

function UI:GetIcons()
    local names = {"ryou"}
    for name in pairs(icons) do table.insert(names, name) end
    for name in pairs(iconAliases) do table.insert(names, name) end
    for name in pairs(self._assets or {}) do table.insert(names, name) end
    table.sort(names)
    return names
end

-- The artwork revision is separate from the library revision so each URL is immutable.
local ASSET_REVISION = "be94fa3ecf37965ceae1e7e51f1449d178e6c642"
local ASSET_URL = "https://raw.githubusercontent.com/vryex/ryouhub/" .. ASSET_REVISION .. "/ryou-ui-v14/assets/neo/"
local CACHE_VERSION = ASSET_REVISION:sub(1, 12)
local CACHE_DIR = "RyouUI/Cache/" .. CACHE_VERSION
local PNG_SIGNATURE = "\137PNG\r\n\26\n"
local AssetRegistry = {
    logo_small = { file = "R_FACETADA_VECTOR_512.png", bytes = 34353 },
    logo_hero = { file = "R_GENERADA_CON_BRILLO_RGBA_1254.png", bytes = 677407 },
    launcher = { file = "LAUNCHER_GENERADO_RGBA_1254.png", bytes = 1379512 },
    launcher_fallback = { file = "LAUNCHER_CIRCULAR_VECTOR_512.png", bytes = 91469 },
    header_ribbon = { file = "HEADER_DIAGONAL_RGBA.png", bytes = 63746 },
    hero_orbits = { file = "HERO_ORBITAS_RGBA.png", bytes = 160011 },
    rail_glow = { file = "RAIL_INFERIOR_RGBA.png", bytes = 43775 },
    background_artwork = { file = "FONDO_NEON_ARTWORK_1672x941.png", bytes = 1477520 },
    logo_mono = { file = "R_FACETADA_MONO_512.png", bytes = 17839 },
}

local ImageAssets = { ready = {}, pending = {}, warned = {} }

local function hostFunction(...)
    for index = 1, select("#", ...) do
        local fn = select(index, ...)
        if type(fn) == "function" then return fn end
    end
end

local registerImage = hostFunction(getcustomasset, getsynasset, syn and syn.getcustomasset)
local sendRequest = hostFunction(request, http_request, syn and syn.request)

local function assetWarning(key, message)
    if ImageAssets.warned[key] then return end
    ImageAssets.warned[key] = true
    warn("[Ryou UI] " .. message)
end

local function validPng(data, asset)
    return type(data) == "string" and #data == asset.bytes
        and data:sub(1, 8) == PNG_SIGNATURE and data:sub(13, 16) == "IHDR"
        and data:sub(-8, -5) == "IEND"
end

local function downloadPng(asset)
    local url = ASSET_URL .. asset.file
    local ok, data = pcall(function() return game:HttpGet(url) end)
    if ok and validPng(data, asset) then return data end
    if sendRequest then
        local sent, result = pcall(sendRequest, { Url = url, Method = "GET" })
        if sent and type(result) == "table" and result.StatusCode == 200 and validPng(result.Body, asset) then
            return result.Body
        end
    end
end

local function localImage(path)
    local ok, contentId = pcall(registerImage, path)
    if ok and type(contentId) == "string" and contentId ~= "" then return contentId end
end

local function cacheContains(path, asset)
    if type(isfile) == "function" then
        local ok, exists = pcall(isfile, path)
        if ok and not exists then return false end
        if ok and type(readfile) ~= "function" then return exists end
    end
    if type(readfile) == "function" then
        local ok, data = pcall(readfile, path)
        return ok and validPng(data, asset)
    end
    return false
end

local function prepareCache()
    if ImageAssets.cachePrefix then return ImageAssets.cachePrefix end
    local prefix = "RyouUI-" .. CACHE_VERSION .. "-"
    if type(makefolder) == "function" then
        local available = true
        for _, folder in ipairs({ "RyouUI", "RyouUI/Cache", CACHE_DIR }) do
            local known, exists = false, false
            if type(isfolder) == "function" then known, exists = pcall(isfolder, folder) end
            if not (known and exists) then
                local ok = pcall(makefolder, folder)
                if known and not ok then available = false; break end
            end
        end
        if available then prefix = CACHE_DIR .. "/" end
    end
    ImageAssets.cachePrefix = prefix
    return prefix
end

local function resolveImage(asset)
    local prefix = prepareCache()
    local path = prefix .. asset.file
    local flat = "RyouUI-" .. CACHE_VERSION .. "-" .. asset.file
    for _, candidate in ipairs(path == flat and {path} or {path, flat}) do
        if cacheContains(candidate, asset) then
            local id = localImage(candidate)
            if id then return id end
        end
    end

    local data = downloadPng(asset)
    if not data then
        task.wait(.65)
        data = downloadPng(asset)
    end
    if not data then return nil, "GitHub no devolvió el PNG esperado" end

    local saved = pcall(writefile, path, data)
    if not saved and path ~= flat then
        path = flat
        saved = pcall(writefile, path, data)
    end
    if not saved then return nil, "no se pudo guardar el PNG en la caché" end
    local id = localImage(path)
    if not id then return nil, "el cliente no pudo registrar el PNG local" end
    return id
end

function ImageAssets:Get(name, done)
    if not registerImage or type(writefile) ~= "function" then
        assetWarning("host", "Arte Neo Sidebar no disponible. El cliente requiere writefile y getcustomasset/getsynasset. Se usa la interfaz de respaldo.")
        return
    end
    if self.ready[name] then
        if done then done(self.ready[name]) end
        return
    end
    local queued = self.pending[name]
    if queued then
        if done then table.insert(queued, done) end
        return
    end
    queued = done and {done} or {}
    self.pending[name] = queued
    task.defer(function()
        local id, reason = resolveImage(AssetRegistry[name])
        self.ready[name] = id
        self.pending[name] = nil
        if reason then assetWarning(name, AssetRegistry[name].file .. " · " .. reason) end
        for _, notify in ipairs(queued) do notify(id) end
    end)
end

function ImageAssets:Preload(...)
    for index = 1, select("#", ...) do
        self:Get((select(index, ...)))
    end
end

local function assetImage(parent, name, props, fallback, alternate, alternateLayout)
    local image = make("ImageLabel", parent, props)
    image.Active = false
    if fallback then image.Visible = false end

    local function apply(id)
        if not image.Parent or not id then return end
        if fallback then fallback.Visible = false end
        image.Image = id
        if fallback then image.Visible = true end
    end
    ImageAssets:Get(name, function(id)
        if not image.Parent then return end
        if id then
            apply(id)
        elseif alternate then
            ImageAssets:Get(alternate, function(replacement)
                if not image.Parent or not replacement then return end
                if alternateLayout then image.Size = alternateLayout end
                apply(replacement)
            end)
        end
    end)
    return image
end

local function gradient(parent, top, bottom, rotation)
    return make("UIGradient", parent, { Color = ColorSequence.new(top, bottom), Rotation = rotation or 90 })
end

-- The neutral stops preserve custom themes while shaping separate highlights and shadows.
local finishes = {
    Shell = {255,234,183,.77,.96,.54},
    Header = {255,224,175,.78,.98,.72},
    Rail = {209,229,224,.8,.97,.8},
    Card = {255,224,178,.45,.84,.57},
    Raised = {255,214,164,.30,.83,.53},
    Field = {241,229,207,.57,.86,.73},
    Secondary = {255,221,171,.40,.83,.62},
    Primary = {255,232,183,.14,.68,.49},
    Selected = {230,211,163,.36,.68,.54},
}

local function faceColors(stops, light)
    local points = {}
    for index, position in ipairs({0,.49,1}) do
        local tone = stops[index]
        if light then tone = math.round(255-(255-tone)*.20) end
        points[index] = ColorSequenceKeypoint.new(position,rgb(tone,tone,tone))
    end
    return ColorSequence.new(points)
end

local function faceGradient(w,node,name)
    local stops = finishes[name]
    local item = make("UIGradient",node,{Rotation=90,Color=faceColors(stops,w.ThemeName=="Light")})
    w:_track(item)
    w.faces[item] = stops
end

local function finish(w, node, name)
    local _, _, _, shine, dark, foot = table.unpack(finishes[name])
    faceGradient(w,node,name)
    local line = edge(w,node)
    w:_bind(line,"Color",name == "Primary" and "LightMint" or name == "Selected" and "Accent" or "Rim")
    make("UIGradient",line,{
        Rotation=120, Transparency=NumberSequence.new({
            NumberSequenceKeypoint.new(0,shine),
            NumberSequenceKeypoint.new(.56,dark),
            NumberSequenceKeypoint.new(1,foot),
        }),
    })
    return line
end

local function selectionLight(w, parent)
    local light = surface(w,parent,"Accent",{
        Name="SelectionLight",Size=full,BackgroundTransparency=.79,Visible=false,
    },6)
    make("UIGradient",light,{
        Rotation=12, Transparency=NumberSequence.new({
            NumberSequenceKeypoint.new(0,1),
            NumberSequenceKeypoint.new(.53,.83),
            NumberSequenceKeypoint.new(.84,.16),
            NumberSequenceKeypoint.new(1,.47),
        }),
    })
    w:_effect(light,"BackgroundTransparency",.79,.94,1)
    return light
end

local function depth(parent, radius, layers)
    local shade = make("Frame",parent,{Name="Depth",Size=full})
    for i=1,layers do
        local spread = (layers-i)*2
        local layer = make("Frame",shade,{
            Position=px(-spread,1-spread), Size=UDim2.new(1,spread*2,1,spread*2),
            BackgroundColor3=rgb(0,0,0), BackgroundTransparency=.94-i*.036,
        })
        corner(layer,radius+spread)
    end
    return shade
end

local function mark(w, parent, size, position, large, exact)
    local node = make("Frame", parent, { Name = "RyouMark", Size = px(size, size), Position = position })
    local fallback = label(w, node, "R", math.floor(size*.61), true, "Accent", {
        Name = "LogoFallback", Size = full, TextXAlignment = Enum.TextXAlignment.Center,
    })
    assetImage(node, large and "logo_hero" or "logo_small", {
        Name = "Logo", AnchorPoint = Vector2.new(.5,.5), Position = UDim2.fromScale(.51,.46),
        Size = large and full or UDim2.fromScale(1.15,1.15), ScaleType = Enum.ScaleType.Fit,
    }, fallback, not exact and (large and "logo_small" or "logo_mono") or nil)
    return node
end

local function artworkLayer(w,parent,asset,position,size,mode,alpha,lightAlpha)
    local art = assetImage(parent,asset,{Name=asset,Position=position,Size=size,ScaleType=mode})
    w:_track(art)
    w.art[art] = { dark=alpha or 0, light=lightAlpha }
    w:_paintArt(art)
    return art
end

local function icon(w, parent, name, size, role, position)
    if name == "ryou" then return mark(w, parent, size, position or UDim2.new(), false) end
    local slot = make("Frame", parent, { Size = px(size, size), Position = position or UDim2.new() })
    local asset = (w.library._assets or {})[name] or name
    if type(asset) == "string" and asset:match("^rbxassetid://%d+$") then
        local image = make("ImageLabel", slot, { Image = asset, Size = full })
        w:_bind(image, "ImageColor3", role)
        return slot
    end
    for _, line in ipairs(icons[iconAliases[name] or name] or icons.grid) do
        local x1, y1, x2, y2, thick = table.unpack(line)
        local dx, dy = x2 - x1, y2 - y1
        local segment = surface(w, slot, role, {
            AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale((x1+x2)/48, (y1+y2)/48),
            Rotation = math.deg(math.atan2(dy, dx)),
            Size = UDim2.new(math.sqrt(dx*dx + dy*dy)/24, 0, 0, math.max(1, (thick or 1.7)*size/24)),
        })
        segment.Name = "Segment"
    end
    return slot
end

local function action(w, owner, parent, text, props, primary, style)
    local b = make("TextButton", parent, props)
    b.Text, b.TextSize, b.Font = text or "", 14, w.boldFont
    w.fontNodes[b] = true
    b.AutoButtonColor = false
    b.BackgroundTransparency = 0
    corner(b, w.radius)
    w:_bind(b, "TextColor3", primary and "Ink" or "Text")
    w:_bind(b, "BackgroundColor3", primary and "Primary" or "Field")
    local visual = b
    if style == "window" then
        b.BackgroundTransparency = 1
        visual = surface(w,b,"Field",{
            Name="Plate",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),
            Size=px(28,26),
        },6)
    end
    if style ~= "bare" then
        finish(w,visual,primary and "Primary" or "Secondary")
    end
    if primary then
        local glint = make("Frame",b,{
            Name="Glint",Position=px(2,1),Size=UDim2.new(1,-4,.34,0),
            BackgroundColor3=rgb(238,255,249),BackgroundTransparency=.72,
        })
        corner(glint,w.radius-1)
        make("UIGradient",glint,{Rotation=90,Transparency=NumberSequence.new(.35,1)})
        w:_effect(glint,"BackgroundTransparency",.72,.90,1)
    end
    local scale = make("UIScale", b, {})
    local function rest()
        w:_animate(scale, .14, { Scale = 1 })
    end
    listen(owner, b.MouseEnter, function()
        if b.Active then w:_animate(visual, .12, { BackgroundColor3 = w.theme[primary and "PrimaryHover" or "Hover"] }) end
    end)
    listen(owner, b.MouseLeave, function()
        w:_animate(visual, .13, { BackgroundColor3 = w.theme[w.bindings[visual].BackgroundColor3] })
        rest()
    end)
    listen(owner, b.InputBegan, function(input)
        if b.Active and (input.UserInputType == MOUSE or input.UserInputType == TOUCH) then
            w:_animate(scale, .09, { Scale = .975 })
            if style ~= "bare" then
                w:_animate(visual,.09,{BackgroundColor3=w.theme[primary and "PrimaryHover" or "Hover"]})
            end
        end
    end)
    listen(owner, b.InputEnded, function()
        rest()
        w:_animate(visual,.14,{BackgroundColor3=w.theme[w.bindings[visual].BackgroundColor3]})
    end)
    return b
end

local function windowAction(w, owner, parent, glyph, right, pressed)
    local b = action(w,owner,parent,"",{
        Name=glyph == "minimize" and "Minimize" or "Close",
        AnchorPoint=Vector2.new(1,.5), Position=UDim2.new(1,-right,.5,0), Size=px(34,38), ZIndex=4,
    },false,"window")
    icon(w,b,glyph,13,"Text",UDim2.new(.5,-6.5,.5,-6.5))
    listen(owner,b.Activated,pressed)
    return b
end

local function textBox(w, owner, parent, placeholder, props)
    local box = make("TextBox", parent, props)
    box.BackgroundTransparency, box.Text = 0, ""
    box.PlaceholderText, box.ClearTextOnFocus = placeholder, false
    box.TextSize, box.Font, box.TextXAlignment = 14, w.font, LEFT
    w.fontNodes[box] = false
    box.TextTruncate = Enum.TextTruncate.AtEnd
    pad(box, 9, 0)
    corner(box, w.radius)
    w:_bind(box, "BackgroundColor3", "Field")
    w:_bind(box, "TextColor3", "Text")
    w:_bind(box, "PlaceholderColor3", "Muted")
    local line = finish(w,box,"Field")
    listen(owner, box.Focused, function()
        w:_animate(line, .15, { Color = w.theme.Accent })
    end)
    listen(owner, box.FocusLost, function()
        w:_animate(line, .15, { Color = w.theme.Edge })
    end)
    return box
end

function Window:_track(item)
    if self.tracked[item] then return end
    self.tracked[item] = true
    -- A parented Instance can outlive its Luau reference. Retain each binding until Destroying.
    item.Destroying:Connect(function()
        self.tracked[item],self.bindings[item],self.faces[item] = nil,nil,nil
        self.art[item],self.effects[item],self.heroTitles[item] = nil,nil,nil
        self.fontNodes[item],self.surfaceNodes[item] = nil,nil
        self:_cancel(item)
    end)
end

function Window:_paintArt(item)
    local art = self.art[item]
    local alpha = art.dark
    if self.ThemeName == "Light" then alpha = art.light end
    item.Visible = self.neon and self.decorationIntensity>0 and alpha~=nil
    if alpha then item.ImageTransparency = 1-(1-alpha)*self.decorationIntensity end
end

function Window:_paintEffect(item)
    local effect = self.effects[item]
    local on = self.ThemeName=="Light" and effect.light or effect.dark
    local weight = self.neon and self.decorationIntensity or 0
    item[effect.property] = effect.off+(on-effect.off)*weight
end

function Window:_effect(item,property,dark,light,off)
    self:_track(item)
    self.effects[item] = {property=property,dark=dark,light=light,off=off}
    self:_paintEffect(item)
end

function Window:_launcherTint()
    local value = self.neon and math.round(196+59*self.decorationIntensity) or 196
    return rgb(value,value,value)
end

function Window:_refreshEffects()
    for item in pairs(self.art) do self:_paintArt(item) end
    for item in pairs(self.effects) do self:_paintEffect(item) end
    if not self.neon or self.decorationIntensity==0 then
        self:_cancel(self.sweep)
        self.sweep.Visible = false
    end
    self:_cancel(self.launcherImage)
    self.launcherImage.ImageColor3 = self:_launcherTint()
end

function Window:SetNeon(enabled)
    self.neon = enabled == true
    self:_refreshEffects()
    return self
end

function Window:GetNeon() return self.neon end

function Window:_bind(item, property, role)
    self:_track(item)
    self.bindings[item] = self.bindings[item] or {}
    self.bindings[item][property] = role
    item[property] = self.theme[role]
end

function Window:_cancel(item)
    local animation = self.tweens[item]
    if animation then
        self.tweens[item] = nil
        animation.tween:Cancel()
        animation.tween:Destroy()
    end
end

function Window:_animate(item, seconds, goal, delay, done)
    local same = true
    if not self.tweens[item] then
        for property, value in pairs(goal) do
            if item[property] ~= value then same = false; break end
        end
        if same and (delay or 0) == 0 then
            if done then done() end
            return
        end
    end
    self:_cancel(item)
    local scale = MOTION[self.motion] / (self.animationSpeed or 1)
    if scale == 0 then
        for property, value in pairs(goal) do item[property] = value end
        if done then done() end
        return
    end
    local tween = TweenService:Create(item,
        TweenInfo.new(seconds * scale, Enum.EasingStyle.Quint, Enum.EasingDirection.Out, 0, false, (delay or 0) * scale), goal)
    local animation = { tween = tween, goal = goal, done = done }
    self.tweens[item] = animation
    tween.Completed:Once(function(state)
        if self.tweens[item] ~= animation then return end
        self.tweens[item] = nil
        tween:Destroy()
        if state == Enum.PlaybackState.Completed and done then done() end
    end)
    tween:Play()
end

function Window:_gesture(owner, target, update, finish, start)
    listen(owner, target.InputBegan, function(event)
        if self.gesture or (event.UserInputType ~= MOUSE and event.UserInputType ~= TOUCH) then return end
        local point = Vector2.new(event.Position.X, event.Position.Y)
        local gesture = { owner = owner, event = event, origin = point, update = update, finish = finish }
        self.gesture = gesture
        if start and start(point) == false and self.gesture == gesture then self.gesture = nil end
    end)
end

function Window:_endGesture(complete)
    local gesture = self.gesture
    if not gesture then return end
    self.gesture = nil
    if gesture.restore then gesture.restore() end
    if complete and gesture.finish then gesture.finish(gesture) end
end

function Window:_moveFrame(position)
    local bounds = self.screen.AbsoluteSize
    local size = self.frame.Size
    local halfX, halfY = size.X.Offset/2, size.Y.Offset/2
    local center = Vector2.new(
        math.clamp(position.X,halfX+8,math.max(halfX+8,bounds.X-halfX-8)),
        math.clamp(position.Y,halfY+8,math.max(halfY+8,bounds.Y-halfY-8)))
    self.frame.Position = px(math.floor(center.X+.5),math.floor(center.Y+.5))
    self:_fitLauncher()
    return center
end

function Window:_fit()
    local bounds = self.screen.AbsoluteSize
    if bounds.X <= 0 or bounds.Y <= 0 then return end
    local scale = self.interfaceScale
    local maximum = Vector2.new(math.max(1,bounds.X-16)/scale,math.max(1,bounds.Y-16)/scale)
    local width = math.clamp(self.desired.X,math.min(MIN_WIDTH,maximum.X),maximum.X)
    local height = math.clamp(self.desired.Y,math.min(MIN_HEIGHT,maximum.Y),maximum.Y)
    self.frame.Size = px(math.floor(width*scale+.5),math.floor(height*scale+.5))
    self.panel.Size = px(width,height)
    self:_moveFrame(self.position or bounds/2)
    local widest, minimum = 0, 0
    for _, tab in ipairs(self.Tabs) do
        widest = math.max(widest,tab.labelWidths[14])
        minimum = math.max(minimum,tab.labelWidths[12])
    end
    local maxRail = math.min(222,math.floor(width*.25),width-394)
    local compact = maxRail < math.max(115,math.ceil(minimum+58))
    self.Compact = compact
    local railWidth = 53
    if not compact then
        railWidth = math.min(maxRail, math.max(115, math.floor(width*.185), math.ceil(widest+58)))
    end
    local headerHeight = height < 415 and 55 or 70
    self.header.Size = UDim2.new(1, 0, 0, headerHeight)
    self.headerRibbon.Size = px(headerHeight*(1536/220),headerHeight)
    self.headerRibbon.Position = UDim2.new(math.clamp(.26-width/6000,.11,.17),48,0,0)
    self.content.Position = px(0, headerHeight)
    self.content.Size = UDim2.new(1, 0, 1, -headerHeight)
    self.utilities.Visible = width >= 660
    for _, button in ipairs(self.headerTools) do button.Visible = self.utilities.Visible end
    self.titleGroup.Size = UDim2.new(1, -(width >= 660 and 347 or 176), 0, 26)
    self.subtitleGroup.Size = self.titleGroup.Size - px(0, 7)
    self.rail.Size = UDim2.new(0, railWidth, 1, 0)
    self.body.Position = px(railWidth + 1, 0)
    self.body.Size = UDim2.new(1, -railWidth-1, 1, 0)
    for _, tab in ipairs(self.Tabs) do
        local textWidth = math.max(1, railWidth-58)
        local textSize = 14
        while textSize > 12 and tab.labelWidths[textSize] > textWidth do textSize -= 1 end
        local rowHeight = height < 415 and 37 or 40
        tab.slot.Size = UDim2.new(1,0,0,rowHeight)
        tab.titleLabel.TextSize = textSize
        tab.titleLabel.Visible = not compact
        tab.glyph.Position = compact and UDim2.new(.5,-9,.5,-9) or UDim2.new(0,9,.5,-9)
    end
    for _, group in ipairs(self.groups) do
        group.ElementFrame.Visible = not compact and group.expanded
        if not compact then
            local wrapped = TextService:GetTextSize(group.Title,12,self.boldFont,Vector2.new(railWidth-35,10000))
            group.ElementFrame.Size = UDim2.new(1,0,0,math.max(19,wrapped.Y+5))
        end
    end
end

function Window:_fitLauncher()
    local bounds = self.screen.AbsoluteSize
    local anchor = self.launcherPosition or Vector2.new(bounds.X - 55, bounds.Y - 54)
    local x = math.clamp(anchor.X, 37, math.max(37, bounds.X - 37))
    local y = math.clamp(anchor.Y, 37, math.max(37, bounds.Y - 37))
    self.launcher.Position = px(x, y)
    local center = self.frame.Position
    local size = self.frame.Size
    local outside = math.abs(x-center.X.Offset) >= size.X.Offset/2+36
        or math.abs(y-center.Y.Offset) >= size.Y.Offset/2+36
    local visible = self.launcherEnabled and (not self.Opened or outside or self.draggingLauncher == true)
    local appearing = visible and not self.launcher.Visible
    self.launcher.Visible, self.launcher.Active = visible, visible
    if appearing and not self.draggingLauncher then
        self:_cancel(self.launchScale)
        self.launchScale.Scale = self.motion == "Full" and .87 or .96
        self:_animate(self.launchScale,.21,{Scale=1})
    end
end

function Window:_resetEntrance()
    for group, position in pairs(self.entrance) do
        self:_cancel(group)
        group.Position = position
        if group:IsA("CanvasGroup") then group.GroupTransparency = 0 end
    end
    self:_cancel(self.brandScale)
    self.brandScale.Scale = 1
    if self.Selected then
        self:_cancel(self.Selected.marker)
        self.Selected.marker.Size = px(3,23)
    end
    self:_cancel(self.sweep)
    self.sweep.Visible = false
end

function Window:_stage(group, time, delay, x, y)
    local endPosition = self.entrance[group]
    local goal = {Position=endPosition}
    if group:IsA("CanvasGroup") then
        group.GroupTransparency = 1
        goal.GroupTransparency = 0
    end
    group.Position = endPosition + px(x,y)
    self:_animate(group,time,goal,delay)
end

function Window:_launcherOffset(limitX,limitY)
    local a,b = self.launcher.Position,self.frame.Position
    return px(math.clamp((a.X.Offset-b.X.Offset)*.12,-limitX,limitX),
        math.clamp((a.Y.Offset-b.Y.Offset)*.12,-limitY,limitY))
end

function Window:_pulseLauncher()
    if not self.neon or self.decorationIntensity==0 or not self.launcher.Visible or self.motion=="Off" then return end
    self.launcherImage.ImageColor3 = self:_launcherTint():Lerp(rgb(223,252,237),self.decorationIntensity)
    self:_animate(self.launcherImage,.18,{ImageColor3=self:_launcherTint()})
end

function Window:_open(fromLauncher)
    if self.Destroyed or self.Opened then return self end
    local first = not self.hasOpened
    local visible = self.panel.Visible
    local start = fromLauncher and self:_launcherOffset(26,20) or px(0,9)
    if fromLauncher then self:_pulseLauncher() end
    self.Opened, self.hasOpened = true,true
    self.panel.Visible, self.panel.Interactable = true,true
    self.shadow.Visible = true
    self:_fitLauncher()
    self:_resetEntrance()
    if not visible then
        self.panel.GroupTransparency,self.panel.Position = 1,centerAnchor+start
        local shrink = self.motion=="Full" and (first and .94 or .975) or .985
        self.panelScale.Scale = self.interfaceScale*shrink
    end
    local duration = first and .27 or .21
    self:_animate(self.panel,duration,{GroupTransparency=0,Position=centerAnchor})
    self:_animate(self.panelScale,duration,{Scale=self.interfaceScale})
    if first and self.motion == "Full" then
        self:_stage(self.brand, .26, .11, -7, 0)
        self.brandScale.Scale = .95
        self:_animate(self.brandScale, .26, { Scale = 1 }, .11)
        self:_stage(self.utilities, .25, .22, 0, 4)
        self:_stage(self.titleGroup, .34, .17, 0, 6)
        self:_stage(self.subtitleGroup, .29, .26, 0, 4)
        self:_stage(self.rail, .31, .23, -9, 0)
        if self.Selected then
            self:_stage(self.pages,.39,.35,0,8)
            local marker = self.Selected.marker
            marker.Size = px(3,6)
            self:_animate(marker,.24,{Size=px(3,23)},.30)
        end
        for index, tab in ipairs(self.Tabs) do
            if index > 10 then break end
            self:_stage(tab.shell, .27, .24 + (index-1)*.023, -4, 0)
        end
        if self.neon and self.decorationIntensity>0 and self.ThemeName ~= "Light" then
            self.sweep.Visible = true
            self.sweep.BackgroundTransparency = 1-.68*self.decorationIntensity
            self.sweep.Position = UDim2.new(.33,-5,.62,0)
            self:_animate(self.sweep,.42,{Position=UDim2.new(.56,0,.65,0),BackgroundTransparency=1},.17,
                function() self.sweep.Visible = false end)
        end
    end
    for _, fn in ipairs(self.openedCallbacks) do callback(fn, self) end
    return self
end

function Window:Open() return self:_open(false) end

function Window:_hide(minimized)
    if self.Destroyed then return self end
    self.initialCancelled = true
    if not self.Opened then return self:SetOpenButtonVisible(self.launcherEnabled) end
    self.Opened = false
    self.panel.Interactable = false
    self:_closePopup()
    if self.dismissModal then self.dismissModal() end
    if self.finishDialog then self.finishDialog() end
    self:_endGesture(false)
    self:_resetEntrance()
    local focused = Input:GetFocusedTextBox()
    if focused and focused:IsDescendantOf(self.panel) then focused:ReleaseFocus(false) end
    self:_fitLauncher()
    local towardLauncher = minimized and self.launcher.Visible
    local target = towardLauncher and self:_launcherOffset(23,17) or px(0,8)
    local duration = towardLauncher and .22 or .18
    self:_animate(self.panelScale,duration,{Scale=self.interfaceScale*(towardLauncher and .95 or .985)})
    self:_animate(self.panel,duration,{GroupTransparency=1,Position=centerAnchor+target},0,function()
        if self.Opened then return end
        self.panel.Visible = false
        self.shadow.Visible = false
        if towardLauncher then self:_pulseLauncher() end
    end)
    for _, fn in ipairs(self.closedCallbacks) do callback(fn, self) end
    return self
end

function Window:Minimize() return self:_hide(true) end
function Window:Close() return self:_hide(false) end

function Window:Toggle()
    return self.Opened and self:Close() or self:Open()
end

function Window:SetMotion(mode)
    assert(MOTION[mode] ~= nil, "Motion must be Full, Reduced or Off")
    if self.motion == mode then return self end
    self.motion = mode
    -- Settle in-flight transitions before using the new timing for every control.
    for item, animation in pairs(table.clone(self.tweens)) do
        if self.tweens[item] ~= animation then continue end
        self:_cancel(item)
        for property, value in pairs(animation.goal) do item[property] = value end
        if animation.done then animation.done() end
    end
    self:_resetEntrance()
    self:_cancel(self.launcherImage)
    self.launcherImage.ImageColor3 = self:_launcherTint()
    return self
end

function Window:GetMotion() return self.motion end

function Window:_paintHeroTitle(label)
    local item = self.heroTitles[label]
    local color = self.theme.HeroAccent:ToHex()
    local function escape(text)
        return (text:gsub("&","&amp;"):gsub("<","&lt;"):gsub(">","&gt;"))
    end
    label.Text = escape(item.title) .. ' <font color="#' .. color .. '">' .. escape(item.accent) .. '</font>'
end

function Window:SetTheme(theme)
    local config = type(theme) == "table" and theme or { Name = theme }
    local name = string.lower(tostring(config.Name or "Dark"))
    self.ThemeName = (name == "light" or name == "white" or name == "blanco") and "Light" or "Dark"
    self.theme = table.clone(self.ThemeName == "Light" and LIGHT or DARK)
    local light = self.ThemeName == "Light"
    if light then
        self:_cancel(self.sweep)
        self.sweep.Visible = false
    end
    for item, stops in pairs(self.faces) do item.Color = faceColors(stops,light) end
    for item in pairs(self.art) do self:_paintArt(item) end
    for item in pairs(self.effects) do self:_paintEffect(item) end
    if typeof(config.Background) == "Color3" then self.theme.Base = config.Background end
    if typeof(config.Accent) == "Color3" then
        local color = config.Accent
        local function linear(value)
            return value <= .04045 and value/12.92 or ((value+.055)/1.055)^2.4
        end
        local shade = light and .945 or .718
        local top = .2126*linear(color.R)+.7152*linear(color.G)+.0722*linear(color.B)
        local bottom = .2126*linear(color.R*shade)+.7152*linear(color.G*shade)+.0722*linear(color.B*shade)
        self.theme.Accent, self.theme.Primary = color,color
        self.theme.PrimaryHover = color:Lerp(rgb(255,255,255),.10)
        self.theme.Ink = (bottom+.05)/.05 >= 1.05/(top+.05) and rgb(0,0,0) or rgb(255,255,255)
    end
    self.customAccent = typeof(config.Accent) == "Color3" and config.Accent or nil
    self.customBackground = typeof(config.Background) == "Color3" and config.Background or nil
    for item in pairs(self.heroTitles) do self:_paintHeroTitle(item) end
    for item, props in pairs(self.bindings) do
        if item.Parent then
            for property, role in pairs(props) do
                local animation = self.tweens[item]
                if animation and animation.goal[property] ~= nil then self:_cancel(item) end
                item[property] = self.theme[role]
            end
        end
    end
    for _, tab in ipairs(self.Tabs) do
        for _, control in ipairs(tab.Elements) do
            if control.paint then control.paint() end
        end
    end
    return self
end

function Window:GetTheme() return self.ThemeName end

function Window:SetThemePreset(name)
    local preset = THEME_PRESETS[tostring(name or "")]
    if not preset then return self end
    self:SetTheme({Name=preset.Base, Accent=preset.Accent})
    self.ThemePreset = name
    return self
end
function Window:GetThemePreset() return self.ThemePreset or "Menta Ryou" end

function Window:SetAccent(color)
    if typeof(color) ~= "Color3" then return self end
    return self:SetTheme({
        Name=self.ThemeName or "Dark", Accent=color, Background=self.customBackground,
    })
end
function Window:GetAccent() return self.theme.Accent end

function Window:SetBackgroundColor(color)
    if typeof(color) ~= "Color3" then return self end
    return self:SetTheme({
        Name=self.ThemeName or "Dark", Accent=self.customAccent, Background=color,
    })
end
function Window:GetBackgroundColor() return self.theme.Base end

function Window:SetFontStyle(name)
    local fonts = FONT_STYLES[tostring(name or "")]
    if not fonts then return self end
    self.fontStyle = name
    self.font, self.boldFont = fonts[1], fonts[2]
    for item, bold in pairs(self.fontNodes) do
        if item.Parent then item.Font = bold and self.boldFont or self.font end
    end
    return self
end
function Window:GetFontStyle() return self.fontStyle or "Gotham" end

function Window:SetSurfaceTransparency(value)
    self.surfaceTransparency = math.clamp(tonumber(value) or 0,0,.35)
    for item in pairs(self.surfaceNodes) do
        if item.Parent then item.BackgroundTransparency = self.surfaceTransparency end
    end
    if self.panel then self.panel.BackgroundTransparency = self.surfaceTransparency*.6 end
    return self
end
function Window:GetSurfaceTransparency() return self.surfaceTransparency or 0 end

function Window:SetAnimationSpeed(value)
    self.animationSpeed = math.clamp(tonumber(value) or 1,.5,2)
    return self
end
function Window:GetAnimationSpeed() return self.animationSpeed or 1 end

-- Tabla segura para serializar con HttpService:JSONEncode; no incluye funciones ni instancias.
function Window:ExportAppearance()
    return {
        Version=1, Preset=self:GetThemePreset(), Base=self.ThemeName,
        Accent=self:GetAccent():ToHex(),
        Background=self.customBackground and self.customBackground:ToHex() or nil,
        Font=self:GetFontStyle(), Motion=self.motion,
        Speed=self:GetAnimationSpeed(), Transparency=self:GetSurfaceTransparency(),
        Scale=self:GetScale(), Neon=self:GetNeon(),
        Decoration=self:GetDecorationIntensity(),
    }
end
function Window:ImportAppearance(data)
    if type(data) ~= "table" then return self end
    if THEME_PRESETS[data.Preset] then
        self:SetThemePreset(data.Preset)
    elseif data.Base=="Light" or data.Base=="Dark" then
        self:SetTheme(data.Base)
    end
    local function parseColor(hex)
        if type(hex) ~= "string" or not hex:match("^#?%x%x%x%x%x%x$") then return nil end
        local ok, color = pcall(Color3.fromHex, hex:sub(1,1)=="#" and hex or ("#"..hex))
        return ok and color or nil
    end
    local accent = parseColor(data.Accent)
    if accent then self:SetAccent(accent) end
    local background = parseColor(data.Background)
    if background then self:SetBackgroundColor(background) end
    if FONT_STYLES[data.Font] then self:SetFontStyle(data.Font) end
    if MOTION[data.Motion] then self:SetMotion(data.Motion) end
    if data.Speed ~= nil then self:SetAnimationSpeed(data.Speed) end
    if data.Transparency ~= nil then self:SetSurfaceTransparency(data.Transparency) end
    if data.Scale ~= nil then self:SetScale(data.Scale) end
    if data.Neon ~= nil then self:SetNeon(data.Neon==true) end
    if data.Decoration ~= nil then self:SetDecorationIntensity(data.Decoration) end
    return self
end
function Window:SetTitle(str) self.Title = copyText(str); self.title.Text = self.Title; return self end
function Window:SetAuthor(str) self.Author = copyText(str); self.subtitle.Text = self.Author; return self end
Window.SetSubtitle = Window.SetAuthor
function Window:OnOpen(fn) table.insert(self.openedCallbacks, fn); return self end
function Window:OnClose(fn) table.insert(self.closedCallbacks, fn); return self end
function Window:OnDestroy(fn) table.insert(self.destroyCallbacks, fn); return self end
local function sizeInPixels(size)
    if typeof(size) == "UDim2" then
        return Vector2.new(size.X.Offset > 0 and size.X.Offset or 1040, size.Y.Offset > 0 and size.Y.Offset or 615)
    end
    assert(typeof(size) == "Vector2", "Expected Vector2 or UDim2 with offsets")
    return size
end

local function boundedValue(value,minimum,maximum)
    local number = tonumber(value)
    if not number or number~=number then return 1 end
    return math.clamp(number,minimum,maximum)
end

function Window:SetDecorationIntensity(value)
    self.decorationIntensity = boundedValue(value,0,1)
    self:_refreshEffects()
    return self
end

function Window:GetDecorationIntensity() return self.decorationIntensity end

function Window:SetScale(value)
    if self.gesture and (self.gesture.windowOrigin or self.gesture.resizing) then self:_endGesture(false) end
    self.interfaceScale = boundedValue(value,.85,1.20)
    self:_cancel(self.panelScale)
    self.panelScale.Scale = self.interfaceScale
    self:_fit()
    return self
end

function Window:GetScale() return self.interfaceScale end

function Window:SetSize(size)
    self.desired = sizeInPixels(size)
    self:_fit()
    return self
end
function Window:GetSize() return self.desired end
function Window:SetPosition(position)
    assert(position == nil or typeof(position) == "Vector2", "Expected Vector2 or nil")
    self.position = position
    self:_fit()
    return self
end
function Window:SetToTheCenter() return self:SetPosition(nil) end
function Window:SetToggleKey(key) self.key = key; return self end
function Window:SetResizable(enabled) self.resize.Visible = enabled ~= false; return self end
function Window:SetOpenButtonVisible(enabled)
    self.launcherEnabled = enabled ~= false
    self:_fitLauncher()
    return self
end
function Window:SetOpenButtonGhosted(enabled)
    local transparency = enabled == true and .38 or 0
    self.launcherPlate.BackgroundTransparency = transparency
    self.launcherImage.ImageTransparency = transparency
    return self
end
function Window:EditOpenButton(config)
    if config.Enabled ~= nil then self:SetOpenButtonVisible(config.Enabled) end
    if config.Ghosted ~= nil then self:SetOpenButtonGhosted(config.Ghosted) end
    return self
end

function Window:Destroy()
    if self.Destroyed then return end
    self.Destroyed, self.Opened = true, false
    self:_closePopup()
    if self.dismissModal then self.dismissModal() end
    if self.finishDialog then self.finishDialog() end
    self:_endGesture(false)
    clean(self.owner)
    while #self.notices > 0 do self.notices[#self.notices].Remove() end
    for item in pairs(self.tweens) do self:_cancel(item) end
    if not self.guiDestroying then self.gui:Destroy() end
    if self.library.Window == self then self.library.Window = nil end
    for _, fn in ipairs(self.destroyCallbacks) do callback(fn, self) end
end

function Window:_closePopup()
    local popup = self.popup
    if not popup then return end
    self.popup = nil
    clean(popup.owner)
    local focused = Input:GetFocusedTextBox()
    if focused and focused:IsDescendantOf(popup.panel) then focused:ReleaseFocus(false) end
    self:_cancel(popup.scale)
    popup.scale:Destroy()
    popup.panel.Visible = false
    self.popupLayer.Visible = false
    popup.closed()
end

function Window:_showPopup(anchor,panel,preferredHeight,closed,scrollHost)
    if not self.Opened or self.Destroyed or self.dismissModal then return false end
    self:_closePopup()
    self:_endGesture(false)
    local owner = childScope(self.owner)
    local scale = make("UIScale",panel,{Scale=.98})
    self.popup = {owner=owner,panel=panel,scale=scale,closed=closed}
    local function fit()
        local factor = self.interfaceScale
        local view = self.panel.Size
        local width,height = view.X.Offset,view.Y.Offset
        if width<20 or height<20 then return end
        local origin = self.panel.AbsolutePosition
        local point = (anchor.AbsolutePosition-origin)/factor
        local bounds = anchor.AbsoluteSize/factor
        if scrollHost then
            local top = scrollHost.AbsolutePosition.Y
            local bottom = top+scrollHost.AbsoluteWindowSize.Y
            if anchor.AbsolutePosition.Y+anchor.AbsoluteSize.Y<=top or anchor.AbsolutePosition.Y>=bottom then
                self:_closePopup()
                return
            end
        end
        local w = math.min(math.max(panel.Name=="SearchPopup" and 246 or 150,bounds.X),width-16)
        local below = math.max(0,height-point.Y-bounds.Y-12)
        local above = math.max(0,point.Y-12)
        local down = below>=preferredHeight or below>=above
        local h = math.min(preferredHeight,math.max(82,down and below or above),height-16)
        local y = down and point.Y+bounds.Y+4 or point.Y-h-4
        panel.Size = px(math.floor(w),math.floor(h))
        panel.Position = px(math.floor(math.clamp(point.X,8,width-w-8)),
            math.floor(math.clamp(y,8,height-h-8)))
    end
    listen(owner,anchor:GetPropertyChangedSignal("AbsolutePosition"),fit)
    listen(owner,anchor:GetPropertyChangedSignal("AbsoluteSize"),fit)
    listen(owner,self.panel:GetPropertyChangedSignal("Size"),fit)
    fit()
    if not self.popup then return false end
    self.popupLayer.Visible,panel.Visible = true,true
    self:_animate(scale,.13,{Scale=1})
    return true
end

local function addHeaderSearch(w)
    local button = action(w,w.owner,w.header,"",{
        Name="HeaderSearch",AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-77,.5,0),
        Size=px(34,38),ZIndex=4,
    },false,"window")
    icon(w,button,"magnifier",15,"Text",UDim2.new(.5,-7,.5,-7))
    local panel = surface(w,w.popupLayer,"Base",{Name="SearchPopup",Visible=false,Active=true,ZIndex=2},8)
    finish(w,panel,"Raised")
    local query = textBox(w,w.owner,panel,"Buscar en la interfaz…",{Position=px(6,5),Size=UDim2.new(1,-12,0,32)})
    local results = scroll(w,panel,{Position=px(6,43),Size=UDim2.new(1,-12,1,-49)})
    stack(results,4)
    local items
    local function clear()
        if items then clean(items); items=nil end
        for _, child in ipairs(results:GetChildren()) do
            if child:IsA("GuiObject") then child:Destroy() end
        end
    end
    local function refresh()
        if not panel.Visible then return end
        clear()
        items = childScope(w.owner)
        local needle = string.lower(query.Text)
        local count = 0
        local function add(tab,control,title)
            if count>=35 or not string.find(string.lower(title),needle,1,true) then return end
            count += 1
            local hit = action(w,items,results,title,{Size=UDim2.new(1,-3,0,32),LayoutOrder=count})
            hit.TextTruncate = Enum.TextTruncate.AtEnd
            listen(items,hit.Activated,function()
                w:_closePopup()
                w:SelectTab(tab)
                if control and control.row.Parent then
                    task.defer(function()
                        if w.Destroyed or w.Selected~=tab or not control.row.Parent then return end
                        local host = tab.scroller
                        local delta = (control.row.AbsolutePosition.Y-host.AbsolutePosition.Y)/w.interfaceScale
                        host.CanvasPosition = Vector2.new(0,math.max(0,host.CanvasPosition.Y+delta-6))
                    end)
                end
            end)
        end
        for _, tab in ipairs(w.Tabs) do
            add(tab,nil,tab.Title)
            if needle~="" then
                for _, control in ipairs(tab.Elements) do
                    if control.Title~="" and not control.Destroyed and control.row.Visible~=false then
                        add(tab,control,tab.Title.." · "..control.Title)
                    end
                end
            end
        end
        if count==0 then label(w,results,"Sin resultados",13,false,"Muted") end
        results.CanvasPosition = Vector2.zero
    end
    listen(w.owner,query:GetPropertyChangedSignal("Text"),refresh)
    listen(w.owner,button.Activated,function()
        if panel.Visible then w:_closePopup(); return end
        if w:_showPopup(button,panel,218,clear) then
            query.Text = ""
            refresh()
            query:CaptureFocus()
        end
    end)
end

function UI:CreateWindow(options)
    local o = options or {}
    local player = Players.LocalPlayer
    assert(player, "Ryou UI requires a Roblox client")
    if self.Window then self.Window:Destroy() end
    local playerGui = player:WaitForChild("PlayerGui")
    for _, child in ipairs(playerGui:GetChildren()) do
        if child:IsA("ScreenGui") and child:GetAttribute("RyouNeoSidebar") == true then
            child:Destroy()
        end
    end

    local w = setmetatable({
        library = self, owner = scope(), theme = DARK, motion = o.Motion or "Full",
        radius = math.clamp(tonumber(o.Radius) or 8, 4, 16),
        gap = math.clamp(tonumber(o.Spacing) or 7, 4, 16),
        font = o.Font or Enum.Font.Gotham, boldFont = o.BoldFont or Enum.Font.GothamBold,
        fontStyle = "Gotham", animationSpeed = 1, surfaceTransparency = 0,
        desired = sizeInPixels(o.Size or Vector2.new(1040, 615)), position = o.Position,
        key = o.ToggleKey or KEYBOARD, launcherEnabled = o.Launcher ~= false,
        Tabs = {}, groups = {}, entrance = {}, notices = {},
        art = {}, effects = {}, faces = {}, heroTitles = {}, tracked = {}, tweens = {}, bindings = {},
        fontNodes = {}, surfaceNodes = {},
        neon = o.Neon ~= false, interfaceScale = boundedValue(o.Scale,.85,1.2),
        decorationIntensity = boundedValue(o.DecorationIntensity,0,1),
        openedCallbacks = {}, closedCallbacks = {}, destroyCallbacks = {},
    }, Window)
    assert(MOTION[w.motion] ~= nil, "Motion must be Full, Reduced or Off")
    self.Window = w
    w.gui = make("ScreenGui", playerGui, {
        Name = "RyouUI14", ResetOnSpawn = false, DisplayOrder = 25,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling, ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
    })
    w.gui:SetAttribute("RyouNeoSidebar",true)
    ImageAssets:Preload("logo_small", "header_ribbon", "launcher")
    w.ScreenGui = w.gui
    w.screen = make("Frame", w.gui, { Size = full })
    w.frame = make("Frame", w.screen, { AnchorPoint = Vector2.new(.5, .5) })
    w.shadow = depth(w.frame,22,4)
    w.shadow.Position = px(0,4)
    w.shadow.Visible = false
    w.panel = make("CanvasGroup",w.frame,{
        AnchorPoint=Vector2.new(.5,.5),Position=centerAnchor,Visible=false,Interactable=false,
    })
    w.panelScale = make("UIScale",w.panel,{Scale=w.interfaceScale})
    w.Root = w.panel
    w.popupLayer = make("Frame",w.panel,{Name="InternalPopups",Visible=false,Size=full,ZIndex=11})
    local dismiss = make("TextButton",w.popupLayer,{
        Name="DismissPopup",Size=full,Active=true,Selectable=false,Text="",AutoButtonColor=false,
    })
    listen(w.owner,dismiss.Activated,function() w:_closePopup() end)
    w:_bind(w.panel, "BackgroundColor3", "Base")
    w.panel.BackgroundTransparency = 0
    corner(w.panel, 22)
    finish(w,w.panel,"Shell")

    local header = surface(w, w.panel, "Rail", { Size = UDim2.new(1, 0, 0, 74), Active = true, ClipsDescendants = true })
    w.header = header
    w.dragZone = make("TextButton",header,{
        Name="WindowDragArea",Size=full,ZIndex=3,Active=true,Selectable=false,Text="",AutoButtonColor=false,
    })
    faceGradient(w,header,"Header")
    w.headerRibbon = artworkLayer(w,header,"header_ribbon",UDim2.new(),px(488,70),Enum.ScaleType.Fit,.19,.92)
    local rule = surface(w, header, "Edge", { Position = UDim2.new(0, 16, 1, -1), Size = UDim2.new(1, -32, 0, 1) })
    rule.Name = "HeaderRule"
    w.sweep = make("Frame",header,{Size=px(65,8),Rotation=-26,Visible=false})
    w:_bind(w.sweep,"BackgroundColor3","Accent")
    make("UIGradient",w.sweep,{Rotation=90,Transparency=NumberSequence.new({
        NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(.5,.66),NumberSequenceKeypoint.new(1,1),
    })})
    w.brand = make("CanvasGroup",header,{Size=px(60,55),Position=UDim2.new(0,20,.5,-27)})
    w.brandScale = make("UIScale",w.brand,{})
    -- PNG alpha bounds are 391 × 289 of 512. A 50 px slot reduces the visible mark by 19%.
    mark(w,w.brand,50,px(3,3),false,true)
    w.titleGroup = make("Frame", header, { Position = UDim2.new(0, 91, .5, -23), Size = UDim2.new(1, -350, 0, 26) })
    w.subtitleGroup = make("Frame", header, { Position = UDim2.new(0, 92, .5, 3), Size = UDim2.new(1, -350, 0, 19) })
    w.title = label(w, w.titleGroup, copyText(o.Title, "Ryou UI"), 25, true, nil,
        { Size = full, TextTruncate = Enum.TextTruncate.AtEnd })
    w.subtitle = label(w, w.subtitleGroup, copyText(o.Subtitle or o.Author, "Created by Ryou"), 13, false, "Muted",
        { Size = full, TextTruncate = Enum.TextTruncate.AtEnd })
    w.Title, w.Author = w.title.Text, w.subtitle.Text
    windowAction(w,w.owner,header,"minimize",43,function() w:Minimize() end)
    windowAction(w,w.owner,header,"error",9,function() w:Close() end)

    w.utilities = make("Frame", header, {
        Position = UDim2.new(1,-251,.5,-17), Size = px(92,34), Active=false,
    })
    local badge = surface(w, w.utilities, "Field", { Size = px(92,26), Position = px(0,4) }, 7)
    finish(w,badge,"Raised")
    surface(w,badge,"Accent",{Size = px(5,5),Position = px(8,11)}, 4)
    label(w,badge,copyText(o.Badge, "V14 · Stable"),12,true,"Text",{Position=px(19,0),Size=UDim2.new(1,-22,1,0),
        TextTruncate=Enum.TextTruncate.AtEnd})
    local util = type(o.Utilities) == "table" and o.Utilities or {}
    local cloud = action(w,w.owner,header,"",{Position=UDim2.new(1,-155,.5,-16),Size=px(31,32),ZIndex=4})
    local bell = action(w,w.owner,header,"",{Position=UDim2.new(1,-120,.5,-16),Size=px(31,32),ZIndex=4})
    w.headerTools = {cloud,bell}
    addHeaderSearch(w)
    icon(w,cloud,"cloud",15,"Text",px(8,8))
    icon(w,bell,"bell",15,"Text",px(8,8))
    surface(w,bell,"Accent",{ Size=px(5,5), Position=px(23,6) },3)
    listen(w.owner,cloud.Activated,function()
        if util.Cloud then callback(util.Cloud, w) else w:Notify({Title="Ryou UI", Content="Biblioteca visual V14"}) end
    end)
    listen(w.owner,bell.Activated,function()
        if util.Notifications then callback(util.Notifications, w) else w:Notify({Title="Notificaciones", Content="El panel está listo."}) end
    end)
    local content = make("Frame", w.panel, { Position = px(0, 74), Size = UDim2.new(1, 0, 1, -74) })
    w.content = content
    w.rail = make("Frame", content, { Position = px(0, 0) })
    w.rail.BackgroundTransparency = 0
    w:_bind(w.rail, "BackgroundColor3", "Rail")
    faceGradient(w,w.rail,"Rail")
    local railGlow = artworkLayer(w,w.rail,"rail_glow",UDim2.fromScale(0,1),UDim2.fromScale(1,.84),Enum.ScaleType.Fit,.12,.94)
    railGlow.AnchorPoint = Vector2.new(0,1)
    w.nav = scroll(w, w.rail, { Size = full })
    pad(w.nav, 6, 9)
    stack(w.nav, 4)
    w.body = make("Frame", content, {ClipsDescendants=true})
    artworkLayer(w,w.body,"background_artwork",UDim2.new(),full,Enum.ScaleType.Crop,.78,nil)
    w.pages = make("Frame", w.body, { Size = full })
    local divider = surface(w, w.body, "Edge", { Position = px(0, 0), Size = UDim2.new(0, 1, 1, 0), BackgroundTransparency=.5 })
    divider.Name = "RailRule"
    for _, group in ipairs({ w.brand, w.titleGroup, w.subtitleGroup, w.utilities, w.rail, w.pages }) do
        w.entrance[group] = group.Position
    end
    w.resize = make("TextButton", w.panel, {
        Text = "", AutoButtonColor = false, Size = px(36, 34), AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.fromScale(1, 1), ZIndex = 8,
    })
    icon(w, w.resize, "grip", 17, "Muted", px(15, 13))
    w:SetResizable(o.Resizable ~= false)

    w.launcher = make("TextButton", w.screen, {
        Text = "", AutoButtonColor = false, Size = px(70, 70), AnchorPoint = Vector2.new(.5, .5),
        Visible = false, ZIndex = 15,
    })
    w.launchScale = make("UIScale", w.launcher, {})
    local fallback = make("Frame", w.launcher, {Name="LauncherFallback", Size=full})
    local pod = surface(w, fallback, "Rail", {Position=px(3,3), Size=px(64,64)}, 32)
    edge(w, pod)
    label(w, pod, "R", 28, true, "Accent", {Size=full, TextXAlignment=Enum.TextXAlignment.Center})
    w.launcherPlate, w.OpenButton = pod, w.launcher
    w.launcherImage = assetImage(w.launcher, "launcher", {
        Name="LauncherArt", AnchorPoint=Vector2.new(.5,.5), Position=UDim2.fromScale(.51,.50),
        Size=UDim2.fromScale(1.34,1.34), ScaleType=Enum.ScaleType.Fit,
    }, fallback, "launcher_fallback", UDim2.fromScale(1.06,1.06))
    if type(o.OpenButton) == "table" then
        if o.OpenButton.Enabled ~= nil then w.launcherEnabled = o.OpenButton.Enabled ~= false end
        w:SetOpenButtonGhosted(o.OpenButton.Ghosted)
    end
    listen(w.owner, w.launcher.MouseEnter, function()
        if not w.gesture then w:_animate(w.launchScale,.19,{Scale=1.045}) end
    end)
    listen(w.owner, w.launcher.MouseLeave, function()
        if not w.gesture then w:_animate(w.launchScale,.14,{Scale=1}) end
    end)
    listen(w.owner, w.launcher.Activated, function(event)
        if event and event.UserInputType == Enum.UserInputType.Gamepad1 then
            if w.Opened then w:Close() else w:_open(true) end
        end
    end)
    w.tray = make("Frame", w.screen, { AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 10, 1, -10), Size = UDim2.new(1, -20, 0, 0),
        AutomaticSize = VERTICAL, ZIndex = 20 })
    make("UISizeConstraint", w.tray, { MaxSize = Vector2.new(305, math.huge) })
    stack(w.tray, 6)

    local launchStart
    w:_gesture(w.owner, w.launcher, function(point, gesture)
        if not gesture.moved and (point - gesture.origin).Magnitude < 9 then return end
        if not gesture.moved then w:_animate(w.launchScale,.12,{Scale=1.035}) end
        gesture.moved = true
        w.draggingLauncher = true
        w.launcherPosition = launchStart + point - gesture.origin
        w:_fitLauncher()
    end, function(gesture)
        if gesture.moved then
            w:_fitLauncher()
        elseif gesture.event.UserInputState ~= Enum.UserInputState.Cancel then
            if w.Opened then w:Close() else w:_open(true) end
        end
    end, function()
        if not w.launcherEnabled then return false end
        w.gesture.restore = function()
            w.draggingLauncher = false
            w:_fitLauncher()
            w:_animate(w.launchScale,.17,{Scale=1})
        end
        launchStart = Vector2.new(w.launcher.Position.X.Offset, w.launcher.Position.Y.Offset)
        w:_animate(w.launchScale,.09,{Scale=.93})
        w:_pulseLauncher()
        return true
    end)

    w:_gesture(w.owner,w.dragZone,function(point,gesture)
        w.position = w:_moveFrame(gesture.windowOrigin+point-gesture.origin)
    end,nil,function()
        if not w.Opened or w.dismissModal then return false end
        local position, drawn = w.frame.Position, w.panel.Position
        local center = Vector2.new(position.X.Offset+drawn.X.Offset,position.Y.Offset+drawn.Y.Offset)
        w:_cancel(w.panel)
        w.panel.Position,w.panel.GroupTransparency = centerAnchor,0
        w.position = w:_moveFrame(center)
        w.gesture.windowOrigin = w.position
        return true
    end)
    local sizeStart, resizeOrigin
    w:_gesture(w.owner, w.resize, function(point, gesture)
        local delta = point - gesture.origin
        local bounds = w.screen.AbsoluteSize
        local maximum = Vector2.new(math.max(1, bounds.X-resizeOrigin.X-8), math.max(1, bounds.Y-resizeOrigin.Y-8))
        local final = Vector2.new(
            math.clamp(sizeStart.X + delta.X, math.min(MIN_WIDTH*w.interfaceScale, maximum.X), maximum.X),
            math.clamp(sizeStart.Y + delta.Y, math.min(MIN_HEIGHT*w.interfaceScale, maximum.Y), maximum.Y))
        w.position = resizeOrigin + final/2
        w:SetSize(final/w.interfaceScale)
    end, nil, function()
        if not w.Opened or not w.resize.Visible or w.dismissModal then return false end
        local size,position = w.frame.Size,w.frame.Position
        sizeStart = Vector2.new(size.X.Offset,size.Y.Offset)
        resizeOrigin = Vector2.new(position.X.Offset,position.Y.Offset)-sizeStart/2
        w.gesture.resizing = true
        return true
    end)

    listen(w.owner, Input.InputChanged, function(event)
        local gesture = w.gesture
        if not gesture then return end
        if event == gesture.event or (gesture.event.UserInputType == MOUSE and event.UserInputType == Enum.UserInputType.MouseMovement) then
            if event.UserInputState == Enum.UserInputState.Cancel then
                w:_endGesture(false)
            else
                gesture.update(Vector2.new(event.Position.X,event.Position.Y),gesture)
            end
        end
    end)
    listen(w.owner, Input.InputEnded, function(event)
        local gesture = w.gesture
        if gesture and (event == gesture.event or (event.UserInputType == MOUSE and gesture.event.UserInputType == MOUSE)) then
            w:_endGesture(event.UserInputState ~= Enum.UserInputState.Cancel)
        end
    end)
    listen(w.owner, Input.WindowFocusReleased, function()
        w:_endGesture(false)
        w:_animate(w.launchScale, .15, { Scale = 1 })
    end)
    listen(w.owner, Input.InputBegan, function(event, consumed)
        if event.KeyCode==Enum.KeyCode.Escape and w.popup then w:_closePopup(); return end
        if consumed or Input:GetFocusedTextBox() then return end
        if event.KeyCode == Enum.KeyCode.Escape and w.dismissModal then w.dismissModal(); return end
        if event.KeyCode == w.key then w:Toggle() end
    end)
    listen(w.owner,w.screen:GetPropertyChangedSignal("AbsoluteSize"),function()
        w:_endGesture(false)
        w:_fit()
    end)
    listen(w.owner, w.gui.Destroying, function()
        if not w.Destroyed then
            w.guiDestroying = true
            w:Destroy()
        end
    end)
    w:SetTheme(o.Theme or self._defaultTheme or "Dark")
    if o.ThemePreset then w:SetThemePreset(o.ThemePreset) end
    if o.FontStyle then w:SetFontStyle(o.FontStyle) end
    if o.AnimationSpeed then w:SetAnimationSpeed(o.AnimationSpeed) end
    if o.SurfaceTransparency then w:SetSurfaceTransparency(o.SurfaceTransparency) end
    w:SetNeon(w.neon)
    w:_fit()
    if o.Open == false then
        w:SetOpenButtonVisible(w.launcherEnabled)
    else
        task.delay(w.motion=="Off" and 0 or .12,function()
            if not w.Destroyed and not w.hasOpened and not w.initialCancelled then w:_open(w.launcherEnabled) end
        end)
    end
    return w
end

function Window:SelectTab(which)
    local selected
    if type(which) == "number" then which = self.Tabs[which] end
    for _, tab in ipairs(self.Tabs) do
        if tab == which or tab.Id == which or tab.Title == which then selected = tab; break end
    end
    if not selected or selected == self.Selected then return selected end
    local previous = self.Selected
    self:_closePopup()
    self.Selected, self.CurrentTab = selected, selected
    if previous then
        previous.page.Visible = false
        previous.marker.Visible = false
        previous.activeFill.Visible = false
        self:_bind(previous.titleLabel, "TextColor3", "Muted")
        self:_cancel(previous.page)
        self:_cancel(previous.marker)
    end
    selected.page.Visible = true
    selected.marker.Visible = true
    selected.activeFill.Visible = true
    for _, segment in ipairs(selected.glyph:GetChildren()) do
        if segment.Name == "Segment" then self:_bind(segment,"BackgroundColor3","Accent") end
    end
    if previous then
        for _, segment in ipairs(previous.glyph:GetChildren()) do
            if segment.Name == "Segment" then self:_bind(segment,"BackgroundColor3","Muted") end
        end
    end
    selected.marker.Size = px(3, 6)
    self:_animate(selected.marker, .20, { Size = px(3, 23) })
    self:_bind(selected.titleLabel, "TextColor3", "Text")
    if previous and self.Opened then
        selected.page.Position = px(5,0)
        self:_animate(selected.page,.20,{Position=px(0,0)})
    else
        selected.page.Position = px(0,0)
    end
    return selected
end

function Window:Tab(options)
    local o = type(options) == "string" and { Title = options } or options or {}
    local name = copyText(o.Title or o.Name, "Pestaña")
    local t = setmetatable({ Window = self, Title = name, Id = o.Id or name, Elements = {} }, Tab)
    self.navOrder = (self.navOrder or 0) + 1
    local slot = make("Frame", self.nav, { Size = UDim2.new(1, 0, 0, 40), LayoutOrder = self.navOrder })
    t.slot, t.labelWidths = slot, {}
    for size=12,14 do
        t.labelWidths[size] = TextService:GetTextSize(name,size,self.boldFont,Vector2.new(10000,10000)).X
    end
    local shell = make("Frame", slot, { Size = full })
    t.shell = shell
    self.entrance[shell] = shell.Position
    local hit = action(self,self.owner,shell,"",{Size=full},false,"bare")
    hit.BackgroundTransparency = 1
    t.hit = hit
    t.activeFill = surface(self,hit,"Selected",{Size=full,Visible=false},7)
    finish(self,t.activeFill,"Selected")
    selectionLight(self,t.activeFill).Visible = true
    t.glyph = icon(self, hit, o.Icon or "grid", 18, "Muted", UDim2.new(0, 12, .5, -9))
    t.marker = surface(self, hit, "Accent", { AnchorPoint = Vector2.new(0, .5),
        Position = UDim2.new(0, 1, .5, 0), Size = px(3, 23), Visible = false }, 2)
    gradient(t.marker,rgb(178,223,206),rgb(255,255,255),85)
    t.titleLabel = label(self, hit, name, 14, true, "Muted", { Position = px(32, 0),
        Size = UDim2.new(1, -41, 1, 0), TextWrapped = true })
    t.page = make("Frame", self.pages, { Size = full, Visible = false })
    t.scroller = scroll(self, t.page, { Size = full })
    pad(t.scroller, 10, 8)
    stack(t.scroller, self.gap)
    if o.ShowTitle ~= false then
        label(self, t.scroller, name, 19, true, nil, { Size = UDim2.new(1, 0, 0, 25), LayoutOrder = -1 })
    end
    if o.Desc and o.ShowTitle ~= false then
        label(self, t.scroller, copyText(o.Desc), 13, false, "Muted", {
            TextWrapped = true, AutomaticSize = VERTICAL, Size = UDim2.new(1, 0, 0, 0), LayoutOrder = 0,
        })
    end
    table.insert(self.Tabs, t)
    listen(self.owner, hit.Activated, function() t:Select() end)
    self:_fit()
    if not self.Selected then self:SelectTab(t) end
    return t
end

function Window:Section(options)
    local o = type(options) == "string" and { Title = options } or options or {}
    self.navOrder = (self.navOrder or 0) + 1
    local stripe = make("Frame", self.nav, { Size = UDim2.new(1, 0, 0, 21), LayoutOrder = self.navOrder })
    local title = label(self, stripe, copyText(o.Title or o.Name), 12, true, "Muted",
        { Position = px(8, 0), Size = UDim2.new(1, -12, 1, 0), Visible = not self.Compact,
            TextWrapped = true })
    local group = { label = title, window = self, Title = title.Text, ElementFrame = stripe, expanded = true }
    function group:Tab(config) return self.window:Tab(config) end
    function group:Open() self.expanded = true; stripe.Visible = not self.window.Compact; return self end
    function group:Close() self.expanded = false; stripe.Visible = false; return self end
    table.insert(self.groups, group)
    self:_fit()
    return group
end
Window.Group = Window.Section

function Tab:Select() self.Window:SelectTab(self); return self end
function Tab:LockAll() for _, control in ipairs(self.Elements) do control:Lock() end; return self end
function Tab:UnlockAll() for _, control in ipairs(self.Elements) do control:Unlock() end; return self end
function Tab:Section(options)
    local o = type(options) == "string" and { Title = options } or options or {}
    local w = self.Window
    self.order = (self.order or 0) + 1
    local row = make("Frame", self.scroller, { Size = UDim2.new(1, 0, 0, 19), LayoutOrder = self.order })
    local inset = o.Icon and 20 or 0
    local badgeWidth = o.Badge and 54 or 0
    if o.Icon then icon(w,row,o.Icon,13,"Accent",px(2,3)) end
    label(w,row,copyText(o.Title or o.Name),12,true,"Text",{
        Position=px(inset,0),Size=UDim2.new(1,-inset-badgeWidth,1,0),TextTruncate=Enum.TextTruncate.AtEnd,
    })
    if o.Badge then
        local badge = surface(w,row,"Selected",{
            Position=UDim2.new(1,-49,0,1),Size=px(47,16),
        },5)
        finish(w,badge,"Selected")
        surface(w,badge,"Accent",{Position=px(5,6),Size=px(4,4)},2)
        label(w,badge,copyText(o.Badge),10,true,"SelectedText",{
            Position=px(13,0),Size=UDim2.new(1,-15,1,0),TextTruncate=Enum.TextTruncate.AtEnd,
        })
    end
    surface(w,row,"Edge",{Position=UDim2.new(0,0,1,-1),Size=UDim2.new(1,0,0,1),BackgroundTransparency=.6})
    return self
end

local function insertBlock(tab, class, props)
    tab.order = (tab.order or 0)+1
    props.LayoutOrder = tab.order
    return make(class, tab.scroller, props)
end

function Tab:Banner(options)
    local o, w = options or {}, self.Window
    local preferredHeight = math.clamp(o.Height or 138, 74, 200)
    local large = preferredHeight >= 120
    local banner = insertBlock(self, "Frame", {Size=UDim2.new(1,-3,0,preferredHeight), ClipsDescendants=true})
    banner.BackgroundTransparency=0
    w:_bind(banner,"BackgroundColor3","Rail")
    corner(banner,12)
    finish(w,banner,"Raised")
    local halo = artworkLayer(w,banner,"background_artwork",UDim2.fromScale(.15,-.12),UDim2.fromScale(.85,1.24),Enum.ScaleType.Crop,.70,nil)
    make("UIGradient",halo,{Transparency=NumberSequence.new({
        NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(.40,.75),NumberSequenceKeypoint.new(1,0),
    })})
    local orbits = artworkLayer(w,banner,"hero_orbits",UDim2.new(1,0,0,0),full,Enum.ScaleType.Fit,.22,.89)
    orbits.AnchorPoint = Vector2.new(1,0)
    local device = make("Frame", banner, {
        AnchorPoint=Vector2.new(.5,.5), Size=px(220,210),
    })
    local scale = make("UIScale",device,{})
    mark(w,device,179,px(20,15),true)
    local title = label(w,banner,copyText(o.Title,"Ryou UI"),large and 34 or 21,true,"Text",{
        RichText=true,TextTruncate=Enum.TextTruncate.AtEnd})
    if o.AccentText then
        w:_track(title)
        w.heroTitles[title] = {title=title.Text,accent=copyText(o.AccentText)}
        w:_paintHeroTitle(title)
    end
    local subtitle = label(w,banner,copyText(o.Subtitle),large and 16 or 13,false,"Muted",{
        TextTruncate=Enum.TextTruncate.AtEnd})
    local underline = surface(w,banner,"Accent",{Size=px(29,2)},2)
    local function fit()
        local width = banner.AbsoluteSize.X/w.interfaceScale
        local short = w.frame.Size.Y.Offset > 0 and w.panel.Size.Y.Offset < 415
        local height = short and math.min(preferredHeight,large and 96 or 74) or preferredHeight
        if banner.Size.Y.Offset ~= height then banner.Size = UDim2.new(1,-3,0,height) end
        orbits.Size = px(height*(1536/550),height)
        local narrow = width < 485
        device.Visible = width >= 275
        local logoScale = math.min(height/145,narrow and .70 or 1.06)
        scale.Scale = logoScale
        device.Position = UDim2.new(1,-math.floor(112*logoScale),.54,0)
        local inset = short and 13 or 17
        local reserve = device.Visible and math.ceil(195*logoScale)+inset or inset*2
        title.TextSize = large and ((narrow or short) and 27 or 34) or 21
        subtitle.TextSize = large and not short and 16 or 13
        local top = math.max(6,math.floor((height-title.TextSize-subtitle.TextSize-12)/2))
        title.Position, title.Size = px(inset,top),UDim2.new(1,-reserve,0,title.TextSize+4)
        subtitle.Position = px(inset,top+title.TextSize+5)
        subtitle.Size = UDim2.new(1,-reserve,0,subtitle.TextSize+4)
        underline.Position = px(inset,top+title.TextSize+subtitle.TextSize+12)
    end
    listen(w.owner,banner:GetPropertyChangedSignal("AbsoluteSize"),fit)
    listen(w.owner,w.frame:GetPropertyChangedSignal("Size"),fit)
    fit()
    return banner
end

function Tab:Columns(options)
    local o, w = options or {}, self.Window
    local count = math.clamp(math.floor(o.Count or 2), 2, 3)
    local wrapper = insertBlock(self, "Frame", { Size=UDim2.new(1,-3,0,0), AutomaticSize=VERTICAL })
    local layout = stack(wrapper,7)
    local columns = {}
    for index=1,count do
        local holder = make("Frame",wrapper,{LayoutOrder=index,Size=UDim2.new(1,0,0,0),AutomaticSize=VERTICAL})
        if o.Cards ~= false then
            holder.BackgroundTransparency=0
            w:_bind(holder,"BackgroundColor3","Raised")
            corner(holder,11)
            finish(w,holder,"Raised")
            pad(holder,8,6)
        end
        stack(holder,5)
        columns[index] = setmetatable({Window=w,scroller=holder,Elements=self.Elements,scrollHost=self.scrollHost or self.scroller,cardColumn=o.Cards ~= false},Tab)
    end
    local function fit()
        local compact = wrapper.AbsoluteSize.X/w.interfaceScale < (o.MinWidth or (count == 3 and 570 or 455))
        layout.FillDirection = compact and Enum.FillDirection.Vertical or Enum.FillDirection.Horizontal
        for index, column in ipairs(columns) do
            local ratio = count == 2 and math.clamp(o.Split or .53,.32,.68) or 1/count
            if count == 2 and index == 2 then ratio = 1-ratio end
            column.scroller.Size = UDim2.new(compact and 1 or ratio,compact and 0 or -math.ceil(7*(count-1)/count),0,0)
        end
    end
    listen(w.owner,wrapper:GetPropertyChangedSignal("AbsoluteSize"),fit)
    fit()
    return table.unpack(columns)
end

function Tab:Stats(options)
    local w = self.Window
    local values = options or {}
    if #values == 0 then return nil end
    local count = math.min(#values,3)
    local row = insertBlock(self,"Frame",{Size=UDim2.new(1,0,0,41)})
    stack(row,4).FillDirection = Enum.FillDirection.Horizontal
    local cells = {}
    for index=1,count do
        local value = values[index]
        local cell = surface(w,row,"Field",{Size=UDim2.new(1/count,-math.ceil(4*(count-1)/count),1,0),LayoutOrder=index},8)
        finish(w,cell,"Field")
        local glyph = icon(w,cell,value.Icon or "activity",14,"Accent",UDim2.new(0,6,.5,-7))
        local caption = label(w,cell,copyText(value.Value),12,true,"Text",{TextTruncate=Enum.TextTruncate.AtEnd})
        local detail = label(w,cell,copyText(value.Text),10,false,"Muted",{TextTruncate=Enum.TextTruncate.AtEnd})
        cells[index] = { glyph, caption, detail }
    end
    local function fit()
        local narrow = row.AbsoluteSize.X/(count*w.interfaceScale) < 77
        for _, cell in ipairs(cells) do
            local glyph, caption, detail = table.unpack(cell)
            glyph.Visible = not narrow
            local inset = narrow and 2 or 24
            local align = narrow and Enum.TextXAlignment.Center or LEFT
            caption.Position, detail.Position = px(inset,4),px(inset,21)
            caption.Size, detail.Size = UDim2.new(1,-inset-3,0,17),UDim2.new(1,-inset-3,0,14)
            caption.TextXAlignment,detail.TextXAlignment = align,align
            caption.TextSize = narrow and 11 or 12
        end
    end
    listen(w.owner,row:GetPropertyChangedSignal("AbsoluteSize"),fit)
    fit()
    return row
end

local function control(tab, options, bare)
    local o, w = options or {}, tab.Window
    local c = setmetatable({ tab = tab, window = w, owner = childScope(w.owner), Callback = o.Callback, targets = {} }, Control)
    tab.order = (tab.order or 0) + 1
    local row = make("Frame", tab.scroller, { Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = VERTICAL, LayoutOrder = tab.order })
    c.ElementFrame, c.row = row, row
    if not bare then
        row.BackgroundTransparency = 0
        w:_bind(row, "BackgroundColor3", "Rail")
        corner(row, w.radius)
        finish(w,row,"Card")
    end
    pad(row, bare and 0 or 8, bare and 1 or 6)
    stack(row, 4)
    local head = make("Frame", row, { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = VERTICAL, LayoutOrder = 0 })
    local iconSize = math.clamp(tonumber(o.IconSize) or 17, 12, 24)
    local inset = o.Icon and iconSize + 8 or 0
    if o.Icon then icon(w, head, o.Icon, iconSize, "Muted", px(0, 2)) end
    c.head = head
    c.copy = make("Frame", head, { Position = px(inset, 0), Size = UDim2.new(1, -inset, 0, 0), AutomaticSize = VERTICAL })
    stack(c.copy, 0)
    c.title = label(w, c.copy, copyText(o.Title or o.Name), 14, true, nil,
        { LayoutOrder = 0, TextWrapped = true, AutomaticSize = VERTICAL, Size = UDim2.new(1, 0, 0, 0) })
    c.title.Visible = c.title.Text ~= ""
    c.desc = label(w, c.copy, copyText(o.Desc or o.Description or o.Content), 12, false, "Muted",
        { LayoutOrder = 1, TextWrapped = true, AutomaticSize = VERTICAL, Size = UDim2.new(1, 0, 0, 0) })
    c.desc.Visible = c.desc.Text ~= ""
    c.Title, c.Desc = c.title.Text, c.desc.Text
    table.insert(tab.Elements, c)
    return c
end

function Control:_commit(value, silent, compare)
    local changed = not (compare and compare(self.Value, value) or self.Value == value)
    if self.Destroyed then return self end
    self.Value = value
    if self.paint then self.paint() end
    if changed and not silent then callback(self.Callback, self:Get()) end
    return self
end
function Control:Get()
    return type(self.Value) == "table" and table.clone(self.Value) or self.Value
end
function Control:SetValue(...) if self.Set then return self:Set(...) end; return self end
function Control:SetTitle(value) self.Title = copyText(value); self.title.Text = self.Title; self.title.Visible = self.title.Text ~= ""; return self end
function Control:SetDesc(value) self.Desc = copyText(value); self.desc.Text = self.Desc; self.desc.Visible = self.desc.Text ~= ""; return self end
function Control:SetVisible(value) self.row.Visible = value == true; return self end
function Control:Show() return self:SetVisible(true) end
function Control:Hide() return self:SetVisible(false) end
function Control:_locked(locked)
    self.Locked = locked
    if self.window.gesture and self.window.gesture.owner == self.owner then self.window:_endGesture(false) end
    if locked and self.Close then self:Close(true) end
    self.window:_bind(self.title,"TextColor3",locked and "Disabled" or "Text")
    for target in pairs(self.targets) do
        target.Active, target.Selectable = not locked, not locked
        if target:IsA("TextBox") then
            target.TextEditable = not locked
            if locked and target:IsFocused() then target:ReleaseFocus(false) end
        end
    end
    if self.paint then self.paint() end
    return self
end
function Control:Lock() return self:_locked(true) end
function Control:Unlock() return self:_locked(false) end
function Control:Destroy()
    if self.Destroyed then return end
    self.Destroyed = true
    if self.closePicker then self.closePicker(); self.closePicker=nil end
    if self.closeCatalog then self.closeCatalog(); self.closeCatalog=nil end
    if self.window.openDropdown == self then self.window:_closePopup() end
    if self.popupPanel then self.popupPanel:Destroy(); self.popupPanel = nil end
    if self.window.gesture and self.window.gesture.owner == self.owner then self.window:_endGesture(false) end
    clean(self.owner)
    for _, item in ipairs(self.row:GetDescendants()) do
        self.window:_cancel(item)
        self.window.bindings[item] = nil
    end
    self.window:_cancel(self.row)
    self.window.bindings[self.row] = nil
    self.row:Destroy()
    local index = table.find(self.tab.Elements, self)
    if index then table.remove(self.tab.Elements, index) end
end

function Tab:Paragraph(options)
    local c = control(self, options, true)
    function c:Set(value) return self:SetDesc(value) end
    return c
end
function Tab:Button(options)
    local o = options or {}
    local c = control(self, o, o.Compact or self.cardColumn)
    local w = self.Window
    if o.Compact then c.head.Visible=false end
    local hit = action(w, c.owner, c.row, copyText(o.Action, o.Compact and c.Title or "Abrir"),
        { Size = UDim2.new(1,0,0,o.Compact and 35 or 37), LayoutOrder = 1 }, o.Primary == true)
    if o.Compact then
        hit.TextTruncate=Enum.TextTruncate.AtEnd
        hit.TextXAlignment=LEFT
        pad(hit,o.Icon and 28 or 9,0)
        if o.Icon then icon(w,hit,o.Icon,16,o.Primary and "Ink" or "Accent",UDim2.new(0,-21,.5,-8)) end
    else
        icon(w, hit, "arrow", 17, o.Primary and "Ink" or "Muted", UDim2.new(1, -27, .5, -8))
    end
    c.targets[hit] = true
    listen(c.owner, hit.Activated, function() if not c.Locked then callback(c.Callback) end end)
    return c
end
function Tab:Toggle(options)
    local o = options or {}
    local c, w = control(self, o), self.Window
    c.copy.Size = c.copy.Size - px(65,0)
    make("UISizeConstraint",c.head,{MinSize=Vector2.new(0,32)})
    local hit = action(w,c.owner,c.head,"",{
        AnchorPoint=Vector2.new(1,.5), Position=UDim2.new(1,0,.5,0), Size=px(58,41),
    })
    hit.BackgroundTransparency=1
    local track=surface(w,hit,"Edge",{Position=px(7,10),Size=px(44,21)},11)
    local knob=surface(w,track,"Text",{Position=px(4,3),Size=px(15,15)},8)
    c.targets[hit] = true
    function c:Set(value, silent) return self:_commit(value == true, silent) end
    function c.paint()
        w:_animate(track, .16, { BackgroundColor3 = c.Value and w.theme.Accent or w.theme.Edge })
        w:_animate(knob, .16, { Position = px(c.Value and 25 or 4, 3),
            BackgroundColor3 = c.Value and w.theme.LightMint or w.theme.Text })
    end
    c:Set(o.Value == true or (o.Value == nil and o.Default == true), true)
    listen(c.owner, hit.Activated, function() if not c.Locked then c:Set(not c.Value) end end)
    return c
end

function Tab:Input(options)
    local o = options or {}
    local c, w = control(self, o), self.Window
    local box = textBox(w, c.owner, c.row, copyText(o.Placeholder, "Escribe aquí…"),
        { Size = UDim2.new(1, 0, 0, 44), LayoutOrder = 1 })
    c.targets[box], c.TextBox = true, box
    function c:Set(value, silent) return self:_commit(copyText(value), silent) end
    function c.paint() if box.Text ~= c.Value then box.Text = c.Value end end
    c:Set(o.Value or o.Default, true)
    listen(c.owner, box.FocusLost, function() if not c.Locked then c:Set(box.Text) else box.Text = c.Value end end)
    if o.Live then listen(c.owner, box:GetPropertyChangedSignal("Text"), function() if not c.Locked then c:Set(box.Text) end end) end
    return c
end

local function finite(value, default)
    local number = tonumber(value)
    return number and number == number and math.abs(number) < math.huge and number or default
end

local function valueBar(w, c, parent, order, name, update)
    local area = action(w, c.owner, parent, "", { LayoutOrder = order, Size = UDim2.new(1, 0, 0, 44) })
    local caption = label(w, area, name, 13, true, nil, { Position = px(9, 1), Size = UDim2.new(1, -18, 0, 21) })
    local rail = surface(w, area, "Edge", { Position = px(10, 29), Size = UDim2.new(1, -20, 0, 4) }, 2)
    local fill = surface(w, rail, "Accent", { Size = UDim2.fromScale(0, 1) }, 2)
    local thumb = surface(w, rail, "Text", { AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(0, .5), Size = px(10, 10) }, 5)
    c.targets[area] = true
    local origin,width
    local function slide(point)
        if width>0 and not c.Locked then update(math.clamp((point.X-origin)/width,0,1)) end
    end
    w:_gesture(c.owner, area, slide, nil, function(point)
        if c.Locked then return false end
        origin,width = rail.AbsolutePosition.X,rail.AbsoluteSize.X
        local scroller = c.tab.scrollHost or c.tab.scroller
        local previous = scroller.ScrollingEnabled
        scroller.ScrollingEnabled = false
        w.gesture.restore = function()
            if scroller.Parent then scroller.ScrollingEnabled = previous end
        end
        slide(point)
        return true
    end)
    return function(fraction, text)
        caption.Text = name .. "  " .. text
        fill.Size, thumb.Position = UDim2.fromScale(fraction, 1), UDim2.fromScale(fraction, .5)
    end
end

function Tab:Slider(options)
    local o = options or {}
    local c, w = control(self, o), self.Window
    local range = type(o.Value) == "table" and o.Value or {}
    local a, b = finite(range.Min or o.Min, 0), finite(range.Max or o.Max, 100)
    local low, high = math.min(a, b), math.max(a, b)
    local step = math.max(finite(o.Step, 1), .000001)
    function c:Set(value, silent)
        local raw = math.clamp(finite(value, low), low, high)
        local snapped = raw == high and high or math.clamp(low + math.round((raw-low)/step)*step, low, high)
        return self:_commit(snapped, silent)
    end
    local render = valueBar(w, c, c.row, 1, "Valor", function(fraction) c:Set(low + fraction*(high-low)) end)
    function c.paint() render(high > low and (c.Value-low)/(high-low) or 0, string.format("%.7g", c.Value)) end
    c:Set(range.Default or range.Value or range[3] or (type(o.Value) ~= "table" and o.Value) or o.Default or low, true)
    return c
end

local function choices(values)
    local result, seen = {}, {}
    for _, value in ipairs(type(values) == "table" and values or {}) do
        local kind = type(value)
        if (kind == "string" or (kind == "number" and value == value)) and not seen[value] then
            seen[value] = true
            table.insert(result, value)
        end
    end
    return result
end

local function sameList(a, b)
    if not a or #a ~= #b then return false end
    for index, value in ipairs(a) do if value ~= b[index] then return false end end
    return true
end

function Tab:Dropdown(options)
    local o = options or {}
    local c, w = control(self, o), self.Window
    c.Values, c.Multi = choices(o.Values), o.Multi == true or o.MultiSelect == true
    local trigger = action(w,c.owner,c.row,"",{Size=UDim2.new(1,0,0,33),LayoutOrder=1})
    local summary = label(w, trigger, "", 14, false, nil, { Position = px(9, 0),
        Size = UDim2.new(1, -42, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd })
    icon(w, trigger, "chevron", 18, "Muted", UDim2.new(1, -26, .5, -9))
    c.targets[trigger] = true
    local panel = surface(w,w.popupLayer,"Base",{Name="DropdownPopup",Visible=false,Active=true,ZIndex=2},8)
    finish(w,panel,"Raised")
    c.popupPanel = panel
    local search = textBox(w, c.owner, panel, "Buscar opción…", { Position = px(4,4), Size = UDim2.new(1,-8,0,30) })
    c.targets[search] = true
    local list = scroll(w, panel, { Position = px(4,39), Size = UDim2.new(1,-8,1,-43) })
    stack(list, 4)
    local optionsScope
    local rows = {}
    local function selected(value)
        if c.Multi then return table.find(c.Value or {}, value) ~= nil end
        return c.Value == value
    end
    function c.paint()
        if c.Multi then
            local names = {}
            for _, value in ipairs(c.Value) do table.insert(names, tostring(value)) end
            summary.Text = #names > 0 and table.concat(names, ", ") or "Seleccionar"
        else
            summary.Text = copyText(c.Value, "Seleccionar")
        end
        for value, row in pairs(rows) do
            local active = selected(value)
            row.check.Visible, row.light.Visible = active, active
            local role = active and "Selected" or "Field"
            w:_bind(row.hit,"BackgroundColor3",role)
            w:_bind(row.text,"TextColor3",active and "SelectedText" or "Text")
        end
    end
    function c:Set(value, silent, force)
        if self.Destroyed then return self end
        if self.Multi then
            local values = choices(type(value) == "table" and value or { value })
            local unchanged = sameList(self.Value, values)
            self:_commit(values, silent, sameList)
            if force and unchanged and not silent then callback(self.Callback, self:Get()) end
            return self
        end
        local unchanged = self.Value == value
        self:_commit(value, silent)
        if force and unchanged and not silent then callback(self.Callback, self:Get()) end
        return self
    end
    local function rebuild()
        if optionsScope then clean(optionsScope) end
        optionsScope = childScope(c.owner)
        for _, child in ipairs(list:GetChildren()) do
            if child:IsA("GuiObject") then
                for _, item in ipairs(child:GetDescendants()) do w:_cancel(item) end
                w:_cancel(child)
                c.targets[child] = nil
                child:Destroy()
            end
        end
        table.clear(rows)
        local needle = string.lower(search.Text)
        local count = 0
        for index, value in ipairs(c.Values) do
            if not string.find(string.lower(tostring(value)), needle, 1, true) then continue end
            if count >= 180 then break end
            local hit = action(w, optionsScope, list, "", { LayoutOrder = index, Size = UDim2.new(1,-2,0,31) })
            hit.Active, hit.Selectable = not c.Locked, not c.Locked
            c.targets[hit] = true
            rows[value] = {
                hit = hit, light = selectionLight(w,hit),
                text = label(w, hit, tostring(value), 14, false, nil, { Position = px(9, 0),
                    Size = UDim2.new(1, -40, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd }),
                check = icon(w, hit, "success", 17, "Accent", UDim2.new(1, -25, .5, -8)),
            }
            count += 1
            listen(optionsScope, hit.Activated, function()
                if c.Locked then return end
                if c.Multi then
                    local nextValue = c:Get()
                    local existing = table.find(nextValue, value)
                    if existing then table.remove(nextValue, existing) else table.insert(nextValue, value) end
                    c:Set(nextValue)
                else
                    c:Set(value)
                    c:Close()
                end
            end)
        end
        if count == 0 then label(w, list, "Sin resultados", 13, false, "Muted") end
        list.CanvasPosition = Vector2.zero
        c.paint()
    end
    function c:Refresh(values)
        self.Values = choices(values)
        rebuild()
        return self
    end
    function c:Open()
        if self.Locked or self.Destroyed then return self end
        if self.expanded then return self:Close() end
        if w:_showPopup(trigger,panel,185,function()
            self.expanded = false
            if w.openDropdown == self then w.openDropdown = nil end
        end,self.tab.scrollHost or self.tab.scroller) then
            self.expanded = true
            w.openDropdown = self
        end
        return self
    end
    function c:Close()
        if w.openDropdown == self then w:_closePopup() end
        return self
    end
    c:Set(o.Value or o.Default, true)
    rebuild()
    listen(c.owner, search:GetPropertyChangedSignal("Text"), rebuild)
    listen(c.owner, trigger.Activated, function()
        if c.Locked then return end
        if c.expanded then c:Close() else c:Open() end
    end)
    return c
end

local function dialog(w, owner, title, subtitle, width, height, alignToContent)
    w:_closePopup()
    if w.dismissModal then w.dismissModal() end
    if w.finishDialog then w.finishDialog() end
    if w.Destroyed or not w.Opened then return nil end
    local focused=Input:GetFocusedTextBox()
    if focused and focused:IsDescendantOf(w.panel) then focused:ReleaseFocus(false) end
    w:_endGesture(false)
    if w.dismissModal then w.dismissModal() end
    local layer = make("TextButton",w.panel,{Name="ModalVeil",Text="",AutoButtonColor=false,
        Active=true,Modal=true,Selectable=false,Size=full,ZIndex=12,
        BackgroundColor3=rgb(0,0,0),BackgroundTransparency=.37})
    local shell = make("Frame",layer,{AnchorPoint=Vector2.new(.5,.5)})
    depth(shell,14,3)
    local dialogFace = make("CanvasGroup",shell,{Size=full,GroupTransparency=.28})
    local card = surface(w,dialogFace,"Base",{Name="ToolDialog",Size=full,Active=true,ClipsDescendants=true},14)
    finish(w,card,"Raised")
    local scope = childScope(owner)
    local header = surface(w,card,"Raised",{ClipsDescendants=true})
    finish(w,header,"Header")
    artworkLayer(w,header,"header_ribbon",UDim2.new(.25,20,0,0),px(321,46),Enum.ScaleType.Fit,.24)
    mark(w,header,43,UDim2.new(0,8,.5,-22),false)
    label(w,header,title,17,true,"Text",{Position=px(53,6),Size=UDim2.new(1,-102,0,23),
        TextTruncate=Enum.TextTruncate.AtEnd})
    label(w,header,subtitle,12,false,"Muted",{Position=px(53,28),Size=UDim2.new(1,-102,0,17),
        TextTruncate=Enum.TextTruncate.AtEnd})
    local body = make("Frame",card,{ClipsDescendants=true})
    local footer = make("Frame",card,{})
    local dead = false
    local function release()
        if dead then return end
        dead = true
        if w.gesture and w.gesture.owner==scope then w:_endGesture(false) end
        local box=Input:GetFocusedTextBox()
        if box and box:IsDescendantOf(layer) then box:ReleaseFocus(false) end
        clean(scope)
        for _, descendant in ipairs(layer:GetDescendants()) do w:_cancel(descendant) end
        if w.dismissModal == release then w.dismissModal = nil end
        layer.Active,layer.Interactable = false,false
        local function finalize()
            w:_cancel(dialogFace)
            layer:Destroy()
            if w.finishDialog == finalize then w.finishDialog = nil end
        end
        w.finishDialog = finalize
        if w.Opened and not w.Destroyed then
            w:_animate(dialogFace,.13,{GroupTransparency=1},0,finalize)
        else
            finalize()
        end
    end
    local function fit()
        local size = w.panel.Size
        local bounds = Vector2.new(size.X.Offset,size.Y.Offset)
        local short = bounds.Y < 415
        local cardHeight = math.max(1,math.min(height,bounds.Y-(short and 48 or 32)))
        local cardWidth = math.max(1,math.min(width,bounds.X-32, short and 468 or width))
        local top, bottom = short and 45 or 52, short and 32 or 36
        shell.Size=px(cardWidth,cardHeight)
        local center = bounds.X/2
        if alignToContent then
            local margin = math.min(16,(bounds.X-cardWidth)/2)
            center = math.min(center + w.body.Position.X.Offset/2, bounds.X-cardWidth/2-margin)
        end
        shell.Position=UDim2.new(0,center,.5,0)
        header.Size=UDim2.new(1,0,0,top)
        body.Position=px(10,top+7)
        body.Size=UDim2.new(1,-20,1,-top-bottom-22)
        footer.Position=UDim2.new(0,10,1,-bottom-8)
        footer.Size=UDim2.new(1,-20,0,bottom)
    end
    listen(scope,w.panel:GetPropertyChangedSignal("Size"),fit)
    listen(scope,w.body:GetPropertyChangedSignal("Position"),fit)
    windowAction(w,scope,header,"error",7,release)
    w.dismissModal = release
    fit()
    local scale=make("UIScale",shell,{Scale=.975})
    w:_animate(scale,.18,{Scale=1})
    w:_animate(dialogFace,.18,{GroupTransparency=0})
    return body,footer,release,scope
end

local function footerButton(w, scope, parent, title, right, primary)
    return action(w,scope,parent,title,{Size=UDim2.new(.5,-4,1,0),
        Position=UDim2.new(right and .5 or 0,right and 4 or 0,0,0)},primary)
end

local function pointer(w, owner, target, update, scrollHost)
    w:_gesture(owner,target,update,nil,function(point)
        if scrollHost then
            local previous = scrollHost.ScrollingEnabled
            scrollHost.ScrollingEnabled = false
            w.gesture.restore = function() scrollHost.ScrollingEnabled = previous end
        end
        update(point)
        return true
    end)
end

local function fraction(point, frame)
    local delta = point-frame.AbsolutePosition
    local size=frame.AbsoluteSize
    return math.clamp(delta.X/math.max(1,size.X),0,1),math.clamp(delta.Y/math.max(1,size.Y),0,1)
end

function Tab:Colorpicker(options)
    local o = options or {}
    local c,w = control(self,o), self.Window
    local hit = action(w,c.owner,c.row,"",{LayoutOrder=1,Size=UDim2.new(1,0,0,42)})
    local sample = make("Frame",hit,{Position=px(8,8),Size=px(26,26),BackgroundTransparency=0})
    corner(sample,6)
    local valueText = label(w,hit,"",14,true,"Text",{Position=px(44,0),Size=UDim2.new(1,-76,1,0)})
    icon(w,hit,"chevron",16,"Muted",UDim2.new(1,-25,.5,-8))
    c.targets[hit]=true
    function c.paint()
        sample.BackgroundColor3=c.Value
        valueText.Text="#"..c.Value:ToHex()
    end
    function c:Set(value,silent)
        if typeof(value)=="Color3" then self:_commit(value,silent) end
        return self
    end
    function c:Close()
        if self.closePicker then self.closePicker(); self.closePicker=nil end
        return self
    end
    function c:Open()
        if self.Locked or self.Destroyed then return self end
        local body,footer,release,owner=dialog(w,self.owner,copyText(o.Title,"Visuales"),"Selector de color",435,404)
        if not body then return self end
        self.closePicker=release
        local h,s,v=self.Value:ToHSV()
        local draft=self.Value
        local viewport=scroll(w,body,{Size=full})
        local stage=make("Frame",viewport,{Size=UDim2.new(1,-5,0,180)})
        local square=make("TextButton",stage,{Text="",AutoButtonColor=false,Size=UDim2.new(.57,-26,1,0),
            BackgroundTransparency=0,ClipsDescendants=true})
        corner(square,10)
        edge(w,square)
        local white=make("Frame",square,{Size=full,BackgroundColor3=rgb(255,255,255),BackgroundTransparency=0})
        local shade=make("Frame",square,{Size=full,BackgroundColor3=rgb(0,0,0),BackgroundTransparency=0})
        make("UIGradient",white,{Transparency=NumberSequence.new(0,1)})
        make("UIGradient",shade,{Rotation=90,Transparency=NumberSequence.new(1,0)})
        local marker=make("Frame",square,{Size=px(13,13),AnchorPoint=Vector2.new(.5,.5)})
        corner(marker,7)
        make("UIStroke",marker,{Color=rgb(255,255,255),Thickness=2})
        local hue=make("TextButton",stage,{Text="",AutoButtonColor=false,Position=UDim2.new(.57,-18,0,0),
            Size=UDim2.new(0,20,1,0),BackgroundTransparency=0,BackgroundColor3=rgb(255,255,255)})
        corner(hue,9)
        local rainbow={}
        for index=0,6 do table.insert(rainbow,ColorSequenceKeypoint.new(index/6,Color3.fromHSV(index/6,1,1))) end
        make("UIGradient",hue,{Color=ColorSequence.new(rainbow),Rotation=90})
        local hueMark=make("Frame",hue,{AnchorPoint=Vector2.new(.5,.5),Size=px(21,5),
            BackgroundColor3=rgb(248,253,251),BackgroundTransparency=0})
        corner(hueMark,3)
        local info=make("Frame",stage,{Position=UDim2.new(.57,10,0,0),Size=UDim2.new(.43,-10,1,0)})
        stack(info,5)
        local swatch=make("Frame",info,{LayoutOrder=1,Size=UDim2.new(1,0,0,41),BackgroundTransparency=0})
        corner(swatch,8)
        local hex=textBox(w,owner,info,"#RRGGBB",{LayoutOrder=2,Size=UDim2.new(1,0,0,35)})
        local boxes={}
        for index,name in ipairs({"H","S","V"}) do
            boxes[index]=textBox(w,owner,info,name,{LayoutOrder=index+2,Size=UDim2.new(1,0,0,29)})
        end
        local function paint()
            draft=Color3.fromHSV(h,s,v)
            square.BackgroundColor3=Color3.fromHSV(h,1,1)
            marker.Position=UDim2.fromScale(math.clamp(s,.04,.96),math.clamp(1-v,.04,.96))
            hueMark.Position=UDim2.fromScale(.5,math.clamp(h,.015,.985))
            swatch.BackgroundColor3=draft
            hex.Text="#"..draft:ToHex()
            boxes[1].Text=string.format("H  %d°",math.round(h*360))
            boxes[2].Text=string.format("S  %d%%",math.round(s*100))
            boxes[3].Text=string.format("V  %d%%",math.round(v*100))
        end
        local function fromColor(color) h,s,v=color:ToHSV();paint() end
        pointer(w,owner,square,function(point)
            local x,y=fraction(point,square)
            s,v=x,1-y
            paint()
        end,viewport)
        pointer(w,owner,hue,function(point)
            local _,y=fraction(point,hue)
            h=math.min(.999999,y)
            paint()
        end,viewport)
        local function readHex()
            local code=hex.Text:match("^#?(%x%x%x%x%x%x)$")
            if code then fromColor(Color3.fromHex(code)) else paint() end
        end
        listen(owner,hex.FocusLost,readHex)
        local numberFields={}
        for index,box in ipairs(boxes) do
            local function readNumber()
                local n=tonumber(box.Text:match("%-?%d+%.?%d*"))
                if n then
                    if index==1 then h=(n%360)/360 elseif index==2 then s=math.clamp(n/100,0,1)
                    else v=math.clamp(n/100,0,1) end
                end
                paint()
            end
            numberFields[box]=readNumber
            listen(owner,box.FocusLost,readNumber)
        end
        local presets={rgb(67,246,174),rgb(70,198,242),rgb(71,103,246),rgb(157,76,240),rgb(232,70,184),
            rgb(241,88,106),rgb(250,144,87),rgb(250,214,104)}
        local strip=make("Frame",viewport,{Position=px(0,187),Size=UDim2.new(1,-5,0,54)})
        label(w,strip,"Preajustes",12,true,"Text")
        for index,color in ipairs(presets) do
            local pick=action(w,owner,strip,"",{Position=UDim2.new((index-1)/#presets,0,0,21),
                Size=UDim2.new(1/#presets,-4,0,32)})
            local paintChip=make("Frame",pick,{Position=px(2,2),Size=UDim2.new(1,-4,1,-4),
                BackgroundColor3=color,BackgroundTransparency=0})
            corner(paintChip,6)
            listen(owner,pick.Activated,function() fromColor(color) end)
        end
        viewport.AutomaticCanvasSize=Enum.AutomaticSize.None
        viewport.CanvasSize=px(0,245)
        local cancel=footerButton(w,owner,footer,"Cancelar",false,false)
        local apply=footerButton(w,owner,footer,"Aplicar",true,true)
        listen(owner,cancel.Activated,function() c:Close() end)
        listen(owner,apply.Activated,function()
            local focused=Input:GetFocusedTextBox()
            if focused == hex then readHex() end
            if numberFields[focused] then numberFields[focused]() end
            c:Close()
            if not c.Locked then c:Set(draft) end
        end)
        paint()
        return self
    end
    c:Set(o.Value or o.Default or w.theme.Accent,true)
    listen(c.owner,hit.Activated,function() c:Open() end)
    return c
end
Tab.ColorPicker = Tab.Colorpicker

local function normalizeItems(items)
    local result,seen = {},{}
    for _, item in ipairs(type(items)=="table" and items or {}) do
        if type(item)=="table" and (type(item.Id)=="string" or type(item.Id)=="number" and item.Id==item.Id)
            and not seen[item.Id] then
            seen[item.Id] = true
            table.insert(result,item)
        end
    end
    return result
end

local function itemWithId(items,id)
    for _, item in ipairs(items) do if item.Id==id then return item end end
    return nil
end

local function avatarImage(value)
    return type(value)=="string" and (value:match("^rbxassetid://%d+$")
        or value:match("^rbxthumb://.+") or value:match("^rbxasset://.+"))
end

local function artwork(w, parent, item, pos, size, isPreview)
    local frame = surface(w,parent,"Field",{Position=pos,Size=size,ClipsDescendants=true},8)
    if not item then return frame end
    local thumbnail = isPreview and avatarImage(item.Preview) and item.Preview or item.Thumbnail
    if avatarImage(thumbnail) then
        make("ImageLabel",frame,{Name="AvatarImage",Size=full,Image=thumbnail,ScaleType=Enum.ScaleType.Fit})
        return frame
    end
    local tone = typeof(item.Tint)=="Color3" and item.Tint or rgb(70,210,161)
    if item.Art=="Avatar" then
        local portrait = make("Frame",frame,{
            AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=full,
        })
        make("UIAspectRatioConstraint",portrait,{AspectRatio=1,AspectType=Enum.AspectType.FitWithinMaxSize})
        local avatar = {
            {.39,.12,.22,.23, false}, {.32,.36,.36,.30,true}, {.20,.37,.11,.29,true}, {.69,.37,.11,.29,true},
            {.34,.67,.15,.25,true}, {.51,.67,.15,.25,true},
        }
        for _, part in ipairs(avatar) do
            local block=make("Frame",portrait,{Position=UDim2.fromScale(part[1],part[2]),Size=UDim2.fromScale(part[3],part[4]),
                BackgroundColor3=part[5] and tone or rgb(212,221,218),BackgroundTransparency=0})
            corner(block,3)
            gradient(block,rgb(255,255,255),rgb(104,138,137))
        end
    elseif item.Art=="Swatch" then
        w.bindings[frame].BackgroundColor3=nil
        frame.BackgroundColor3 = rgb(255,255,255)
        gradient(frame, tone, rgb(9,19,35),25)
        for index=1,3 do
            local band=make("Frame",frame,{Position=UDim2.fromScale(-.15,.12+index*.18),Size=UDim2.fromScale(1.3,.12),
                Rotation=-9,BackgroundColor3=tone:Lerp(rgb(231,255,243),.42),BackgroundTransparency=.46+index*.07})
            corner(band,5)
        end
    else
        icon(w,frame,"image",22,"Muted",UDim2.new(.5,-11,.5,-11))
    end
    return frame
end

local function filteredItems(items, query)
    local filtered={}
    local needle=string.lower(query)
    for _,item in ipairs(items) do
        local combined=string.lower(copyText(item.Title).." "..copyText(item.Desc).." "..tostring(item.Id))
        if string.find(combined,needle,1,true) then table.insert(filtered,item) end
    end
    return filtered
end

local function clearRows(w, container)
    for _, row in ipairs(container:GetChildren()) do
        if row:IsA("GuiObject") then
            for _, desc in ipairs(row:GetDescendants()) do w:_cancel(desc) end
            w:_cancel(row)
            row:Destroy()
        end
    end
end

function Tab:Gallery(options)
    local o,w=options or {},self.Window
    local c=control(self,o)
    c.Items=normalizeItems(o.Items)
    local pane=make("Frame",c.row,{Name="OutfitPane",LayoutOrder=1,Size=UDim2.new(1,0,0,245)})
    local scrollHost=self.scrollHost or self.scroller
    local search=textBox(w,c.owner,pane,"Buscar por nombre o ID…",{Size=UDim2.new(.64,-6,0,38)})
    local grid=scroll(w,pane,{Name="OutfitGrid"})
    local tiles=make("UIGridLayout",grid,{CellPadding=px(5,5),SortOrder=Enum.SortOrder.LayoutOrder})
    local empty=label(w,pane,"Sin resultados",13,true,"Muted",{
        Position=px(3,53),Size=UDim2.new(.62,0,0,30),Visible=false,TextWrapped=true,
    })
    local preview=surface(w,pane,"Field",{Name="OutfitPreview",Position=UDim2.fromScale(.64,0),Size=UDim2.fromScale(.36,1)},10)
    finish(w,preview,"Raised")
    local previewTitle=label(w,preview,"Vista previa",13,true,"Text",{Position=px(8,3),Size=UDim2.new(1,-16,0,18)})
    local previewName=label(w,preview,"",12,false,"Muted",{Position=px(8,19),Size=UDim2.new(1,-16,0,16),
        TextTruncate=Enum.TextTruncate.AtEnd})
    local apply=action(w,c.owner,preview,"Aplicar",{Position=UDim2.new(0,7,1,-40),Size=UDim2.new(1,-14,0,34)},true)
    c.targets[search],c.targets[apply]=true,true
    local sketch, shownItem, rowOwner
    local rows={}
    function c.paint()
        local current=itemWithId(c.Items,c.Value)
        if not sketch or shownItem~=current then
            if sketch then sketch:Destroy() end
            sketch=artwork(w,preview,current,px(7,36),UDim2.new(1,-14,1,-80),true)
            shownItem=current
        end
        previewName.Text=current and copyText(current.Title,tostring(current.Id)) or "Sin selección"
        apply.Active=current~=nil and not c.Locked and not c.statusText
        apply.TextTransparency=apply.Active and 0 or .33
        for id, row in pairs(rows) do
            local active = id==c.Value
            row.Hint.Visible,row.Light.Visible = active,active
            w:_bind(row.Hit,"BackgroundColor3",active and "Selected" or "Field")
        end
    end
    function c:Set(value,silent)
        local item=itemWithId(self.Items,value)
        return self:_commit(item and item.Id or nil,silent)
    end
    local function rebuild()
        if rowOwner then clean(rowOwner) end
        rowOwner=childScope(c.owner)
        for _, row in pairs(rows) do c.targets[row.Hit]=nil end
        table.clear(rows)
        clearRows(w,grid)
        local items=filteredItems(c.Items,search.Text)
        empty.Text=c.statusText or "Sin resultados"
        empty.Visible=c.statusText~=nil or #items==0
        grid.Visible=c.statusText==nil
        w:_bind(empty,"TextColor3",c.statusKind=="error" and "Text" or "Muted")
        for index=1,math.min(c.statusText and 0 or #items,120) do
            local item=items[index]
            local hit=action(w,rowOwner,grid,"",{LayoutOrder=index})
            local light=selectionLight(w,hit)
            local thumb=artwork(w,hit,item,px(4,4),UDim2.new(1,-8,1,-26))
            local hint=icon(w,thumb,"success",12,"Accent",UDim2.new(1,-16,0,3))
            label(w,hit,copyText(item.Title,tostring(item.Id)),12,false,"Text",{
                Position=UDim2.new(0,5,1,-20),Size=UDim2.new(1,-9,0,18),TextTruncate=Enum.TextTruncate.AtEnd})
            c.targets[hit]=true
            hit.Active=not c.Locked
            rows[item.Id]={Hit=hit,Hint=hint,Light=light}
            listen(rowOwner,hit.Activated,function() if not c.Locked then c:Set(item.Id) end end)
        end
        grid.CanvasPosition=Vector2.zero
        c.paint()
    end
    function c:SetStatus(status, message)
        if self.Destroyed then return self end
        assert(status == "ready" or status == "loading" or status == "error", "Unknown gallery status")
        self.statusKind = status
        self.statusText = status ~= "ready" and copyText(message,status=="loading" and "Cargando…" or "No se pudo cargar") or nil
        rebuild()
        return self
    end
    function c:Refresh(items)
        if self.Destroyed then return self end
        self.Items=normalizeItems(items)
        if not itemWithId(self.Items,self.Value) then self.Value=nil end
        if sketch then sketch:Destroy(); sketch = nil end
        rebuild()
        return self
    end
    local function fit()
        local scale = w.interfaceScale
        local width = pane.AbsoluteSize.X/scale
        -- CanvasPosition is expressed in layout pixels.
        local top = (pane.AbsolutePosition.Y-scrollHost.AbsolutePosition.Y)/scale+scrollHost.CanvasPosition.Y
        local height = math.clamp(scrollHost.AbsoluteSize.Y/scale-math.max(0,top)-16,120,280)
        if width<330 then
            local narrowHeight = math.max(height,275)
            if pane.Size.Y.Offset~=narrowHeight then pane.Size=UDim2.new(1,0,0,narrowHeight) end
            search.Size=UDim2.new(1,0,0,32)
            grid.Position,grid.Size=px(0,38),UDim2.new(1,0,0,100)
            empty.Position,empty.Size=px(4,42),UDim2.new(1,-8,0,28)
            preview.Position,preview.Size=px(0,145),UDim2.new(1,0,1,-145)
            previewTitle.TextSize=13
            local count = width>=216 and 3 or 2
            tiles.CellSize=px(math.max(1,math.floor((width-count*5)/count)),86)
            tiles.FillDirectionMaxCells=count
            return
        end
        local split = width < 360 and .58 or .64
        local gridWidth = math.max(1,math.floor(width*split)-6)
        local columns = math.clamp(math.floor((gridWidth+5)/65),1,4)
        local cellWidth = math.max(1,math.floor((gridWidth-(columns-1)*5-3)/columns))
        if pane.Size.Y.Offset~=height then pane.Size=UDim2.new(1,0,0,height) end
        search.Size=UDim2.new(split,-6,0,32)
        grid.Position=px(0,38)
        grid.Size=UDim2.new(split,-6,1,-38)
        empty.Position=px(3,40)
        empty.Size=UDim2.new(split,-9,0,28)
        preview.Position=UDim2.fromScale(split,0)
        preview.Size=UDim2.fromScale(1-split,1)
        previewTitle.Text="Vista previa"
        previewTitle.TextSize=13
        tiles.CellSize=px(cellWidth,math.clamp(cellWidth+12,68,103))
        tiles.FillDirectionMaxCells=columns
    end
    listen(c.owner,pane:GetPropertyChangedSignal("AbsoluteSize"),fit)
    listen(c.owner,pane:GetPropertyChangedSignal("AbsolutePosition"),fit)
    listen(c.owner,scrollHost:GetPropertyChangedSignal("AbsoluteSize"),fit)
    listen(c.owner,search:GetPropertyChangedSignal("Text"),rebuild)
    listen(c.owner,apply.Activated,function()
        local item=itemWithId(c.Items,c.Value)
        if not c.Locked and not c.statusText and item then callback(o.OnApply,item) end
    end)
    c.Value=itemWithId(c.Items,o.Value) and o.Value or (c.Items[1] and c.Items[1].Id)
    fit()
    rebuild()
    return c
end

function Tab:Catalog(options)
    local o,w=options or {},self.Window
    local c=control(self,o)
    c.Items=normalizeItems(o.Items)
    local trigger=action(w,c.owner,c.row,"",{Size=UDim2.new(1,0,0,42),LayoutOrder=1})
    local caption=label(w,trigger,"",14,true,"Text",{Position=px(9,0),Size=UDim2.new(1,-44,1,0),
        TextTruncate=Enum.TextTruncate.AtEnd})
    icon(w,trigger,"arrow",16,"Accent",UDim2.new(1,-25,.5,-8))
    c.targets[trigger]=true
    function c.paint()
        local item=itemWithId(c.Items,c.Value)
        caption.Text=item and ("Catálogo · "..copyText(item.Title,tostring(item.Id))) or "Abrir catálogo"
    end
    function c:Set(value,silent)
        local item=itemWithId(self.Items,value)
        return self:_commit(item and item.Id or nil,silent)
    end
    function c:Close()
        if self.closeCatalog then self.closeCatalog();self.closeCatalog=nil end
        return self
    end
    function c:Refresh(items)
        if self.Destroyed then return self end
        self.Items=normalizeItems(items)
        if not itemWithId(self.Items,self.Value) then self.Value=nil end
        self:Close()
        self.paint()
        return self
    end
    function c:Open()
        if self.Locked or self.Destroyed then return self end
        local body,footer,release,owner=dialog(w,self.owner,copyText(o.DialogTitle,"Seleccionar elemento"),
            copyText(o.DialogDesc,"Explora el catálogo y selecciona una opción."),532,380,true)
        if not body then return self end
        self.closeCatalog=release
        local draft=self.Value
        local showing=false
        local search=textBox(w,owner,body,"Buscar…",{Size=UDim2.new(1,0,0,34)})
        local list=scroll(w,body,{Position=px(0,40),Size=UDim2.new(1,0,1,-40)})
        stack(list,4)
        local preview=surface(w,body,"Rail",{Position=px(0,0),Size=full,Visible=false},10)
        local previewButton=footerButton(w,owner,footer,"Vista previa",false,false)
        local apply=footerButton(w,owner,footer,"Aplicar",true,true)
        local rowOwner
        local function paintPreview()
            local item=itemWithId(c.Items,draft)
            clearRows(w,preview)
            if item then
                artwork(w,preview,item,px(6,6),UDim2.new(1,-12,1,-57))
                label(w,preview,copyText(item.Title,tostring(item.Id)),15,true,"Text",{
                    Position=UDim2.new(0,9,1,-49),Size=UDim2.new(1,-16,0,22),TextTruncate=Enum.TextTruncate.AtEnd})
                label(w,preview,copyText(item.Desc),12,false,"Muted",{
                    Position=UDim2.new(0,9,1,-26),Size=UDim2.new(1,-16,0,19),TextTruncate=Enum.TextTruncate.AtEnd})
            end
            preview.Visible, list.Visible, search.Visible = showing, not showing, not showing
            previewButton.Text=showing and "Volver a la lista" or "Vista previa"
            apply.Active=item~=nil
            previewButton.Active=item~=nil
            apply.TextTransparency=item and 0 or .33
            previewButton.TextTransparency=item and 0 or .33
        end
        local function rebuild()
            if rowOwner then clean(rowOwner) end
            rowOwner=childScope(owner)
            clearRows(w,list)
            local items=filteredItems(c.Items,search.Text)
            if #items==0 then label(w,list,"Sin resultados",13,false,"Muted") end
            local rows={}
            for index=1,math.min(#items,120) do
                local item=items[index]
                local hit=action(w,rowOwner,list,"",{LayoutOrder=index,Size=UDim2.new(1,-4,0,46)})
                local light=selectionLight(w,hit)
                artwork(w,hit,item,px(5,4),px(64,38))
                label(w,hit,copyText(item.Title,tostring(item.Id)),14,true,"Text",{
                    Position=px(78,4),Size=UDim2.new(1,-110,0,22),TextTruncate=Enum.TextTruncate.AtEnd})
                label(w,hit,copyText(item.Desc),12,false,"Muted",{
                    Position=px(78,23),Size=UDim2.new(1,-105,0,18),TextTruncate=Enum.TextTruncate.AtEnd})
                local selection=icon(w,hit,"success",14,"Accent",UDim2.new(1,-25,.5,-7))
                rows[item.Id]={Hit=hit,Selection=selection,Light=light}
                local function select()
                    draft=item.Id
                    for id,row in pairs(rows) do
                        row.Selection.Visible, row.Light.Visible = id==draft, id==draft
                        w:_bind(row.Hit,"BackgroundColor3",id==draft and "Selected" or "Field")
                    end
                    paintPreview()
                end
                listen(rowOwner,hit.Activated,select)
            end
            for id,row in pairs(rows) do
                row.Selection.Visible, row.Light.Visible = id==draft, id==draft
                w:_bind(row.Hit,"BackgroundColor3",id==draft and "Selected" or "Field")
            end
            list.CanvasPosition=Vector2.zero
            paintPreview()
        end
        listen(owner,search:GetPropertyChangedSignal("Text"),rebuild)
        listen(owner,previewButton.Activated,function()
            local item=itemWithId(c.Items,draft)
            if not item then return end
            showing=not showing
            paintPreview()
            if showing then callback(o.OnPreview,item) end
        end)
        listen(owner,apply.Activated,function()
            local item=itemWithId(c.Items,draft)
            if not item or c.Locked then return end
            c:Close()
            c:Set(item.Id)
            callback(o.OnApply,item)
        end)
        rebuild()
        return self
    end
    c:Set(o.Value,true)
    listen(c.owner,trigger.Activated,function() c:Open() end)
    return c
end

function Window:Notify(options)
    if self.Destroyed then return nil end
    local o = options or {}
    local kind = string.lower(copyText(o.Type, "info"))
    local tint = ({ info = "Muted", success = "Accent", warning = "Muted", error = "Text" })[kind]
    if not tint then kind, tint = "info", "Muted" end
    self.noticeOrder = (self.noticeOrder or 0) + 1
    local shell = make("Frame", self.tray, { LayoutOrder = self.noticeOrder, Size = UDim2.new(1, 0, 0, 72) })
    local item = make("CanvasGroup", shell, { Size = full,
        GroupTransparency = 1, Position = px(-12, 0) })
    item.BackgroundTransparency = 0
    self:_bind(item, "BackgroundColor3", "Rail")
    corner(item, self.radius)
    edge(self, item)
    icon(self, item, kind, 18, tint, px(10, 12))
    local copy = make("Frame", item, { Position = px(36, 0), Size = UDim2.new(1, -46, 0, 0), AutomaticSize = VERTICAL })
    pad(copy, 0, 8)
    stack(copy, 2)
    label(self, copy, copyText(o.Title, "Ryou"),
        14, true, nil, { LayoutOrder = 0, TextTruncate = Enum.TextTruncate.AtEnd })
    label(self, copy, copyText(o.Content or o.Desc or o.Description), 13, false, "Muted",
        { LayoutOrder = 1, Size = UDim2.new(1, 0, 0, 32), TextWrapped = true, TextTruncate = Enum.TextTruncate.AtEnd })
    local notice = {}
    local timer
    local function remove()
        if timer then task.cancel(timer); timer = nil end
        self:_cancel(item)
        shell:Destroy()
        local at = table.find(self.notices, notice)
        if at then table.remove(self.notices, at) end
    end
    notice.Remove = remove
    function notice:Dismiss()
        if not shell.Parent or self.closing then return end
        self.closing = true
        local w = notice.window
        w:_animate(item, .15, { GroupTransparency = 1, Position = px(-12, 0) }, 0, remove)
    end
    notice.window = self
    local capacity = self.screen.AbsoluteSize.Y < 320 and 1 or 2
    while #self.notices >= capacity do self.notices[1].Remove() end
    table.insert(self.notices, notice)
    self:_animate(item, .21, { GroupTransparency = 0, Position = px(0, 0) })
    timer = task.delay(math.clamp(finite(o.Duration, 3), 1, 10), function()
        timer = nil
        notice:Dismiss()
    end)
    return notice
end

function UI:Notify(options) if self.Window then return self.Window:Notify(options) end; return nil end
function UI:SetTheme(config)
    self._defaultTheme = config
    if self.Window then self.Window:SetTheme(config) end
    return self
end
function UI:GetCurrentTheme()
    if self.Window then return self.Window:GetTheme() end
    local name = type(self._defaultTheme) == "table" and self._defaultTheme.Name or self._defaultTheme
    name = string.lower(tostring(name))
    return (name == "light" or name == "white" or name == "blanco") and "Light" or "Dark"
end
function UI:GetThemes()
    local result = { Dark = {Name="Dark"}, Light = {Name="Light"} }
    for name, preset in pairs(THEME_PRESETS) do
        result[name] = { Name=preset.Base, Accent=preset.Accent }
    end
    return result
end
function UI:GetThemePresets() return table.clone(THEME_ORDER) end
function UI:GetFontStyles() return {"Gotham", "SourceSans", "Arial"} end

return UI
