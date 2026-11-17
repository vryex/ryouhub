-- Ryou UI 14.0.0 · Created by Ryou
-- Client-side ModuleScript for Roblox Studio.
local Players = game:GetService("Players")
local Input = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")

-- Theme tokens ---------------------------------------------------------
local function canonicalThemeName(name)
    local key = string.lower(tostring(name or ""))
    if key == "blanco" or key == "white" or key == "light" or key == "claro" then
        return "Blanco"
    end
    return "Xero" -- internal compatibility key for the Ryou dark theme
end

local THEMES = {
    Xero = {
        Name = "Ryou",
        Colors = {
            Window = Color3.fromRGB(17, 18, 21), Panel = Color3.fromRGB(23, 24, 28),
            Row = Color3.fromRGB(28, 30, 34), Field = Color3.fromRGB(15, 16, 19),
            Hover = Color3.fromRGB(39, 43, 47), Border = Color3.fromRGB(64, 68, 73),
            Text = Color3.fromRGB(242, 244, 245), Muted = Color3.fromRGB(180, 186, 193),
            Faint = Color3.fromRGB(139, 148, 155), White = Color3.fromRGB(150, 234, 201),
        },
        Glass = {
            Root = 0.02,
            Sidebar = 0.04,
            Row = 0.07,
            Field = 0.22,
            Button = 0.16,
            NavActive = 0.05,
            Popup = 0.08,
        },
        Visuals = {
            RootBase = Color3.fromRGB(17, 18, 21),
            RootStroke = Color3.fromRGB(63, 67, 71),
            SidebarBase = Color3.fromRGB(22, 23, 26),
            SidebarStroke = Color3.fromRGB(43, 46, 51),
            SearchStroke = Color3.fromRGB(53, 58, 63),
            OpenStroke = Color3.fromRGB(73, 79, 81),
            OpenButtonBase = Color3.fromRGB(27, 29, 33),
            NavButtonIdle = Color3.fromRGB(22, 23, 26),
            ResizeGuideTransparency = 0.24,
            ControlStroke = Color3.fromRGB(62, 66, 71),
            FieldStroke = Color3.fromRGB(53, 58, 63),
            ButtonBase = Color3.fromRGB(36, 39, 44),
            ButtonStroke = Color3.fromRGB(64, 68, 73),
            DropdownStroke = Color3.fromRGB(53, 58, 63),
            PopupStroke = Color3.fromRGB(73, 78, 82),
            GothicRow = Color3.fromRGB(25, 27, 30),
            GothicDesc = Color3.fromRGB(180,200,211),
            GothicBadgeText = Color3.fromRGB(224,251,243),
            GothicBadgeBackground = Color3.fromRGB(28, 45, 39),
            SliderValueBackground = Color3.fromRGB(20, 22, 25),
            SliderValueText = Color3.fromRGB(239,246,250),
            SliderValueStroke = Color3.fromRGB(55, 59, 65),
            SliderRail = Color3.fromRGB(18, 19, 23),
            SliderRailStroke = Color3.fromRGB(55, 59, 65),
            SliderTrack = Color3.fromRGB(64, 70, 74),
            SliderTrackGradient = {Color3.fromRGB(46,50,54),Color3.fromRGB(70,76,80),Color3.fromRGB(46,50,54)},
            SliderFill = Color3.fromRGB(150, 234, 201),
            SliderFillGradient = {Color3.fromRGB(150,234,201),Color3.fromRGB(114,197,163)},
            SliderHalo = Color3.fromRGB(150, 234, 201),
            SliderThumb = Color3.fromRGB(236,252,247),
            SliderThumbStroke = Color3.fromRGB(50, 86, 72),
        },
    },
    Blanco = {
        Name = "Blanco",
        Colors = {
            Window = Color3.fromRGB(248,248,250), Panel = Color3.fromRGB(241,241,244),
            Row = Color3.fromRGB(232,232,236), Field = Color3.fromRGB(252,252,255),
            Hover = Color3.fromRGB(223,223,228), Border = Color3.fromRGB(201,201,208),
            Text = Color3.fromRGB(20,20,24), Muted = Color3.fromRGB(88,88,98),
            Faint = Color3.fromRGB(103,104,112), White = Color3.fromRGB(28,103,77),
        },
        Glass = {
            Root = 0.02,
            Sidebar = 0.08,
            Row = 0.12,
            Field = 0.04,
            Button = 0.08,
            NavActive = 0.00,
            Popup = 0.04,
        },
        Visuals = {
            RootBase = Color3.fromRGB(250,250,252),
            RootStroke = Color3.fromRGB(210,210,216),
            SidebarBase = Color3.fromRGB(244,244,247),
            SidebarStroke = Color3.fromRGB(214,214,220),
            SearchStroke = Color3.fromRGB(206,206,212),
            OpenStroke = Color3.fromRGB(190,190,198),
            OpenButtonBase = Color3.fromRGB(247,247,250),
            NavButtonIdle = Color3.fromRGB(238,238,242),
            ResizeGuideTransparency = 0.42,
            ControlStroke = Color3.fromRGB(198,198,205),
            FieldStroke = Color3.fromRGB(202,202,209),
            ButtonBase = Color3.fromRGB(246,246,249),
            ButtonStroke = Color3.fromRGB(202,202,209),
            DropdownStroke = Color3.fromRGB(202,202,209),
            PopupStroke = Color3.fromRGB(190,190,198),
            GothicRow = Color3.fromRGB(238,238,242),
            GothicDesc = Color3.fromRGB(92,92,102),
            GothicBadgeText = Color3.fromRGB(32,32,38),
            GothicBadgeBackground = Color3.fromRGB(233,233,238),
            SliderValueBackground = Color3.fromRGB(252,252,255),
            SliderValueText = Color3.fromRGB(20,20,24),
            SliderValueStroke = Color3.fromRGB(198,198,205),
            SliderRail = Color3.fromRGB(225,225,231),
            SliderRailStroke = Color3.fromRGB(190,190,199),
            SliderTrack = Color3.fromRGB(207,207,215),
            SliderTrackGradient = {Color3.fromRGB(198,198,207),Color3.fromRGB(217,217,224),Color3.fromRGB(198,198,207)},
            SliderFill = Color3.fromRGB(50,50,56),
            SliderFillGradient = {Color3.fromRGB(20,20,24),Color3.fromRGB(78,78,86)},
            SliderHalo = Color3.fromRGB(20,20,24),
            SliderThumb = Color3.fromRGB(250,250,252),
            SliderThumbStroke = Color3.fromRGB(118,118,128),
        },
    },
}

local CURRENT_THEME_NAME = "Xero"
local CURRENT_THEME = THEMES[CURRENT_THEME_NAME] or THEMES.Xero
local RyouUI = { Version = "14.0.0", Brand = "Ryou", SupportsGameLabels = true, Creator = "Ryou", UIScale = 1 }
local C, Glass = {}, {}

local function overwriteTable(target, source)
    for key in pairs(target) do target[key] = nil end
    for key, value in pairs(source or {}) do target[key] = value end
end

local function getThemeDefinition(themeName, paletteOptions)
    local base=THEMES[canonicalThemeName(themeName)]
    if not paletteOptions then return base end
    local colors=table.clone(base.Colors)
    local visuals=table.clone(base.Visuals)
    local accent=paletteOptions.Accent
    if typeof(accent)=="Color3" then
        colors.White=accent
        visuals.SliderFill=accent
        visuals.SliderFillGradient={accent,accent:Lerp(colors.Window,.18)}
    end
    return {Name=base.Name,Colors=colors,Glass=base.Glass,Visuals=visuals}
end

local function applyThemeDefinition(themeName,paletteOptions)
    CURRENT_THEME_NAME=canonicalThemeName(themeName)
    CURRENT_THEME=getThemeDefinition(CURRENT_THEME_NAME,paletteOptions)
    overwriteTable(C,CURRENT_THEME.Colors)
    overwriteTable(Glass,CURRENT_THEME.Glass)
    return CURRENT_THEME
end

applyThemeDefinition(CURRENT_THEME_NAME)

-- Built-in icons are drawn with Roblox Frames. Registered images use asset IDs.
local registeredIcons = {}
local function normalizeIconName(name)
    return (string.lower(tostring(name or "")):gsub("%s+", "-"))
end
local function iconAsset(value)
    if type(value) == "number" and value >= 1 and value % 1 == 0 then
        return "rbxassetid://" .. string.format("%.0f", value)
    end
    if type(value) == "string" then
        if value:match("^rbxassetid://[1-9]%d*$") then return value end
        return registeredIcons[normalizeIconName(value)]
    end
end

local function colorEquals(left, right)
    return typeof(left) == "Color3" and typeof(right) == "Color3"
        and math.abs(left.R - right.R) < 0.0001
        and math.abs(left.G - right.G) < 0.0001
        and math.abs(left.B - right.B) < 0.0001
end

local function themeRoleFromColor(color)
    if typeof(color) ~= "Color3" then return nil end
    for role, value in pairs(C) do
        if colorEquals(color, value) then return role end
    end
    return nil
end

local function setThemeRole(object, suffix, role)
    if object and role and type(object.SetAttribute) == "function" then
        object:SetAttribute("RyouTheme" .. suffix, role)
    end
end

local function detectAndTagThemeRoles(object)
    if not object or type(object.IsA) ~= "function" then return end
    if object:IsA("GuiObject") then
        setThemeRole(object, "Background", themeRoleFromColor(object.BackgroundColor3))
    end
    if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
        setThemeRole(object, "Text", themeRoleFromColor(object.TextColor3))
    end
    if object:IsA("TextBox") then
        setThemeRole(object, "Placeholder", themeRoleFromColor(object.PlaceholderColor3))
    end
    if object:IsA("UIStroke") then
        setThemeRole(object, "Stroke", themeRoleFromColor(object.Color))
    end
end

local function applyThemeRolesToObject(object)
    if not object or type(object.GetAttribute) ~= "function" then return end
    local bgRole = object:GetAttribute("RyouThemeBackground")
    if bgRole and object:IsA("GuiObject") and C[bgRole] then
        object.BackgroundColor3 = C[bgRole]
    end
    local textRole = object:GetAttribute("RyouThemeText")
    if textRole and (object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox")) and C[textRole] then
        object.TextColor3 = C[textRole]
    end
    local placeholderRole = object:GetAttribute("RyouThemePlaceholder")
    if placeholderRole and object:IsA("TextBox") and C[placeholderRole] then
        object.PlaceholderColor3 = C[placeholderRole]
    end
    local strokeRole = object:GetAttribute("RyouThemeStroke")
    if strokeRole and object:IsA("UIStroke") and C[strokeRole] then
        object.Color = C[strokeRole]
    end
end

local function applyThemeRolesRecursive(root)
    if not root then return end
    applyThemeRolesToObject(root)
    for _, descendant in ipairs(root:GetDescendants()) do
        applyThemeRolesToObject(descendant)
    end
end

-- Tipografía de interfaz Roblox moderna: sin fuentes externas ni archivos privados.
-- Si el cliente es antiguo conserva Gotham como respaldo.
local function fontChoice(name,fallback)
    local ok,font=pcall(function() return Enum.Font[name] end)
    return ok and font or fallback
end
local DEFAULT_FONT = fontChoice("BuilderSans",Enum.Font.Gotham)
local DEFAULT_MEDIUM = fontChoice("BuilderSansMedium",Enum.Font.GothamMedium)
local DEFAULT_BOLD = fontChoice("BuilderSansBold",Enum.Font.GothamBold)
local FONT, MEDIUM, BOLD = DEFAULT_FONT, DEFAULT_MEDIUM, DEFAULT_BOLD
local DISPLAY = fontChoice("Jura",Enum.Font.GothamBold)
local function new(class, props, parent)
    local object = Instance.new(class)
    if object:IsA("GuiObject") then object.BorderSizePixel = 0 end
    if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
        object.Font = FONT
        object.TextSize = 13
        object.TextColor3 = C.Text
        object.Text = ""
    end
    if object:IsA("GuiButton") then object.AutoButtonColor = false end
    for key, value in pairs(props or {}) do object[key] = value end
    detectAndTagThemeRoles(object)
    object.Parent = parent
    return object
end
local function round(object, radius)
    return new("UICorner", {CornerRadius = UDim.new(0, radius or 10)}, object)
end
local function stroke(object, color, thickness)
    return new("UIStroke", {Color = color or C.Border, Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border}, object)
end
local function padding(object, x, y)
    return new("UIPadding", {PaddingLeft = UDim.new(0,x), PaddingRight = UDim.new(0,x),
        PaddingTop = UDim.new(0,y or x), PaddingBottom = UDim.new(0,y or x)}, object)
end
local function vertical(object, gap)
    return new("UIListLayout", {Padding = UDim.new(0,gap or 0),
        SortOrder = Enum.SortOrder.LayoutOrder}, object)
end
local function label(parent, text, size, color, props)
    local p = {Text = text or "", TextSize = size or 13, TextColor3 = color or C.Text,
        BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.new(1,0,0,20)}
    for k,v in pairs(props or {}) do p[k] = v end
    return new("TextLabel", p, parent)
end
local function imageIcon(parent, value, px, color)
    return new("ImageLabel", {
        Name = "RyouIcon", Size = UDim2.fromOffset(px, px),
        BackgroundTransparency = 1, Image = iconAsset(value),
        ImageColor3 = color, ScaleType = Enum.ScaleType.Fit,
    }, parent)
end
local uiTween
local function button(parent, text, props)
    local p = {
        Text = text or "",
        BackgroundColor3 = C.Row,
        BackgroundTransparency = Glass.Button,
        Size = UDim2.fromOffset(36,36)
    }
    for k,v in pairs(props or {}) do p[k] = v end
    local surface=new("TextButton", p, parent)
    -- Microinteracción sutil; no reescalar modales ni superficies de arrastre.
    local excluded={ModalBackdrop=true,Modal=true,SVPlane=true,HueStrip=true,
        ToggleHit=true,SliderArea=true}
    if not excluded[tostring(p.Name or "")] then
        local pressScale=new("UIScale",{Name="RyouPress",Scale=1},surface)
        surface.InputBegan:Connect(function(input)
            if input.UserInputType==Enum.UserInputType.Touch
                or input.UserInputType==Enum.UserInputType.MouseButton1 then
                uiTween(pressScale,{Scale=.976},.095,Enum.EasingStyle.Quad)
            end
        end)
        surface.InputEnded:Connect(function(input)
            if input.UserInputType==Enum.UserInputType.Touch
                or input.UserInputType==Enum.UserInputType.MouseButton1 then
                uiTween(pressScale,{Scale=1},.24,Enum.EasingStyle.Back)
            end
        end)
    end
    return surface
end
local function plain(text)
    return tostring(text or ""):gsub("<[^>]+>", "")
end
local function normalized(text)
    local s = string.lower(plain(text))
    for a,b in pairs({["á"]="a",["é"]="e",["í"]="i",["ó"]="o",["ú"]="u",["ñ"]="n",
        ["Á"]="a",["É"]="e",["Í"]="i",["Ó"]="o",["Ú"]="u",["Ñ"]="n"}) do s = s:gsub(a,b) end
    return s
end
local function invoke(callback, ...)
    if type(callback) ~= "function" then return end
    local ok, err = pcall(callback, ...)
    if not ok then warn("[Ryou] " .. tostring(err)) end
end
local function disconnect(bucket)
    for _,connection in ipairs(bucket) do connection:Disconnect() end
    table.clear(bucket)
end
local function connect(window, signal, callback, bucket)
    local connection = signal:Connect(callback)
    if bucket then table.insert(bucket, connection) end
    return connection
end
local activeTweens = setmetatable({}, {__mode = "k"})
local function stopTween(object)
    local previous = activeTweens[object]
    if previous then
        activeTweens[object] = nil
        previous:Cancel()
    end
end
local function motionDuration(seconds, staged)
    local mode = RyouUI.Window and RyouUI.Window.Motion
    if mode == "off" then return 0 end
    if mode == "reduced" and not staged then return math.min(seconds, .09) end
    return seconds
end
uiTween = function(object, goal, duration, easing, direction, staged)
    if not object or not object.Parent then return end
    stopTween(object)
    local seconds = motionDuration(duration or .17, staged)
    if seconds == 0 then
        for key, value in pairs(goal) do object[key] = value end
        return
    end
    local tween = TweenService:Create(object,
        TweenInfo.new(seconds, easing or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out), goal)
    activeTweens[object] = tween
    tween.Completed:Once(function()
        if activeTweens[object] == tween then activeTweens[object] = nil end
        tween:Destroy()
    end)
    tween:Play()
    return tween
end
local function hover(window, target, baseColor, baseTransparency, hoverColor, hoverTransparency)
    local idleColor = baseColor or C.Row
    local idleTransparency = baseTransparency
    if idleTransparency == nil then
        idleTransparency = target.BackgroundTransparency
        if idleTransparency == nil then idleTransparency = Glass.Button end
    end

    local overColor = hoverColor or C.Hover
    local overTransparency = hoverTransparency
    if overTransparency == nil then
        overTransparency = math.max(0, idleTransparency - 0.10)
    end

    local idleRole = themeRoleFromColor(idleColor)
    local hoverRole = themeRoleFromColor(overColor)

    connect(window, target.MouseEnter, function()
        uiTween(target,{BackgroundColor3=hoverRole and C[hoverRole] or overColor,
            BackgroundTransparency=overTransparency},.16)
    end)
    connect(window, target.MouseLeave, function()
        uiTween(target,{BackgroundColor3=idleRole and C[idleRole] or idleColor,
            BackgroundTransparency=idleTransparency},.20)
    end)
end
local function line(parent, x, y, w, h, rotation, color)
    return new("Frame", {Position=UDim2.fromOffset(x,y), Size=UDim2.fromOffset(w,h),
        Rotation=rotation or 0, BackgroundColor3=color or C.Muted}, parent)
end
local function segment(parent, a, b, thickness, color, size)
    local dx, dy = b[1] - a[1], b[2] - a[2]
    return new("Frame", {
        AnchorPoint = Vector2.new(.5, .5),
        Position = UDim2.fromScale((a[1] + b[1]) / 48, (a[2] + b[2]) / 48),
        Size = UDim2.fromOffset(math.sqrt(dx * dx + dy * dy) * size / 24, thickness * size / 24),
        Rotation = math.deg(math.atan2(dy, dx)), BackgroundColor3 = color,
    }, parent)
end

local function mark(parent, size, color)
    local holder = new("Frame", {Name = "RyouMark", BackgroundTransparency = 1,
        Size = UDim2.fromOffset(size, size)}, parent)
    local tone = color or C.White
    -- Coordinates match branding/ryou-mark.svg.
    segment(holder, {5, 6}, {5, 20}, 2.8, tone, size)
    segment(holder, {3.6, 6}, {15, 6}, 2.8, tone, size)
    segment(holder, {14, 5.7}, {19, 10}, 2.8, tone, size)
    segment(holder, {19, 9.6}, {15, 13.6}, 2.8, tone, size)
    segment(holder, {8, 12.8}, {15.8, 12.8}, 2.8, tone, size)
    segment(holder, {12.3, 16}, {19, 21}, 2.8, tone, size)
    return holder
end

local glyphs = {
    home = {{{3,11},{12,3},{21,11}}, {{6,10},{6,20},{18,20},{18,10}}},
    sliders = {{{4,7},{20,7}}, {{4,17},{20,17}}, {{8,4},{8,10}}, {{15,14},{15,20}}},
    layers = {{{3,9},{12,4},{21,9},{12,14},{3,9}}, {{3,14},{12,19},{21,14}}},
    palette = {{{4,18},{4,6},{9,3},{19,3},{21,11},{15,14},{15,20},{7,20},{4,18}}, {{8,8},{11,8}}, {{15,7},{17,7}}, {{8,13},{11,13}}},
    bell = {{{4,17},{7,14},{7,8},{12,4},{17,8},{17,14},{20,17},{4,17}}, {{10,21},{14,21}}},
    user = {{{9,5},{15,5},{15,11},{9,11},{9,5}}, {{4,20},{4,17},{8,14},{16,14},{20,17},{20,20}}},
    grid = {{{4,4},{20,4},{20,20},{4,20},{4,4}}, {{4,12},{20,12}}, {{12,4},{12,20}}},
    check = {{{5,12},{10,17},{19,7}}},
    info = {{{12,5},{12,8}}, {{12,11},{12,19}}},
    warning = {{{12,4},{21,20},{3,20},{12,4}}, {{12,9},{12,14}}, {{12,16},{12,18}}},
    close = {{{5,5},{19,19}}, {{19,5},{5,19}}},
    minus = {{{5,12},{19,12}}},
    search = {{{12,4},{5,4},{4,11},{7,15},{13,15},{16,9},{12,4}}, {{14,14},{20,20}}},
}
local iconAliases = {settings = "sliders", ["sliders-horizontal"] = "sliders",
    ["layout-grid"] = "grid", ["badge-info"] = "info", shirt = "user"}
local function icon(parent, name, size, color, fallback)
    local px = size or 20
    local tone = color or C.Muted
    if iconAsset(name) then return imageIcon(parent, name, px, tone) end
    local holder = new("Frame", {Name = "RyouIcon", BackgroundTransparency = 1,
        Size = UDim2.fromOffset(px, px)}, parent)
    local key = normalizeIconName(name)
    local paths = glyphs[iconAliases[key] or key]
    if paths then
        for _, path in ipairs(paths) do
            for index = 2, #path do segment(holder, path[index - 1], path[index], 1.8, tone, px) end
        end
    elseif fallback and fallback ~= "" then
        local nextByte = utf8.offset(fallback, 2) or #fallback + 1
        label(holder, string.upper(fallback:sub(1, nextByte - 1)), math.min(14, px), tone, {
            Font = BOLD, Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center,
        })
    else
        segment(holder, {10, 12}, {14, 12}, 2, tone, px)
    end
    return holder
end
local function tintIcon(holder, color)
    if holder:IsA("ImageLabel") then
        holder.ImageColor3 = color
    else
        for _, part in ipairs(holder:GetChildren()) do
            if part:IsA("TextLabel") then part.TextColor3 = color else part.BackgroundColor3 = color end
        end
    end
end
local function scroll(parent, props)
    local p = {BackgroundTransparency=1, Size=UDim2.fromScale(1,1), CanvasSize=UDim2.new(),
        AutomaticCanvasSize=Enum.AutomaticSize.Y, ScrollingDirection=Enum.ScrollingDirection.Y,
        ScrollBarThickness=3, ScrollBarImageColor3=C.Faint, ElasticBehavior=Enum.ElasticBehavior.Never}
    for k,v in pairs(props or {}) do p[k]=v end
    return new("ScrollingFrame",p,parent)
end

local Tab = {}; Tab.__index = Tab
local Control = {}; Control.__index = Control

-- Measure wrapped copy once per width/content change. Rows never derive their
-- height from a child whose height is a fraction of that same row.
local function textHeight(text,size,font,width)
    if text=="" then return 0 end
    return math.max(size+3,math.ceil(TextService:GetTextSize(text,size,font,Vector2.new(math.max(30,width),100000)).Y)+3)
end
function Control:_resize(width)
    if self.Destroyed then return end
    local section=self.__type=="Section"
    local px=section and 4 or self.Window.Spacing
    local py=section and 5 or math.max(6, self.Window.Spacing - 4)
    local headWidth=math.max(40,width-px*2)
    local reserve=self.Reserve or 0
    local copyOffsetX=self.CopyOffsetX or 0
    local copyWidth=math.max(30,headWidth-reserve-copyOffsetX)
    local titleHeight=textHeight(self.Title,self.TitleLabel.TextSize,self.TitleLabel.Font,copyWidth)
    local descHeight=textHeight(self.Desc,self.DescLabel.TextSize,self.DescLabel.Font,copyWidth)
    local copyHeight=titleHeight+(descHeight>0 and 4+descHeight or 0)
    local headHeight=math.max(copyHeight,self.HeadMinimum or 0)
    self.Head.Position=UDim2.fromOffset(px,py)
    self.Head.Size=UDim2.new(1,-px*2,0,headHeight)
    self.Copy.Position=UDim2.fromOffset(copyOffsetX,0)
    self.Copy.Size=UDim2.new(1,-reserve-copyOffsetX,0,copyHeight)
    if self.ControlIcon then
        local iconSize=self.ControlIconSize or 16
        self.ControlIcon.Position=UDim2.fromOffset(self.IconX or 0,math.max(0,math.floor((headHeight-iconSize)/2)))
        self.ControlIcon.Size=UDim2.fromOffset(iconSize,iconSize)
    end
    self.TitleLabel.Size=UDim2.new(1,0,0,titleHeight)
    self.DescLabel.Position=UDim2.fromOffset(0,titleHeight+4)
    self.DescLabel.Size=UDim2.new(1,0,0,descHeight)
    if self.Thumbnail then
        local size=self.ThumbnailSize or 36
        local thumbY=math.max(0,math.floor((headHeight-size)/2))
        local thumbX=(self.ImageAlign=="left") and 0 or math.max(0,headWidth-size)
        self.Thumbnail.Position=UDim2.fromOffset(thumbX,thumbY)
        self.Thumbnail.Size=UDim2.fromOffset(size,size)
    end
    local y=py+headHeight
    if self.BodyField then
        local fieldHeight=40
        if self.ValueLabel then fieldHeight=math.clamp(textHeight(self.ValueLabel.Text,11,FONT,headWidth-36)+7,40,48) end
        self.BodyField.Position=UDim2.fromOffset(px,y+4)
        self.BodyField.Size=UDim2.new(1,-px*2,0,fieldHeight)
        y+=4+fieldHeight
    end
    -- Dropdown expandible en su propia tarjeta; esta altura participa
    -- del layout real. No aparece ninguna ventana flotante.
    if self.InlineDropdown then
        local expandedHeight=math.max(0,math.floor(self._dropdownHeight or 0))
        self.InlineDropdown.Position=UDim2.fromOffset(px,y+4)
        self.InlineDropdown.Size=UDim2.new(1,-px*2,0,expandedHeight)
        self.InlineDropdown.Visible=expandedHeight>2
        y+=expandedHeight>0 and (expandedHeight+4) or 0
    end
    if self.SliderArea then
        local sliderAreaHeight=self.SliderAreaHeight or 14
        local sliderLimitsGap=self.SliderLimitsGap or 2
        self.SliderArea.Position=UDim2.fromOffset(px,y+3)
        self.SliderArea.Size=UDim2.new(1,-px*2,0,sliderAreaHeight)
        self.Limits.Position=UDim2.fromOffset(px,y+3+sliderAreaHeight+sliderLimitsGap)
        self.Limits.Size=UDim2.new(1,-px*2,0,14)
        y+=sliderAreaHeight+sliderLimitsGap+17
    end
    if self.Rule then self.Rule.Position=UDim2.fromOffset(px,y+5); self.Rule.Size=UDim2.new(1,-px*2,0,1); y+=7 end
    local height=y+(section and 2 or py)
    self.ElementFrame.Size=UDim2.new(1,0,0,height)
    self.Slot.Size=UDim2.new(1,-6,0,height)
end
function Tab:_layout()
    if self.Window.Destroyed then return end
    local width=math.max(80,(self.Content.AbsoluteSize.X>10 and self.Content.AbsoluteSize.X / self.Window.UIScale or (self.Window.ContentWidth or 500))-12)
    local height=4
    for _,c in ipairs(self.Elements) do
        if not c.Destroyed then
            c:_resize(width)
            if c.Slot.Visible then height+=c.Slot.Size.Y.Offset+self.Window.RowGap end
        end
    end
    local bottomPad=14
    local canvasHeight=math.max(0,height-8+bottomPad)
    self.Content.CanvasSize=UDim2.fromOffset(0,canvasHeight)
    local viewportHeight=self.Content.AbsoluteWindowSize.Y / self.Window.UIScale
    self.Content.CanvasPosition=Vector2.new(0,math.clamp(self.Content.CanvasPosition.Y,0,math.max(0,canvasHeight-viewportHeight)))
end

function Control:ApplyTheme()
    if self.Destroyed then return self end
    local light = (self.Window and self.Window.ThemeName == "Blanco") or CURRENT_THEME_NAME == "Blanco"
    if self.ElementFrame and self.ElementFrame.Parent then
        self.ElementFrame.BackgroundColor3 = light and (self.LightColor or C.Row) or (self.DarkColor or C.Row)
    end
    if self.RowStroke and self.RowStroke.Parent then
        self.RowStroke.Color = light and (self.LightStrokeColor or C.Border) or (self.DarkStrokeColor or THEMES.Xero.Visuals.ControlStroke)
    end
    if self.TitleLabel and self.TitleLabel.Parent then
        if self.Locked then
            self.TitleLabel.TextColor3 = C.Faint
        else
            self.TitleLabel.TextColor3 = light and (self.LightTitleColor or C.Text) or (self.DarkTitleColor or C.Text)
        end
    end
    if self.DescLabel and self.DescLabel.Parent then
        self.DescLabel.TextColor3 = light and (self.LightDescColor or C.Muted) or (self.DarkDescColor or C.Muted)
    end
    if self.PictureStroke and self.PictureStroke.Parent then
        self.PictureStroke.Color = light and (self.LightImageStrokeColor or C.Border) or (self.DarkImageStrokeColor or C.Text)
    end
    if self.ControlIcon and self.ControlIcon.Parent then
        tintIcon(self.ControlIcon, light and (self.LightIconColor or C.Muted) or (self.DarkIconColor or C.Muted))
    end
    if self._applyThemeExtras then self:_applyThemeExtras(light) end
    return self
end

function Control:SetTitle(value)
    self.Title = plain(value); self.TitleLabel.Text = self.Title
    self.Tab:_queueFilter(); return self
end
function Control:SetDesc(value)
    self.Desc = plain(value); self.DescLabel.Text = self.Desc
    self.DescLabel.Visible = self.Desc ~= ""; self.Tab:_queueFilter(); return self
end
function Control:SetVisible(value) self.ElementFrame.Visible = value == true; return self end
function Control:Show() return self:SetVisible(true) end
function Control:Hide() return self:SetVisible(false) end
function Control:Lock()
    self.Locked = true; self.TitleLabel.TextColor3 = C.Faint
    if self.Interactive then
        self.Interactive.Active = false
        if self.Interactive:IsA("TextBox") then self.Interactive.TextEditable = false end
    end
    if self.EditableField then self.EditableField.TextEditable=false end
    if self.Close and self.Window._inlineOpen == self then self:Close(true) end
    if self.Window._popupOwner == self then self.Window:_closePopup() end
    return self
end
function Control:Unlock()
    self.Locked = false; self.TitleLabel.TextColor3 = C.Text
    if self.Interactive then
        self.Interactive.Active = true
        if self.Interactive:IsA("TextBox") then self.Interactive.TextEditable = true end
    end
    if self.EditableField then self.EditableField.TextEditable=true end
    self:ApplyTheme()
    return self
end
function Control:Destroy()
    if self.Destroyed then return end
    self.Destroyed = true
    if self.Window._popupOwner == self then self.Window:_closePopup() end
    if self.Window._inlineOpen == self then self.Window._inlineOpen = nil end
    if self.Window._drag and self.Window._drag.Owner == self then self.Window:_endDrag() end
    if self._dispose then self._dispose() end
    local index=table.find(self.Tab.Elements,self)
    if index then table.remove(self.Tab.Elements,index) end
    self.Slot:Destroy()
    self.Tab:_queueFilter()
end
function Control:SetValue(value, silent) return self:Set(value,silent) end
function Control:Get() return self.Value end

function Tab:_queueFilter()
    if self._filterQueued or self.Window.Destroyed then return end
    self._filterQueued = true
    task.defer(function()
        self._filterQueued = false
        if not self.Window.Destroyed then self:_filter() end
    end)
end
function Tab:_filter()
    local query = normalized(self.Query or "")
    local shown = 0
    local matchingGroups = {}
    local ordered=table.clone(self.Elements)
    table.sort(ordered,function(a,b) return a.Slot.LayoutOrder<b.Slot.LayoutOrder end)
    local groupTitle=""
    for _,c in ipairs(ordered) do
        if not c.Destroyed then
            if c.__type=="Section" then groupTitle=c.Title else c.GroupTitle=groupTitle end
        end
    end
    for _,c in ipairs(self.Elements) do
        if not c.Destroyed and c.__type ~= "Section" then
            local allowed = c.ElementFrame.Visible
            local matched = query == "" or string.find(normalized(c.Title .. " " .. c.Desc .. " " .. (c.GroupTitle or "")),query,1,true) ~= nil
            c.Slot.Visible = allowed and matched
            if allowed and matched then shown += 1; matchingGroups[c.GroupTitle or ""] = true end
        end
    end
    for _,c in ipairs(self.Elements) do
        if not c.Destroyed and c.__type == "Section" then
            c.Slot.Visible = c.ElementFrame.Visible and (query == "" or matchingGroups[c.Title] == true)
        end
    end
    self.Empty.Visible = shown == 0
    if self._lastQuery~=query then self.Content.CanvasPosition=Vector2.zero; self._lastQuery=query end
    self:_layout()
end
function Tab:_control(kind, options)
    local o = options or {}
    self._order += 1
    local lightTheme = self.Window.ThemeName == "Blanco"
    local darkColor = o.Color or THEMES.Xero.Colors.Row
    local lightColor = o.LightColor or THEMES.Blanco.Colors.Row
    local darkStrokeColor = o.StrokeColor or THEMES.Xero.Visuals.ControlStroke
    local lightStrokeColor = o.LightStrokeColor or THEMES.Blanco.Visuals.ControlStroke
    local slot = new("Frame", {Name="Slot",BackgroundTransparency=1,
        Size=UDim2.new(1,-4,0,0),LayoutOrder=self._order},self.Content)
    local row = new("Frame", {Name=kind,BackgroundColor3=lightTheme and lightColor or darkColor,BackgroundTransparency=Glass.Row,
        Size=UDim2.new(1,0,0,0),LayoutOrder=self._order,ClipsDescendants=true},slot)
    round(row,self.Window.Radius); local rowStroke=stroke(row,lightTheme and lightStrokeColor or darkStrokeColor); rowStroke.Transparency=.65
    local head = new("Frame", {Name="Heading",BackgroundTransparency=1,
        Size=UDim2.new(1,0,0,0),LayoutOrder=1},row)
    local copy = new("Frame", {Name="Copy",BackgroundTransparency=1,
        Size=UDim2.new(1,0,0,0)},head)
    local title = label(copy,plain(o.Title or kind),14,C.Text,{Font=MEDIUM,TextWrapped=true,
        TextYAlignment=Enum.TextYAlignment.Top,Size=UDim2.new(1,0,0,18),LayoutOrder=1})
    local desc = label(copy,plain(o.Desc),12,C.Muted,{TextWrapped=true,AutomaticSize=Enum.AutomaticSize.Y,
        Size=UDim2.new(1,0,0,0),LayoutOrder=2,Visible=o.Desc ~= nil and o.Desc ~= ""})
    local controlIcon, controlIconSize
    if o.Icon ~= nil and tostring(o.Icon) ~= "" then
        controlIconSize=math.clamp(math.floor(tonumber(o.IconSize) or 16),10,24)
        controlIcon=icon(head,o.Icon,controlIconSize,
            lightTheme and (o.LightIconColor or C.Muted) or (o.IconColor or C.Muted))
    end
    local control = setmetatable({Title=plain(o.Title or kind),Desc=plain(o.Desc),__type=kind,
        Window=self.Window,Tab=self,ElementFrame=row,Slot=slot,Head=head,Copy=copy,RowStroke=rowStroke,
        TitleLabel=title,DescLabel=desc,Callback=o.Callback,GroupTitle=self._groupTitle,Locked=false,
        ControlIcon=controlIcon,ControlIconSize=controlIconSize,CopyOffsetX=controlIcon and (controlIconSize+9) or 0,
        DarkIconColor=o.IconColor,LightIconColor=o.LightIconColor,
        DarkColor=darkColor,LightColor=lightColor,DarkStrokeColor=darkStrokeColor,LightStrokeColor=lightStrokeColor,
        DarkTitleColor=o.TitleColor,LightTitleColor=o.LightTitleColor,DarkDescColor=o.DescColor,LightDescColor=o.LightDescColor},Control)
    desc.AutomaticSize=Enum.AutomaticSize.None; desc.TextYAlignment=Enum.TextYAlignment.Top
    table.insert(self.Elements,control)
    if kind ~= "Section" then
        connect(self.Window,row.MouseEnter,function()
            if control.Destroyed or control.Locked then return end
            uiTween(row,{BackgroundColor3=C.Hover,BackgroundTransparency=math.max(0,Glass.Row-.05)},.18)
            if rowStroke and rowStroke.Parent then uiTween(rowStroke,{Transparency=.03},.18) end
        end)
        connect(self.Window,row.MouseLeave,function()
            if control.Destroyed then return end
            local light=self.Window.ThemeName=="Blanco"
            uiTween(row,{BackgroundColor3=light and lightColor or darkColor,BackgroundTransparency=Glass.Row},.21)
            if rowStroke and rowStroke.Parent then uiTween(rowStroke,{Transparency=.22},.21) end
        end)
    end
    connect(self.Window,row:GetPropertyChangedSignal("Visible"),function() self:_queueFilter() end)
    connect(self.Window,row:GetPropertyChangedSignal("LayoutOrder"),function() slot.LayoutOrder=row.LayoutOrder; self:_queueFilter() end)
    control.Locked=o.Locked==true
    if control.Locked then control:Lock() end
    self:_queueFilter()
    return control
end
function Tab:Section(options)
    local o = type(options)=="string" and {Title=options} or (options or {})
    self._groupTitle = plain(o.Title)
    local c = self:_control("Section",o)
    c.ElementFrame.BackgroundTransparency = 1
    c.ElementFrame.UIStroke:Destroy(); c.RowStroke=nil
    c.DarkTitleColor=THEMES.Xero.Colors.Muted; c.LightTitleColor=THEMES.Blanco.Colors.Muted
    c.TitleLabel.TextColor3=C.Muted; c.TitleLabel.TextSize=10; c.TitleLabel.Font=BOLD
    local rule = new("Frame",{Size=UDim2.new(1,0,0,1),BackgroundColor3=C.Border,LayoutOrder=3},c.ElementFrame)
    c.Rule = rule
    return c
end
function Tab:Paragraph(options)
    local c = self:_control("Paragraph",options)
    local o = options or {}
    if o.TitleColor then c.TitleLabel.TextColor3=o.TitleColor end
    if o.DescColor then c.DescLabel.TextColor3=o.DescColor end
    if type(o.Image)=="string" and (o.Image:match("^rbxassetid://") or o.Image:match("^rbxthumb://")) then
        local pictureSize=math.max(32, tonumber(o.ImageSize) or 32)
        local align=(o.ImageAlign=="left") and "left" or "right"
        c.ImageAlign=align
        c.ThumbnailSize=pictureSize
        c.IconX=align=="left" and (pictureSize+10) or 0
        c.CopyOffsetX=(c.CopyOffsetX or 0)+c.IconX
        c.Reserve=(align=="left") and 0 or (pictureSize+14)
        c.HeadMinimum=math.max(34,pictureSize)
        local picture=new("ImageLabel",{Name="Thumbnail",Image=o.Image,BackgroundColor3=C.Field,
            Position=UDim2.new(1,-pictureSize,0,0),Size=UDim2.fromOffset(pictureSize,pictureSize),ScaleType=Enum.ScaleType.Crop},c.Head)
        round(picture,o.CircleImage and math.floor(pictureSize/2) or 10)
        local darkImageStroke=o.ImageStrokeColor or Color3.fromRGB(238,238,238)
        local lightImageStroke=o.LightImageStrokeColor or THEMES.Blanco.Colors.Border
        local pictureStroke=stroke(picture,(c.Window.ThemeName=="Blanco") and lightImageStroke or darkImageStroke,o.ImageStrokeThickness or 1)
        c.Thumbnail=picture
        c.PictureStroke=pictureStroke
        c.DarkImageStrokeColor=darkImageStroke
        c.LightImageStrokeColor=lightImageStroke
    end
    if o.Gothic then
        local visuals=c.Window.ThemeDef.Visuals
        local rule=new("Frame",{Name="CardAccent",BackgroundColor3=C.White,
            Position=UDim2.new(0,1,0,9),Size=UDim2.new(0,2,1,-18)},c.ElementFrame)
        round(rule,2)
        c.DarkColor=o.Color or THEMES.Xero.Visuals.GothicRow
        c.LightColor=o.LightColor or THEMES.Blanco.Visuals.GothicRow
        c.DarkDescColor=o.DescColor or THEMES.Xero.Visuals.GothicDesc
        c.LightDescColor=o.LightDescColor or THEMES.Blanco.Visuals.GothicDesc
        c.TitleLabel.Font=BOLD
        local badge
        if o.BadgeText and not c.Thumbnail then
            c.Reserve=math.max(c.Reserve or 0,90)
            c.HeadMinimum=math.max(c.HeadMinimum or 0,26)
            badge=label(c.Head,plain(o.BadgeText),11,visuals.GothicBadgeText,{
                AnchorPoint=Vector2.new(1,0),Position=UDim2.fromScale(1,0),Size=UDim2.fromOffset(82,24),
                TextXAlignment=Enum.TextXAlignment.Center,TextTruncate=Enum.TextTruncate.AtEnd,
                Font=MEDIUM,BackgroundColor3=visuals.GothicBadgeBackground})
            round(badge,c.Window.Radius)
        end
        c._applyThemeExtras=function(self)
            rule.BackgroundColor3=C.White
            if badge then
                local palette=self.Window.ThemeDef.Visuals
                badge.TextColor3=palette.GothicBadgeText
                badge.BackgroundColor3=palette.GothicBadgeBackground
            end
        end
    end
    c:ApplyTheme()
    function c:Set(value) return self:SetDesc(value) end
    return c
end
function Tab:Button(options)
    local c = self:_control("Button",options)
    c.Reserve=54; c.HeadMinimum=44
    local hit = button(c.Head,"→",{Name="Action",BackgroundColor3=C.Panel,BackgroundTransparency=Glass.Button,TextSize=14,
        Position=UDim2.new(1,-44,0,0),Size=UDim2.fromOffset(44,44)})
    round(hit,8); stroke(hit,C.Border); hover(c.Window,hit,C.Field)
    -- The title and description are clickable too; nested field controls are separate.
    local titleHit=button(c.Copy,"",{Name="Activate",BackgroundTransparency=1,Size=UDim2.fromScale(1,1),ZIndex=3})
    local function activate() if not c.Locked and not c.Destroyed then invoke(c.Callback) end end
    connect(c.Window,hit.Activated,activate); connect(c.Window,titleHit.Activated,activate)
    c.Interactive=hit
    return c
end
function Tab:Toggle(options)
    local o = options or {}; local c = self:_control("Toggle",o)
    c.Reserve=58; c.HeadMinimum=44
    local target=button(c.Head,"",{Name="ToggleHit",BackgroundTransparency=1,
        Position=UDim2.new(1,-48,0,0),Size=UDim2.fromOffset(48,44)})
    local hit=new("Frame",{Name="Switch",BackgroundColor3=C.Border,
        Position=UDim2.fromOffset(2,11),Size=UDim2.fromOffset(44,22)},target)
    round(hit,11); stroke(hit,C.Border)
    local knob=new("Frame",{Name="Thumb",BackgroundColor3=C.Muted,Position=UDim2.fromOffset(4,4),
        Size=UDim2.fromOffset(14,14)},hit); round(knob,7)
    c.Interactive=target
    function c:Set(value,silent)
        if self.Destroyed then return self end
        value=value == true
        local changed=self.Value ~= value; self.Value=value
        local trackColor=value and C.White or C.Border
        local thumbColor=value and C.Window or C.Muted
        local thumbPosition=UDim2.fromOffset(value and 26 or 4,4)
        if changed and not silent then
            uiTween(hit,{BackgroundColor3=trackColor},.23,Enum.EasingStyle.Quart)
            uiTween(knob,{BackgroundColor3=thumbColor,Position=thumbPosition},.23,Enum.EasingStyle.Quart)
        else
            stopTween(hit); stopTween(knob)
            hit.BackgroundColor3=trackColor
            knob.BackgroundColor3=thumbColor
            knob.Position=thumbPosition
        end
        if changed and not silent then invoke(self.Callback,value) end
        return self
    end
    c._applyThemeExtras=function(self) self:Set(self.Value,true) end
    c:Set(o.Value == true,true)
    connect(c.Window,target.Activated,function() if not c.Locked then c:Set(not c.Value) end end)
    return c
end
-- Mismo esquema de Xero Duels: entrada directa del propio TextBox,
-- sin TextButton superpuesto ni modales ni Focus forzado.
local function field(parent, placeholder)
    local box=new("TextBox",{
        Name="Field",Text="",PlaceholderText=placeholder or "",
        PlaceholderColor3=C.Faint,BackgroundColor3=C.Field,
        BackgroundTransparency=Glass.Field,BorderSizePixel=0,
        ClearTextOnFocus=false,TextColor3=C.Text,Font=MEDIUM,
        TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,
        TextYAlignment=Enum.TextYAlignment.Center,
        Active=true,TextEditable=true,Selectable=true,MultiLine=false,
        Size=UDim2.new(1,0,0,34),ZIndex=20,LayoutOrder=2
    },parent)
    round(box,10)
    local focusStroke=stroke(box,C.Border)
    focusStroke.Transparency=.28
    padding(box,10,0)
    box.Focused:Connect(function()
        uiTween(focusStroke,{Color3=C.White,Transparency=.04},.20,Enum.EasingStyle.Quart)
        uiTween(box,{BackgroundTransparency=.03},.17)
    end)
    box.FocusLost:Connect(function()
        uiTween(focusStroke,{Color3=C.Border,Transparency=.28},.22)
        uiTween(box,{BackgroundTransparency=Glass.Field},.24)
    end)
    return box
end
function Tab:Input(options)
    local o=options or {}; local c=self:_control("Input",o)
    local box=field(c.ElementFrame,o.Placeholder or "Escribe aquí…")
    c.Interactive=box; c.BodyField=box
    box.TextEditable=not c.Locked
    function c:Set(value,silent)
        if self.Destroyed then return self end
        value=tostring(value or ""); local changed=self.Value ~= value
        self.Value=value; box.Text=value
        if changed and not silent then invoke(self.Callback,value) end
        return self
    end
    c:Set(o.Value or o.Default or "",true)
    connect(c.Window,box.FocusLost,function()
        if c.Locked then box.Text=c.Value else c:Set(box.Text) end
    end)
    if o.Live then connect(c.Window,box:GetPropertyChangedSignal("Text"),function()
        if not c.Locked then c:Set(box.Text) end
    end) end
    return c
end
function Tab:Slider(options)
    local o=options or {}; local c=self:_control("Slider",o)
    local range=type(o.Value)=="table" and o.Value or {}
    local low=tonumber(range.Min or o.Min) or 0; local high=tonumber(range.Max or o.Max) or 100
    if high<low then low,high=high,low end
    local step=math.max(tonumber(o.Step) or 1,0.000001)
    local decimals=0
    while decimals<6 and math.abs(step*10^decimals-math.floor(step*10^decimals+.5))>.000001 do decimals+=1 end
    c.Min,c.Max,c.Step=low,high,step
    c.Reserve=72; c.HeadMinimum=34
    c.SliderAreaHeight=34; c.SliderLimitsGap=1

    local sliderVisuals=c.Window.ThemeDef.Visuals
    local box=field(c.Head,"")
    c.EditableField=box
    box.TextEditable=not c.Locked
    box.Name="Value"
    box.Size=UDim2.fromOffset(58,34)
    box.Position=UDim2.new(1,-58,0,0)
    box.TextXAlignment=Enum.TextXAlignment.Center
    box.BackgroundColor3=sliderVisuals.SliderValueBackground
    box.TextColor3=sliderVisuals.SliderValueText
    box.Font=MEDIUM
    box.TextSize=13
    if box:FindFirstChildOfClass("UICorner") then box:FindFirstChildOfClass("UICorner").CornerRadius=UDim.new(0,9) end
    local boxStroke=box:FindFirstChildOfClass("UIStroke")
    if boxStroke then boxStroke.Color=sliderVisuals.SliderValueStroke; boxStroke.Transparency=.12 end

    local area=button(c.ElementFrame,"",{Name="SliderArea",BackgroundTransparency=1,
        Size=UDim2.new(1,0,0,30),LayoutOrder=2})

    local rail=new("Frame",{Name="Rail",Position=UDim2.new(0,8,.5,-5),Size=UDim2.new(1,-16,0,10),
        BackgroundColor3=sliderVisuals.SliderRail},area)
    round(rail,7); local railStroke=stroke(rail,sliderVisuals.SliderRailStroke,1)

    local track=new("Frame",{Name="Track",Position=UDim2.new(0,6,.5,-3),Size=UDim2.new(1,-12,0,6),
        BackgroundColor3=sliderVisuals.SliderTrack},rail)
    round(track,4)
    local trackGradient=new("UIGradient",{Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0,sliderVisuals.SliderTrackGradient[1]),
        ColorSequenceKeypoint.new(.5,sliderVisuals.SliderTrackGradient[2]),
        ColorSequenceKeypoint.new(1,sliderVisuals.SliderTrackGradient[3])
    })},track)

    local fill=new("Frame",{Name="Fill",Size=UDim2.fromScale(0,1),BackgroundColor3=sliderVisuals.SliderFill},track)
    round(fill,4)
    local fillGradient=new("UIGradient",{Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0,sliderVisuals.SliderFillGradient[1]),
        ColorSequenceKeypoint.new(1,sliderVisuals.SliderFillGradient[2])
    })},fill)

    local halo=new("Frame",{Name="ThumbHalo",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(0,.5),
        Size=UDim2.fromOffset(20,20),BackgroundColor3=sliderVisuals.SliderHalo,BackgroundTransparency=.88,ZIndex=3},track)
    round(halo,10)
    local thumb=new("Frame",{Name="Thumb",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(0,.5),
        Size=UDim2.fromOffset(13,13),BackgroundColor3=sliderVisuals.SliderThumb,ZIndex=4},track)
    round(thumb,7); local thumbStroke=stroke(thumb,sliderVisuals.SliderThumbStroke,1); thumbStroke.Transparency=.05

    local limits=new("Frame",{Name="Limits",BackgroundTransparency=1,Size=UDim2.new(1,0,0,10),LayoutOrder=3},c.ElementFrame)
    c.SliderArea=area; c.Limits=limits
    label(limits,tostring(low),11,C.Faint,{Size=UDim2.fromScale(.5,1),Font=Enum.Font.Code})
    label(limits,tostring(high),11,C.Faint,{Size=UDim2.fromScale(.5,1),Position=UDim2.fromScale(.5,0),
        TextXAlignment=Enum.TextXAlignment.Right,Font=Enum.Font.Code})

    c._applyThemeExtras=function(self)
        local v=self.Window.ThemeDef.Visuals
        box.BackgroundColor3=v.SliderValueBackground
        box.TextColor3=v.SliderValueText
        if boxStroke then boxStroke.Color=v.SliderValueStroke end
        rail.BackgroundColor3=v.SliderRail
        railStroke.Color=v.SliderRailStroke
        track.BackgroundColor3=v.SliderTrack
        trackGradient.Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0,v.SliderTrackGradient[1]),
            ColorSequenceKeypoint.new(.5,v.SliderTrackGradient[2]),
            ColorSequenceKeypoint.new(1,v.SliderTrackGradient[3])
        })
        fill.BackgroundColor3=v.SliderFill
        fillGradient.Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0,v.SliderFillGradient[1]),
            ColorSequenceKeypoint.new(1,v.SliderFillGradient[2])
        })
        halo.BackgroundColor3=v.SliderHalo
        thumb.BackgroundColor3=v.SliderThumb
        thumbStroke.Color=v.SliderThumbStroke
    end

    local function format(value) return string.format("%." .. decimals .. "f",value) end
    function c:Set(value,silent)
        if self.Destroyed then return self end
        value=tonumber(value)
        if not value or value~=value or value==math.huge or value==-math.huge then return self end
        if value>=high then
            value=high
        else
            value=math.clamp(low+math.floor((value-low)/step+.5)*step,low,high)
        end
        value=math.clamp(tonumber(format(value)) or low,low,high)
        local changed=self.Value~=value; self.Value=value; box.Text=format(value)
        local ratio=high>low and (value-low)/(high-low) or 0
        fill.Size=UDim2.fromScale(ratio,1)
        thumb.Position=UDim2.fromScale(ratio,.5)
        halo.Position=UDim2.fromScale(ratio,.5)
        if changed and not silent then invoke(self.Callback,value) end
        return self
    end
    local function update(position)
        local width=track.AbsoluteSize.X
        if width>0 then c:Set(low+math.clamp((position.X-track.AbsolutePosition.X)/width,0,1)*(high-low)) end
    end
    connect(c.Window,area.InputBegan,function(input)
        if c.Locked then return end
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            c.Window:_beginDrag(input,update,self.Content,c); update(input.Position)
        end
    end)
    connect(c.Window,box.FocusLost,function()
        if not c.Locked then c:Set(tonumber(box.Text)) end
        box.Text=format(c.Value)
    end)
    c.Interactive=area
    c:Set(low,true)
    c:Set(range.Default or (type(o.Value)=="number" and o.Value) or o.Default or low,true)
    c:ApplyTheme()
    return c
end
-- Evita entradas repetidas incluso si un cliente actualiza varias veces
-- un dropdown mientras carga su catálogo. La unicidad es por etiqueta.
local function uniqueDropdownValues(values)
    local unique, seen = {}, {}
    for _, value in ipairs(type(values)=="table" and values or {}) do
        local key = normalized(tostring(value))
        if not seen[key] then
            seen[key] = true
            unique[#unique+1] = value
        end
    end
    return unique
end
function Tab:Dropdown(options)
    local o=options or {}
    local c=self:_control("Dropdown",o)
    c.Values=uniqueDropdownValues(o.Values)
    c.Multi=o.Multi==true or o.MultiSelect==true
    c._dropdownHeight=0
    c._dropdownOpen=false
    c._dropdownRevision=0
    local window=c.Window

    local trigger=button(c.ElementFrame,"",{Name="SelectInline",
        BackgroundColor3=C.Field,BackgroundTransparency=Glass.Field,
        Size=UDim2.new(1,0,0,40),LayoutOrder=2})
    round(trigger,10)
    local triggerEdge=stroke(trigger,C.Border)
    triggerEdge.Transparency=.18
    local valueLabel=label(trigger,"Seleccionar",13,C.Text,{
        Position=UDim2.fromOffset(11,0),Size=UDim2.new(1,-48,1,0),
        TextTruncate=Enum.TextTruncate.AtEnd})
    local indicator=label(trigger,"⌄",18,C.Muted,{
        Position=UDim2.new(1,-34,0,0),Size=UDim2.new(0,26,1,0),
        TextXAlignment=Enum.TextXAlignment.Center})
    c.Interactive=trigger
    c.BodyField=trigger
    c.ValueLabel=valueLabel

    local panel=new("Frame",{
        Name="InlineChoices",ClipsDescendants=true,
        BackgroundColor3=C.Field,BackgroundTransparency=.08,
        Size=UDim2.new(1,0,0,0),Visible=false,
    },c.ElementFrame)
    round(panel,11)
    local panelBorder=stroke(panel,C.Border);panelBorder.Transparency=.25
    c.InlineDropdown=panel
    local panelTint=new("UIGradient",{
        Color=ColorSequence.new(C.Panel,C.Field),
        Rotation=88
    },panel)
    c._applyThemeExtras=function()
        panelTint.Color=ColorSequence.new(C.Panel,C.Field)
        panelBorder.Color=C.Border
        triggerEdge.Color=C.Border
        valueLabel.TextColor3=C.Text
    end
    local findBox=field(panel,"Filtrar opciones...")
    findBox.Name="InlineSearch"
    findBox.Position=UDim2.fromOffset(8,8)
    findBox.Size=UDim2.new(1,-16,0,30)
    local separator=new("Frame",{
        Name="Separator",BackgroundColor3=C.Border,BackgroundTransparency=.45,
        Position=UDim2.fromOffset(10,44),
        Size=UDim2.new(1,-20,0,1)
    },panel)
    local optionsList=scroll(panel,{
        Name="InlineList",BackgroundTransparency=1,
        AutomaticCanvasSize=Enum.AutomaticSize.None,CanvasSize=UDim2.new(),
        ScrollBarThickness=2,ScrollBarImageColor3=C.White,
        ScrollingDirection=Enum.ScrollingDirection.Y,
        Active=true
    })
    local optionLayout=new("UIListLayout",{
        FillDirection=Enum.FillDirection.Vertical,SortOrder=Enum.SortOrder.LayoutOrder,
        Padding=UDim.new(0,3)
    },optionsList)
    local footer=label(panel,"",10,C.Faint,{
        Position=UDim2.new(0,11,1,-20),Size=UDim2.new(1,-22,0,15),
        Font=MEDIUM
    })
    local optionConnections={}
    local heightValue=new("NumberValue",{Name="DropdownHeight",Value=0},panel)
    c._dispose=function() disconnect(optionConnections) end
    local rendering=false
    local function targetHeight()
        local hasSearch=o.Searchable~=false
        local available=c.Tab.Content.AbsoluteWindowSize.Y / window.UIScale
        local visibleRows=math.min(#c.Values,math.clamp(math.floor((available-80)/36),1,5))
        if visibleRows<1 then visibleRows=1 end
        return (hasSearch and 49 or 8)+visibleRows*33+(visibleRows-1)*3+23
    end
    local function render()
        if rendering or not c._dropdownOpen or not panel.Parent or window.Destroyed then return end
        rendering=true
        disconnect(optionConnections)
        for _,child in ipairs(optionsList:GetChildren()) do
            if child:IsA("GuiObject") then child:Destroy() end
        end
        local query=normalized(findBox.Text)
        local selectedValue=c.Value
        local count=0
        local matches=0
        local unique={}
        for _,value in ipairs(c.Values) do
            local title=tostring(value)
            local key=normalized(title)
            if not unique[key] then
                unique[key]=true
                if query=="" or string.find(key,query,1,true) then
                    matches+=1
                    if count<180 then
                        count+=1
                        local selected=c.Multi and table.find(selectedValue or {},value)~=nil
                            or (not c.Multi and selectedValue==value)
                        local item=button(optionsList,"",{
                            Name="Choice"..count,LayoutOrder=count,
                            Size=UDim2.new(1,-5,0,33),
                            BackgroundColor3=selected and C.Hover or C.Row,
                            BackgroundTransparency=selected and .12 or .44
                        })
                        round(item,8)
                        local itemText=label(item,title,13,selected and C.White or C.Text,{
                            Font=selected and MEDIUM or FONT,
                            Position=UDim2.fromOffset(10,0),Size=UDim2.new(1,-41,1,0),
                            TextTruncate=Enum.TextTruncate.AtEnd
                        })
                        local selectedMark=label(item,selected and "✓" or "",12,C.White,{
                            Font=BOLD,Position=UDim2.new(1,-28,0,0),
                            Size=UDim2.fromOffset(20,33),
                            TextXAlignment=Enum.TextXAlignment.Center
                        })
                        -- Los listeners de opciones se eliminan al filtrar/cerrar.
                        -- Evitar listeners globales acumulados en búsquedas largas.
                        connect(window,item.MouseEnter,function()
                            uiTween(item,{BackgroundColor3=C.Hover,BackgroundTransparency=.07},.15)
                        end,optionConnections)
                        connect(window,item.MouseLeave,function()
                            uiTween(item,{BackgroundColor3=selected and C.Hover or C.Row,
                                BackgroundTransparency=selected and .12 or .44},.19)
                        end,optionConnections)
                        connect(window,item.Activated,function()
                            if c.Locked then return end
                            if c.Multi then
                                local a=table.clone(c.Value or {})
                                local j=table.find(a,value)
                                if j then table.remove(a,j) else table.insert(a,value) end
                                c:Set(a)
                            else
                                local revision=c._dropdownRevision
                                c:Set(value,false,true)
                                if c._dropdownRevision==revision then c:Close() end
                            end
                        end,optionConnections)
                    end
                end
            end
        end
        local contentHeight=count>0 and count*33+math.max(0,count-1)*3 or 33
        optionsList.CanvasSize=UDim2.fromOffset(0,contentHeight+3)
        footer.Text=matches==0 and "No hay coincidencias"
            or (matches>180 and ("Mostrando 180 de "..matches) or (tostring(matches).." opciones"))
        rendering=false
    end

    function c:Set(value,silent,force)
        if self.Destroyed then return self end
        local changed
        if self.Multi then
            local arr=type(value)=="table" and table.clone(value) or (value and {value} or {})
            changed=table.concat(arr,"\0") ~= table.concat(type(self.Value)=="table" and self.Value or {},"\0")
            self.Value=arr
            valueLabel.Text=#arr>0 and table.concat(arr,", ") or "Elegir opciones"
        else
            changed=self.Value~=value
            self.Value=value
            valueLabel.Text=value~=nil and tostring(value) or "Elegir opción"
        end
        if (changed or force) and not silent then
            invoke(self.Callback,self.Multi and table.clone(self.Value) or self.Value)
        end
        self.Tab:_queueFilter()
        if self._dropdownOpen and not rendering then render() end
        return self
    end
    local setOpen
    function c:Refresh(values)
        self.Values=uniqueDropdownValues(values)
        self._dropdownRevision+=1
        if self._dropdownOpen then
            setOpen(true,false)
        end
        return self
    end
    function setOpen(open,instant)
        if c.Destroyed then return end
        stopTween(heightValue)
        if open then
            if window._inlineOpen and window._inlineOpen~=c then
                window._inlineOpen:Close(true)
            end
            window._inlineOpen=c
        elseif window._inlineOpen==c then
            window._inlineOpen=nil
            findBox:ReleaseFocus()
            disconnect(optionConnections)
        end
        c._dropdownOpen=open
        c._dropdownRevision+=1
        local revision=c._dropdownRevision
        local height=open and targetHeight() or 0
        local hasSearch=o.Searchable~=false
        local listTop=hasSearch and 49 or 8
        findBox.Visible=hasSearch
        separator.Visible=hasSearch
        optionsList.Position=UDim2.fromOffset(8,listTop)
        optionsList.Size=UDim2.new(1,-16,0,math.max(32,height-listTop-23))
        if open then
            panel.Visible=true
            findBox.Text=""
            render()
            uiTween(triggerEdge,{Color3=C.White,Transparency=.08},.18)
            uiTween(indicator,{Rotation=180,TextColor3=C.White},.23,Enum.EasingStyle.Quart)
            -- Si está al fondo del panel, desplazarse suavemente para
            -- revelar las opciones, sin dejar la lista cortada.
            task.delay(.26,function()
                if c.Destroyed or revision~=c._dropdownRevision or not c._dropdownOpen or window.Destroyed or window.CurrentTab~=c.Tab then return end
                local viewport=c.Tab.Content
                local bottom=panel.AbsolutePosition.Y+panel.AbsoluteSize.Y
                local visibleBottom=viewport.AbsolutePosition.Y+viewport.AbsoluteSize.Y-8
                local delta=bottom-visibleBottom
                if delta>0 then
                    local maximum=math.max(0,viewport.AbsoluteCanvasSize.Y-viewport.AbsoluteWindowSize.Y)
                    uiTween(viewport,{CanvasPosition=Vector2.new(0,math.clamp(
                        viewport.CanvasPosition.Y+(delta+9)/window.UIScale,0,maximum/window.UIScale))},.22,Enum.EasingStyle.Quart)
                end
            end)
        else
            uiTween(triggerEdge,{Color3=C.Border,Transparency=.18},.19)
            uiTween(indicator,{Rotation=0,TextColor3=C.Muted},.20,Enum.EasingStyle.Quart)
        end
        if instant then
            heightValue.Value=height
        else
            uiTween(heightValue,{Value=height},open and .23 or .17,Enum.EasingStyle.Quart)
        end
    end
    function c:Close(instant)
        setOpen(false,instant)
        return self
    end
    function c:Open()
        if not self.Locked and not self.Destroyed and not self._dropdownOpen then setOpen(true,false) end
        return self
    end
    function c:Toggle()
        if self._dropdownOpen then return self:Close() end
        return self:Open()
    end
    connect(window,heightValue:GetPropertyChangedSignal("Value"),function()
        c._dropdownHeight=heightValue.Value
        c.Tab:_queueFilter()
    end)
    connect(window,findBox:GetPropertyChangedSignal("Text"),function()
        if c._dropdownOpen then
            optionsList.CanvasPosition=Vector2.new(0,0)
            render()
        end
    end)
    connect(window,trigger.Activated,function() c:Toggle() end)
    c:Set(o.Value or o.Default or (c.Multi and {} or nil),true)
    return c
end
function Tab:Colorpicker(options)
    local o=options or {};local c=self:_control("Colorpicker",o)
    c.Reserve=58;c.HeadMinimum=44
    local hit=button(c.Head,"",{Name="ColorChip",Position=UDim2.new(1,-46,0,0),
        Size=UDim2.fromOffset(44,44),BackgroundColor3=C.White})
    round(hit,10)
    local hitStroke=stroke(hit,C.Border,1)
    hitStroke.Transparency=.14
    c.Interactive=hit

    function c:Set(value,silent)
        if self.Destroyed or typeof(value)~="Color3" then return self end
        local changed=self.Value~=value
        self.Value=value
        hit.BackgroundColor3=value
        if self._updateColor then self._updateColor() end
        if changed and not silent then invoke(self.Callback,value) end
        return self
    end

    function c:Open()
        if self.Locked or self.Destroyed then return end
        local window=self.Window
        -- Panel de precisión: compacto, no un cuadro gigante de arcoíris.
        local panel=window:_popup(self.Title,328,348,self)
        local body=scroll(panel,{Name="ColorWorkbench",
            Position=UDim2.fromOffset(15,55),Size=UDim2.new(1,-30,1,-68),
            AutomaticCanvasSize=Enum.AutomaticSize.None,CanvasSize=UDim2.fromOffset(0,294)})
        local h,s,v=self.Value:ToHSV()
        local state={H=h,S=s,V=v,Internal=false}
        if state.S<.001 then state.H=0 end
        local initial=self.Value
        local swatch=new("Frame",{Name="ColorPreview",Position=UDim2.fromOffset(0,0),
            Size=UDim2.fromOffset(37,36),BackgroundColor3=self.Value},body)
        round(swatch,11)
        local swatchEdge=stroke(swatch,C.Border,1);swatchEdge.Transparency=.10
        label(body,"HEX",9,C.Muted,{Position=UDim2.fromOffset(48,0),
            Size=UDim2.fromOffset(40,13),Font=BOLD})
        local hex=field(body,"#FFFFFF")
        hex.Position=UDim2.fromOffset(48,13)
        hex.Size=UDim2.new(1,-137,0,28)
        hex.TextSize=12
        hex.Font=Enum.Font.Code
        local original=button(body,"Original",{Name="RestoreColor",
            Position=UDim2.new(1,-83,0,3),Size=UDim2.fromOffset(83,33),TextSize=10})
        round(original,10)
        stroke(original,C.Border,1).Transparency=.31
        connect(window,original.Activated,function() self:Set(initial) end,window._popupConnections)
        local lineRule=new("Frame",{BackgroundColor3=C.Border,BackgroundTransparency=.56,
            Position=UDim2.fromOffset(0,48),Size=UDim2.new(1,0,0,1)},body)

        local palette=button(body,"",{Name="SVPlane",BackgroundColor3=Color3.fromHSV(state.H,1,1),
            Position=UDim2.fromOffset(0,58),Size=UDim2.new(1,0,0,117),
            ClipsDescendants=true})
        round(palette,12)
        stroke(palette,C.Border,1).Transparency=.14
        local white=new("Frame",{Size=UDim2.fromScale(1,1),BorderSizePixel=0,
            BackgroundColor3=Color3.new(1,1,1),ZIndex=2},palette)
        new("UIGradient",{Transparency=NumberSequence.new({
            NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)
        })},white)
        local shade=new("Frame",{Size=UDim2.fromScale(1,1),BorderSizePixel=0,
            BackgroundColor3=Color3.new(0,0,0),ZIndex=3},palette)
        new("UIGradient",{Rotation=90,Transparency=NumberSequence.new({
            NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)
        })},shade)
        local pointer=new("Frame",{Name="PickerPosition",AnchorPoint=Vector2.new(.5,.5),
            Size=UDim2.fromOffset(16,16),BackgroundTransparency=1,ZIndex=6},palette)
        round(pointer,8)
        local pointerStroke=stroke(pointer,Color3.new(1,1,1),2)
        pointerStroke.Transparency=0
        new("UIStroke",{Color=Color3.new(0,0,0),Transparency=.24,Thickness=1},pointer)

        local tone=label(body,"TONO",9,C.Muted,{Font=BOLD,
            Position=UDim2.fromOffset(0,186),Size=UDim2.fromOffset(70,15)})
        local stats=label(body,"H 0°  ·  S 0%  ·  B 0%",9,C.Muted,{
            Position=UDim2.new(1,-192,0,186),Size=UDim2.fromOffset(192,15),
            Font=Enum.Font.Code,TextXAlignment=Enum.TextXAlignment.Right})
        local hue=button(body,"",{Name="HueStrip",Position=UDim2.fromOffset(0,206),
            Size=UDim2.new(1,0,0,12),BackgroundColor3=Color3.new(1,1,1)})
        round(hue,6)
        new("UIGradient",{Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0,Color3.fromRGB(255,48,58)),
            ColorSequenceKeypoint.new(.16,Color3.fromRGB(255,200,48)),
            ColorSequenceKeypoint.new(.33,Color3.fromRGB(70,235,90)),
            ColorSequenceKeypoint.new(.5,Color3.fromRGB(52,226,233)),
            ColorSequenceKeypoint.new(.67,Color3.fromRGB(66,90,245)),
            ColorSequenceKeypoint.new(.84,Color3.fromRGB(223,75,218)),
            ColorSequenceKeypoint.new(1,Color3.fromRGB(255,48,58))
        })},hue)
        local handle=new("Frame",{Name="HueHandle",AnchorPoint=Vector2.new(.5,.5),
            Position=UDim2.fromScale(state.H,.5),Size=UDim2.fromOffset(7,19),
            BackgroundColor3=Color3.fromRGB(249,250,250),ZIndex=5},hue)
        round(handle,4)
        stroke(handle,Color3.fromRGB(25,32,35),1)

        label(body,"COLORES RÁPIDOS",9,C.Muted,{Font=BOLD,
            Position=UDim2.fromOffset(0,231),Size=UDim2.new(1,0,0,15)})
        local colors={
            Color3.fromRGB(240,244,244),Color3.fromRGB(34,40,45),
            Color3.fromRGB(149,240,211),Color3.fromRGB(67,169,215),
            Color3.fromRGB(114,96,218),Color3.fromRGB(225,88,153),
            Color3.fromRGB(232,83,79),Color3.fromRGB(237,179,69)
        }
        local buttons={}
        for i,color in ipairs(colors) do
            local tile=button(body,"",{Name="QuickColor"..i,Position=UDim2.new((i-1)/#colors,2,0,252),
                Size=UDim2.new(1/#colors,-5,0,25),BackgroundColor3=color})
            round(tile,8)
            local edge=stroke(tile,C.Border,1);edge.Transparency=.30
            buttons[#buttons+1]={Color=color,Stroke=edge,Tile=tile}
            connect(window,tile.Activated,function() self:Set(color) end,window._popupConnections)
        end

        local function draw()
            if not state.Internal then
                local nh,ns,nv=self.Value:ToHSV()
                if ns>.001 then state.H=nh end
                state.S=ns;state.V=nv
            end
            swatch.BackgroundColor3=self.Value
            hex.Text="#"..self.Value:ToHex():upper()
            palette.BackgroundColor3=Color3.fromHSV(state.H,1,1)
            pointer.Position=UDim2.new(state.S,0,1-state.V,0)
            handle.Position=UDim2.new(state.H,0,.5,0)
            stats.Text=string.format("H %d°  ·  S %d%%  ·  B %d%%",
                math.floor(state.H*360+.5),
                math.floor(state.S*100+.5),math.floor(state.V*100+.5))
            for _,entry in ipairs(buttons) do
                entry.Stroke.Color=(entry.Color==self.Value) and C.White or C.Border
                entry.Stroke.Transparency=(entry.Color==self.Value) and .01 or .38
            end
        end
        self._updateColor=draw

        local function apply()
            state.Internal=true
            self:Set(Color3.fromHSV(state.H,state.S,state.V))
            state.Internal=false
        end
        local function updatePalette(pos)
            local size=palette.AbsoluteSize
            if size.X<=1 or size.Y<=1 then return end
            state.S=math.clamp((pos.X-palette.AbsolutePosition.X)/size.X,0,1)
            state.V=1-math.clamp((pos.Y-palette.AbsolutePosition.Y)/size.Y,0,1)
            apply()
        end
        local function updateHue(pos)
            local w=hue.AbsoluteSize.X
            if w<=1 then return end
            state.H=math.clamp((pos.X-hue.AbsolutePosition.X)/w,0,1)
            apply()
        end
        connect(window,palette.InputBegan,function(input)
            if input.UserInputType==Enum.UserInputType.MouseButton1
                or input.UserInputType==Enum.UserInputType.Touch then
                window:_beginDrag(input,updatePalette,body,self)
                updatePalette(input.Position)
            end
        end,window._popupConnections)
        connect(window,hue.InputBegan,function(input)
            if input.UserInputType==Enum.UserInputType.MouseButton1
                or input.UserInputType==Enum.UserInputType.Touch then
                window:_beginDrag(input,updateHue,body,self)
                updateHue(input.Position)
            end
        end,window._popupConnections)
        connect(window,hex.FocusLost,function()
            local v=hex.Text:gsub("#","")
            if #v==6 and v:match("^%x+$") then
                self:Set(Color3.fromHex(v))
            else
                draw()
            end
        end,window._popupConnections)
        local function fitCompact()
            local paletteHeight=math.clamp(panel.AbsoluteSize.Y-225,95,135)
            palette.Size=UDim2.new(1,0,0,paletteHeight)
            local d=paletteHeight-117
            tone.Position=UDim2.fromOffset(0,186+d)
            stats.Position=UDim2.new(1,-192,0,186+d)
            hue.Position=UDim2.fromOffset(0,206+d)
            for _,entry in ipairs(buttons) do
                local p=entry.Tile.Position
                entry.Tile.Position=UDim2.new(p.X.Scale,p.X.Offset,0,252+d)
            end
            for _,child in ipairs(body:GetChildren()) do
                if child:IsA("TextLabel") and child.Text=="COLORES RÁPIDOS" then
                    child.Position=UDim2.fromOffset(0,231+d)
                end
            end
        end
        connect(window,panel:GetPropertyChangedSignal("AbsoluteSize"),fitCompact,window._popupConnections)
        fitCompact()
        window._popupCleanup=function() self._updateColor=nil end
        draw()
    end
    connect(c.Window,hit.Activated,function() c:Open() end)
    c._applyThemeExtras=function(self) hit.BackgroundColor3=self.Value end
    c:Set(C.White,true)
    c:Set(o.Default or o.Value or C.White,true)
    return c
end
function Tab:FooterButton(options)
    local tab=self
    local window=self.Window
    assert(not window.Destroyed,"La ventana está cerrada")
    local o=options or {}
    if self._footerAction then self._footerAction:Destroy() end
    local action=button(self.Page,plain(o.Title or "Aplicar"),{
        Name="FooterAction",Position=UDim2.fromScale(1,1),AnchorPoint=Vector2.new(1,1),
        Size=UDim2.new(1,-4,0,44),TextSize=14,Font=BOLD,
        BackgroundColor3=C.Hover,TextColor3=C.White,BackgroundTransparency=0,ZIndex=7})
    round(action,window.Radius)
    hover(window,action,C.Hover,0,C.Row,0)
    self.Content.Size=UDim2.new(1,0,1,-51)
    local locked=false
    local handle={}
    function handle:SetTitle(title)
        action.Text=plain(title)
        return self
    end
    function handle:Lock()
        locked=true
        action.Active=false
        action.Selectable=false
        action.TextTransparency=.45
        return self
    end
    function handle:Unlock()
        locked=false
        action.Active=true
        action.Selectable=true
        action.TextTransparency=0
        return self
    end
    function handle:Destroy()
        if tab._footerAction~=self then return end
        tab._footerAction=nil
        action:Destroy()
        if not window.Destroyed then
            tab.Content.Size=UDim2.fromScale(1,1)
            tab:_queueFilter()
        end
    end
    connect(window,action.Activated,function()
        if not locked then invoke(o.Callback) end
    end)
    self._footerAction=handle
    if o.Locked then handle:Lock() end
    self:_queueFilter()
    return handle
end

function Tab:Select() self.Window:SelectTab(self); return self end
function Tab:LockAll() for _,c in ipairs(self.Elements) do c:Lock() end end
function Tab:UnlockAll() for _,c in ipairs(self.Elements) do c:Unlock() end end

local function normalizedMotion(mode)
    return (mode == "off" or mode == "reduced") and mode or "full"
end
function RyouUI:CreateWindow(options)
    local o=options or {}
    if self.Window and not self.Window.Destroyed then self.Window:Destroy() end
    local player=Players.LocalPlayer
    assert(player,"Ryou UI must run on the client")
    local parent=player:WaitForChild("PlayerGui")
    local resolvedTheme = canonicalThemeName(o.Theme or CURRENT_THEME_NAME)
    local family=typeof(o.Font)=="EnumItem" and o.Font.EnumType==Enum.Font and o.Font~=Enum.Font.Unknown and o.Font
    FONT,MEDIUM,BOLD=family or DEFAULT_FONT,family or DEFAULT_MEDIUM,family or DEFAULT_BOLD
    local w={_connections={},_popupConnections={},_onDestroy={},_onOpen={},_onClose={},Tabs={},
        Groups={},Opened=o.Opened~=false,Destroyed=false,Compact=false,ToggleKey=o.ToggleKey or Enum.KeyCode.RightShift,
        Title=plain(o.Title or "RyouHub"),_brandBaseTitle=plain(o.Title or "RyouHub"),Author=o.Author or "por Ryou",UIScale=1,_navOrder=0,
        ThemeName=resolvedTheme,ThemeDef=applyThemeDefinition(resolvedTheme,o),
        Motion=normalizedMotion(o.Motion), Radius=math.clamp(tonumber(o.Radius) or 8, 4, 18),
        Spacing=math.clamp(tonumber(o.Spacing) or 12, 8, 20)}
    w.RowGap=math.max(4,w.Spacing-8)
    self.Window=w
    local gui=new("ScreenGui",{Name="RyouUI14",ResetOnSpawn=false,
        DisplayOrder=10,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},parent)
    local launcherGui=new("ScreenGui",{Name="RyouUI14Launcher",ResetOnSpawn=false,
        DisplayOrder=11,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},parent)
    local launcherSurface=new("Frame",{Name="FullScreen",BackgroundTransparency=1,Size=UDim2.fromScale(1,1)},launcherGui)
    w.LauncherGui=launcherGui
    self.ScreenGui=gui; w.ScreenGui=gui
    -- Full-viewport bounds are shared by popups, dragging and responsive layout.
    local surface=new("Frame",{Name="Surface",BackgroundTransparency=1,Size=UDim2.fromScale(1,1)},gui)
    local mount=new("Frame",{Name="WindowMount",BackgroundTransparency=1,Size=UDim2.fromScale(1,1)},surface)
    local root=new("Frame",{Name="RyouPanel",BackgroundColor3=w.ThemeDef.Visuals.RootBase,BackgroundTransparency=Glass.Root,AnchorPoint=Vector2.new(.5,.5),
        Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(680,430),ClipsDescendants=true,Visible=false},mount)
    round(root,w.Radius + 5)
    local rootStroke=stroke(root,w.ThemeDef.Visuals.RootStroke)
    local scale=new("UIScale",{Scale=1},root)
    self.UIScaleObj=scale
    local backdrop=new("Frame",{Name="Background",BackgroundTransparency=1,
        Size=UDim2.fromScale(1,1),ZIndex=1,ClipsDescendants=true},root)
    local background=new("ImageLabel",{Name="Image",BackgroundTransparency=1,
        Size=UDim2.fromScale(1,1),Image=iconAsset(o.BackgroundImage) or "",
        ImageTransparency=.76,ScaleType=Enum.ScaleType.Crop},backdrop)
    round(background,w.Radius+5)
    local top=new("Frame",{Name="Topbar",BackgroundTransparency=1,Size=UDim2.new(1,0,0,58),ZIndex=5},root)
    local logo=mark(top,28,C.White)
    local logoScale=new("UIScale",{Scale=1},logo)
    logo.Position=UDim2.fromOffset(16,12)

    local titleCluster=new("Frame",{Name="TitleCluster",BackgroundTransparency=1,
        Position=UDim2.fromOffset(50,9),Size=UDim2.fromOffset(290,24)},top)
    -- El título y el contador se posicionan manualmente para mantenerlos juntos
    -- en cualquier ancho; un UIListLayout con AutomaticSize dejaba huecos raros.
    local brand=label(titleCluster,w._brandBaseTitle,18,C.Text,{Position=UDim2.fromOffset(0,0),
        Size=UDim2.fromOffset(134,23),Font=DISPLAY})
    local statusLabel=label(titleCluster,"",12,C.Muted,{Position=UDim2.fromOffset(126,0),
        Size=UDim2.fromOffset(96,22),Font=BOLD})
    local inferredGameLabel=w._brandBaseTitle:match("|%s*(.-)%s*$")
    local subtitleGame=tostring(o.Subtitle or inferredGameLabel or "RYOU")
    local subtitle=label(top,subtitleGame,10,C.Faint,{Position=UDim2.fromOffset(52,37),Size=UDim2.fromOffset(180,14)})
    local author=label(top,w.Author,11,C.Muted,{Position=UDim2.new(1,-248,0,27),Size=UDim2.fromOffset(104,20),TextXAlignment=Enum.TextXAlignment.Right})
    local controls=new("Frame",{BackgroundTransparency=1,Position=UDim2.new(1,-89,0,7),Size=UDim2.fromOffset(76,36)},top)
    local minimize=button(controls,"",{Name="Minimize"}); round(minimize,10)
    local minimizeIcon=icon(minimize,"minus")
    minimizeIcon.AnchorPoint=Vector2.new(.5,.5); minimizeIcon.Position=UDim2.fromScale(.5,.5)
    local close=button(controls,"",{Name="Close"}); round(close,10)
    local closeIcon=icon(close,"close")
    closeIcon.AnchorPoint=Vector2.new(.5,.5); closeIcon.Position=UDim2.fromScale(.5,.5)
    hover(w,minimize); hover(w,close)
    local topRule=line(root,14,57,784,1,0,C.Border); topRule.Size=UDim2.new(1,-28,0,1)
    -- RyouHub V10: rail vertical. Compacta en iconos si hay poco ancho.
    -- La lista de secciones se desplaza verticalmente, independiente de los ajustes.
    local sidebar=new("Frame",{Name="Navigation",BackgroundColor3=w.ThemeDef.Visuals.SidebarBase,
        BackgroundTransparency=Glass.Sidebar,ClipsDescendants=true,ZIndex=12},root)
    round(sidebar,w.Radius)
    local sidebarStroke=stroke(sidebar,w.ThemeDef.Visuals.SidebarStroke)
    local nav=scroll(sidebar,{Name="Tabs",Position=UDim2.fromOffset(5,41),
        Size=UDim2.new(1,-10,1,-48),ScrollingDirection=Enum.ScrollingDirection.Y,
        AutomaticCanvasSize=Enum.AutomaticSize.None,ScrollBarThickness=2})
    local navLayout=vertical(nav,4)
    local function fitNavigation()
        nav.CanvasSize=UDim2.fromOffset(0,navLayout.AbsoluteContentSize.Y+10)
    end
    connect(w,navLayout:GetPropertyChangedSignal("AbsoluteContentSize"),fitNavigation)
    connect(w,sidebar:GetPropertyChangedSignal("AbsoluteSize"),fitNavigation)
    local content=new("Frame",{Name="Content",BackgroundTransparency=1,ZIndex=4},root)
    local pageTitle=label(content,"",20,C.Text,{Size=UDim2.new(1,0,0,26),Font=BOLD,TextTruncate=Enum.TextTruncate.AtEnd})
    local pageDesc=label(content,"",12,C.Muted,{Position=UDim2.fromOffset(0,30),
        Size=UDim2.new(1,0,0,16),TextTruncate=Enum.TextTruncate.AtEnd})
    local searchBox=new("Frame",{Name="SearchBox",BackgroundColor3=C.Field,BackgroundTransparency=Glass.Field,ClipsDescendants=true,
        Position=UDim2.new(1,-312,0,8),Size=UDim2.fromOffset(198,30),ZIndex=6},top)
    round(searchBox,17); local searchStroke=stroke(searchBox,w.ThemeDef.Visuals.SearchStroke)
    local search=new("TextBox",{Name="Search",BackgroundTransparency=1,ClearTextOnFocus=false,
        Active=true,TextEditable=true,Selectable=true,Font=MEDIUM,TextColor3=C.Text,
        TextSize=12,TextTruncate=Enum.TextTruncate.AtEnd,ZIndex=20,
        PlaceholderText="Buscar ajuste...",PlaceholderColor3=C.Faint,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,
        Position=UDim2.fromOffset(28,0),Size=UDim2.new(1,-54,1,0)},searchBox)
    icon(searchBox,"search").Position=UDim2.new(0,8,.5,-10)
    local clear=button(searchBox,"×",{Name="Clear",BackgroundTransparency=1,Position=UDim2.new(1,-28,0,0),Size=UDim2.new(0,26,1,0),Visible=false})
    local pages=new("Frame",{Name="Pages",BackgroundTransparency=1,ClipsDescendants=true},content)
    local openButton=button(launcherSurface,"",{Name="OpenRyou",Position=UDim2.fromOffset(12,12),
        Size=UDim2.fromOffset(56,52),BackgroundColor3=w.ThemeDef.Visuals.OpenButtonBase,ZIndex=20})
    round(openButton,17)
    local openStroke=stroke(openButton,w.ThemeDef.Visuals.OpenStroke)
    local launcherShadow=new("UIStroke",{Color=Color3.new(),Transparency=.65,
        Thickness=3,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},openButton)
    local openAccent=segment(openButton,{17,4},{20,4},.8,C.White,56)
    local openIcon=mark(openButton,28,C.White)
    openIcon.Position=UDim2.fromOffset(12,12)
    local openLabel=label(openButton,"",12,C.Text,{Visible=false,
        Position=UDim2.fromOffset(49,0),Size=UDim2.new(1,-58,1,0),Font=MEDIUM,
        TextTruncate=Enum.TextTruncate.AtEnd})
    local sweep=line(top,0,0,30,2,0,C.White)
    sweep.Visible=false
    w.OpenButton=openButton; w._launcherMoved=false; w.UIElements={Main=root,Title=brand,ActiveStatus=statusLabel,SideBar=sidebar,MainBar=content,Pages=pages,Search=searchBox,Topbar=top}
    local desired=o.Size or UDim2.fromOffset(680,430)
    if typeof(o.Position)=="UDim2" then root.Position=o.Position end
    if typeof(o.LauncherPosition)=="UDim2" then openButton.Position=o.LauncherPosition; w._launcherMoved=true end
    w._desiredWidth=desired.X.Offset>0 and desired.X.Offset or 680
    w._desiredHeight=desired.Y.Offset>0 and desired.Y.Offset or 430
    w.Resizable=o.Resizable~=false
    local minSize=o.MinSize or Vector2.new(390,320)
    w._minWidth=math.max(300,tonumber(minSize.X) or 390)
    w._minHeight=math.max(260,tonumber(minSize.Y) or 320)

    local resizeHandles={}
    local resizeVisuals={}

    -- Affordance visual de resize: sólo en las dos esquinas inferiores.
    -- Los hitboxes de los cuatro bordes/esquinas siguen existiendo, pero ya no
    -- llenamos el marco con líneas. Cada marca es una cápsula diagonal suave.
    local function addResizeVisual(name, position, anchor, size, rotation)
        local grip = new("Frame", {
            Name = name,
            AnchorPoint = anchor,
            Position = position,
            Size = size,
            Rotation = rotation or 0,
            BackgroundColor3 = C.Text,
            BackgroundTransparency = w.ThemeDef.Visuals.ResizeGuideTransparency,
            BorderSizePixel = 0,
            ZIndex = 39,
            Visible = w.Resizable,
        }, root)
        round(grip, 99)
        table.insert(resizeVisuals, grip)
        return grip
    end

    -- Dos pequeñas líneas redondeadas por esquina, separadas del borde para
    -- que ClipsDescendants/UICorner nunca les corte las puntas.
    addResizeVisual("ResizeGuideBL_Outer", UDim2.new(0, 13, 1, -10), Vector2.new(.5, .5), UDim2.fromOffset(16, 3), -45)
    addResizeVisual("ResizeGuideBL_Inner", UDim2.new(0, 20, 1, -10), Vector2.new(.5, .5), UDim2.fromOffset(10, 3), -45)
    addResizeVisual("ResizeGuideBR_Outer", UDim2.new(1, -13, 1, -10), Vector2.new(.5, .5), UDim2.fromOffset(16, 3), 45)
    addResizeVisual("ResizeGuideBR_Inner", UDim2.new(1, -20, 1, -10), Vector2.new(.5, .5), UDim2.fromOffset(10, 3), 45)

    -- Guías laterales: cápsulas verticales discretas, un poco metidas hacia
    -- dentro del marco para conservar el redondeo exterior del hub.
    addResizeVisual("ResizeGuideLeft", UDim2.new(0, 6, .5, 0), Vector2.new(.5, .5), UDim2.fromOffset(3, 36), 0)
    addResizeVisual("ResizeGuideRight", UDim2.new(1, -6, .5, 0), Vector2.new(.5, .5), UDim2.fromOffset(3, 36), 0)

    local function addResizeHandle(name,position,anchor,size,xFactor,yFactor)
        local hit=button(root,"",{Name=name,AnchorPoint=anchor,Position=position,
            Size=size,BackgroundTransparency=1,ZIndex=40,Visible=w.Resizable})
        table.insert(resizeHandles,{Hit=hit,X=xFactor,Y=yFactor})
        return hit
    end
    -- Esquinas: cambian ancho y alto a la vez.
    addResizeHandle("ResizeBL",UDim2.fromScale(0,1),Vector2.new(0,1),UDim2.fromOffset(28,28),-1, 1)
    addResizeHandle("ResizeBR",UDim2.fromScale(1,1),Vector2.new(1,1),UDim2.fromOffset(28,28), 1, 1)
    -- Bordes invisibles más grandes: facilitan especialmente estirar verticalmente en celular.
    addResizeHandle("ResizeTop",UDim2.fromScale(.5,0),Vector2.new(.5,0),UDim2.new(.34,0,0,12),0,-1)
    addResizeHandle("ResizeBottom",UDim2.fromScale(.5,1),Vector2.new(.5,1),UDim2.new(.34,0,0,14),0,1)
    addResizeHandle("ResizeLeft",UDim2.fromScale(0,.5),Vector2.new(0,.5),UDim2.new(0,12,.34,0),-1,0)
    addResizeHandle("ResizeRight",UDim2.fromScale(1,.5),Vector2.new(1,.5),UDim2.new(0,12,.34,0),1,0)
    function w:_endDrag()
        local d=self._drag; self._drag=nil
        if d and d.Scroll and d.Scroll.Parent then d.Scroll.ScrollingEnabled=d.WasScrolling end
        if d and type(d.Owner)=="table" and d.Owner.X~=nil and d.Owner.Y~=nil then
            if self._fit then self._fit(false) end
        end
    end
    function w:_beginDrag(input,update,scroller,owner)
        self:_endDrag()
        self._drag={Input=input,Update=update,Scroll=scroller,Owner=owner,WasScrolling=scroller and scroller.ScrollingEnabled}
        if scroller then scroller.ScrollingEnabled=false end
    end
    function w:_closePopup()
        if self._inlineOpen and self._inlineOpen.Close then
            self._inlineOpen:Close(true)
        end
        self:_endDrag(); disconnect(self._popupConnections)
        if self._popupCleanup then self._popupCleanup(); self._popupCleanup=nil end
        if self._popupLayer then self._popupLayer:Destroy(); self._popupLayer=nil end
        self._popupOwner=nil
        launcherGui.Enabled=true
    end
    function w:_popup(title,width,height,owner)
        self:_closePopup()
        local layer=button(surface,"",{Name="ModalBackdrop",BackgroundColor3=Color3.new(),BackgroundTransparency=.3,Size=UDim2.fromScale(1,1),ZIndex=50})
        launcherGui.Enabled=false
        local panel=button(layer,"",{Name="Modal",BackgroundColor3=C.Panel,BackgroundTransparency=Glass.Popup,AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(width,height),ZIndex=2,ClipsDescendants=true})
        round(panel,20)
        local modalEdge=stroke(panel,w.ThemeDef.Visuals.PopupStroke)
        modalEdge.Transparency=.13
        local modalScale=new("UIScale",{Scale=.96},panel)
        uiTween(modalScale,{Scale=1},.23,Enum.EasingStyle.Quart)
        label(panel,title,16,C.Text,{Position=UDim2.fromOffset(16,17),Size=UDim2.new(1,-62,0,22),Font=BOLD,TextTruncate=Enum.TextTruncate.AtEnd})
        local dismiss=button(panel,"×",{Position=UDim2.new(1,-50,0,7),Size=UDim2.fromOffset(40,40),TextSize=18}); round(dismiss,12)
        local function fit()
            panel.Size=UDim2.fromOffset(math.max(100,math.min(width,surface.AbsoluteSize.X-24)),math.max(100,math.min(height,surface.AbsoluteSize.Y-24)))
        end
        connect(self,layer.Activated,function() self:_closePopup() end,self._popupConnections)
        connect(self,dismiss.Activated,function() self:_closePopup() end,self._popupConnections)
        connect(self,surface:GetPropertyChangedSignal("AbsoluteSize"),fit,self._popupConnections)
        self._popupLayer=layer; self._popupOwner=owner; fit()
        return panel
    end
    function w:_drawer(value)
        -- Mantiene disponible el punto de entrada legacy del navegador.
        self._drawerOpen=false
        sidebar.Visible=true
    end
    local function clampRoot()
        local bounds=surface.AbsoluteSize
        local size=Vector2.new(root.Size.X.Offset*w.UIScale,root.Size.Y.Offset*w.UIScale)
        if bounds.X<=0 or bounds.Y<=0 then return end
        local x=root.Position.X.Scale*bounds.X+root.Position.X.Offset
        local y=root.Position.Y.Scale*bounds.Y+root.Position.Y.Offset
        -- Sin margen artificial: el borde superior puede llegar exactamente a Y=0.
        local minX=math.min(size.X/2,bounds.X/2); local minY=math.min(size.Y/2,bounds.Y/2)
        root.Position=UDim2.fromOffset(math.clamp(x,minX,math.max(minX,bounds.X-minX)),math.clamp(y,minY,math.max(minY,bounds.Y-minY)))
    end
    local function clampLauncher()
        local bounds=launcherSurface.AbsoluteSize
        if bounds.X<=0 or bounds.Y<=0 then return end
        local size=Vector2.new(openButton.Size.X.Offset,openButton.Size.Y.Offset)
        local position=openButton.Position
        openButton.Position=UDim2.fromOffset(math.clamp(position.X.Scale*bounds.X+position.X.Offset,0,math.max(0,bounds.X-size.X)),
            math.clamp(position.Y.Scale*bounds.Y+position.Y.Offset,0,math.max(0,bounds.Y-size.Y)))
    end
    function w:_applyOpenButtonState()
        local ghosted=self._openButtonGhosted==true
        local visibleWhenClosed=(self._openButtonEnabled~=false) or ghosted
        local shouldShow=(not self.Opened) and visibleWhenClosed
        openButton.Visible=shouldShow
        openButton.Active=shouldShow
        openButton.AutoButtonColor=shouldShow and (not ghosted)
        openButton.BackgroundTransparency=ghosted and 1 or Glass.Button
        openAccent.BackgroundTransparency=ghosted and 1 or .05
        openLabel.TextTransparency=ghosted and 1 or 0
        launcherShadow.Transparency=ghosted and 1 or .65
        if openStroke then openStroke.Transparency=ghosted and 1 or 0 end
        if openIcon then
            for _,part in ipairs(openIcon:GetChildren()) do
                part.BackgroundTransparency=ghosted and 1 or 0
            end
        end
    end
    local function fit(skipContentLayout)
        if w.Destroyed then return end
        local bounds=surface.AbsoluteSize
        if bounds.X<1 or bounds.Y<1 then return end

        -- La ventana conserva tamaño lógico, pero nunca puede salir del viewport.
        -- En móvil se redistribuye en vez de escalarse completa, para mantener
        -- texto, botones, dropdowns y sliders legibles/táctiles.
        local maxWidth=bounds.X/w.UIScale
        local maxHeight=bounds.Y/w.UIScale
        local minWidth=math.min(w._minWidth,maxWidth)
        local minHeight=math.min(w._minHeight,maxHeight)

        local width=math.clamp(w._desiredWidth,minWidth,maxWidth)
        local height=math.clamp(w._desiredHeight,minHeight,maxHeight)
        root.Size=UDim2.fromOffset(width,height)

        local compact=width<680 or height<390
        local inset=compact and 10 or 14
        local topHeight=compact and 58 or 64
        local navWidth=width<510 and 52 or (width<850 and 140 or 162)
        local contentY=topHeight+8
        local contentEnd=height-inset
        w._compactNavigation=compact
        w._iconOnlyNav=width<510

        w.Short=height<435
        w.Narrow=width<500
        w.Compact=width<650 or w.Short
        w.ContentWidth=width-(inset*2+navWidth+11)
        top.Size=UDim2.new(1,0,0,topHeight)
        logo.Position=UDim2.fromOffset(inset,10)
        controls.Position=UDim2.new(1,-inset-76,0,6)
        controls.Size=UDim2.fromOffset(76,36)
        minimize.Position=UDim2.fromOffset(0,0); minimize.Size=UDim2.fromOffset(36,35)
        close.Position=UDim2.fromOffset(40,0); close.Size=UDim2.fromOffset(36,35)
        topRule.Position=UDim2.fromOffset(inset,topHeight-1)
        topRule.Size=UDim2.new(1,-2*inset,0,1)

        local clusterX=inset+34
        local searchWidth=math.clamp(math.floor(width*.24), 108, 220)
        local clusterWidth=math.max(0,width-clusterX-inset-91-(width>=470 and searchWidth or 0))
        titleCluster.Position=UDim2.fromOffset(clusterX,6)
        titleCluster.Size=UDim2.fromOffset(clusterWidth,24)
        local requestedTitle=w._brandBaseTitle
        local legacyTitle=requestedTitle:lower()
        brand.Text=(legacyTitle=="ryou" or legacyTitle:match("^ryou%s*|")) and "RyouHub" or requestedTitle
        brand.TextSize=compact and 18 or 22
        brand.TextTruncate=Enum.TextTruncate.AtEnd
        local measuredBrand=math.ceil(TextService:GetTextSize(brand.Text,brand.TextSize,brand.Font,Vector2.new(850,24)).X)
        local measuredStatus=math.ceil(TextService:GetTextSize(statusLabel.Text,11,statusLabel.Font,Vector2.new(150,24)).X)
        brand.Size=UDim2.fromOffset(math.min(measuredBrand+2,clusterWidth),24)
        statusLabel.Position=UDim2.fromOffset(measuredBrand+9,0)
        statusLabel.Size=UDim2.fromOffset(measuredStatus+4,24)
        statusLabel.Visible=statusLabel.Text~="" and measuredBrand+measuredStatus+13<=clusterWidth
        author.Position=UDim2.fromOffset(clusterX,28)
        local authorWidth=math.min(clusterWidth,math.ceil(TextService:GetTextSize(author.Text,11,author.Font,Vector2.new(800,24)).X))
        author.Size=UDim2.fromOffset(authorWidth,16)
        author.TextXAlignment=Enum.TextXAlignment.Left
        author.TextTruncate=Enum.TextTruncate.AtEnd
        subtitle.Position=UDim2.fromOffset(clusterX+authorWidth+9,28)
        subtitle.Size=UDim2.fromOffset(math.max(0,clusterWidth-authorWidth-9),16)
        subtitle.TextTruncate=Enum.TextTruncate.AtEnd
        subtitle.Visible=clusterWidth-authorWidth>=52 and o.Subtitle~=nil

        sidebar.Position=UDim2.fromOffset(inset,contentY)
        sidebar.Size=UDim2.fromOffset(navWidth,math.max(0,contentEnd-contentY))
        sidebar.Visible=true
        nav.Position=UDim2.fromOffset(4,5)
        nav.Size=UDim2.new(1,-8,1,-10)
        for _,group in ipairs(w.Groups) do group.ElementFrame.Visible=group.Title~="" and not w._iconOnlyNav end
        for _,tab in ipairs(w.Tabs) do
            tab.NavTitle.Visible=not w._iconOnlyNav
            tab.NavIcon.Position=w._iconOnlyNav and UDim2.new(.5,-9,.5,-9) or UDim2.new(0,10,.5,-9)
        end

        content.Position=UDim2.fromOffset(inset+navWidth+11,contentY)
        content.Size=UDim2.fromOffset(math.max(1,w.ContentWidth),math.max(1,contentEnd-contentY))
        local controlGap=inset+76+8
        searchBox.Visible=width>=470
        if not searchBox.Visible and search.Text~="" then
            search:ReleaseFocus()
            search.Text=""
        end
        searchBox.Position=UDim2.new(1,-searchWidth-controlGap,0,math.floor((topHeight-36)*.5))
        searchBox.Size=UDim2.fromOffset(searchWidth,36)
        local hasDescription=pageDesc.Text~="" and height>=300
        pageDesc.Visible=hasDescription
        local headingHeight=hasDescription and 52 or 32
        pages.Position=UDim2.fromOffset(0,headingHeight)
        pages.Size=UDim2.new(1,0,1,-headingHeight)

        local wideLauncher=openLabel.Text~=""
        openButton.Size=UDim2.fromOffset(wideLauncher and 146 or 56,52)
        openLabel.Visible=wideLauncher
        if not w._launcherMoved then openButton.Position=UDim2.fromOffset(12,12) end

        clampRoot()
        clampLauncher()
        for _,tab in ipairs(w.Tabs) do
            if not skipContentLayout then tab:_queueFilter() end
        end
    end
    w._fit=fit
    function w:SelectTab(which)
        if self.Destroyed then return end
        local target=type(which)=="number" and self.Tabs[which] or which
        if type(which)=="string" then for _,tab in ipairs(self.Tabs) do if tab.Title==which then target=tab; break end end end
        if type(target)~="table" or target.Window~=self then return end
        local previous=self.CurrentTab
        if previous and searchBox.Visible then previous.Query=search.Text end
        self:_closePopup()
        self.CurrentTab=target
        for _,tab in ipairs(self.Tabs) do
            local selected=tab==target
            tab.Page.Visible=selected
            uiTween(tab.NavButton,{
                BackgroundColor3=selected and C.Hover or self.ThemeDef.Visuals.NavButtonIdle,
                BackgroundTransparency=selected and Glass.NavActive or 1
            },.19)
            uiTween(tab.NavTitle,{TextColor3=selected and C.Text or C.Muted},.24)
            tintIcon(tab.NavIcon,selected and C.White or C.Muted)
            if tab.SelectionBar then
                tab.SelectionBar.Visible=selected
                tab.SelectionBar.BackgroundColor3=C.White
                if selected then
                    tab.SelectionBar.Size=UDim2.fromOffset(3,3)
                    tab.SelectionBar.Position=UDim2.new(0,2,.5,-1)
                    uiTween(tab.SelectionBar,{
                        Size=UDim2.fromOffset(3,18),
                        Position=UDim2.new(0,2,.5,-9),
                        BackgroundTransparency=0
                    },.30,Enum.EasingStyle.Back)
                else
                    tab.SelectionBar.BackgroundTransparency=1
                end
            end
        end
        pageTitle.Text=target.Title; pageDesc.Text=target.Desc
        fit(true)
        search.Text=searchBox.Visible and (target.Query or "") or ""; clear.Visible=search.Text~=""
        self:_drawer(false)
        target:_filter()
        if previous~=target then
            if previous then
                stopTween(previous.Page)
                previous.Page.Position=UDim2.fromOffset(0,0)
            end
            if self.Opened and self._hasOpened and self.Motion~="off" then
                target.Page.Position=UDim2.fromOffset(self.Motion=="full" and 10 or 3,0)
                uiTween(target.Page,{Position=UDim2.fromOffset(0,0)},.20,Enum.EasingStyle.Quart)
            end
            task.defer(function()
                if self.Destroyed or self.CurrentTab~=target or not sidebar.Visible or not target.NavButton.Visible then return end
                local topEdge=nav.AbsolutePosition.Y
                local bottomEdge=topEdge+nav.AbsoluteWindowSize.Y
                local first=target.NavButton.AbsolutePosition.Y
                local last=first+target.NavButton.AbsoluteSize.Y
                local delta=first<topEdge and first-topEdge or math.max(0,last-bottomEdge)
                if delta~=0 then
                    local maximum=math.max(0,nav.AbsoluteCanvasSize.Y-nav.AbsoluteWindowSize.Y)
                    nav.CanvasPosition=Vector2.new(0,math.clamp(nav.CanvasPosition.Y+delta,0,maximum))
                end
            end)
        end
        return target
    end
    function w:_tab(options,group)
        local opt=type(options)=="string" and {Title=options} or (options or {})
        assert(not self.Destroyed,"La ventana está cerrada")
        local title=plain(opt.Title or "Pestaña")
        local tab=setmetatable({Window=self,Title=title,Desc=plain(opt.Desc),Group=group,
            Elements={},_order=0,Query="",Index=#self.Tabs+1},Tab)
        local page=new("Frame",{Name=title,BackgroundTransparency=1,Size=UDim2.fromScale(1,1),Visible=false},pages)
        local list=scroll(page,{Name="Options",AutomaticCanvasSize=Enum.AutomaticSize.None})
        vertical(list,self.RowGap)
        padding(list,2,2)
        local empty=label(page,"Sin opciones para mostrar",13,C.Muted,{
            Position=UDim2.fromOffset(8,8),Size=UDim2.new(1,-16,0,24),Visible=false})

        self._navOrder+=1
        local navButton=button(nav,"",{Name=title,Size=UDim2.new(1,-3,0,40),
            BackgroundColor3=self.ThemeDef.Visuals.NavButtonIdle,BackgroundTransparency=1,LayoutOrder=self._navOrder})
        round(navButton,self.Radius)
        local selectionBar=new("Frame",{Name="Selected",Position=UDim2.new(0,2,.5,-9),
            Size=UDim2.fromOffset(2,18),BackgroundColor3=C.White,Visible=false,ZIndex=3},navButton)
        round(selectionBar,2)
        local navIcon=icon(navButton,opt.Icon,18,C.Muted,title)
        navIcon.Position=self._iconOnlyNav and UDim2.new(.5,-9,.5,-9) or UDim2.new(0,10,.5,-9)
        local titleLabel=label(navButton,title,13,C.Muted,{
            Position=UDim2.fromOffset(36,0),Size=UDim2.new(1,-43,1,0),
            Font=MEDIUM,TextTruncate=Enum.TextTruncate.AtEnd,Visible=not self._iconOnlyNav})
        tab.Page,tab.Content,tab.Empty=page,list,empty
        tab.NavButton,tab.NavTitle,tab.NavIcon,tab.SelectionBar=navButton,titleLabel,navIcon,selectionBar
        tab.IconScale=new("UIScale",{Scale=1},navIcon)
        table.insert(self.Tabs,tab)
        connect(self,navButton.Activated,function() self:SelectTab(tab) end)
        local function idle()
            if self.CurrentTab~=tab then uiTween(navButton,{BackgroundTransparency=1},.14) end
        end
        connect(self,navButton.MouseEnter,function()
            if self.CurrentTab~=tab then uiTween(navButton,{BackgroundColor3=C.Hover,BackgroundTransparency=.26},.12) end
        end)
        connect(self,navButton.MouseLeave,idle)
        connect(self,list:GetPropertyChangedSignal("AbsoluteSize"),function() tab:_queueFilter() end)
        if not self.CurrentTab then self:SelectTab(tab) end
        return tab
    end
    function w:Tab(options) return self:_tab(options) end
    function w:Section(options)
        local opt=type(options)=="string" and {Title=options} or (options or {})
        local title=plain(opt.Title)
        self._navOrder+=1
        local heading=label(nav,title,11,C.Faint,{Font=BOLD,LayoutOrder=self._navOrder,
            Size=UDim2.new(1,-4,0,23),Visible=title~="" and not self._iconOnlyNav,TextTruncate=Enum.TextTruncate.AtEnd})
        padding(heading,9,0)
        local section={Window=self,ElementFrame=heading,Title=title}
        function section:Tab(config) return self.Window:_tab(config,self) end
        function section:Open() return self end
        function section:Close() return self end
        table.insert(self.Groups,section)
        return section
    end
    function w:SetTitle(title)
        self.Title=plain(title)

        local active=self.Title:match("(%d+)%s+activos")
        -- Quita primero el contador y después el separador. No metas el punto medio
        -- UTF-8 dentro de una clase [] de patrones Lua: puede comerse sólo un byte
        -- y dejar el carácter de reemplazo que se ve como "?" junto al nombre del juego.
        local baseTitle=self.Title:gsub("%s*%d+%s+activos%s*$","")
        baseTitle=baseTitle:gsub("%s*·%s*$","")
        baseTitle=baseTitle:gsub("%s*%-%s*$","")
        baseTitle=baseTitle:gsub("%s+$","")
        if baseTitle=="" then baseTitle="Ryou" end
        self._brandBaseTitle=baseTitle

        statusLabel.Text=active and (active.." activos") or ""

        if self._fit then
            self._fit(true)
        else
            brand.Text=self._brandBaseTitle
        end
        return self
    end
    function w:SetAuthor(text) self.Author=plain(text); author.Text=self.Author; fit(true); return self end
    function w:SetSize(size)
        self._desiredWidth=math.max(1,size.X.Offset); self._desiredHeight=math.max(1,size.Y.Offset); fit(); return self
    end
    function w:GetSize() return Vector2.new(self._desiredWidth,self._desiredHeight) end
    function w:SetResizable(value)
        self.Resizable=value~=false
        for _,info in ipairs(resizeHandles) do info.Hit.Visible=self.Resizable end
        for _,grip in ipairs(resizeVisuals) do grip.Visible=self.Resizable end
        return self
    end
    function w:SetUIScale(value)
        self.UIScale=math.clamp(tonumber(value) or 1,.7,1.4); scale.Scale=self.UIScale
        RyouUI.UIScale=self.UIScale; fit(); return self
    end
    function w:GetUIScale() return self.UIScale end
    function w:SetToTheCenter() root.Position=UDim2.fromScale(.5,.5); clampRoot(); return self end
    function w:SetToggleKey(key) self.ToggleKey=key; return self end
    function w:SetOpenButtonVisible(value)
        if value==nil then
            self._openButtonEnabled=true
        else
            self._openButtonEnabled=value~=false
        end
        self:_applyOpenButtonState()
        return self
    end
    function w:SetOpenButtonGhosted(value)
        self._openButtonGhosted=value==true
        self:_applyOpenButtonState()
        return self
    end
    function w:EditOpenButton(config)
        if config.Enabled~=nil then self:SetOpenButtonVisible(config.Enabled) end
        if config.Ghosted~=nil then self:SetOpenButtonGhosted(config.Ghosted) end
        if config.Title~=nil then openLabel.Text=plain(config.Title); fit(true) end
        return self
    end
    function w:GetTheme()
        return self.ThemeName or CURRENT_THEME_NAME
    end
    function w:SetTheme(name, silent)
        local resolved = canonicalThemeName(name)
        self:_closePopup()
        local themeDef=applyThemeDefinition(resolved,o)
        self.ThemeName=resolved
        self.ThemeDef=themeDef

        root.BackgroundColor3 = themeDef.Visuals.RootBase
        root.BackgroundTransparency = Glass.Root
        rootStroke.Color = themeDef.Visuals.RootStroke
        topRule.BackgroundColor3 = C.Border
        sidebar.BackgroundColor3 = themeDef.Visuals.SidebarBase
        sidebar.BackgroundTransparency = Glass.Sidebar
        sidebarStroke.Color = themeDef.Visuals.SidebarStroke
        searchBox.BackgroundColor3 = C.Field
        searchBox.BackgroundTransparency = Glass.Field
        searchStroke.Color = themeDef.Visuals.SearchStroke
        openButton.BackgroundColor3 = themeDef.Visuals.OpenButtonBase
        openButton.BackgroundTransparency = Glass.Button
        openStroke.Color = themeDef.Visuals.OpenStroke
        for _, grip in ipairs(resizeVisuals) do
            grip.BackgroundColor3 = C.Text
            grip.BackgroundTransparency = themeDef.Visuals.ResizeGuideTransparency
        end
        self:_applyOpenButtonState()
        tintIcon(logo,C.White); tintIcon(openIcon,C.White)
        applyThemeRolesRecursive(gui)
        applyThemeRolesRecursive(launcherGui)
        if self.CurrentTab then
            self:SelectTab(self.CurrentTab)
        end
        for _, tab in ipairs(self.Tabs) do
            for _, control in ipairs(tab.Elements or {}) do
                if control.ApplyTheme then control:ApplyTheme() end
            end
        end
        if not silent and RyouUI.Notify and RyouUI.Window == self then
            RyouUI:Notify({Title = "Tema", Content = "Interfaz cambiada a " .. (resolved == "Blanco" and "Blanco" or "Oscuro")})
        end
        return self
    end
    function w:OnDestroy(callback) table.insert(self._onDestroy,callback); return self end
    function w:OnOpen(callback) table.insert(self._onOpen,callback); return self end
    function w:OnClose(callback) table.insert(self._onClose,callback); return self end
    local revision=0
    local origin=UDim2.fromOffset(0,0)
    local function resetEntrance()
        for _,node in ipairs({logoScale,brand,author,sidebar,nav,sweep,pageTitle,pageDesc}) do stopTween(node) end
        logoScale.Scale=1
        brand.TextTransparency=0
        author.TextTransparency=0
        sidebar.BackgroundTransparency=Glass.Sidebar
        nav.Position=UDim2.fromOffset(4,5)
        sweep.Visible=false
        pageTitle.TextTransparency=0
        pageDesc.TextTransparency=0
        for _,tab in ipairs(w.Tabs) do
            stopTween(tab.NavTitle)
            stopTween(tab.IconScale)
            tab.NavTitle.TextTransparency=0
            tab.IconScale.Scale=1
        end
    end
    local function animateWindow(opened)
        revision+=1
        local token=revision
        local first=opened and not w._hasOpened and w.Motion=="full"
        local wasVisible=root.Visible
        resetEntrance()
        stopTween(root)
        if opened then
            w._hasOpened=true
            root.Visible=true
        end
        root.Interactable=opened
        if w.Motion=="off" then
            stopTween(mount)
            mount.Position=origin
            root.BackgroundTransparency=Glass.Root
            root.Visible=opened
            return
        end
        local travel=w.Motion=="reduced" and 3 or (first and 12 or 7)
        local seconds=first and .36 or (opened and .20 or .17)
        local offset=UDim2.fromOffset(0,travel)
        if opened and not wasVisible then
            mount.Position=offset
            root.BackgroundTransparency=math.min(1,Glass.Root+.60)
        end
        local direction=opened and Enum.EasingDirection.Out or Enum.EasingDirection.In
        uiTween(mount,{Position=opened and origin or offset},seconds,Enum.EasingStyle.Quart,direction,true)
        uiTween(root,{BackgroundTransparency=opened and Glass.Root or .60},seconds,Enum.EasingStyle.Quart,direction,true)

        local function after(delay,callback)
            task.delay(delay,function()
                if not w.Destroyed and revision==token then callback() end
            end)
        end
        if not opened then
            after(seconds,function() root.Visible=false end)
        end
        if not first then return end

        logoScale.Scale=.72
        brand.TextTransparency=1
        author.TextTransparency=1
        sidebar.BackgroundTransparency=1
        nav.Position=UDim2.fromOffset(0,5)
        pageTitle.TextTransparency=1
        pageDesc.TextTransparency=1
        for index,tab in ipairs(w.Tabs) do
            tab.NavTitle.TextTransparency=1
            tab.IconScale.Scale=.64
            after(.20+math.min(index-1,9)*.025,function()
                uiTween(tab.NavTitle,{TextTransparency=0},.17)
                uiTween(tab.IconScale,{Scale=1},.18)
                if w.CurrentTab==tab then
                    tab.SelectionBar.BackgroundTransparency=1
                    uiTween(tab.SelectionBar,{BackgroundTransparency=0,Size=UDim2.fromOffset(3,18),
                        Position=UDim2.new(0,2,.5,-9)},.21,Enum.EasingStyle.Quart)
                end
            end)
        end
        after(.07,function() uiTween(logoScale,{Scale=1},.23,Enum.EasingStyle.Quart) end)
        after(.12,function()
            uiTween(brand,{TextTransparency=0},.22)
            sweep.Position=UDim2.new(0,0,1,-2)
            sweep.BackgroundTransparency=.2
            sweep.Visible=true
            uiTween(sweep,{Position=UDim2.new(1,-30,1,-2),BackgroundTransparency=1},.35,Enum.EasingStyle.Quart)
        end)
        after(.19,function()
            uiTween(author,{TextTransparency=0},.23)
            uiTween(sidebar,{BackgroundTransparency=Glass.Sidebar},.24)
            uiTween(nav,{Position=UDim2.fromOffset(4,5)},.25,Enum.EasingStyle.Quart)
        end)
        after(.36,function()
            uiTween(pageTitle,{TextTransparency=0},.28)
            uiTween(pageDesc,{TextTransparency=0},.30)
            local selected=w.CurrentTab
            if selected then
                stopTween(selected.Page)
                selected.Page.Position=UDim2.fromOffset(0,8)
                uiTween(selected.Page,{Position=origin},.30,Enum.EasingStyle.Quart)
            end
        end)
    end
    function w:SetMotion(mode)
        local nextMode=normalizedMotion(mode)
        if nextMode~=self.Motion then
            self.Motion=nextMode
            local hadOpened=self._hasOpened
            self._hasOpened=true
            animateWindow(self.Opened)
            self._hasOpened=hadOpened or self.Opened
        end
        return self
    end
    function w:GetMotion() return self.Motion end
    function w:Open()
        if self.Destroyed then return self end
        local changed=not self.Opened
        self.Opened=true
        if changed or not self._hasOpened then animateWindow(true) end
        self:_applyOpenButtonState()
        if changed then for _,callback in ipairs(self._onOpen) do invoke(callback) end end
        return self
    end
    function w:Close()
        if self.Destroyed then return self end
        local changed=self.Opened
        self.Opened=false
        self:_closePopup()
        if changed then animateWindow(false) end
        self:_applyOpenButtonState()
        if changed then for _,callback in ipairs(self._onClose) do invoke(callback) end end
        return self
    end
    function w:Toggle() if self.Opened then return self:Close() else return self:Open() end end
    function w:Destroy()
        if self.Destroyed then return end
        self.Destroyed=true; self:_closePopup(); disconnect(self._connections)
        revision+=1
        stopTween(mount)
        table.clear(self._notices or {})
        gui:Destroy(); launcherGui:Destroy()
        if RyouUI.Window==self then RyouUI.Window=nil; RyouUI.ScreenGui=nil; RyouUI.UIScaleObj=nil end
        for _,callback in ipairs(self._onDestroy) do invoke(callback) end
    end
    function w:Notify(config)
        if RyouUI.Window==self then return RyouUI:Notify(config) end
    end
    function w:Dialog(config)
        if self.Destroyed or not self.Opened then return end
        local cfg=config or {}; local panel=self:_popup(plain(cfg.Title or "Ryou"),350,230,nil)
        local body=scroll(panel,{Position=UDim2.fromOffset(18,58),Size=UDim2.new(1,-36,1,-122)})
        label(body,plain(cfg.Content or cfg.Desc),13,C.Muted,{Size=UDim2.new(1,-6,0,0),AutomaticSize=Enum.AutomaticSize.Y,TextWrapped=true,TextYAlignment=Enum.TextYAlignment.Top})
        local buttons=cfg.Buttons or {{Title="Aceptar"}}
        for i,entry in ipairs(buttons) do
            local b=button(panel,entry.Title or "Aceptar",{Position=UDim2.new((i-1)/#buttons,16,1,-54),Size=UDim2.new(1/#buttons,-22,0,36)})
            round(b,8)
            connect(self,b.Activated,function() self:_closePopup(); invoke(entry.Callback) end,self._popupConnections)
        end
        local layer=self._popupLayer
        return {Close=function() if self._popupLayer==layer then self:_closePopup() end end}
    end
    -- La navegación de secciones vive en el dock, sin selector emergente.
    connect(w,minimize.Activated,function() w:Close() end)
    connect(w,close.Activated,function()
        w:Dialog({Title="Cerrar Ryou",Content="Se cerrará el panel y se limpiará esta sesión. Puedes volver a ejecutar el hub cuando quieras.",
            Buttons={{Title="Volver"},{Title="Cerrar",Callback=function() w:Destroy() end}}})
    end)
    connect(w,clear.Activated,function() search.Text="" end)
    connect(w,search:GetPropertyChangedSignal("Text"),function()
        clear.Visible=search.Text~=""
        if w.CurrentTab then w.CurrentTab.Query=search.Text; w.CurrentTab:_queueFilter() end
    end)
    local function drag(input,target,centered)
        if input.UserInputType~=Enum.UserInputType.MouseButton1 and input.UserInputType~=Enum.UserInputType.Touch then return end
        local start=input.Position; local pos=target.Position; local moved=false
        local parentSize=target.Parent.AbsoluteSize
        local startX=pos.X.Scale*parentSize.X+pos.X.Offset
        local startY=pos.Y.Scale*parentSize.Y+pos.Y.Offset
        w:_beginDrag(input,function(position)
            local delta=position-start
            if delta.Magnitude>(centered and 5 or 8) then moved=true end
            if moved then
                target.Position=UDim2.fromOffset(startX+delta.X,startY+delta.Y)
                if centered then clampRoot() else
                    w._launcherMoved=true
                    w._skipOpen=true
                    clampLauncher()
                end
            end
        end)
    end

    local function beginResize(info,input)
        if not w.Resizable then return end
        if input.UserInputType~=Enum.UserInputType.MouseButton1 and input.UserInputType~=Enum.UserInputType.Touch then return end
        local start=input.Position
        local startWidth=root.AbsoluteSize.X
        local startHeight=root.AbsoluteSize.Y
        local bounds=surface.AbsoluteSize
        local rootCenter=Vector2.new(root.AbsolutePosition.X+root.AbsoluteSize.X/2,root.AbsolutePosition.Y+root.AbsoluteSize.Y/2)
        w:_beginDrag(input,function(position)
            local delta=position-start
            local maxScreenW=bounds.X
            local maxScreenH=bounds.Y
            local minScreenW=math.min(w._minWidth*w.UIScale,maxScreenW)
            local minScreenH=math.min(w._minHeight*w.UIScale,maxScreenH)
            local screenW=math.clamp(startWidth+info.X*delta.X,minScreenW,maxScreenW)
            local screenH=math.clamp(startHeight+info.Y*delta.Y,minScreenH,maxScreenH)
            w._desiredWidth=screenW/w.UIScale
            w._desiredHeight=screenH/w.UIScale
            root.Size=UDim2.fromOffset(w._desiredWidth,w._desiredHeight)
            if not w._resizeFitQueued then
                w._resizeFitQueued=true
                task.defer(function()
                    RunService.RenderStepped:Wait()
                    w._resizeFitQueued=false
                    if not w.Destroyed then fit(true) end
                end)
            end
        end,nil,info)
    end
    for _,info in ipairs(resizeHandles) do
        connect(w,info.Hit.InputBegan,function(input) beginResize(info,input) end)
    end
    top.Active=true
    connect(w,top.InputBegan,function(input)
        local pos=searchBox.AbsolutePosition
        if input.Position.X < controls.AbsolutePosition.X and
            (not searchBox.Visible or input.Position.X < pos.X or input.Position.X > pos.X+searchBox.AbsoluteSize.X) then
            drag(input,root,true)
        end
    end)
    connect(w,openButton.InputBegan,function(input)
        if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then
            if w._drag then return end
            w._skipOpen=false
            drag(input,openButton,false)
        end
    end)
    connect(w,openButton.Activated,function() if not w._skipOpen then w:Toggle() end end)
    connect(w,Input.InputChanged,function(input)
        local d=w._drag
        if d and ((d.Input.UserInputType==Enum.UserInputType.Touch and input==d.Input)
            or (d.Input.UserInputType==Enum.UserInputType.MouseButton1 and input.UserInputType==Enum.UserInputType.MouseMovement)) then d.Update(input.Position) end
    end,w._connections)
    connect(w,Input.InputEnded,function(input)
        local d=w._drag
        if d and (input==d.Input or (d.Input.UserInputType==Enum.UserInputType.MouseButton1 and input.UserInputType==Enum.UserInputType.MouseButton1)) then w:_endDrag() end
    end,w._connections)
    connect(w,Input.WindowFocusReleased,function() w:_endDrag() end,w._connections)
    connect(w,Input.InputBegan,function(input,processed)
        if input.KeyCode==Enum.KeyCode.Escape and (w._popupLayer or w._inlineOpen) and not Input:GetFocusedTextBox() then w:_closePopup(); return end
        if w._drag or processed or Input:GetFocusedTextBox() then return end
        if input.KeyCode==w.ToggleKey then w:Toggle() end
    end,w._connections)
    connect(w,surface:GetPropertyChangedSignal("AbsoluteSize"),fit)
    connect(w,launcherSurface:GetPropertyChangedSignal("AbsoluteSize"),clampLauncher)
    connect(w,gui.Destroying,function() if not w.Destroyed then w:Destroy() end end)
    connect(w,launcherGui.Destroying,function() if not w.Destroyed then w:Destroy() end end)
    if o.OpenButton then w:EditOpenButton(o.OpenButton) end
    if o.Author then w:SetAuthor(o.Author) end
    if o.UIScale then w:SetUIScale(o.UIScale) end
    w:SetTheme(resolvedTheme, true)
    task.defer(function()
        if not w.Destroyed then
            fit()
            if w.Opened and not w._hasOpened then animateWindow(true) end
        end
    end)
    return w
end
RyouUI.Icons = {}
for name in pairs(glyphs) do RyouUI.Icons[name]=true end
for alias in pairs(iconAliases) do RyouUI.Icons[alias]=true end
function RyouUI:RegisterIcon(name,asset)
    local key=normalizeIconName(name)
    local uri=iconAsset(asset)
    assert(key:match("^[%w_%-]+$") and uri,"Se requiere un nombre y un ID de imagen de Roblox")
    registeredIcons[key]=uri
    self.Icons[key]=uri
    return self
end
function RyouUI:GetIconAsset(name) return iconAsset(name) end
function RyouUI:PreloadIcon(name,callback)
    local asset=iconAsset(name)
    if asset then
        task.spawn(function()
            local ok=pcall(function() game:GetService("ContentProvider"):PreloadAsync({asset}) end)
            invoke(callback,ok and asset or nil)
        end)
    else
        invoke(callback,nil)
    end
    return self
end

function RyouUI:SetTheme(name)
    local resolved = canonicalThemeName(name)
    if self.Window and not self.Window.Destroyed then
        self.Window:SetTheme(resolved,true)
    else
        applyThemeDefinition(resolved)
    end
    local publicName = resolved == "Xero" and "Ryou" or resolved
    self.Theme = {Name = publicName, Accent = C.White, Background = C.Window, Text = C.Text}
    return self.Theme
end
function RyouUI:GetCurrentTheme()
    if self.Window and not self.Window.Destroyed and self.Window.GetTheme then
        return self.Window:GetTheme()
    end
    return CURRENT_THEME_NAME
end
function RyouUI:GetThemes()
    return {
        Ryou = {Name = "Ryou"},
        Xero = {Name = "Ryou"}, -- legacy alias
        Nox = {Name = "Ryou"},  -- legacy alias
        Onyx = {Name = "Ryou"}, -- legacy alias
        Blanco = {Name = "Blanco"},
        White = {Name = "Blanco"},
    }
end
local notices = {
    info={Icon="info",Color=Color3.fromRGB(122,174,235)},
    success={Icon="check",Color=Color3.fromRGB(132,220,173)},
    warning={Icon="warning",Color=Color3.fromRGB(249,194,106)},
    error={Icon="close",Color=Color3.fromRGB(255,133,138)},
}
function RyouUI:Notify(options)
    local w=self.Window
    if not w or w.Destroyed then return end
    local o=options or {}
    local stack=w._noticeStack
    if not stack then
        stack=new("Frame",{Name="Notices",AnchorPoint=Vector2.new(1,1),
            Position=UDim2.new(1,-12,1,-14),Size=UDim2.new(1,-24,0,0),
            AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1,ZIndex=100},w.ScreenGui)
        new("UISizeConstraint",{MaxSize=Vector2.new(306,math.huge)},stack)
        vertical(stack,6)
        w._noticeStack=stack
        w._notices={}
        w._noticeSequence=0
    end
    local toast=notices[o.Type] or notices.info
    local maxEntries=w.ScreenGui.AbsoluteSize.Y<430 and 1 or 2
    while #w._notices>=maxEntries do w._notices[1].Close(true) end
    w._noticeSequence+=1
    local slot=new("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0),
        AutomaticSize=Enum.AutomaticSize.Y,LayoutOrder=w._noticeSequence},stack)
    local panel=new("Frame",{BackgroundColor3=C.Panel,Position=UDim2.fromOffset(18,0),
        BackgroundTransparency=.62,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y},slot)
    round(panel,w.Radius)
    stroke(panel,C.Border)
    local statusIcon=icon(panel,toast.Icon,17,toast.Color)
    statusIcon.Position=UDim2.fromOffset(10,11)
    local copy=new("Frame",{Position=UDim2.fromOffset(34,0),Size=UDim2.new(1,-46,0,0),
        AutomaticSize=Enum.AutomaticSize.Y,BackgroundTransparency=1},panel)
    vertical(copy,2); padding(copy,0,8)
    label(copy,plain(o.Title or "Ryou"),13,C.Text,{Font=BOLD,
        LayoutOrder=1,TextTruncate=Enum.TextTruncate.AtEnd})
    local body=plain(o.Content or o.Desc)
    if body~="" then
        label(copy,body,12,C.Muted,{LayoutOrder=2,Size=UDim2.new(1,0,0,34),
            TextWrapped=true,TextTruncate=Enum.TextTruncate.AtEnd})
    end
    local handle={}
    local function remove()
        if w.Destroyed or not slot.Parent then return end
        local index=table.find(w._notices,handle)
        if index then table.remove(w._notices,index) end
        slot:Destroy()
    end
    local closing=false
    function handle.Close(immediate)
        if w.Destroyed or not slot.Parent then return end
        if immediate==true or w.Motion=="off" then remove(); return end
        if closing then return end
        closing=true
        uiTween(panel,{Position=UDim2.fromOffset(22,0),BackgroundTransparency=.72},.14)
        task.delay(.14,remove)
    end
    table.insert(w._notices,handle)
    uiTween(panel,{Position=UDim2.fromOffset(0,0),BackgroundTransparency=.02},.20,Enum.EasingStyle.Quart)
    task.delay(math.clamp(tonumber(o.Duration) or 3,1,12),function() handle.Close() end)
    return handle
end
RyouUI:SetTheme("Ryou")
return RyouUI
