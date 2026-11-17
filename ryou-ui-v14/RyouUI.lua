-- Ryou UI 14.0.0 | Created by Ryou
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

local UI = { Version = "14.0.0", Variant = "Neo Sidebar" }
local Window, Tab, Control = {}, {}, {}
Window.__index, Tab.__index, Control.__index = Window, Tab, Control

local rgb = Color3.fromRGB
local px = UDim2.fromOffset
local full = UDim2.fromScale(1, 1)
local LEFT = Enum.TextXAlignment.Left
local VERTICAL = Enum.AutomaticSize.Y
local MOUSE, TOUCH = Enum.UserInputType.MouseButton1, Enum.UserInputType.Touch
local DARK = {
    Base = rgb(9, 15, 18), Rail = rgb(15, 22, 25), Field = rgb(23, 33, 37),
    Hover = rgb(29, 46, 47), Edge = rgb(45, 69, 68), Text = rgb(243, 249, 248),
    Muted = rgb(168, 183, 185), Accent = rgb(73, 245, 184), Ink = rgb(4, 23, 17),
    Selected = rgb(19, 61, 48), Raised = rgb(23, 36, 39), AccentHover = rgb(124, 255, 207), LightMint = rgb(126, 255, 209),
}
local LIGHT = {
    Base = rgb(247, 249, 248), Rail = rgb(235, 240, 238), Field = rgb(225, 232, 229),
    Hover = rgb(214, 224, 220), Edge = rgb(182, 194, 189), Text = rgb(25, 39, 35),
    Muted = rgb(66, 83, 77), Accent = rgb(0, 104, 77), Ink = rgb(255, 255, 255),
    Selected = rgb(192, 232, 214), Raised = rgb(246, 250, 248), AccentHover = rgb(0, 76, 57), LightMint = rgb(127, 255, 206),
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
        Text = str, TextSize = size, TextXAlignment = LEFT,
        Font = bold and w.boldFont or w.font, Size = UDim2.new(1, 0, 0, 20),
    }
    for key, value in pairs(props or {}) do settings[key] = value end
    local item = make("TextLabel", parent, settings)
    w:_bind(item, "TextColor3", role or "Text")
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
    logo_glow = { file = "R_HALO_SUAVE_RGBA_1024.png", bytes = 98888 },
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
    local function paint()
        if fallback then fallback.Visible = not image.IsLoaded end
    end
    if fallback then image:GetPropertyChangedSignal("IsLoaded"):Connect(paint) end

    local function apply(id)
        if not image.Parent or not id then return end
        image.Image = id
        paint()
    end
    local function useAlternate()
        if not alternate or not image.Parent then return end
        ImageAssets:Get(alternate, function(replacement)
            if not image.Parent or image.IsLoaded or not replacement then return end
            if alternateLayout then image.Size = alternateLayout end
            apply(replacement)
        end)
    end
    ImageAssets:Get(name, function(id)
        if not image.Parent then return end
        if not id then
            useAlternate()
            return
        end
        apply(id)
        if alternate and not image.IsLoaded then
            task.delay(4, function()
                if image.Parent and not image.IsLoaded then useAlternate() end
            end)
        end
    end)
    return image
end

local function gradient(parent, top, bottom, rotation)
    return make("UIGradient", parent, { Color = ColorSequence.new(top, bottom), Rotation = rotation or 90 })
end

local function mark(w, parent, size, position, large)
    local node = make("Frame", parent, { Name = "RyouMark", Size = px(size, size), Position = position })
    local fallback = label(w, node, "R", math.floor(size*.61), true, "Accent", {
        Size = full, TextXAlignment = Enum.TextXAlignment.Center,
    })
    assetImage(node, large and "logo_hero" or "logo_small", {
        Name = "Logo", AnchorPoint = Vector2.new(.5,.5), Position = UDim2.fromScale(.51,.46),
        Size = large and full or UDim2.fromScale(1.15,1.15), ScaleType = Enum.ScaleType.Fit,
    }, fallback, large and "logo_small" or "logo_mono")
    return node
end

local function artworkLayer(w, parent, asset, position, size, mode, alpha)
    local art = assetImage(parent, asset, {
        Name = asset, Position = position, Size = size, ScaleType = mode,
        ImageTransparency = alpha or 0, Visible = w.ThemeName ~= "Light",
    })
    w.art[art] = true
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

local function action(w, owner, parent, text, props, primary)
    local b = make("TextButton", parent, props)
    b.Text, b.TextSize, b.Font = text or "", 14, w.boldFont
    b.AutoButtonColor = false
    b.BackgroundTransparency = 0
    corner(b, w.radius)
    w:_bind(b, "TextColor3", primary and "Ink" or "Text")
    w:_bind(b, "BackgroundColor3", primary and "Accent" or "Field")
    if primary then gradient(b, rgb(255,255,255), rgb(184,228,210), 90) end
    local scale = make("UIScale", b, {})
    local function rest()
        w:_animate(scale, .14, { Scale = 1 })
    end
    listen(owner, b.MouseEnter, function()
        if b.Active then w:_animate(b, .12, { BackgroundColor3 = w.theme[primary and "AccentHover" or "Hover"] }) end
    end)
    listen(owner, b.MouseLeave, function()
        w:_animate(b, .13, { BackgroundColor3 = w.theme[w.bindings[b].BackgroundColor3] })
        rest()
    end)
    listen(owner, b.InputBegan, function(input)
        if b.Active and (input.UserInputType == MOUSE or input.UserInputType == TOUCH) then
            w:_animate(scale, .09, { Scale = .975 })
        end
    end)
    listen(owner, b.InputEnded, rest)
    return b
end

local function textBox(w, owner, parent, placeholder, props)
    local box = make("TextBox", parent, props)
    box.BackgroundTransparency, box.Text = 0, ""
    box.PlaceholderText, box.ClearTextOnFocus = placeholder, false
    box.TextSize, box.Font, box.TextXAlignment = 14, w.font, LEFT
    box.TextTruncate = Enum.TextTruncate.AtEnd
    pad(box, 9, 0)
    corner(box, w.radius)
    w:_bind(box, "BackgroundColor3", "Field")
    w:_bind(box, "TextColor3", "Text")
    w:_bind(box, "PlaceholderColor3", "Muted")
    local line = edge(w, box)
    listen(owner, box.Focused, function()
        w:_animate(line, .15, { Color = w.theme.Accent })
    end)
    listen(owner, box.FocusLost, function()
        w:_animate(line, .15, { Color = w.theme.Edge })
    end)
    return box
end

function Window:_bind(item, property, role)
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
    self:_cancel(item)
    local scale = MOTION[self.motion]
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

function Window:_fit()
    local bounds = self.screen.AbsoluteSize
    if bounds.X <= 0 or bounds.Y <= 0 then return end
    local maximum = Vector2.new(math.max(1, bounds.X - 16), math.max(1, bounds.Y - 16))
    local width = math.clamp(self.desired.X, math.min(MIN_WIDTH, maximum.X), maximum.X)
    local height = math.clamp(self.desired.Y, math.min(MIN_HEIGHT, maximum.Y), maximum.Y)
    self.frame.Size = px(width, height)
    local desired = self.position or bounds / 2
    local center = Vector2.new(
        math.clamp(desired.X, width/2+8, math.max(width/2+8, bounds.X-width/2-8)),
        math.clamp(desired.Y, height/2+8, math.max(height/2+8, bounds.Y-height/2-8)))
    self.frame.Position = px(center.X, center.Y)
    local compact = width < 560
    self.Compact = compact
    local railWidth = compact and 56 or math.clamp(math.floor(width*.185), 121, 200)
    local headerHeight = height < 415 and 58 or 74
    self.header.Size = UDim2.new(1, 0, 0, headerHeight)
    self.content.Position = px(0, headerHeight)
    self.content.Size = UDim2.new(1, 0, 1, -headerHeight)
    self.utilities.Visible = width >= 660
    self.titleGroup.Size = UDim2.new(1, -(width >= 660 and 423 or 192), 0, 26)
    self.subtitleGroup.Size = self.titleGroup.Size - px(0, 7)
    self.rail.Size = UDim2.new(0, railWidth, 1, 0)
    self.body.Position = px(railWidth + 1, 0)
    self.body.Size = UDim2.new(1, -railWidth-1, 1, 0)
    self:_fitLauncher()
    for _, tab in ipairs(self.Tabs) do
        tab.titleLabel.Visible = not compact
        tab.glyph.Position = compact and UDim2.new(.5, -9, .5, -9) or UDim2.new(0, 12, .5, -9)
    end
    for _, group in ipairs(self.groups) do group.label.Visible = not compact end
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
    self.launcher.Visible = self.launcherEnabled and (not self.Opened or outside or self.draggingLauncher == true)
    self.launcher.Active = self.launcher.Visible
end

function Window:_resetEntrance()
    for group, position in pairs(self.entrance) do
        self:_cancel(group)
        group.GroupTransparency, group.Position = 0, position
    end
    self:_cancel(self.brandScale)
    self.brandScale.Scale = 1
    self:_cancel(self.sweep)
    self.sweep.Visible = false
end

function Window:_stage(group, time, delay, x, y)
    local endPosition = self.entrance[group]
    group.GroupTransparency = 1
    group.Position = endPosition + px(x, y)
    self:_animate(group, time, { GroupTransparency = 0, Position = endPosition }, delay)
end

function Window:Open()
    if self.Destroyed or self.Opened then return self end
    self.Opened = true
    local first = not self.hasOpened
    self.hasOpened = true
    local visible = self.panel.Visible
    self.panel.Visible = true
    self.shadow.Visible = true
    self:_fitLauncher()
    self:_resetEntrance()
    if not visible then
        self.panel.GroupTransparency, self.panel.Position = 1, px(0, 11)
    end
    self:_animate(self.panel, first and (self.motion == "Full" and .23 or .43) or .21, { GroupTransparency = 0, Position = px(0, 0) })
    if first and self.motion == "Full" then
        self:_stage(self.brand, .26, .11, -7, 0)
        self.brandScale.Scale = .95
        self:_animate(self.brandScale, .26, { Scale = 1 }, .11)
        self:_stage(self.utilities, .25, .22, 0, 4)
        self:_stage(self.titleGroup, .34, .17, 0, 6)
        self:_stage(self.subtitleGroup, .29, .26, 0, 4)
        self:_stage(self.rail, .31, .23, -9, 0)
        if self.Selected then self:_stage(self.pages, .40, .35, 0, 8) end
        for index, tab in ipairs(self.Tabs) do
            if index > 10 then break end
            self:_stage(tab.shell, .27, .24 + (index-1)*.023, -4, 0)
        end
        self.sweep.Visible = self.ThemeName ~= "Light"
        self.sweep.BackgroundTransparency = .32
        self.sweep.Position = UDim2.new(.21, -33, .65, 0)
        self:_animate(self.sweep, .42, { Position = UDim2.new(.56, 0, .65, 0), BackgroundTransparency = 1 }, .17,
            function() self.sweep.Visible = false end)
    end
    for _, fn in ipairs(self.openedCallbacks) do callback(fn, self) end
    return self
end

function Window:Close()
    if self.Destroyed then return self end
    self.initialCancelled = true
    if not self.Opened then return self:SetOpenButtonVisible(self.launcherEnabled) end
    self.Opened = false
    if self.dismissModal then self.dismissModal() end
    self:_endGesture(false)
    self:_animate(self.launchScale, .12, { Scale = 1 })
    self:_resetEntrance()
    local focused = Input:GetFocusedTextBox()
    if focused and focused:IsDescendantOf(self.panel) then focused:ReleaseFocus(false) end
    self.launcher.Visible = self.launcherEnabled
    self.launcher.Active = self.launcherEnabled
    self:_animate(self.panel, .17, { GroupTransparency = 1, Position = px(0, 8) }, 0, function()
        if not self.Opened then self.panel.Visible = false; self.shadow.Visible = false end
    end)
    for _, fn in ipairs(self.closedCallbacks) do callback(fn, self) end
    return self
end

function Window:Toggle()
    return self.Opened and self:Close() or self:Open()
end

function Window:SetMotion(mode)
    assert(MOTION[mode] ~= nil, "Motion must be Full, Reduced or Off")
    self.motion = mode
    if mode == "Off" then
        for item, animation in pairs(table.clone(self.tweens)) do
            if self.tweens[item] ~= animation then continue end
            self:_cancel(item)
            for property, value in pairs(animation.goal) do item[property] = value end
            if animation.done then animation.done() end
        end
        self:_resetEntrance()
        self:_cancel(self.panel)
        self.panel.Visible = self.Opened
        self.panel.GroupTransparency, self.panel.Position = self.Opened and 0 or 1, px(0, 0)
    end
    return self
end

function Window:SetTheme(theme)
    local config = type(theme) == "table" and theme or { Name = theme }
    local name = string.lower(tostring(config.Name or "Dark"))
    self.ThemeName = (name == "light" or name == "white" or name == "blanco") and "Light" or "Dark"
    self.theme = table.clone(self.ThemeName == "Light" and LIGHT or DARK)
    for art in pairs(self.art) do art.Visible = self.ThemeName ~= "Light" end
    if typeof(config.Background) == "Color3" then self.theme.Base = config.Background end
    if typeof(config.Accent) == "Color3" then
        local brightness = config.Accent.R*.213 + config.Accent.G*.715 + config.Accent.B*.072
        self.theme.Accent = config.Accent
        self.theme.Ink = brightness > .55 and rgb(12, 18, 16) or rgb(255, 255, 255)
    end
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
    if self.dismissModal then self.dismissModal() end
    self:_endGesture(false)
    clean(self.owner)
    while #self.notices > 0 do self.notices[#self.notices].Remove() end
    for item in pairs(self.tweens) do self:_cancel(item) end
    if not self.guiDestroying then self.gui:Destroy() end
    if self.library.Window == self then self.library.Window = nil end
    for _, fn in ipairs(self.destroyCallbacks) do callback(fn, self) end
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
        gap = math.clamp(tonumber(o.Spacing) or 9, 4, 16),
        font = o.Font or Enum.Font.Gotham, boldFont = o.BoldFont or Enum.Font.GothamBold,
        desired = sizeInPixels(o.Size or Vector2.new(1040, 615)), position = o.Position,
        key = o.ToggleKey or KEYBOARD, launcherEnabled = o.Launcher ~= false,
        Tabs = {}, groups = {}, entrance = {}, notices = {}, art = setmetatable({}, {__mode = "k"}),
        tweens = {}, bindings = setmetatable({}, { __mode = "k" }),
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
    w.shadow = make("Frame", w.frame, { Position = px(-7, 5), Size = UDim2.new(1,14,1,8), Visible=false })
    for i=1,4 do
        local layer = make("Frame", w.shadow, {
            Position=px(i*2,i*2), Size=UDim2.new(1,-i*4,1,-i*4),
            BackgroundColor3=rgb(0,0,0), BackgroundTransparency=.90-i*.025,
        })
        corner(layer, 24-i)
    end
    w.panel = make("CanvasGroup", w.frame, { Size = full, Visible = false })
    w.Root = w.panel
    w:_bind(w.panel, "BackgroundColor3", "Base")
    w.panel.BackgroundTransparency = .035
    corner(w.panel, 22)
    local outline = edge(w, w.panel)
    gradient(outline, rgb(218,255,245), rgb(119,200,175), 75)

    local header = surface(w, w.panel, "Rail", { Size = UDim2.new(1, 0, 0, 74), Active = true, ClipsDescendants = true })
    w.header = header
    artworkLayer(w, header, "header_ribbon", UDim2.fromScale(.06,0), UDim2.fromScale(.82,1), Enum.ScaleType.Stretch)
    local rule = surface(w, header, "Edge", { Position = UDim2.new(0, 16, 1, -1), Size = UDim2.new(1, -32, 0, 1) })
    rule.Name = "HeaderRule"
    w.sweep = surface(w, header, "Accent", { Size = px(65, 2), Rotation = -26, Visible = false }, 2)
    w.brand = make("CanvasGroup", header, { Size = px(60, 55), Position = UDim2.new(0, 22, .5, -27) })
    w.brandScale = make("UIScale", w.brand, {})
    mark(w, w.brand, 62, px(-3, -4), false)
    w.titleGroup = make("CanvasGroup", header, { Position = UDim2.new(0, 91, .5, -23), Size = UDim2.new(1, -350, 0, 26) })
    w.subtitleGroup = make("CanvasGroup", header, { Position = UDim2.new(0, 92, .5, 3), Size = UDim2.new(1, -350, 0, 19) })
    w.title = label(w, w.titleGroup, copyText(o.Title, "Ryou UI"), 25, true, nil,
        { Size = full, TextTruncate = Enum.TextTruncate.AtEnd })
    w.subtitle = label(w, w.subtitleGroup, copyText(o.Subtitle or o.Author, "Created by Ryou"), 13, false, "Muted",
        { Size = full, TextTruncate = Enum.TextTruncate.AtEnd })
    w.Title, w.Author = w.title.Text, w.subtitle.Text
    local close = action(w, w.owner, header, "", { Position = UDim2.new(1, -52, .5, -22), Size = px(44, 44) })
    local minimize = action(w, w.owner, header, "", { Position = UDim2.new(1, -99, .5, -22), Size = px(44, 44) })
    icon(w, close, "error", 17, "Text", px(13, 13))
    icon(w, minimize, "minimize", 17, "Text", px(13,13))
    listen(w.owner, close.Activated, function() w:Close() end)
    listen(w.owner, minimize.Activated, function() w:Close() end)

    w.utilities = make("CanvasGroup", header, {
        Position = UDim2.new(1, -320, .5,-22), Size = px(213, 44),
    })
    local badge = surface(w, w.utilities, "Field", { Size = px(112, 34), Position = px(0,5) }, 10)
    edge(w,badge)
    surface(w,badge,"Accent",{Size = px(7,7),Position = px(10,14)}, 4)
    label(w,badge,copyText(o.Badge, "V14 · Stable"),12,true,"Text",{Position=px(24,0),Size=UDim2.new(1,-28,1,0),
        TextTruncate=Enum.TextTruncate.AtEnd})
    local util = type(o.Utilities) == "table" and o.Utilities or {}
    local cloud = action(w, w.owner, w.utilities, "", { Position = px(121,0), Size = px(42,44) })
    local bell = action(w, w.owner, w.utilities, "", { Position = px(169,0), Size = px(42,44) })
    icon(w,cloud,"cloud",19,"Text",px(11,12))
    icon(w,bell,"bell",19,"Text",px(11,12))
    surface(w,bell,"Accent",{ Size=px(5,5), Position=px(32,9) },3)
    listen(w.owner,cloud.Activated,function()
        if util.Cloud then callback(util.Cloud, w) else w:Notify({Title="Ryou UI", Content="Biblioteca visual V14"}) end
    end)
    listen(w.owner,bell.Activated,function()
        if util.Notifications then callback(util.Notifications, w) else w:Notify({Title="Notificaciones", Content="El panel está listo."}) end
    end)
    local content = make("Frame", w.panel, { Position = px(0, 74), Size = UDim2.new(1, 0, 1, -74) })
    w.content = content
    w.rail = make("CanvasGroup", content, { Position = px(0, 0) })
    w.rail.BackgroundTransparency = 0
    w:_bind(w.rail, "BackgroundColor3", "Rail")
    artworkLayer(w, w.rail, "rail_glow", UDim2.fromScale(0,.18), UDim2.fromScale(1,.82), Enum.ScaleType.Stretch)
    w.nav = scroll(w, w.rail, { Size = full })
    pad(w.nav, 11, 15)
    stack(w.nav, 5)
    w.body = make("Frame", content, {ClipsDescendants=true})
    artworkLayer(w, w.body, "background_artwork", UDim2.new(), full, Enum.ScaleType.Crop, .94)
    w.pages = make("CanvasGroup", w.body, { Size = full })
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
        if not w.gesture then w:_animate(w.launchScale,.14,{Scale=1.04}) end
    end)
    listen(w.owner, w.launcher.MouseLeave, function()
        if not w.gesture then w:_animate(w.launchScale,.14,{Scale=1}) end
    end)
    listen(w.owner, w.launcher.Activated, function(event)
        if event and event.UserInputType == Enum.UserInputType.Gamepad1 then w:Toggle() end
    end)
    w.tray = make("Frame", w.screen, { AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 10, 1, -10), Size = UDim2.new(1, -20, 0, 0),
        AutomaticSize = VERTICAL, ZIndex = 20 })
    make("UISizeConstraint", w.tray, { MaxSize = Vector2.new(305, math.huge) })
    stack(w.tray, 6)

    local launchStart
    w:_gesture(w.owner, w.launcher, function(point, gesture)
        if not gesture.moved and (point - gesture.origin).Magnitude < 9 then return end
        gesture.moved = true
        w.draggingLauncher = true
        w.launcherPosition = launchStart + point - gesture.origin
        w:_fitLauncher()
    end, function(gesture)
        w:_animate(w.launchScale, .15, { Scale = 1 })
        if gesture.moved then
            w:_fitLauncher()
        elseif gesture.event.UserInputState ~= Enum.UserInputState.Cancel then
            w:Toggle()
        end
    end, function()
        if not w.launcherEnabled then return false end
        w.gesture.restore = function() w.draggingLauncher = false; w:_fitLauncher() end
        launchStart = Vector2.new(w.launcher.Position.X.Offset, w.launcher.Position.Y.Offset)
        w:_animate(w.launchScale, .09, { Scale = .97 })
        return true
    end)

    local dragStart
    w:_gesture(w.owner, header, function(point, gesture)
        w:SetPosition(dragStart + point - gesture.origin)
    end, nil, function(point)
        local controls = w.utilities.Visible and w.utilities or minimize
        if point.X >= controls.AbsolutePosition.X then return false end
        dragStart = Vector2.new(w.frame.Position.X.Offset, w.frame.Position.Y.Offset)
        return true
    end)
    local sizeStart, resizeOrigin
    w:_gesture(w.owner, w.resize, function(point, gesture)
        local delta = point - gesture.origin
        local bounds = w.screen.AbsoluteSize
        local maximum = Vector2.new(math.max(1, bounds.X-resizeOrigin.X-8), math.max(1, bounds.Y-resizeOrigin.Y-8))
        local final = Vector2.new(
            math.clamp(sizeStart.X + delta.X, math.min(MIN_WIDTH, maximum.X), maximum.X),
            math.clamp(sizeStart.Y + delta.Y, math.min(MIN_HEIGHT, maximum.Y), maximum.Y))
        w.position = resizeOrigin + final/2
        w:SetSize(final)
    end, nil, function()
        sizeStart = w.frame.AbsoluteSize
        resizeOrigin = w.frame.AbsolutePosition - w.screen.AbsolutePosition
        return w.resize.Visible
    end)

    listen(w.owner, Input.InputChanged, function(event)
        local gesture = w.gesture
        if not gesture then return end
        if event == gesture.event or (gesture.event.UserInputType == MOUSE and event.UserInputType == Enum.UserInputType.MouseMovement) then
            gesture.update(Vector2.new(event.Position.X, event.Position.Y), gesture)
        end
    end)
    listen(w.owner, Input.InputEnded, function(event)
        local gesture = w.gesture
        if gesture and (event == gesture.event or (event.UserInputType == MOUSE and gesture.event.UserInputType == MOUSE)) then
            w:_endGesture(true)
        end
    end)
    listen(w.owner, Input.WindowFocusReleased, function()
        w:_endGesture(false)
        w:_animate(w.launchScale, .15, { Scale = 1 })
    end)
    listen(w.owner, Input.InputBegan, function(event, consumed)
        if consumed or Input:GetFocusedTextBox() then return end
        if event.KeyCode == Enum.KeyCode.Escape and w.dismissModal then w.dismissModal(); return end
        if event.KeyCode == w.key then w:Toggle() end
    end)
    listen(w.owner, w.screen:GetPropertyChangedSignal("AbsoluteSize"), function() w:_fit() end)
    listen(w.owner, w.gui.Destroying, function()
        if not w.Destroyed then
            w.guiDestroying = true
            w:Destroy()
        end
    end)
    w:SetTheme(o.Theme or self._defaultTheme or "Dark")
    w:_fit()
    if o.Open == false then
        w:SetOpenButtonVisible(w.launcherEnabled)
    else
        task.defer(function() if not w.Destroyed and not w.hasOpened and not w.initialCancelled then w:Open() end end)
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
    if self.openDropdown then self.openDropdown:Close(true) end
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
        selected.page.GroupTransparency, selected.page.Position = .38, px(5, 0)
        self:_animate(selected.page, .20, { GroupTransparency = 0, Position = px(0, 0) })
    else
        selected.page.GroupTransparency, selected.page.Position = 0, px(0, 0)
    end
    return selected
end

function Window:Tab(options)
    local o = type(options) == "string" and { Title = options } or options or {}
    local name = copyText(o.Title or o.Name, "Pestaña")
    local t = setmetatable({ Window = self, Title = name, Id = o.Id or name, Elements = {} }, Tab)
    self.navOrder = (self.navOrder or 0) + 1
    local slot = make("Frame", self.nav, { Size = UDim2.new(1, 0, 0, 44), LayoutOrder = self.navOrder })
    local shell = make("CanvasGroup", slot, { Size = full })
    t.shell = shell
    self.entrance[shell] = shell.Position
    local hit = action(self, self.owner, shell, "", { Size = full })
    hit.BackgroundTransparency = 1
    t.hit = hit
    t.activeFill = surface(self, hit, "Selected", { Size = full, Visible = false }, 8)
    edge(self,t.activeFill).Transparency = .48
    gradient(t.activeFill,rgb(155,192,181),rgb(255,255,255),22)
    local spill = surface(self,t.activeFill,"Accent",{
        Position=UDim2.fromScale(.15,0),Size=UDim2.fromScale(.85,1),BackgroundTransparency=.55,
    },8)
    make("UIGradient",spill,{
        Transparency=NumberSequence.new({
            NumberSequenceKeypoint.new(0,1), NumberSequenceKeypoint.new(.65,.85), NumberSequenceKeypoint.new(1,.12),
        }),
    })
    t.glyph = icon(self, hit, o.Icon or "grid", 18, "Muted", UDim2.new(0, 12, .5, -9))
    t.marker = surface(self, hit, "Accent", { AnchorPoint = Vector2.new(0, .5),
        Position = UDim2.new(0, 1, .5, 0), Size = px(3, 23), Visible = false }, 2)
    t.titleLabel = label(self, hit, name, 14, true, "Muted", { Position = px(39, 0),
        Size = UDim2.new(1, -45, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd })
    t.page = make("CanvasGroup", self.pages, { Size = full, Visible = false })
    t.scroller = scroll(self, t.page, { Size = full })
    pad(t.scroller, 14, 11)
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
            TextTruncate = Enum.TextTruncate.AtEnd })
    local group = { label = title, window = self, Title = title.Text, ElementFrame = stripe }
    function group:Tab(config) return self.window:Tab(config) end
    function group:Open() stripe.Visible = true; return self end
    function group:Close() stripe.Visible = false; return self end
    table.insert(self.groups, group)
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
    local row = make("Frame", self.scroller, { Size = UDim2.new(1, 0, 0, 26), LayoutOrder = self.order })
    label(w, row, copyText(o.Title or o.Name), 12, true, "Muted", { TextTruncate = Enum.TextTruncate.AtEnd })
    surface(w, row, "Edge", { Position = UDim2.new(0, 0, 1, -1), Size = UDim2.new(1, 0, 0, 1) })
    return self
end

local function insertBlock(tab, class, props)
    tab.order = (tab.order or 0)+1
    props.LayoutOrder = tab.order
    return make(class, tab.scroller, props)
end

function Tab:Banner(options)
    local o, w = options or {}, self.Window
    local preferredHeight = math.clamp(o.Height or 153, 74, 200)
    local large = preferredHeight >= 120
    local banner = insertBlock(self, "Frame", {Size=UDim2.new(1,-3,0,preferredHeight), ClipsDescendants=true})
    banner.BackgroundTransparency=0
    w:_bind(banner,"BackgroundColor3","Rail")
    corner(banner,12)
    edge(w,banner).Transparency=.28
    gradient(banner,rgb(179,205,199),rgb(255,255,255),15)
    artworkLayer(w,banner,"hero_orbits",UDim2.fromScale(.07,0),UDim2.fromScale(.93,1),Enum.ScaleType.Stretch)
    local device = make("Frame", banner, {
        AnchorPoint=Vector2.new(.5,.5), Size=px(220,210),
    })
    local scale = make("UIScale",device,{})
    artworkLayer(w,device,"logo_glow",px(8,0),px(201,210),Enum.ScaleType.Fit,.16)
    mark(w,device,179,px(20,15),true)
    local title = label(w,banner,copyText(o.Title,"Ryou UI"),large and 34 or 21,true,"Text",{
        Position=UDim2.new(0,18,.5,large and -40 or -28),Size=UDim2.new(1,-200,0,large and 41 or 29),
        RichText=true,TextTruncate=Enum.TextTruncate.AtEnd})
    local subtitle = label(w,banner,copyText(o.Subtitle),large and 17 or 13,false,"Muted",{
        Position=UDim2.new(0,19,.5,large and 3 or 2),Size=UDim2.new(1,-200,0,22),
        TextTruncate=Enum.TextTruncate.AtEnd})
    surface(w,banner,"Accent",{Position=UDim2.new(0,19,.5,large and 34 or 23),Size=px(37,3)},2)
    local function fit()
        local width = banner.AbsoluteSize.X
        local short = w.frame.Size.Y.Offset > 0 and w.frame.Size.Y.Offset < 415
        local height = short and math.min(preferredHeight,105) or preferredHeight
        if banner.Size.Y.Offset ~= height then banner.Size = UDim2.new(1,-3,0,height) end
        local narrow = width < 485
        device.Visible = width >= 305
        scale.Scale = math.min(height/145, narrow and .69 or 1.08)
        device.Position = UDim2.new(1,narrow and -73 or (large and -137 or -92),.50,0)
        local reserve = width < 305 and 27 or (narrow and 146 or (large and 245 or 170))
        title.Size = UDim2.new(1,-reserve,0,large and 41 or 29)
        title.TextSize = large and ((narrow or short) and 27 or 36) or 21
        subtitle.Size = UDim2.new(1,-reserve,0,22)
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
    local layout = stack(wrapper,8)
    local columns = {}
    for index=1,count do
        local holder = make("Frame",wrapper,{LayoutOrder=index,Size=UDim2.new(1,0,0,0),AutomaticSize=VERTICAL})
        if o.Cards ~= false then
            holder.BackgroundTransparency=0
            w:_bind(holder,"BackgroundColor3","Rail")
            corner(holder,12)
            edge(w,holder).Transparency=.35
            gradient(holder,rgb(255,255,255),rgb(156,176,169),95)
            pad(holder,10,9)
        end
        stack(holder,7)
        columns[index] = setmetatable({Window=w,scroller=holder,Elements=self.Elements,scrollHost=self.scrollHost or self.scroller},Tab)
    end
    local function fit()
        local compact = wrapper.AbsoluteSize.X < (o.MinWidth or (count == 3 and 570 or 455))
        layout.FillDirection = compact and Enum.FillDirection.Vertical or Enum.FillDirection.Horizontal
        for index, column in ipairs(columns) do
            local ratio = count == 2 and math.clamp(o.Split or .53,.32,.68) or 1/count
            if count == 2 and index == 2 then ratio = 1-ratio end
            column.scroller.Size = UDim2.new(compact and 1 or ratio,compact and 0 or -math.ceil(8*(count-1)/count),0,0)
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
    local row = insertBlock(self,"Frame",{Size=UDim2.new(1,-3,0,48)})
    local layout = stack(row,5)
    layout.FillDirection = Enum.FillDirection.Horizontal
    for index=1,count do
        local value = values[index]
        local cell = surface(w,row,"Field",{Size=UDim2.new(1/count,-4,1,0),LayoutOrder=index},8)
        icon(w,cell,value.Icon or "activity",14,"Accent",UDim2.new(0,6,.5,-7))
        label(w,cell,copyText(value.Value),12,true,"Text",{Position=px(23,5),Size=UDim2.new(1,-26,0,18),
            TextTruncate=Enum.TextTruncate.AtEnd})
        label(w,cell,copyText(value.Text),10,false,"Muted",{Position=px(23,24),Size=UDim2.new(1,-26,0,16),
            TextTruncate=Enum.TextTruncate.AtEnd})
    end
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
        local outline = edge(w,row)
        outline.Transparency = .42
    end
    pad(row, bare and 0 or 10, bare and 2 or 8)
    stack(row, 5)
    local head = make("Frame", row, { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = VERTICAL, LayoutOrder = 0 })
    local iconSize = math.clamp(tonumber(o.IconSize) or 17, 12, 24)
    local inset = o.Icon and iconSize + 8 or 0
    if o.Icon then icon(w, head, o.Icon, iconSize, "Muted", px(0, 2)) end
    c.head = head
    c.copy = make("Frame", head, { Position = px(inset, 0), Size = UDim2.new(1, -inset, 0, 0), AutomaticSize = VERTICAL })
    stack(c.copy, 1)
    c.title = label(w, c.copy, copyText(o.Title or o.Name), 14, true, nil,
        { LayoutOrder = 0, TextWrapped = true, AutomaticSize = VERTICAL, Size = UDim2.new(1, 0, 0, 0) })
    c.title.Visible = c.title.Text ~= ""
    c.desc = label(w, c.copy, copyText(o.Desc or o.Description or o.Content), 13, false, "Muted",
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
    self.title.TextTransparency = locked and .35 or 0
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
    if self.window.openDropdown == self then self.window.openDropdown = nil end
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
    local c = control(self, o, o.Compact)
    local w = self.Window
    if o.Compact then c.head.Visible=false end
    local hit = action(w, c.owner, c.row, copyText(o.Action, o.Compact and c.Title or "Abrir"),
        { Size = UDim2.new(1, 0, 0, 44), LayoutOrder = 1 }, o.Primary == true)
    if o.Compact then
        edge(w,hit).Transparency=.35
        hit.TextTruncate=Enum.TextTruncate.AtEnd
        hit.TextXAlignment=LEFT
        pad(hit,o.Icon and 35 or 10,0)
        if o.Icon then icon(w,hit,o.Icon,16,o.Primary and "Ink" or "Accent",UDim2.new(0,-25,.5,-8)) end
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
    local function slide(point)
        local width = rail.AbsoluteSize.X
        if width > 0 and not c.Locked then update(math.clamp((point.X - rail.AbsolutePosition.X)/width, 0, 1)) end
    end
    w:_gesture(c.owner, area, slide, nil, function(point)
        if c.Locked then return false end
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

local function expandable(w, c, height, onOpen)
    local panel = surface(w,c.row,"Base",{LayoutOrder=2,Size=UDim2.new(1,0,0,0),ClipsDescendants=true,Visible=false},8)
    function c:Open()
        if self.Locked or self.Destroyed or self.expanded then return self end
        self.expanded = true
        panel.Visible = true
        w:_animate(panel, .21, { Size = UDim2.new(1, 0, 0, height) }, 0, onOpen)
        return self
    end
    function c:Close(instant)
        if self.Destroyed or not self.expanded then return self end
        self.expanded = false
        local focused = Input:GetFocusedTextBox()
        if focused and focused:IsDescendantOf(panel) then focused:ReleaseFocus(false) end
        if instant then
            w:_cancel(panel)
            panel.Size, panel.Visible = UDim2.new(1, 0, 0, 0), false
        else
            w:_animate(panel, .17, { Size = UDim2.new(1, 0, 0, 0) }, 0, function() panel.Visible = false end)
        end
        return self
    end
    return panel
end

function Tab:Dropdown(options)
    local o = options or {}
    local c, w = control(self, o), self.Window
    c.Values, c.Multi = choices(o.Values), o.Multi == true or o.MultiSelect == true
    local trigger = action(w, c.owner, c.row, "", { Size = UDim2.new(1, 0, 0, 44), LayoutOrder = 1 })
    local summary = label(w, trigger, "", 14, false, nil, { Position = px(9, 0),
        Size = UDim2.new(1, -42, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd })
    icon(w, trigger, "chevron", 18, "Muted", UDim2.new(1, -26, .5, -9))
    c.targets[trigger] = true
    edge(w,trigger)
    local panel
    panel = expandable(w, c, 195, function()
        task.defer(function()
            if w.Destroyed or c.Destroyed or not c.expanded then return end
            local scroller = c.tab.scrollHost or c.tab.scroller
            local viewportTop = scroller.AbsolutePosition.Y
            local viewportHeight = scroller.AbsoluteWindowSize.Y
            local panelTop = panel.AbsolutePosition.Y
            local visibleHeight = math.min(panel.Size.Y.Offset + 8, math.max(96, viewportHeight - 60))
            local overflow = panelTop + visibleHeight - viewportTop - viewportHeight
            if overflow <= 0 then return end
            local limit = math.max(0, scroller.AbsoluteCanvasSize.Y - viewportHeight)
            local current = scroller.CanvasPosition
            w:_animate(scroller,.23,{CanvasPosition=Vector2.new(current.X,math.min(current.Y+overflow,limit))})
        end)
    end)
    local search = textBox(w, c.owner, panel, "Buscar opción…", { Position = px(2, 2), Size = UDim2.new(1, -4, 0, 42) })
    c.targets[search] = true
    local list = scroll(w, panel, { Position = px(0, 50), Size = UDim2.new(1, 0, 1, -50) })
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
            row.check.Visible = selected(value)
            w:_bind(row.hit,"BackgroundColor3",selected(value) and "Selected" or "Field")
            w:_animate(row.text, .12, { TextColor3 = selected(value) and w.theme.Accent or w.theme.Text })
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
            local hit = action(w, optionsScope, list, "", { LayoutOrder = index, Size = UDim2.new(1, -3, 0, 44) })
            hit.Active, hit.Selectable = not c.Locked, not c.Locked
            c.targets[hit] = true
            rows[value] = {
                hit = hit,
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
    local open = c.Open
    function c:Open()
        if self.expanded then return self:Close() end
        if w.openDropdown and w.openDropdown ~= self then w.openDropdown:Close(true) end
        open(self)
        if self.expanded then w.openDropdown = self end
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
    if w.dismissModal then w.dismissModal() end
    if w.Destroyed or not w.Opened then return nil end
    local focused=Input:GetFocusedTextBox()
    if focused and focused:IsDescendantOf(w.panel) then focused:ReleaseFocus(false) end
    w:_endGesture(false)
    if w.dismissModal then w.dismissModal() end
    local layer = make("TextButton",w.panel,{Name="ModalVeil",Text="",AutoButtonColor=false,
        Active=true,Modal=true,Selectable=false,Size=full,ZIndex=12,
        BackgroundColor3=rgb(0,0,0),BackgroundTransparency=.37})
    local card = surface(w,layer,"Base",{Name="ToolDialog",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),
        Active=true,ClipsDescendants=true},14)
    edge(w,card)
    local scope = childScope(owner)
    local header = surface(w,card,"Rail",{ClipsDescendants=true})
    artworkLayer(w,header,"header_ribbon",UDim2.fromScale(.18,0),UDim2.fromScale(.82,1),Enum.ScaleType.Stretch)
    mark(w,header,43,UDim2.new(0,8,.5,-22),false)
    label(w,header,title,17,true,"Text",{Position=px(53,6),Size=UDim2.new(1,-102,0,23),
        TextTruncate=Enum.TextTruncate.AtEnd})
    label(w,header,subtitle,12,false,"Muted",{Position=px(53,28),Size=UDim2.new(1,-102,0,17),
        TextTruncate=Enum.TextTruncate.AtEnd})
    local close = action(w,scope,header,"",{Position=UDim2.new(1,-45,0,5),Size=px(38,42)})
    icon(w,close,"error",17,"Text",px(10,12))
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
        w:_cancel(layer)
        layer:Destroy()
        if w.dismissModal == release then w.dismissModal = nil end
    end
    local function fit()
        local bounds = w.frame.AbsoluteSize
        local short = bounds.Y < 415
        local cardHeight = math.max(1,math.min(height,bounds.Y-(short and 48 or 32)))
        local cardWidth = math.max(1,math.min(width,bounds.X-32, short and 468 or width))
        local top, bottom = short and 46 or 54, short and 36 or 42
        card.Size=px(cardWidth,cardHeight)
        local center = bounds.X/2
        if alignToContent then
            local margin = math.min(16,(bounds.X-cardWidth)/2)
            center = math.min(center + w.body.Position.X.Offset/2, bounds.X-cardWidth/2-margin)
        end
        card.Position=UDim2.new(0,center,.5,0)
        header.Size=UDim2.new(1,0,0,top)
        body.Position=px(10,top+7)
        body.Size=UDim2.new(1,-20,1,-top-bottom-22)
        footer.Position=UDim2.new(0,10,1,-bottom-8)
        footer.Size=UDim2.new(1,-20,0,bottom)
    end
    listen(scope,w.frame:GetPropertyChangedSignal("AbsoluteSize"),fit)
    listen(scope,w.body:GetPropertyChangedSignal("Position"),fit)
    listen(scope,close.Activated,release)
    w.dismissModal = release
    fit()
    local scale=make("UIScale",card,{Scale=.975})
    w:_animate(scale,.18,{Scale=1})
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

local function artwork(w, parent, item, pos, size)
    local frame = surface(w,parent,"Field",{Position=pos,Size=size,ClipsDescendants=true},8)
    if not item then return frame end
    local thumbnail=item.Thumbnail
    if type(thumbnail)=="string" and (thumbnail:match("^rbxassetid://%d+$") or thumbnail:match("^rbxthumb://")) then
        make("ImageLabel",frame,{Size=full,Image=thumbnail,ScaleType=Enum.ScaleType.Fit})
        return frame
    end
    local tone = typeof(item.Tint)=="Color3" and item.Tint or rgb(70,210,161)
    if item.Art=="Avatar" then
        local avatar = {
            {.39,.12,.22,.23, false}, {.32,.36,.36,.30,true}, {.20,.37,.11,.29,true}, {.69,.37,.11,.29,true},
            {.34,.67,.15,.25,true}, {.51,.67,.15,.25,true},
        }
        for _, part in ipairs(avatar) do
            local block=make("Frame",frame,{Position=UDim2.fromScale(part[1],part[2]),Size=UDim2.fromScale(part[3],part[4]),
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
    local pane=make("Frame",c.row,{LayoutOrder=1,Size=UDim2.new(1,0,0,298)})
    local scrollHost=self.scrollHost or self.scroller
    local search=textBox(w,c.owner,pane,"Buscar por nombre o ID…",{Size=UDim2.new(.64,-6,0,38)})
    local grid=scroll(w,pane,{Position=px(0,46),Size=UDim2.new(.64,-6,1,-46)})
    local tiles=make("UIGridLayout",grid,{CellPadding=UDim2.fromOffset(5,5),SortOrder=Enum.SortOrder.LayoutOrder})
    local empty=label(w,pane,"Sin resultados",13,true,"Muted",{Position=px(3,53),Size=UDim2.new(.62,0,0,30),Visible=false})
    local preview=surface(w,pane,"Field",{Position=UDim2.fromScale(.64,0),Size=UDim2.fromScale(.36,1)},10)
    edge(w,preview)
    local previewTitle=label(w,preview,"Vista previa",13,true,"Text",{Position=px(8,3),Size=UDim2.new(1,-16,0,18)})
    local previewName=label(w,preview,"",12,false,"Muted",{Position=px(8,22),Size=UDim2.new(1,-16,0,19),
        TextTruncate=Enum.TextTruncate.AtEnd})
    local apply=action(w,c.owner,preview,"Aplicar",{Position=UDim2.new(0,7,1,-48),Size=UDim2.new(1,-14,0,41)},true)
    c.targets[search],c.targets[apply]=true,true
    local sketch, rowOwner
    local rows={}
    function c.paint()
        local current=itemWithId(c.Items,c.Value)
        if sketch then sketch:Destroy() end
        sketch=artwork(w,preview,current,px(7,44),UDim2.new(1,-14,1,-99))
        previewName.Text=current and copyText(current.Title,tostring(current.Id)) or "Sin selección"
        apply.Active=current~=nil and not c.Locked and not c.statusText
        apply.TextTransparency=apply.Active and 0 or .55
        for id, row in pairs(rows) do
            row.Hint.Visible=id==c.Value
            w:_bind(row.Hit,"BackgroundColor3",id==c.Value and "Selected" or "Field")
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
        for index=1,math.min(c.statusText and 0 or #items,120) do
            local item=items[index]
            local hit=action(w,rowOwner,grid,"",{LayoutOrder=index})
            local thumb=artwork(w,hit,item,px(4,4),UDim2.new(1,-8,1,-24))
            local hint=icon(w,thumb,"success",12,"Accent",UDim2.new(1,-16,0,3))
            label(w,hit,copyText(item.Title,tostring(item.Id)),11,false,"Text",{
                Position=UDim2.new(0,5,1,-19),Size=UDim2.new(1,-9,0,16),TextTruncate=Enum.TextTruncate.AtEnd})
            c.targets[hit]=true
            hit.Active=not c.Locked
            rows[item.Id]={Hit=hit,Hint=hint}
            listen(rowOwner,hit.Activated,function() if not c.Locked then c:Set(item.Id) end end)
        end
        grid.CanvasPosition=Vector2.zero
        c.paint()
    end
    function c:SetStatus(status, message)
        if self.Destroyed then return self end
        assert(status == "ready" or status == "loading" or status == "error", "Unknown gallery status")
        self.statusText = status ~= "ready" and copyText(message,status=="loading" and "Cargando…" or "No se pudo cargar") or nil
        rebuild()
        return self
    end
    function c:Refresh(items)
        if self.Destroyed then return self end
        self.Items=normalizeItems(items)
        if not itemWithId(self.Items,self.Value) then self.Value=nil end
        rebuild()
        return self
    end
    local function fit()
        local width=pane.AbsoluteSize.X
        local height=math.clamp(scrollHost.AbsoluteSize.Y-132,127,298)
        if pane.Size.Y.Offset~=height then pane.Size=UDim2.new(1,0,0,height) end
        local narrow=width < 408
        local columns=width>=610 and 4 or width>=380 and 3 or 2
        local split=narrow and .57 or .64
        search.Size=UDim2.new(split,-6,0,38)
        grid.Size=UDim2.new(split,-6,1,-46)
        preview.Position=UDim2.fromScale(split,0)
        preview.Size=UDim2.fromScale(1-split,1)
        previewTitle.Text=narrow and "Preview" or "Vista previa"
        tiles.CellSize=UDim2.new(1/columns,-5,0,narrow and 74 or 94)
        tiles.FillDirectionMaxCells=columns
    end
    listen(c.owner,pane:GetPropertyChangedSignal("AbsoluteSize"),fit)
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
            apply.TextTransparency=item and 0 or .55
            previewButton.TextTransparency=item and 0 or .55
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
                artwork(w,hit,item,px(5,4),px(64,38))
                label(w,hit,copyText(item.Title,tostring(item.Id)),14,true,"Text",{
                    Position=px(78,4),Size=UDim2.new(1,-110,0,22),TextTruncate=Enum.TextTruncate.AtEnd})
                label(w,hit,copyText(item.Desc),12,false,"Muted",{
                    Position=px(78,23),Size=UDim2.new(1,-105,0,18),TextTruncate=Enum.TextTruncate.AtEnd})
                local selection=icon(w,hit,"success",14,"Accent",UDim2.new(1,-25,.5,-7))
                rows[item.Id]={Hit=hit,Selection=selection}
                local function select()
                    draft=item.Id
                    for id,row in pairs(rows) do
                        row.Selection.Visible=id==draft
                        w:_bind(row.Hit,"BackgroundColor3",id==draft and "Selected" or "Field")
                    end
                    paintPreview()
                end
                listen(rowOwner,hit.Activated,select)
            end
            for id,row in pairs(rows) do
                row.Selection.Visible=id==draft
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
function UI:GetThemes() return { Dark = { Name = "Dark" }, Light = { Name = "Light" } } end

return UI
