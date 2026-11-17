-- Ryou UI 14.0.0 | Created by Ryou
local Players = game:GetService("Players")
local Input = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local UI = { Version = "14.0.0" }
local Window, Tab, Control = {}, {}, {}
Window.__index, Tab.__index, Control.__index = Window, Tab, Control

local rgb = Color3.fromRGB
local px = UDim2.fromOffset
local full = UDim2.fromScale(1, 1)
local LEFT = Enum.TextXAlignment.Left
local VERTICAL = Enum.AutomaticSize.Y
local MOUSE, TOUCH = Enum.UserInputType.MouseButton1, Enum.UserInputType.Touch
local DARK = {
    Base = rgb(17, 19, 21), Rail = rgb(22, 25, 27), Field = rgb(30, 34, 36),
    Hover = rgb(40, 46, 48), Edge = rgb(59, 66, 68), Text = rgb(238, 242, 241),
    Muted = rgb(168, 180, 178), Accent = rgb(132, 241, 198), Ink = rgb(13, 28, 23),
}
local LIGHT = {
    Base = rgb(247, 249, 248), Rail = rgb(235, 240, 238), Field = rgb(225, 232, 229),
    Hover = rgb(214, 224, 220), Edge = rgb(182, 194, 189), Text = rgb(25, 39, 35),
    Muted = rgb(66, 83, 77), Accent = rgb(0, 104, 77), Ink = rgb(255, 255, 255),
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
    ryou = {{4,3,4,21,3},{4,4,15,4,3},{15,4,20,8,3},{20,8,15,12,3},{10,12,15,12,3},{13,15,20,21,3}},
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
    assert(not icons[name] and not iconAliases[name], "This built-in icon name is reserved")
    assert(type(asset) == "string" and asset:match("^rbxassetid://%d+$"), "Expected an rbxassetid:// URL")
    self._assets = self._assets or {}
    self._assets[name] = asset
    return self
end

function UI:GetIcons()
    local names = {}
    for name in pairs(icons) do table.insert(names, name) end
    for name in pairs(iconAliases) do table.insert(names, name) end
    for name in pairs(self._assets or {}) do table.insert(names, name) end
    table.sort(names)
    return names
end

local function icon(w, parent, name, size, role, position)
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

local function action(w, owner, parent, text, props)
    local b = make("TextButton", parent, props)
    b.Text, b.TextSize, b.Font = text or "", 14, w.boldFont
    b.AutoButtonColor = false
    b.BackgroundTransparency = 0
    corner(b, w.radius)
    w:_bind(b, "TextColor3", "Text")
    w:_bind(b, "BackgroundColor3", "Field")
    local scale = make("UIScale", b, {})
    local function rest()
        w:_animate(scale, .14, { Scale = 1 })
    end
    listen(owner, b.MouseEnter, function()
        if b.Active then w:_animate(b, .12, { BackgroundColor3 = w.theme.Hover }) end
    end)
    listen(owner, b.MouseLeave, function()
        w:_animate(b, .13, { BackgroundColor3 = w.theme.Field })
        rest()
    end)
    listen(owner, b.InputBegan, function(input)
        if b.Active and (input.UserInputType == MOUSE or input.UserInputType == TOUCH) then
            w:_animate(scale, .09, { Scale = .97 })
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
    local compact = width < 530
    self.Compact = compact
    local railWidth = compact and 55 or 152
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
    local anchor = self.launcherPosition or Vector2.new(bounds.X - 38, bounds.Y * .65)
    local x = math.clamp(anchor.X, 32, math.max(32, bounds.X - 32))
    local y = math.clamp(anchor.Y, 32, math.max(32, bounds.Y - 32))
    self.launcher.Position = px(x, y)
end

function Window:_resetEntrance()
    for group, position in pairs(self.entrance) do
        self:_cancel(group)
        group.GroupTransparency, group.Position = 0, position
    end
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
    self.launcher.Visible = false
    self.launcher.Active = false
    self:_resetEntrance()
    if not visible then
        self.panel.GroupTransparency, self.panel.Position = 1, px(0, 11)
    end
    self:_animate(self.panel, first and .43 or .21, { GroupTransparency = 0, Position = px(0, 0) })
    if first and self.motion == "Full" then
        self:_stage(self.brand, .31, .12, -6, 0)
        self:_stage(self.titleGroup, .34, .17, 0, 6)
        self:_stage(self.subtitleGroup, .29, .26, 0, 4)
        self:_stage(self.rail, .39, .16, -8, 0)
        if self.Selected then self:_stage(self.pages, .38, .36, 0, 8) end
        for index, tab in ipairs(self.Tabs) do
            if index > 10 then break end
            self:_stage(tab.shell, .27, .24 + (index-1)*.023, -4, 0)
        end
        self.sweep.Visible = true
        self.sweep.Position = UDim2.new(0, -56, 1, -2)
        self:_animate(self.sweep, .42, { Position = UDim2.new(1, 3, 1, -2) }, .17,
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
    self:_endGesture(false)
    self:_animate(self.launchScale, .12, { Scale = 1 })
    self:_resetEntrance()
    local focused = Input:GetFocusedTextBox()
    if focused and focused:IsDescendantOf(self.panel) then focused:ReleaseFocus(false) end
    self.launcher.Visible = self.launcherEnabled
    self.launcher.Active = self.launcherEnabled
    self:_animate(self.panel, .17, { GroupTransparency = 1, Position = px(0, 8) }, 0, function()
        if not self.Opened then self.panel.Visible = false end
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
        return Vector2.new(size.X.Offset > 0 and size.X.Offset or 710, size.Y.Offset > 0 and size.Y.Offset or 435)
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
    self.launcher.Visible = self.launcherEnabled and not self.Opened
    self.launcher.Active = self.launcher.Visible
    return self
end
function Window:SetOpenButtonGhosted(enabled)
    self.launcherPlate.BackgroundTransparency = enabled == true and .38 or 0
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

    local w = setmetatable({
        library = self, owner = scope(), theme = DARK, motion = o.Motion or "Full",
        radius = math.clamp(tonumber(o.Radius) or 8, 4, 16),
        gap = math.clamp(tonumber(o.Spacing) or 9, 4, 16),
        font = o.Font or Enum.Font.Gotham, boldFont = o.BoldFont or Enum.Font.GothamBold,
        desired = sizeInPixels(o.Size or Vector2.new(710, 435)), position = o.Position,
        key = o.ToggleKey or KEYBOARD, launcherEnabled = o.Launcher ~= false,
        Tabs = {}, groups = {}, entrance = {}, notices = {},
        tweens = {}, bindings = setmetatable({}, { __mode = "k" }),
        openedCallbacks = {}, closedCallbacks = {}, destroyCallbacks = {},
    }, Window)
    assert(MOTION[w.motion] ~= nil, "Motion must be Full, Reduced or Off")
    self.Window = w
    w.gui = make("ScreenGui", player:WaitForChild("PlayerGui"), {
        Name = "RyouUI14", ResetOnSpawn = false, DisplayOrder = 25,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling, ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
    })
    w.ScreenGui = w.gui
    w.screen = make("Frame", w.gui, { Size = full })
    w.frame = make("Frame", w.screen, { AnchorPoint = Vector2.new(.5, .5) })
    w.panel = make("CanvasGroup", w.frame, { Size = full, Visible = false })
    w.Root = w.panel
    w:_bind(w.panel, "BackgroundColor3", "Base")
    w.panel.BackgroundTransparency = 0
    corner(w.panel, 15)
    edge(w, w.panel)

    local header = surface(w, w.panel, "Rail", { Size = UDim2.new(1, 0, 0, 63), Active = true })
    local rule = surface(w, header, "Edge", { Position = UDim2.new(0, 0, 1, -1), Size = UDim2.new(1, 0, 0, 1) })
    rule.Name = "HeaderRule"
    w.sweep = surface(w, header, "Accent", { Size = px(52, 2), Visible = false })
    w.brand = make("CanvasGroup", header, { Size = px(42, 40), Position = px(13, 11) })
    local plate = surface(w, w.brand, "Field", { Size = full }, 10)
    icon(w, plate, "ryou", 25, "Accent", px(8, 7))
    w.titleGroup = make("CanvasGroup", header, { Position = px(65, 10), Size = UDim2.new(1, -124, 0, 24) })
    w.subtitleGroup = make("CanvasGroup", header, { Position = px(65, 34), Size = UDim2.new(1, -124, 0, 19) })
    w.title = label(w, w.titleGroup, copyText(o.Title, "Ryou UI"), 21, true, nil,
        { Size = full, TextTruncate = Enum.TextTruncate.AtEnd })
    w.subtitle = label(w, w.subtitleGroup, copyText(o.Subtitle or o.Author, "Created by Ryou"), 13, false, "Muted",
        { Size = full, TextTruncate = Enum.TextTruncate.AtEnd })
    w.Title, w.Author = w.title.Text, w.subtitle.Text
    local close = action(w, w.owner, header, "", { Position = UDim2.new(1, -52, 0, 9), Size = px(44, 44) })
    icon(w, close, "error", 17, "Muted", px(13, 13))
    listen(w.owner, close.Activated, function() w:Close() end)
    local content = make("Frame", w.panel, { Position = px(0, 63), Size = UDim2.new(1, 0, 1, -63) })
    w.rail = make("CanvasGroup", content, { Position = px(0, 0) })
    w.rail.BackgroundTransparency = 0
    w:_bind(w.rail, "BackgroundColor3", "Rail")
    w.nav = scroll(w, w.rail, { Size = full })
    pad(w.nav, 5, 8)
    stack(w.nav, 4)
    w.body = make("Frame", content, {})
    w.pages = make("CanvasGroup", w.body, { Size = full })
    local divider = surface(w, w.body, "Edge", { Position = px(-1, 0), Size = UDim2.new(0, 1, 1, 0) })
    divider.Name = "RailRule"
    for _, group in ipairs({ w.brand, w.titleGroup, w.subtitleGroup, w.rail, w.pages }) do
        w.entrance[group] = group.Position
    end
    w.resize = make("TextButton", w.panel, {
        Text = "", AutoButtonColor = false, Size = px(36, 34), AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.fromScale(1, 1), ZIndex = 8,
    })
    icon(w, w.resize, "grip", 17, "Muted", px(15, 13))
    w:SetResizable(o.Resizable ~= false)

    w.launcher = make("TextButton", w.screen, {
        Text = "", AutoButtonColor = false, Size = px(60, 56), AnchorPoint = Vector2.new(.5, .5),
        Visible = false, ZIndex = 15,
    })
    w.launchScale = make("UIScale", w.launcher, {})
    local shadow = make("Frame", w.launcher, {
        Position = px(4, 5), Size = px(52, 51), BackgroundColor3 = Color3.new(), BackgroundTransparency = .45,
    })
    corner(shadow, 15)
    local pod = surface(w, w.launcher, "Base", { Position = px(4, 1), Size = px(52, 51), Rotation = -7 }, 15)
    edge(w, pod)
    w.launcherPlate, w.OpenButton = pod, w.launcher
    if type(o.OpenButton) == "table" then w:EditOpenButton(o.OpenButton) end
    icon(w, w.launcher, "ryou", 28, "Text", px(15, 12))
    surface(w, w.launcher, "Accent", { Position = px(42, 37), Size = px(6, 3), Rotation = -7 }, 2)
    w.tray = make("Frame", w.screen, { AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 10, 1, -10), Size = UDim2.new(1, -20, 0, 0),
        AutomaticSize = VERTICAL, ZIndex = 20 })
    make("UISizeConstraint", w.tray, { MaxSize = Vector2.new(305, math.huge) })
    stack(w.tray, 6)

    local launchStart
    w:_gesture(w.owner, w.launcher, function(point, gesture)
        if not gesture.moved and (point - gesture.origin).Magnitude < 9 then return end
        gesture.moved = true
        w.launcherPosition = launchStart + point - gesture.origin
        w:_fitLauncher()
    end, function(gesture)
        w:_animate(w.launchScale, .15, { Scale = 1 })
        if gesture.moved then
            w.launcherPosition = w.launcher.AbsolutePosition - w.screen.AbsolutePosition + w.launcher.AbsoluteSize/2
        elseif gesture.event.UserInputState ~= Enum.UserInputState.Cancel then
            w:Open()
        end
    end, function()
        if not w.launcherEnabled or w.Opened then return false end
        launchStart = Vector2.new(w.launcher.Position.X.Offset, w.launcher.Position.Y.Offset)
        w:_animate(w.launchScale, .09, { Scale = .91 })
        return true
    end)

    local dragStart
    w:_gesture(w.owner, header, function(point, gesture)
        w:SetPosition(dragStart + point - gesture.origin)
    end, nil, function(point)
        if point.X >= close.AbsolutePosition.X then return false end
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
        if not consumed and not Input:GetFocusedTextBox() and event.KeyCode == w.key then w:Toggle() end
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
        self:_bind(previous.titleLabel, "TextColor3", "Muted")
        self:_cancel(previous.page)
        self:_cancel(previous.marker)
    end
    selected.page.Visible = true
    selected.marker.Visible = true
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
    t.glyph = icon(self, hit, o.Icon or "grid", 18, "Text", UDim2.new(0, 12, .5, -9))
    t.marker = surface(self, hit, "Accent", { AnchorPoint = Vector2.new(0, .5),
        Position = UDim2.new(0, 1, .5, 0), Size = px(3, 23), Visible = false }, 2)
    t.titleLabel = label(self, hit, name, 14, true, "Muted", { Position = px(39, 0),
        Size = UDim2.new(1, -45, 1, 0), TextTruncate = Enum.TextTruncate.AtEnd })
    t.page = make("CanvasGroup", self.pages, { Size = full, Visible = false })
    t.scroller = scroll(self, t.page, { Size = full })
    pad(t.scroller, 14, 11)
    stack(t.scroller, self.gap)
    label(self, t.scroller, name, 19, true, nil, { Size = UDim2.new(1, 0, 0, 25), LayoutOrder = -1 })
    if o.Desc then
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
    end
    pad(row, bare and 0 or 10, bare and 2 or 8)
    stack(row, 5)
    local head = make("Frame", row, { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = VERTICAL, LayoutOrder = 0 })
    local iconSize = math.clamp(tonumber(o.IconSize) or 17, 12, 24)
    local inset = o.Icon and iconSize + 8 or 0
    if o.Icon then icon(w, head, o.Icon, iconSize, "Muted", px(0, 2)) end
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
    self.title.TextTransparency = locked and .35 or 0
    for target in pairs(self.targets) do
        target.Active, target.Selectable = not locked, not locked
        if target:IsA("TextBox") then
            target.TextEditable = not locked
            if locked and target:IsFocused() then target:ReleaseFocus(false) end
        end
    end
    return self
end
function Control:Lock() return self:_locked(true) end
function Control:Unlock() return self:_locked(false) end
function Control:Destroy()
    if self.Destroyed then return end
    self.Destroyed = true
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
    local c = control(self, options)
    local w = self.Window
    local hit = action(w, c.owner, c.row, copyText(options and options.Action, "Ejecutar"),
        { Size = UDim2.new(1, 0, 0, 44), LayoutOrder = 1 })
    icon(w, hit, "arrow", 17, "Muted", UDim2.new(1, -27, .5, -8))
    c.targets[hit] = true
    listen(c.owner, hit.Activated, function() if not c.Locked then callback(c.Callback) end end)
    return c
end
function Tab:Toggle(options)
    local o = options or {}
    local c, w = control(self, o), self.Window
    local hit = action(w, c.owner, c.row, "", { Size = UDim2.new(1, 0, 0, 44), LayoutOrder = 1 })
    local state = label(w, hit, "", 13, true, nil, { Position = px(10, 0), Size = UDim2.new(1, -78, 1, 0) })
    local track = surface(w, hit, "Edge", { Position = UDim2.new(1, -61, .5, -11), Size = px(48, 22) }, 11)
    local knob = surface(w, track, "Text", { Size = px(14, 14), Position = px(4, 4) }, 7)
    c.targets[hit] = true
    function c:Set(value, silent) return self:_commit(value == true, silent) end
    function c.paint()
        state.Text = c.Value and "Activado" or "Desactivado"
        w:_animate(track, .16, { BackgroundColor3 = c.Value and w.theme.Accent or w.theme.Edge })
        w:_animate(knob, .16, { Position = px(c.Value and 30 or 4, 4),
            BackgroundColor3 = c.Value and w.theme.Ink or w.theme.Text })
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
        local scroller = c.tab.scroller
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

local function expandable(w, c, height)
    local panel = make("Frame", c.row, { LayoutOrder = 2, Size = UDim2.new(1, 0, 0, 0),
        ClipsDescendants = true, Visible = false })
    function c:Open()
        if self.Locked or self.Destroyed or self.expanded then return self end
        self.expanded = true
        panel.Visible = true
        w:_animate(panel, .21, { Size = UDim2.new(1, 0, 0, height) })
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
    local panel = expandable(w, c, 195)
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

function Tab:Colorpicker(options)
    local o = options or {}
    local c, w = control(self, o), self.Window
    local hit = action(w, c.owner, c.row, "", { LayoutOrder = 1, Size = UDim2.new(1, 0, 0, 44) })
    local chip = make("Frame", hit, { Position = px(9, 9), Size = px(26, 26), BackgroundTransparency = 0 })
    corner(chip, 6)
    local caption = label(w, hit, "", 14, true, nil, { Position = px(45, 0), Size = UDim2.new(1, -56, 1, 0) })
    c.targets[hit] = true
    local panel = expandable(w, c, 196)
    stack(panel, 4)
    local hue, saturation, brightness = 0, 0, 1
    local function setHSV(h, s, v)
        hue, saturation, brightness = h, s, v
        c:_commit(Color3.fromHSV(h, s, v))
    end
    local drawHue = valueBar(w, c, panel, 1, "Tono", function(f) setHSV(math.min(f, .999999), saturation, brightness) end)
    local drawSaturation = valueBar(w, c, panel, 2, "Saturación", function(f) setHSV(hue, f, brightness) end)
    local drawBrightness = valueBar(w, c, panel, 3, "Brillo", function(f) setHSV(hue, saturation, f) end)
    local footer = make("Frame", panel, { LayoutOrder = 4, Size = UDim2.new(1, 0, 0, 44) })
    local hex = textBox(w, c.owner, footer, "#RRGGBB", { Position = px(2, 2), Size = UDim2.new(1, -124, 0, 40) })
    c.targets[hex] = true
    local palette = { rgb(132, 241, 198), rgb(206, 176, 253), rgb(250, 227, 154) }
    for index, color in ipairs(palette) do
        local swatch = action(w, c.owner, footer, "", { Position = UDim2.new(1, -116 + (index-1)*39, 0, 2), Size = px(36, 40) })
        local fill = make("Frame", swatch, { Position = px(6, 8), Size = px(24, 24),
            BackgroundColor3 = color, BackgroundTransparency = 0 })
        corner(fill, 4)
        c.targets[swatch] = true
        listen(c.owner, swatch.Activated, function() if not c.Locked then c:Set(color) end end)
    end
    function c.paint()
        local code = "#" .. c.Value:ToHex()
        caption.Text, chip.BackgroundColor3 = code, c.Value
        if not hex:IsFocused() then hex.Text = code end
        drawHue(hue, string.format("%d°", math.floor(hue*360)))
        drawSaturation(saturation, string.format("%d%%", math.floor(saturation*100)))
        drawBrightness(brightness, string.format("%d%%", math.floor(brightness*100)))
    end
    function c:Set(value, silent)
        if typeof(value) ~= "Color3" then return self end
        local h, s, v = value:ToHSV()
        if s > 0 then hue = h end
        if v > 0 then saturation = s end
        brightness = v
        return self:_commit(value, silent)
    end
    c:Set(o.Value or o.Default or w.theme.Accent, true)
    listen(c.owner, hex.FocusLost, function()
        local value = hex.Text:gsub("^#", "")
        if not c.Locked and #value == 6 and value:match("^%x+$") then c:Set(Color3.fromHex(value)) end
        c.paint()
    end)
    listen(c.owner, hit.Activated, function()
        if c.Locked then return end
        if c.expanded then c:Close() else c:Open() end
    end)
    return c
end
Tab.ColorPicker = Tab.Colorpicker

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
