-- RyouHub · biblioteca visual compartida
-- Creador: Ryou. Se conservan los alias y campos de la API de compatibilidad.

local Players = game:GetService("Players")
local Input = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")

-- Ryou themes + backgrounds --------------------------------------------
local XeroEnv = (getgenv and getgenv()) or _G

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
            Window = Color3.fromRGB(13,17,21), Panel = Color3.fromRGB(21,27,34),
            Row = Color3.fromRGB(27,35,43), Field = Color3.fromRGB(14,20,26),
            Hover = Color3.fromRGB(39,52,62), Border = Color3.fromRGB(60,75,87),
            Text = Color3.fromRGB(239,246,250), Muted = Color3.fromRGB(174,191,204),
            Faint = Color3.fromRGB(134,156,172), White = Color3.fromRGB(156,229,206),
        },
        Glass = {
            Root = 0.02,
            Sidebar = 0.04,
            Row = 0.07,
            Field = 0.22,
            Button = 0.16,
            NavIdle = 0.26,
            NavHover = 0.14,
            NavActive = 0.05,
            Popup = 0.08,
        },
        Visuals = {
            RootBase = Color3.fromRGB(16,23,29),
            RootStroke = Color3.fromRGB(70,92,105),
            RootGradient = {
                Color3.fromRGB(11,17,22),
                Color3.fromRGB(29,43,50),
                Color3.fromRGB(15,23,29),
            },
            SidebarBase = Color3.fromRGB(16,24,30),
            SidebarStroke = Color3.fromRGB(55,76,88),
            SearchStroke = Color3.fromRGB(62,79,91),
            OpenStroke = Color3.fromRGB(79,125,117),
            OpenButtonBase = Color3.fromRGB(20,30,36),
            BackdropGlowA = Color3.fromRGB(45,93,90),
            NavButtonIdle = Color3.fromRGB(25,34,42),
            NavButtonHover = Color3.fromRGB(41,57,66),
            ResizeGuideTransparency = 0.24,
            ControlStroke = Color3.fromRGB(54,70,82),
            FieldStroke = Color3.fromRGB(50,67,77),
            ButtonBase = Color3.fromRGB(25,35,43),
            ButtonStroke = Color3.fromRGB(56,75,88),
            DropdownStroke = Color3.fromRGB(58,78,87),
            PopupStroke = Color3.fromRGB(83,126,120),
            GothicShell = Color3.fromRGB(156,229,206),
            GothicShellStroke = Color3.fromRGB(79,125,117),
            GothicGlow = Color3.fromRGB(35,62,62),
            GothicBar = Color3.fromRGB(156,229,206),
            GothicCorner = Color3.fromRGB(88,150,139),
            GothicWatermark = Color3.fromRGB(156,229,206),
            GothicWatermarkTransparency = 0.90,
            GothicRow = Color3.fromRGB(25,35,44),
            GothicStroke = Color3.fromRGB(60,83,94),
            GothicDesc = Color3.fromRGB(180,200,211),
            GothicBadgeText = Color3.fromRGB(224,251,243),
            GothicBadgeBackground = Color3.fromRGB(30,54,55),
            GothicBadgeStroke = Color3.fromRGB(67,119,111),
            SliderValueBackground = Color3.fromRGB(18,26,33),
            SliderValueText = Color3.fromRGB(239,246,250),
            SliderValueStroke = Color3.fromRGB(59,82,91),
            SliderRail = Color3.fromRGB(17,25,32),
            SliderRailStroke = Color3.fromRGB(60,83,94),
            SliderTrack = Color3.fromRGB(57,80,89),
            SliderTrackGradient = {Color3.fromRGB(38,56,68),Color3.fromRGB(74,101,111),Color3.fromRGB(38,56,68)},
            SliderFill = Color3.fromRGB(156,229,206),
            SliderFillGradient = {Color3.fromRGB(177,245,225),Color3.fromRGB(90,169,162)},
            SliderHalo = Color3.fromRGB(156,229,206),
            SliderThumb = Color3.fromRGB(236,252,247),
            SliderThumbStroke = Color3.fromRGB(77,127,121),
        },
    },
    Blanco = {
        Name = "Blanco",
        Colors = {
            Window = Color3.fromRGB(248,248,250), Panel = Color3.fromRGB(241,241,244),
            Row = Color3.fromRGB(232,232,236), Field = Color3.fromRGB(252,252,255),
            Hover = Color3.fromRGB(223,223,228), Border = Color3.fromRGB(201,201,208),
            Text = Color3.fromRGB(20,20,24), Muted = Color3.fromRGB(88,88,98),
            Faint = Color3.fromRGB(122,122,132), White = Color3.fromRGB(255,255,255),
        },
        Glass = {
            Root = 0.02,
            Sidebar = 0.08,
            Row = 0.12,
            Field = 0.04,
            Button = 0.08,
            NavIdle = 0.08,
            NavHover = 0.02,
            NavActive = 0.00,
            Popup = 0.04,
        },
        Visuals = {
            RootBase = Color3.fromRGB(250,250,252),
            RootStroke = Color3.fromRGB(210,210,216),
            RootGradient = {
                Color3.fromRGB(255,255,255),
                Color3.fromRGB(245,245,248),
                Color3.fromRGB(236,236,240),
            },
            SidebarBase = Color3.fromRGB(244,244,247),
            SidebarStroke = Color3.fromRGB(214,214,220),
            SearchStroke = Color3.fromRGB(206,206,212),
            OpenStroke = Color3.fromRGB(190,190,198),
            OpenButtonBase = Color3.fromRGB(247,247,250),
            BackdropGlowA = Color3.fromRGB(225,225,230),
            NavButtonIdle = Color3.fromRGB(238,238,242),
            NavButtonHover = Color3.fromRGB(229,229,234),
            ResizeGuideTransparency = 0.42,
            ControlStroke = Color3.fromRGB(198,198,205),
            FieldStroke = Color3.fromRGB(202,202,209),
            ButtonBase = Color3.fromRGB(246,246,249),
            ButtonStroke = Color3.fromRGB(202,202,209),
            DropdownStroke = Color3.fromRGB(202,202,209),
            PopupStroke = Color3.fromRGB(190,190,198),
            GothicShell = Color3.fromRGB(255,255,255),
            GothicShellStroke = Color3.fromRGB(202,202,210),
            GothicGlow = Color3.fromRGB(226,226,232),
            GothicBar = Color3.fromRGB(194,194,203),
            GothicCorner = Color3.fromRGB(184,184,194),
            GothicWatermark = Color3.fromRGB(28,28,34),
            GothicWatermarkTransparency = 0.90,
            GothicRow = Color3.fromRGB(238,238,242),
            GothicStroke = Color3.fromRGB(198,198,206),
            GothicDesc = Color3.fromRGB(92,92,102),
            GothicBadgeText = Color3.fromRGB(32,32,38),
            GothicBadgeBackground = Color3.fromRGB(233,233,238),
            GothicBadgeStroke = Color3.fromRGB(198,198,206),
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

local CURRENT_THEME_NAME = canonicalThemeName(XeroEnv.XERO_THEME or "Xero")
local CURRENT_THEME = THEMES[CURRENT_THEME_NAME] or THEMES.Xero
local Nox = { Version = "7.0.0-concept-c-polish", Brand = "Ryou", SupportsGameLabels = true, Creator = "Ryou", UIScale = 1 }
local C, Glass = {}, {}

local function overwriteTable(target, source)
    for key in pairs(target) do target[key] = nil end
    for key, value in pairs(source or {}) do target[key] = value end
end

local function applyThemeDefinition(themeName)
    local resolved = canonicalThemeName(themeName)
    CURRENT_THEME_NAME = resolved
    CURRENT_THEME = THEMES[resolved] or THEMES.Xero
    overwriteTable(C, CURRENT_THEME.Colors)
    overwriteTable(Glass, CURRENT_THEME.Glass)
    XeroEnv.XERO_THEME = resolved
    return CURRENT_THEME
end

local function getThemeDefinition(themeName)
    return THEMES[canonicalThemeName(themeName)] or THEMES.Xero
end

applyThemeDefinition(CURRENT_THEME_NAME)

local function ensureFolderTree(path)
    if type(makefolder) ~= "function" then return end
    local current = ""
    for part in tostring(path):gmatch("[^/]+") do
        current = current == "" and part or (current .. "/" .. part)
        local exists = type(isfolder) == "function" and isfolder(current)
        if not exists then pcall(makefolder, current) end
    end
end

local function customAssetFunction()
    local fn = getcustomasset or getsynasset
    return type(fn) == "function" and fn or nil
end

-- Ryou global icon registry ------------------------------------------------
-- PNGs live in /icons on GitHub. They are downloaded lazily once, cached locally
-- and reused by every control/tab that declares Icon = "name".
local XERO_ICON_BASE_URL = tostring(XeroEnv.XERO_ICON_BASE_URL or
    "https://raw.githubusercontent.com/vryex/ryouhub/refs/heads/ryou-ui-v7-polish/icons/")
local XERO_ICON_CACHE_FOLDER = tostring(XeroEnv.XERO_ICON_CACHE_FOLDER or "Ryou/Icons/v2")

local XERO_ICON_FILES = {
    settings = "settings.png",
    copy = "copy.png",
    shirt = "shirt.png",
    ["volume-2"] = "volume-2.png",
    volume = "volume-2.png",
    palette = "palette.png",
    monitor = "monitor.png",
    ["person-standing"] = "person-standing.png",
    movement = "person-standing.png",
    skull = "skull.png",
    ["circle-dot"] = "circle-dot.png",
    fov = "circle-dot.png",
    eye = "eye.png",
    scan = "scan.png",
    hitbox = "scan.png",
    ["mouse-pointer-2"] = "mouse-pointer-2.png",
    triggerbot = "mouse-pointer-2.png",
    zap = "zap.png",
    autoshoot = "zap.png",
    crosshair = "crosshair.png",
    aim = "crosshair.png",
    ["rotate-ccw"] = "rotate-ccw.png",
    reset = "rotate-ccw.png",
    ["folder-open"] = "folder-open.png",
    load = "folder-open.png",
    save = "save.png",
    ["badge-info"] = "badge-info.png",
    info = "badge-info.png",
    footprints = "footprints.png",
    ["moon-star"] = "moon-star.png",
    ["layout-grid"] = "layout-grid.png",
    ["layers"] = "layers.png",
    ["sliders-horizontal"] = "sliders-horizontal.png",
    keyboard = "keyboard.png",
    search = "search.png",
    ["clock-3"] = "clock-3.png",
}

local XERO_ICON_ASSET_CACHE = {}
local XERO_ICON_PENDING = {}

local function normalizeIconName(name)
    return string.lower(tostring(name or "")):gsub("%s+", "-")
end

local function iconFileName(name)
    local key = normalizeIconName(name)
    if key == "" then return nil, nil end
    local fileName = XERO_ICON_FILES[key]
    -- Future-proof: after uploading another safe-name PNG to /icons, Icon="shield"
    -- works even before adding an explicit alias to the table above.
    if not fileName and key:match("^[%w_%-]+$") then fileName = key .. ".png" end
    return key, fileName
end

local function isIconPngPayload(data)
    return type(data) == "string" and #data > 32 and data:sub(1,8) == "\137PNG\r\n\26\n"
end

local function cachedIconAsset(name)
    local key, fileName = iconFileName(name)
    if not key or not fileName then return nil end
    if XERO_ICON_ASSET_CACHE[key] then return XERO_ICON_ASSET_CACHE[key] end

    local assetFn = customAssetFunction()
    if not assetFn or type(isfile) ~= "function" then return nil end
    local path = XERO_ICON_CACHE_FOLDER .. "/" .. fileName
    if not isfile(path) then return nil end

    if type(readfile) == "function" then
        local okRead, data = pcall(readfile, path)
        if not okRead or not isIconPngPayload(data) then return nil end
    end

    local okAsset, asset = pcall(assetFn, path)
    if okAsset and type(asset) == "string" and asset ~= "" then
        XERO_ICON_ASSET_CACHE[key] = asset
        return asset
    end
    return nil
end

local function downloadIconAsset(name)
    local key, fileName = iconFileName(name)
    if not key or not fileName then return nil end
    local cached = cachedIconAsset(key)
    if cached then return cached end

    local assetFn = customAssetFunction()
    if not assetFn or type(writefile) ~= "function" then return nil end

    local url = XERO_ICON_BASE_URL .. fileName
    local body
    local req = (syn and syn.request) or (http and http.request) or http_request or request
    if type(req) == "function" then
        local okRequest, response = pcall(req, {
            Url = url, Method = "GET", Headers = { ["User-Agent"] = "Ryou/3.1 Icons" },
        })
        if okRequest and response then
            local status = tonumber(response.StatusCode or response.Status)
            if status and status >= 200 and status < 300 and isIconPngPayload(response.Body) then
                body = response.Body
            end
        end
    end

    if not body then
        local okHttp, data = pcall(function() return game:HttpGet(url) end)
        if okHttp and isIconPngPayload(data) then body = data end
    end
    if not body then return nil end

    ensureFolderTree(XERO_ICON_CACHE_FOLDER)
    local path = XERO_ICON_CACHE_FOLDER .. "/" .. fileName
    if not pcall(writefile, path, body) then return nil end

    local okAsset, asset = pcall(assetFn, path)
    if okAsset and type(asset) == "string" and asset ~= "" then
        XERO_ICON_ASSET_CACHE[key] = asset
        return asset
    end
    return nil
end

local function requestIconAsset(name, callback)
    if type(callback) ~= "function" then return end
    local key = normalizeIconName(name)
    if key == "" then return end

    local cached = cachedIconAsset(key)
    if cached then callback(cached); return end

    if XERO_ICON_PENDING[key] then
        table.insert(XERO_ICON_PENDING[key], callback)
        return
    end
    XERO_ICON_PENDING[key] = {callback}

    task.spawn(function()
        local asset = downloadIconAsset(key)
        local waiters = XERO_ICON_PENDING[key] or {}
        XERO_ICON_PENDING[key] = nil
        for _, fn in ipairs(waiters) do pcall(fn, asset) end
    end)
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
        object:SetAttribute("XeroTheme" .. suffix, role)
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
    local bgRole = object:GetAttribute("XeroThemeBackground")
    if bgRole and object:IsA("GuiObject") and C[bgRole] then
        object.BackgroundColor3 = C[bgRole]
    end
    local textRole = object:GetAttribute("XeroThemeText")
    if textRole and (object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox")) and C[textRole] then
        object.TextColor3 = C[textRole]
    end
    local placeholderRole = object:GetAttribute("XeroThemePlaceholder")
    if placeholderRole and object:IsA("TextBox") and C[placeholderRole] then
        object.PlaceholderColor3 = C[placeholderRole]
    end
    local strokeRole = object:GetAttribute("XeroThemeStroke")
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

local FONT = Enum.Font.Gotham
local MEDIUM = Enum.Font.GothamMedium
local BOLD = Enum.Font.GothamBold
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
local function remoteIcon(parent, name, size, color, onReady)
    local px = math.clamp(math.floor(tonumber(size) or 16), 10, 28)
    local image = new("ImageLabel", {
        Name = "XeroIcon",
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(px,px),
        Image = "",
        ImageColor3 = color or C.Muted,
        ScaleType = Enum.ScaleType.Fit,
        Visible = false,
    }, parent)
    requestIconAsset(name, function(asset)
        if not image.Parent or not asset then return end
        image.Image = asset
        image.Visible = true
        if type(onReady) == "function" then pcall(onReady, image) end
    end)
    return image
end
local function button(parent, text, props)
    local p = {
        Text = text or "",
        BackgroundColor3 = C.Row,
        BackgroundTransparency = Glass.Button,
        Size = UDim2.fromOffset(36,36)
    }
    for k,v in pairs(props or {}) do p[k] = v end
    return new("TextButton", p, parent)
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
    table.insert(bucket or window._connections, connection)
    return connection
end
local function uiTween(object,goal,duration,easing)
    if not object or not object.Parent then return nil end
    local tween=TweenService:Create(object,
        TweenInfo.new(duration or .17,easing or Enum.EasingStyle.Quad,Enum.EasingDirection.Out),goal)
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
local function mark(parent, size, color)
    -- Firma Ryou: monograma R geométrico. El nombre interno anterior ya no se dibuja.
    local holder = new("Frame", {Name="RyouMark", BackgroundTransparency=1, Size=UDim2.fromOffset(size,size)}, parent)
    local tone = color or C.White
    local t = math.max(2, math.floor(size * 0.10))
    local stemX = math.floor(size * 0.22)
    local stemY = math.floor(size * 0.17)
    local stemH = math.floor(size * 0.66)
    local bowlW = math.floor(size * 0.43)

    local stem = new("Frame", {
        Position=UDim2.fromOffset(stemX,stemY),
        Size=UDim2.fromOffset(t,stemH),
        BackgroundColor3=tone,
    }, holder)
    round(stem,t)

    local topBar = new("Frame", {
        Position=UDim2.fromOffset(stemX,stemY),
        Size=UDim2.fromOffset(bowlW,t),
        BackgroundColor3=tone,
    }, holder)
    round(topBar,t)

    local midY = math.floor(size * 0.47)
    local midBar = new("Frame", {
        Position=UDim2.fromOffset(stemX,midY),
        Size=UDim2.fromOffset(math.floor(size * 0.36),t),
        BackgroundColor3=tone,
    }, holder)
    round(midBar,t)

    local rightStem = new("Frame", {
        Position=UDim2.fromOffset(math.floor(size * 0.60),math.floor(size * 0.23)),
        Size=UDim2.fromOffset(t,math.floor(size * 0.22)),
        BackgroundColor3=tone,
    }, holder)
    round(rightStem,t)

    local leg = line(holder,math.floor(size * 0.43),math.floor(size * 0.51),
        math.floor(size * 0.38),t,48,tone)
    round(leg,t)

    return holder
end
local function icon(parent, kind, numberOverride)
    local h = new("Frame", {BackgroundTransparency=1, Size=UDim2.fromOffset(20,20)}, parent)
    if kind == "close" then line(h,3,9,14,1,45); line(h,3,9,14,1,-45)
    elseif kind == "menu" then for _,y in ipairs({5,10,15}) do line(h,3,y,14,1) end
    elseif kind == "search" then
        local circle = new("Frame", {Position=UDim2.fromOffset(3,2),Size=UDim2.fromOffset(10,10),BackgroundTransparency=1},h)
        round(circle,10); stroke(circle,C.Muted,1.4); line(h,12,13,6,1,45)
    elseif kind == "minus" then line(h,4,10,12,1)
    elseif kind == "chevron" then line(h,4,9,7,1,45); line(h,9,9,7,1,-45)
    else
        local symbols = {Inicio="01",Aimbot="02",["Kill All"]="03",Visuales="04",Movimiento="05",
            AutoFarm="06",["Gráficos"]="07",Animaciones="08",Apariencia="09",["Generar Armas"]="10",["Configuración"]="11",["Créditos"]="12"}
        label(h, numberOverride or symbols[kind] or "·", 10, C.Muted, {Font=Enum.Font.Code,TextXAlignment=Enum.TextXAlignment.Center})
    end
    return h
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
    local px=section and 7 or 15
    local py=section and 8 or 13
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
        self.ControlIcon.Position=UDim2.fromOffset(0,math.max(0,math.floor((headHeight-iconSize)/2)))
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
        local fieldHeight=36
        if self.ValueLabel then fieldHeight=math.max(36,textHeight(self.ValueLabel.Text,11,FONT,headWidth-36)+12) end
        self.BodyField.Position=UDim2.fromOffset(px,y+6)
        self.BodyField.Size=UDim2.new(1,-px*2,0,fieldHeight)
        y+=6+fieldHeight
    end
    if self.SliderArea then
        local sliderAreaHeight=self.SliderAreaHeight or 14
        local sliderLimitsGap=self.SliderLimitsGap or 2
        self.SliderArea.Position=UDim2.fromOffset(px,y+3)
        self.SliderArea.Size=UDim2.new(1,-px*2,0,sliderAreaHeight)
        self.Limits.Position=UDim2.fromOffset(px,y+3+sliderAreaHeight+sliderLimitsGap)
        self.Limits.Size=UDim2.new(1,-px*2,0,10)
        y+=sliderAreaHeight+sliderLimitsGap+14
    end
    if self.Rule then self.Rule.Position=UDim2.fromOffset(px,y+5); self.Rule.Size=UDim2.new(1,-px*2,0,1); y+=7 end
    local height=y+(section and 3 or py)
    self.ElementFrame.Size=UDim2.new(1,0,0,height)
    self.Slot.Size=UDim2.new(1,-6,0,height)
end
function Tab:_layout()
    if self.Window.Destroyed then return end
    local width=math.max(80,(self.Content.AbsoluteSize.X>10 and self.Content.AbsoluteSize.X or (self.Window.ContentWidth or 500))-12)
    local height=4
    for _,c in ipairs(self.Elements) do
        if not c.Destroyed then
            c:_resize(width)
            if c.Slot.Visible then height+=c.Slot.Size.Y.Offset+8 end
        end
    end
    local bottomPad=22
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
        self.ControlIcon.ImageColor3 = light and (self.LightIconColor or C.Muted) or (self.DarkIconColor or C.Muted)
    end
    if self.CardIcon and self.CardIcon.Parent then
        self.CardIcon.BackgroundColor3=C.Field
        local chipText=self.CardIcon:FindFirstChildOfClass("TextLabel")
        if chipText then chipText.TextColor3=light and C.Text or C.White end
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
    if self.Interactive then self.Interactive.Active = false end
    return self
end
function Control:Unlock()
    self.Locked = false; self.TitleLabel.TextColor3 = C.Text
    if self.Interactive then self.Interactive.Active = true end
    return self
end
function Control:Destroy()
    if self.Destroyed then return end
    self.Destroyed = true
    if self.Window._popupOwner == self then self.Window:_closePopup() end
    if self.Window._drag and self.Window._drag.Owner == self then self.Window:_endDrag() end
    self.Slot:Destroy(); self.Tab:_queueFilter()
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
    local shown, total = 0,0
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
            if allowed then total += 1 end
            if allowed and matched then shown += 1; matchingGroups[c.GroupTitle or ""] = true end
        end
    end
    for _,c in ipairs(self.Elements) do
        if not c.Destroyed and c.__type == "Section" then
            c.Slot.Visible = c.ElementFrame.Visible and (query == "" or matchingGroups[c.Title] == true)
        end
    end
    self.Empty.Visible = shown == 0
    if self.Window.CurrentTab == self then
        self.Window.CountLabel.Text = tostring(shown) .. (query ~= "" and " / " .. total or "") .. " opciones"
    end
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
    round(row,17); local rowStroke=stroke(row,lightTheme and lightStrokeColor or darkStrokeColor); rowStroke.Transparency=.22
    local head = new("Frame", {Name="Heading",BackgroundTransparency=1,
        Size=UDim2.new(1,0,0,0),LayoutOrder=1},row)
    local copy = new("Frame", {Name="Copy",BackgroundTransparency=1,
        Size=UDim2.new(1,0,0,0)},head)
    local title = label(copy,plain(o.Title or kind),13,C.Text,{Font=MEDIUM,TextWrapped=true,
        TextYAlignment=Enum.TextYAlignment.Top,Size=UDim2.new(1,0,0,18),LayoutOrder=1})
    local desc = label(copy,plain(o.Desc),11,C.Muted,{TextWrapped=true,AutomaticSize=Enum.AutomaticSize.Y,
        Size=UDim2.new(1,0,0,0),LayoutOrder=2,Visible=o.Desc ~= nil and o.Desc ~= ""})
    local controlIcon, controlIconSize
    if o.Icon ~= nil and tostring(o.Icon) ~= "" then
        controlIconSize=math.clamp(math.floor(tonumber(o.IconSize) or 16),10,24)
        controlIcon=remoteIcon(head,o.Icon,controlIconSize,
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
    if kind~="Section" and not controlIcon and not (kind=="Paragraph" and o.Image) then
        local iconKeys={Toggle="circle-dot",Button="zap",Input="keyboard",
            Slider="sliders-horizontal",Dropdown="folder-open",Colorpicker="palette",Paragraph="badge-info"}
        local chip=new("Frame",{Name="RyouCardIcon",BackgroundColor3=C.Field,BackgroundTransparency=.10,
            Size=UDim2.fromOffset(34,34),Position=UDim2.fromOffset(0,0)},head)
        round(chip,11)
        local chipStroke=stroke(chip,C.Border);chipStroke.Transparency=.38
        local fallback=label(chip,"•",20,C.White,{Font=BOLD,Size=UDim2.fromScale(1,1),
            TextXAlignment=Enum.TextXAlignment.Center})
        local picture=remoteIcon(chip,iconKeys[kind] or "badge-info",20,C.White,function()
            if fallback.Parent then fallback.Visible=false end
        end)
        picture.AnchorPoint=Vector2.new(.5,.5)
        picture.Position=UDim2.fromScale(.5,.5)
        control.CopyOffsetX=45
        control.CardIcon=chip
    end
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
    if o.Locked then control:Lock() end
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
        c.CopyOffsetX=align=="left" and (pictureSize+12) or 0
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
        local decor=new("Frame",{Name="Decor",BackgroundTransparency=1,Size=UDim2.fromScale(1,1),ZIndex=0},c.ElementFrame)
        local gothicVisuals = c.Window.ThemeDef.Visuals
        local shell=new("Frame",{Name="Shell",BackgroundColor3=gothicVisuals.GothicShell,BackgroundTransparency=.985,
            Position=UDim2.fromOffset(1,1),Size=UDim2.new(1,-2,1,-2),ZIndex=0},decor)
        round(shell,10); local shellStroke=stroke(shell,gothicVisuals.GothicShellStroke,1)
        local glow=new("Frame",{AnchorPoint=Vector2.new(1,.5),Position=UDim2.fromScale(.985,.5),Size=UDim2.fromScale(.38,.92),
            BackgroundColor3=gothicVisuals.GothicGlow,BackgroundTransparency=.54,Rotation=-8,ZIndex=0},decor)
        round(glow,22)
        new("UIGradient",{Rotation=28,Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,.16),NumberSequenceKeypoint.new(1,1)})},glow)
        local bar=line(decor,18,14,1,200,0,gothicVisuals.GothicBar); bar.BackgroundTransparency=.58; bar.ZIndex=0
        local corner=line(decor,18,14,42,1,0,gothicVisuals.GothicCorner); corner.BackgroundTransparency=.48; corner.ZIndex=0
        local wm=label(decor,o.DecorText or "RYOU",28,gothicVisuals.GothicWatermark,{AnchorPoint=Vector2.new(1,1),Position=UDim2.fromScale(.968,.9),
            Size=UDim2.fromScale(.46,.30),Font=BOLD,TextTransparency=gothicVisuals.GothicWatermarkTransparency,TextXAlignment=Enum.TextXAlignment.Right,TextYAlignment=Enum.TextYAlignment.Bottom,ZIndex=0})
        c.DarkColor=o.Color or THEMES.Xero.Visuals.GothicRow
        c.LightColor=o.LightColor or THEMES.Blanco.Visuals.GothicRow
        c.DarkStrokeColor=o.StrokeColor or THEMES.Xero.Visuals.GothicStroke
        c.LightStrokeColor=o.LightStrokeColor or THEMES.Blanco.Visuals.GothicStroke
        c.DarkDescColor=o.DescColor or THEMES.Xero.Visuals.GothicDesc
        c.LightDescColor=o.LightDescColor or THEMES.Blanco.Visuals.GothicDesc
        c.TitleLabel.Font=BOLD
        c.TitleLabel.TextSize=math.max(c.TitleLabel.TextSize,14)
        c.DescLabel.TextSize=math.max(c.DescLabel.TextSize,11)
        if c.Thumbnail then
            -- La foto ya lleva su propio stroke. No añadimos un halo separado:
            -- al relayout quedaba como un círculo vacío a la derecha del perfil.
            c.HeadMinimum=math.max(c.HeadMinimum or 0,(c.ThumbnailSize or 36)+8)
            c.Thumbnail.ZIndex=2
        end
        local badge, badgeStroke
        if o.BadgeText then
            badge=label(c.Head,string.upper(plain(o.BadgeText)),9,gothicVisuals.GothicBadgeText,{
                AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-4,0,0),Size=UDim2.fromOffset(82,22),
                TextXAlignment=Enum.TextXAlignment.Center,Font=Enum.Font.Code,BackgroundColor3=gothicVisuals.GothicBadgeBackground,BackgroundTransparency=.05,ZIndex=3})
            round(badge,9); badgeStroke=stroke(badge,gothicVisuals.GothicBadgeStroke,1)
        end
        c._applyThemeExtras=function(self)
            local v=self.Window.ThemeDef.Visuals
            shell.BackgroundColor3=v.GothicShell
            shellStroke.Color=v.GothicShellStroke
            glow.BackgroundColor3=v.GothicGlow
            bar.BackgroundColor3=v.GothicBar
            corner.BackgroundColor3=v.GothicCorner
            wm.TextColor3=v.GothicWatermark
            wm.TextTransparency=v.GothicWatermarkTransparency
            if badge then
                badge.TextColor3=v.GothicBadgeText
                badge.BackgroundColor3=v.GothicBadgeBackground
                if badgeStroke then badgeStroke.Color=v.GothicBadgeStroke end
            end
        end
        c:ApplyTheme()
    end
    c:ApplyTheme()
    function c:Set(value) return self:SetDesc(value) end
    return c
end
function Tab:Button(options)
    local c = self:_control("Button",options)
    c.Reserve=47; c.HeadMinimum=36
    local hit = button(c.Head,"→",{Name="Action",BackgroundColor3=C.Panel,BackgroundTransparency=Glass.Button,TextSize=14,
        Position=UDim2.new(1,-37,0,0),Size=UDim2.fromOffset(37,36)})
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
    c.Reserve=58; c.HeadMinimum=36
    local target=button(c.Head,"",{Name="ToggleHit",BackgroundTransparency=1,
        Position=UDim2.new(1,-48,0,0),Size=UDim2.fromOffset(48,36)})
    local hit=new("Frame",{Name="Switch",BackgroundColor3=C.Border,
        Position=UDim2.fromOffset(2,7),Size=UDim2.fromOffset(44,22)},target)
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
local function field(parent, placeholder)
    local box=new("TextBox",{Name="Field",Text="",PlaceholderText=placeholder or "",
        PlaceholderColor3=C.Faint,BackgroundColor3=C.Field,BackgroundTransparency=Glass.Field,
        Active=true,TextEditable=true,ClearTextOnFocus=false,MultiLine=false,Selectable=true,
        TextXAlignment=Enum.TextXAlignment.Left,TextSize=12,Size=UDim2.new(1,0,0,34),
        ZIndex=6,LayoutOrder=2},parent)
    round(box,10); stroke(box,C.Border); padding(box,9,0)
    return box
end
function Tab:Input(options)
    local o=options or {}; local c=self:_control("Input",o)
    local box=field(c.ElementFrame,o.Placeholder or "Escribe aquí…")
    c.Interactive=box; c.BodyField=box
    function c:Set(value,silent)
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
    c.Reserve=70; c.HeadMinimum=28
    c.SliderAreaHeight=30; c.SliderLimitsGap=1

    local sliderVisuals=c.Window.ThemeDef.Visuals
    local box=field(c.Head,"")
    box.Name="Value"
    box.Size=UDim2.fromOffset(58,26)
    box.Position=UDim2.new(1,-58,0,0)
    box.TextXAlignment=Enum.TextXAlignment.Center
    box.BackgroundColor3=sliderVisuals.SliderValueBackground
    box.TextColor3=sliderVisuals.SliderValueText
    box.Font=MEDIUM
    box.TextSize=10
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
    label(limits,tostring(low),8,C.Faint,{Size=UDim2.fromScale(.5,1),Font=Enum.Font.Code})
    label(limits,tostring(high),8,C.Faint,{Size=UDim2.fromScale(.5,1),Position=UDim2.fromScale(.5,0),
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
        value=math.clamp(low+math.floor((value-low)/step+.5)*step,low,high)
        value=tonumber(format(value)) or low
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
    local o=options or {}; local c=self:_control("Dropdown",o)
    c.Values=uniqueDropdownValues(o.Values); c.Multi=o.Multi==true or o.MultiSelect==true
    local hit=button(c.ElementFrame,"",{Name="Dropdown",BackgroundColor3=C.Field,BackgroundTransparency=Glass.Field,
        Size=UDim2.new(1,0,0,28),LayoutOrder=2}); round(hit,10); stroke(hit,C.Border)
    local valueLabel=label(hit,"",11,C.Text,{Position=UDim2.fromOffset(8,0),Size=UDim2.new(1,-30,1,0),TextWrapped=true})
    icon(hit,"chevron").Position=UDim2.new(1,-26,.5,-10)
    c.Interactive=hit; c.BodyField=hit; c.ValueLabel=valueLabel
    function c:Set(value,silent,force)
        if self.Destroyed then return self end
        local changed
        if self.Multi then
            local arr=type(value)=="table" and table.clone(value) or (value and {value} or {})
            changed=table.concat(arr,"\0") ~= table.concat(type(self.Value)=="table" and self.Value or {},"\0")
            self.Value=arr; valueLabel.Text=#arr>0 and table.concat(arr,", ") or "Seleccionar…"
        else
            changed=self.Value~=value; self.Value=value
            valueLabel.Text=value~=nil and tostring(value) or "Seleccionar…"
        end
        if (changed or force) and not silent then invoke(self.Callback,self.Multi and table.clone(self.Value) or self.Value) end
        self.Tab:_queueFilter()
        return self
    end
    function c:Refresh(values)
        self.Values=uniqueDropdownValues(values)
        self._revision=(self._revision or 0)+1
        if self.Window._popupOwner==self and self._renderOptions then self._renderOptions() end
        return self
    end
    function c:Open()
        if self.Locked or self.Destroyed then return end
        local window=self.Window
        local panel=window:_popup(self.Title,360,410,self)
        local search=field(panel,"Buscar una opción…")
        search.Position=UDim2.fromOffset(16,48); search.Size=UDim2.new(1,-32,0,30)
        local list=scroll(panel,{Position=UDim2.fromOffset(16,90),Size=UDim2.new(1,-32,1,-120)})
        vertical(list,5)
        local hint=label(panel,"",10,C.Faint,{Position=UDim2.new(0,16,1,-29),Size=UDim2.new(1,-32,0,16)})
        local optionConnections={}
        local rendering=false
        window._popupCleanup=function() disconnect(optionConnections); self._renderOptions=nil end
        local function render()
            if rendering or not list.Parent or window.Destroyed then return end
            rendering=true
            disconnect(optionConnections)
            for _,child in ipairs(list:GetChildren()) do if child:IsA("GuiObject") then child:Destroy() end end
            local query=normalized(search.Text); local count, matches=0,0
            local shown={}
            for _,value in ipairs(self.Values) do
                local key=normalized(tostring(value))
                if not shown[key] then
                    shown[key]=true
                    if query=="" or string.find(key,query,1,true) then
                        matches+=1
                        if count<120 then
                        count+=1
                        local selected=self.Multi and table.find(self.Value,value)~=nil or (not self.Multi and self.Value==value)
                        local choiceHeight=math.max(32,textHeight(tostring(value),12,FONT,math.max(60,panel.AbsoluteSize.X-78))+12)
                        local choice=button(list,"",{Name="Option",Size=UDim2.new(1,-4,0,choiceHeight),LayoutOrder=count,
                            BackgroundColor3=selected and C.Text or C.Row})
                        round(choice,10)
                        label(choice,tostring(value),13,selected and C.Window or C.Text,{Position=UDim2.fromOffset(12,0),
                            Size=UDim2.new(1,-38,1,0),TextWrapped=true})
                        label(choice,selected and "✓" or "",12,C.Window,{Position=UDim2.new(1,-28,0,0),Size=UDim2.new(0,20,1,0)})
                        connect(window,choice.Activated,function()
                            if self.Multi then
                                local arr=table.clone(self.Value); local i=table.find(arr,value)
                                if i then table.remove(arr,i) else table.insert(arr,value) end
                                self:Set(arr)
                                if window._popupOwner==self then render() end
                            else
                                local revision=self._revision or 0
                                self:Set(value,false,true)
                                if window._popupOwner==self and revision==(self._revision or 0) then window:_closePopup() end
                            end
                        end,optionConnections)
                        end
                    end
                end
            end
            hint.Text=matches==0 and "Sin resultados" or (matches>120 and "120 de "..matches.." · Escribe para filtrar" or matches.." opciones")
            rendering=false
        end
        self._renderOptions=render
        connect(window,search:GetPropertyChangedSignal("Text"),render,window._popupConnections)
        connect(window,panel:GetPropertyChangedSignal("AbsoluteSize"),render,window._popupConnections)
        render()
    end
    connect(c.Window,hit.Activated,function() c:Open() end)
    c:Set(o.Value or o.Default or (c.Multi and {} or nil),true)
    return c
end
function Tab:Colorpicker(options)
    local o=options or {}; local c=self:_control("Colorpicker",o)
    c.Reserve=62; c.HeadMinimum=44
    local hit=button(c.Head,"",{Name="Color",Position=UDim2.new(1,-46,0,0),Size=UDim2.fromOffset(46,44)})
    round(hit,9); local hitStroke=stroke(hit,C.Border,1); hitStroke.Transparency=.08
    c.Interactive=hit

    function c:Set(value,silent)
        if typeof(value)~="Color3" then return self end
        local changed=self.Value~=value; self.Value=value; hit.BackgroundColor3=value
        if self._updateColor then self._updateColor() end
        if changed and not silent then invoke(self.Callback,value) end
        return self
    end

    function c:Open()
        if self.Locked then return end
        local window=self.Window
        local panel=window:_popup(self.Title,370,410,self)
        local body=scroll(panel,{Name="ColorPaletteBody",Position=UDim2.fromOffset(16,54),
            Size=UDim2.new(1,-32,1,-68),AutomaticCanvasSize=Enum.AutomaticSize.None,CanvasSize=UDim2.fromOffset(0,288)})
        local sheet=new("Frame",{Name="PaletteControls",BackgroundTransparency=1,Size=UDim2.new(1,-13,0,288)},body)

        local h,s,v=self.Value:ToHSV()
        local state={H=h,S=s,V=v,Internal=false}
        if state.S < .001 then state.H=0 end

        local current=new("Frame",{Name="Current",Position=UDim2.fromOffset(0,0),Size=UDim2.fromOffset(44,34),
            BackgroundColor3=self.Value},sheet)
        round(current,9); stroke(current,C.Border,1)

        local hex=field(sheet,"#FFFFFF")
        hex.Position=UDim2.fromOffset(54,0); hex.Size=UDim2.new(1,-54,0,34)
        hex.TextSize=11; hex.Font=MEDIUM

        label(sheet,"Paleta RGB · arrastra para elegir tono e intensidad",9,C.Muted,{
            Position=UDim2.fromOffset(0,39),Size=UDim2.new(1,0,0,16)})

        local palette=button(sheet,"",{Name="RGBPalette",Position=UDim2.fromOffset(0,58),
            Size=UDim2.new(1,0,0,150),BackgroundColor3=Color3.fromHSV(state.H,1,1),ClipsDescendants=true})
        round(palette,11); local paletteStroke=stroke(palette,C.Border,1); paletteStroke.Transparency=.08

        -- Izquierda = blanco, derecha = color puro.
        local whiteLayer=new("Frame",{Name="WhiteBlend",Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(1,1,1),
            BorderSizePixel=0,ZIndex=2},palette)
        new("UIGradient",{Transparency=NumberSequence.new({
            NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)
        })},whiteLayer)

        -- Arriba = luminoso, abajo = negro.
        local blackLayer=new("Frame",{Name="BlackBlend",Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(0,0,0),
            BorderSizePixel=0,ZIndex=3},palette)
        new("UIGradient",{Rotation=90,Transparency=NumberSequence.new({
            NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)
        })},blackLayer)

        local cursor=new("Frame",{Name="PaletteCursor",AnchorPoint=Vector2.new(.5,.5),Size=UDim2.fromOffset(18,18),
            BackgroundTransparency=1,ZIndex=6},palette)
        round(cursor,9); local cursorStroke=stroke(cursor,Color3.new(1,1,1),2); cursorStroke.Transparency=0
        local cursorShadow=new("UIStroke",{Color=Color3.new(0,0,0),Thickness=1,Transparency=.18,
            ApplyStrokeMode=Enum.ApplyStrokeMode.Border},cursor)

        local hueBar=button(sheet,"",{Name="Hue",Position=UDim2.fromOffset(0,221),Size=UDim2.new(1,0,0,18),
            BackgroundColor3=Color3.new(1,1,1),ClipsDescendants=false})
        round(hueBar,9); local hueStroke=stroke(hueBar,C.Border,1); hueStroke.Transparency=.1
        new("UIGradient",{Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0.00,Color3.fromRGB(255,0,0)),
            ColorSequenceKeypoint.new(0.17,Color3.fromRGB(255,255,0)),
            ColorSequenceKeypoint.new(0.33,Color3.fromRGB(0,255,0)),
            ColorSequenceKeypoint.new(0.50,Color3.fromRGB(0,255,255)),
            ColorSequenceKeypoint.new(0.67,Color3.fromRGB(0,0,255)),
            ColorSequenceKeypoint.new(0.83,Color3.fromRGB(255,0,255)),
            ColorSequenceKeypoint.new(1.00,Color3.fromRGB(255,0,0))
        })},hueBar)

        local hueCursor=new("Frame",{Name="HueCursor",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(state.H,.5),
            Size=UDim2.fromOffset(5,26),BackgroundColor3=Color3.fromRGB(250,250,250),ZIndex=6},hueBar)
        round(hueCursor,3); local hueCursorStroke=stroke(hueCursor,Color3.fromRGB(20,20,20),1); hueCursorStroke.Transparency=.1

        local presets=new("Frame",{Name="Presets",BackgroundTransparency=1,
            Position=UDim2.fromOffset(0,252),Size=UDim2.new(1,0,0,30)},sheet)
        local function fitPalette()
            local height=math.clamp(panel.AbsoluteSize.Y-199,85,190)
            palette.Size=UDim2.new(1,0,0,height)
            hueBar.Position=UDim2.fromOffset(0,71+height)
            presets.Position=UDim2.fromOffset(0,102+height)
            body.CanvasSize=UDim2.fromOffset(0,138+height)
            sheet.Size=UDim2.new(1,-13,0,138+height)
        end
        connect(window,panel:GetPropertyChangedSignal("AbsoluteSize"),fitPalette,window._popupConnections)
        fitPalette()
        local presetColors={
            Color3.fromRGB(255,255,255),Color3.fromRGB(180,180,180),Color3.fromRGB(30,30,30),
            Color3.fromRGB(255,72,72),Color3.fromRGB(255,170,45),Color3.fromRGB(255,225,55),
            Color3.fromRGB(70,220,110),Color3.fromRGB(65,195,255),Color3.fromRGB(120,100,255),Color3.fromRGB(235,85,220)
        }

        local function applyHSV()
            state.Internal=true
            self:Set(Color3.fromHSV(state.H,state.S,state.V))
            state.Internal=false
        end

        local function syncFromValue()
            if not state.Internal then
                local nh,ns,nv=self.Value:ToHSV()
                if ns>.001 then state.H=nh end
                state.S=ns; state.V=nv
            end
            current.BackgroundColor3=self.Value
            hex.Text="#"..self.Value:ToHex():upper()
            palette.BackgroundColor3=Color3.fromHSV(state.H,1,1)
            cursor.Position=UDim2.new(state.S,0,1-state.V,0)
            hueCursor.Position=UDim2.new(state.H,0,.5,0)
        end
        self._updateColor=syncFromValue

        local function updatePalette(position)
            local size=palette.AbsoluteSize
            if size.X<=1 or size.Y<=1 then return end
            state.S=math.clamp((position.X-palette.AbsolutePosition.X)/size.X,0,1)
            state.V=1-math.clamp((position.Y-palette.AbsolutePosition.Y)/size.Y,0,1)
            applyHSV()
        end
        local function updateHue(position)
            local width=hueBar.AbsoluteSize.X
            if width<=1 then return end
            state.H=math.clamp((position.X-hueBar.AbsolutePosition.X)/width,0,1)
            applyHSV()
        end

        connect(window,palette.InputBegan,function(input)
            if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
                window:_beginDrag(input,updatePalette,body,self); updatePalette(input.Position)
            end
        end,window._popupConnections)
        connect(window,hueBar.InputBegan,function(input)
            if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
                window:_beginDrag(input,updateHue,body,self); updateHue(input.Position)
            end
        end,window._popupConnections)

        for index,color in ipairs(presetColors) do
            local width=1/#presetColors
            local swatch=button(presets,"",{Name="Preset"..index,Position=UDim2.fromScale((index-1)*width,0),
                Size=UDim2.new(width,-4,0,28),BackgroundColor3=color,LayoutOrder=index})
            round(swatch,7); local ss=stroke(swatch,C.Border,1); ss.Transparency=.1
            connect(window,swatch.Activated,function() self:Set(color) end,window._popupConnections)
        end

        connect(window,hex.FocusLost,function()
            local value=hex.Text:gsub("#","")
            if #value==6 and value:match("^%x+$") then self:Set(Color3.fromHex(value)) else syncFromValue() end
        end,window._popupConnections)

        window._popupCleanup=function() self._updateColor=nil end
        syncFromValue()
    end

    connect(c.Window,hit.Activated,function() c:Open() end)
    c:Set(o.Default or o.Value or C.White,true)
    return c
end
function Tab:Select() self.Window:SelectTab(self); return self end
function Tab:LockAll() for _,c in ipairs(self.Elements) do c:Lock() end end
function Tab:UnlockAll() for _,c in ipairs(self.Elements) do c:Unlock() end end

local DESCRIPTIONS = {
    Inicio="Tu espacio. Todo bajo control.", Aimbot="Organiza tus ajustes de precisión y selección.",
    ["Kill All"]="Controles y ajustes de esta función.", Visuales="Elige qué información quieres ver.",
    Movimiento="Personaliza el movimiento y sus controles.", AutoFarm="Configura tus acciones automáticas.",
    ["Gráficos"]="Ajusta el ambiente, la iluminación y los efectos.",
    Animaciones="Combina paquetes y movimientos a tu gusto.", Apariencia="Tu avatar, a tu manera.",
    ["Configuración"]="Tu interfaz y tus configuraciones guardadas.", ["Generar Armas"]="Organiza tus opciones de inventario.", ["Créditos"]="Conoce al creador y los datos del proyecto.",
}
function Nox:CreateWindow(options)
    local o=options or {}
    if self.Window and not self.Window.Destroyed then self.Window:Destroy() end
    local player=Players.LocalPlayer
    assert(player,"Ryou UI must run on the client")
    local parent=player:WaitForChild("PlayerGui")
    pcall(function()
        if gethui then
            local hui=gethui()
            if hui then parent=hui else parent=game:GetService("CoreGui") end
        else
            parent=game:GetService("CoreGui")
        end
    end)
    local env=(getgenv and getgenv()) or _G
    if env.__NOX_UI and env.__NOX_UI.Destroy then pcall(function() env.__NOX_UI:Destroy() end) end
    local resolvedTheme = canonicalThemeName(o.Theme or CURRENT_THEME_NAME)
    local w={_connections={},_popupConnections={},_onDestroy={},_onOpen={},_onClose={},Tabs={},
        Groups={},Opened=true,Destroyed=false,Compact=false,ToggleKey=o.ToggleKey or Enum.KeyCode.RightShift,
        Title=plain(o.Title or "RyouHub"),_brandBaseTitle=plain(o.Title or "RyouHub"),Author=o.Author or "por Ryou",UIScale=1,_navOrder=0,
        ThemeName=resolvedTheme,ThemeDef=getThemeDefinition(resolvedTheme)}
    w._conceptStart=os.clock()
    self.Window=w; env.__NOX_UI=w
    local gui=new("ScreenGui",{Name="RyouUI",ResetOnSpawn=false,IgnoreGuiInset=true,
        DisplayOrder=2147483000,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},parent)
    -- El panel usa todo el viewport real. Así puede tocar Y=0 y no queda atrapado
    -- debajo del inset de la barra superior de Roblox.
    pcall(function()
        gui.ScreenInsets=Enum.ScreenInsets.None
        gui.ClipToDeviceSafeArea=false
        gui.SafeAreaCompatibility=Enum.SafeAreaCompatibility.None
    end)
    pcall(function() gui.OnTopOfCoreBlur=true end)
    local launcherGui=new("ScreenGui",{Name="RyouLauncher",ResetOnSpawn=false,IgnoreGuiInset=true,
        DisplayOrder=2147483001,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},parent)
    pcall(function()
        launcherGui.ScreenInsets=Enum.ScreenInsets.None
        launcherGui.ClipToDeviceSafeArea=false
        launcherGui.SafeAreaCompatibility=Enum.SafeAreaCompatibility.None
    end)
    pcall(function() launcherGui.OnTopOfCoreBlur=true end)
    local launcherSurface=new("Frame",{Name="FullScreen",BackgroundTransparency=1,Size=UDim2.fromScale(1,1)},launcherGui)
    w.LauncherGui=launcherGui
    self.ScreenGui=gui; w.ScreenGui=gui
    -- Full-viewport bounds are shared by popups, dragging and responsive layout.
    local surface=new("Frame",{Name="Surface",BackgroundTransparency=1,Size=UDim2.fromScale(1,1)},gui)
    local mount=new("Frame",{Name="WindowMount",BackgroundTransparency=1,Size=UDim2.fromScale(1,1)},surface)
    local root=new("Frame",{Name="RyouPanel",BackgroundColor3=w.ThemeDef.Visuals.RootBase,BackgroundTransparency=Glass.Root,AnchorPoint=Vector2.new(.5,.5),
        Position=UDim2.fromScale(.5,.5),Size=UDim2.fromOffset(680,430),ClipsDescendants=true},mount)
    round(root,24); local rootStroke=stroke(root,w.ThemeDef.Visuals.RootStroke)
    local rootGradient=new("UIGradient",{Rotation=22,Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0,w.ThemeDef.Visuals.RootGradient[1]),
        ColorSequenceKeypoint.new(.52,w.ThemeDef.Visuals.RootGradient[2]),
        ColorSequenceKeypoint.new(1,w.ThemeDef.Visuals.RootGradient[3])
    })},root)
    local scale=new("UIScale",{Scale=1},root); self.UIScaleObj=scale

    -- CanvasGroup con UICorner recorta la foto a la forma completa del marco.
    local backdrop=new("CanvasGroup",{Name="RyouBackdrop",BackgroundTransparency=1,Size=UDim2.fromScale(1,1),
        ClipsDescendants=true,ZIndex=1},root)
    round(backdrop,24)
    local glowA=new("Frame",{Name="AccentWash",AnchorPoint=Vector2.new(1,0),Position=UDim2.fromScale(1,0),
        Size=UDim2.new(.72,0,.62,0),BackgroundColor3=w.ThemeDef.Visuals.BackdropGlowA,BackgroundTransparency=.46},backdrop)
    new("UIGradient",{Rotation=125,Transparency=NumberSequence.new(0,1)},glowA)
    label(backdrop,"RyouHub",15,C.Text,{Name="RyouWordmark",Font=BOLD,TextTransparency=.31,
        TextXAlignment=Enum.TextXAlignment.Right,AnchorPoint=Vector2.new(1,1),
        Position=UDim2.new(1,-30,1,-8),Size=UDim2.fromOffset(96,19)})
    new("Frame",{BackgroundColor3=C.White,BackgroundTransparency=.75,AnchorPoint=Vector2.new(1,.5),
        Position=UDim2.new(1,-108,1,-17),Size=UDim2.new(.16,0,0,1)},backdrop)
    local stripe=new("Frame",{BackgroundColor3=C.White,BackgroundTransparency=.72,
        Size=UDim2.new(1,0,0,2)},backdrop)
    new("UIGradient",{Transparency=NumberSequence.new(1,0)},stripe)

    local top=new("Frame",{Name="Topbar",BackgroundTransparency=1,Size=UDim2.new(1,0,0,58),ZIndex=5},root)
    local logo=mark(top,28,C.White); logo.Position=UDim2.fromOffset(16,12)

    local titleCluster=new("Frame",{Name="TitleCluster",BackgroundTransparency=1,
        Position=UDim2.fromOffset(50,9),Size=UDim2.fromOffset(290,24)},top)
    -- El título y el contador se posicionan manualmente para mantenerlos juntos
    -- en cualquier ancho; un UIListLayout con AutomaticSize dejaba huecos raros.
    local brand=label(titleCluster,w._brandBaseTitle,16,C.Text,{Position=UDim2.fromOffset(0,0),
        Size=UDim2.fromOffset(120,22),Font=BOLD})
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
    local sidebar=new("Frame",{Name="Navigation",BackgroundColor3=w.ThemeDef.Visuals.SidebarBase,
        BackgroundTransparency=Glass.Sidebar,ClipsDescendants=true,ZIndex=12},root)
    round(sidebar,20); local sidebarStroke=stroke(sidebar,w.ThemeDef.Visuals.SidebarStroke)
    local nav=scroll(sidebar,{Name="Tabs",Position=UDim2.fromOffset(7,0),Size=UDim2.new(1,-14,1,0),
        ScrollingDirection=Enum.ScrollingDirection.X,AutomaticCanvasSize=Enum.AutomaticSize.X,ScrollBarThickness=5})
    local function horizontal(parent,gap)
        return new("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,
            VerticalAlignment=Enum.VerticalAlignment.Center,SortOrder=Enum.SortOrder.LayoutOrder,
            Padding=UDim.new(0,gap)},parent)
    end
    local navLayout=horizontal(nav,9)
    local function scrollTabs(delta)
        local maximum=math.max(0,nav.AbsoluteCanvasSize.X-nav.AbsoluteWindowSize.X)
        nav.CanvasPosition=Vector2.new(math.clamp(nav.CanvasPosition.X+delta,0,maximum),0)
    end
    local navArrows={}
    for index,direction in ipairs({-1,1}) do
        local arrow=button(sidebar,direction<0 and "‹" or "›",{Name=direction<0 and "PreviousTabs" or "NextTabs",
            AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,index==1 and -37 or -4,.5,0),
            Size=UDim2.fromOffset(31,34),TextSize=21,Visible=false})
        round(arrow,8)
        connect(w,arrow.Activated,function() scrollTabs(direction*nav.AbsoluteWindowSize.X*.75) end)
        navArrows[index]=arrow
    end
    local function fitNavigation()
        local overflow=navLayout.AbsoluteContentSize.X>math.max(0,sidebar.AbsoluteSize.X-86*w.UIScale)
        nav.Position=UDim2.fromOffset(overflow and 46 or 8,0)
        nav.Size=UDim2.new(1,overflow and -92 or -16,1,0)
        for i,arrow in ipairs(navArrows) do
            arrow.Visible=overflow
            arrow.AnchorPoint=Vector2.new(0,.5)
            arrow.Position=i==1 and UDim2.new(0,6,.5,0) or UDim2.new(1,-40,.5,0)
        end
    end
    connect(w,navLayout:GetPropertyChangedSignal("AbsoluteContentSize"),fitNavigation)
    connect(w,sidebar:GetPropertyChangedSignal("AbsoluteSize"),fitNavigation)
    local content=new("Frame",{Name="Content",BackgroundTransparency=1,ZIndex=4},root)
    local pageTitle=label(content,"Inicio",20,C.Text,{Size=UDim2.new(1,-90,0,26),Font=BOLD})
    local sectionPicker=button(content,"",{Name="SectionPicker",BackgroundColor3=C.Panel,ZIndex=7,Visible=false})
    round(sectionPicker,8); stroke(sectionPicker,C.Border)
    local sectionName=label(sectionPicker,"Secciones",14,C.Text,{Font=BOLD,TextTruncate=Enum.TextTruncate.AtEnd,
        Position=UDim2.fromOffset(11,0),Size=UDim2.new(1,-36,1,0)})
    icon(sectionPicker,"chevron").Position=UDim2.new(1,-24,.5,-10)
    local pageDesc=label(content,DESCRIPTIONS.Inicio,10,C.Muted,{Position=UDim2.fromOffset(0,24),Size=UDim2.new(1,0,0,20),TextWrapped=true,TextYAlignment=Enum.TextYAlignment.Top})
    local count=label(content,"0 opciones",9,C.Faint,{Position=UDim2.new(1,-96,0,5),Size=UDim2.fromOffset(96,16),TextXAlignment=Enum.TextXAlignment.Right,Font=Enum.Font.Code})
    w.CountLabel=count
    local searchBox=new("Frame",{Name="SearchBox",BackgroundColor3=C.Field,BackgroundTransparency=Glass.Field,ClipsDescendants=true,
        Position=UDim2.new(1,-312,0,8),Size=UDim2.fromOffset(198,30),ZIndex=6},top)
    round(searchBox,17); local searchStroke=stroke(searchBox,w.ThemeDef.Visuals.SearchStroke)
    local search=new("TextBox",{Name="Search",BackgroundTransparency=1,ClearTextOnFocus=false,
        Active=true,TextEditable=true,Selectable=true,TextSize=12,TextTruncate=Enum.TextTruncate.AtEnd,
        PlaceholderText="Buscar ajuste...",PlaceholderColor3=C.Faint,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,
        Position=UDim2.fromOffset(28,0),Size=UDim2.new(1,-54,1,0)},searchBox)
    icon(searchBox,"search").Position=UDim2.new(0,8,.5,-10)
    local clear=button(searchBox,"×",{Name="Clear",BackgroundTransparency=1,Position=UDim2.new(1,-28,0,0),Size=UDim2.new(0,26,1,0),Visible=false})
    local pages=new("Frame",{Name="Pages",BackgroundTransparency=1,ClipsDescendants=true},content)
    local openButton=button(launcherSurface,"",{Name="OpenRyou",Position=UDim2.new(.5,-73,0,16),Size=UDim2.fromOffset(146,44),BackgroundColor3=w.ThemeDef.Visuals.OpenButtonBase,BackgroundTransparency=Glass.Button,ZIndex=20})
    round(openButton,12); local openStroke=stroke(openButton,w.ThemeDef.Visuals.OpenStroke)
    local openAccent=new("Frame",{Name="RyouOpenAccent",Position=UDim2.fromOffset(0,7),Size=UDim2.fromOffset(3,30),
        BackgroundColor3=C.White,BackgroundTransparency=.05,ZIndex=22},openButton)
    round(openAccent,8)
    local openIcon=mark(openButton,22,C.White); openIcon.Position=UDim2.fromOffset(12,11)
    local openLabel=label(openButton,"RyouHub",11,C.Text,{Position=UDim2.fromOffset(45,5),Size=UDim2.new(1,-55,0,20),Font=MEDIUM})
    local openHint=label(openButton,"ABRIR PANEL",8,C.Muted,{Position=UDim2.fromOffset(45,25),Size=UDim2.new(1,-55,0,12),Font=MEDIUM})
    w.OpenButton=openButton; w._launcherMoved=false; w.UIElements={Main=root,Title=brand,ActiveStatus=statusLabel,SideBar=sidebar,MainBar=content,Pages=pages,Search=searchBox,Topbar=top}
    local desired=o.Size or UDim2.fromOffset(680,430)
    w._desiredWidth=desired.X.Offset>0 and desired.X.Offset or 680
    w._desiredHeight=desired.Y.Offset>0 and desired.Y.Offset or 430
    w._initialFitDone=false
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

    local function addResizeHandle(name,position,anchor,size,xFactor,yFactor,showGrip)
        local hit=button(root,"",{Name=name,AnchorPoint=anchor,Position=position,
            Size=size,BackgroundTransparency=1,ZIndex=40,Visible=w.Resizable})
        table.insert(resizeHandles,{Hit=hit,X=xFactor,Y=yFactor})
        return hit
    end
    -- Esquinas: cambian ancho y alto a la vez.
    addResizeHandle("ResizeTL",UDim2.fromScale(0,0),Vector2.new(0,0),UDim2.fromOffset(28,28),-1,-1,false)
    addResizeHandle("ResizeTR",UDim2.fromScale(1,0),Vector2.new(1,0),UDim2.fromOffset(28,28), 1,-1,false)
    addResizeHandle("ResizeBL",UDim2.fromScale(0,1),Vector2.new(0,1),UDim2.fromOffset(28,28),-1, 1,false)
    addResizeHandle("ResizeBR",UDim2.fromScale(1,1),Vector2.new(1,1),UDim2.fromOffset(28,28), 1, 1,false)
    -- Bordes invisibles más grandes: facilitan especialmente estirar verticalmente en celular.
    addResizeHandle("ResizeTop",UDim2.fromScale(.5,0),Vector2.new(.5,0),UDim2.new(.34,0,0,12),0,-1,false)
    addResizeHandle("ResizeBottom",UDim2.fromScale(.5,1),Vector2.new(.5,1),UDim2.new(.34,0,0,14),0,1,false)
    addResizeHandle("ResizeLeft",UDim2.fromScale(0,.5),Vector2.new(0,.5),UDim2.new(0,12,.34,0),-1,0,false)
    addResizeHandle("ResizeRight",UDim2.fromScale(1,.5),Vector2.new(1,.5),UDim2.new(0,12,.34,0),1,0,false)
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
        local bounds=surface.AbsoluteSize; local size=root.AbsoluteSize
        if bounds.X<=0 or bounds.Y<=0 then return end
        local x=root.Position.X.Scale*bounds.X+root.Position.X.Offset
        local y=root.Position.Y.Scale*bounds.Y+root.Position.Y.Offset
        -- Sin margen artificial: el borde superior puede llegar exactamente a Y=0.
        local minX=math.min(size.X/2,bounds.X/2); local minY=math.min(size.Y/2,bounds.Y/2)
        root.Position=UDim2.fromOffset(math.clamp(x,minX,math.max(minX,bounds.X-minX)),math.clamp(y,minY,math.max(minY,bounds.Y-minY)))
    end
    local function clampLauncher()
        local bounds=launcherSurface.AbsoluteSize; local size=openButton.AbsoluteSize
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
        openHint.TextTransparency=ghosted and 1 or 0
        if openStroke then openStroke.Transparency=ghosted and 1 or 0 end
        if openIcon then
            for _,d in ipairs(openIcon:GetDescendants()) do
                if d:IsA("Frame") then d.BackgroundTransparency=ghosted and 1 or 0 end
                if d:IsA("UIStroke") then d.Transparency=ghosted and 1 or 0 end
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
        local maxWidth=math.max(280,bounds.X/w.UIScale)
        local maxHeight=math.max(240,bounds.Y/w.UIScale)
        local minWidth=math.min(w._minWidth,maxWidth)
        local minHeight=math.min(w._minHeight,maxHeight)

        -- Primer arranque en móvil/landscape: deja aire alrededor del panel.
        -- Después de esto no vuelve a forzar tamaño y el resize manual manda.
        if not w._initialFitDone then
            if maxHeight < 500 then
                w._desiredHeight=math.min(w._desiredHeight,math.max(minHeight,maxHeight*0.78))
                w._desiredWidth=math.min(w._desiredWidth,math.max(minWidth,maxWidth*0.76))
            elseif maxWidth < 650 then
                w._desiredWidth=math.min(w._desiredWidth,math.max(minWidth,maxWidth*0.86))
                w._desiredHeight=math.min(w._desiredHeight,math.max(minHeight,maxHeight*0.84))
            elseif maxWidth < 900 then
                w._desiredWidth=math.min(w._desiredWidth,math.max(minWidth,maxWidth*0.78))
                w._desiredHeight=math.min(w._desiredHeight,math.max(minHeight,maxHeight*0.80))
            end
            w._initialFitDone=true
        end

        local width=math.clamp(w._desiredWidth,minWidth,maxWidth)
        local height=math.clamp(w._desiredHeight,minHeight,maxHeight)
        root.Size=UDim2.fromOffset(width,height)

        local compact=width<680 or height<390
        local inset=compact and 12 or 17
        local topHeight=compact and 59 or 66
        local dockHeight=compact and 44 or 52
        local dockY=topHeight+5
        local contentY=dockY+dockHeight+12
        local contentEnd=height-13
        w._compactNavigation=compact

        w.Short=height<435
        w.Narrow=width<500
        w.Compact=width<650 or w.Short
        w.ContentWidth=width-inset*2
        top.Size=UDim2.new(1,0,0,topHeight)
        logo.Position=UDim2.fromOffset(inset,10)
        controls.Position=UDim2.new(1,-inset-76,0,6)
        controls.Size=UDim2.fromOffset(76,36)
        minimize.Position=UDim2.fromOffset(0,0); minimize.Size=UDim2.fromOffset(36,35)
        close.Position=UDim2.fromOffset(40,0); close.Size=UDim2.fromOffset(36,35)
        topRule.Position=UDim2.fromOffset(inset,topHeight-1)
        topRule.Size=UDim2.new(1,-2*inset,0,1)

        local clusterX=inset+34
        local clusterWidth=math.max(75,width-clusterX-inset-83)
        titleCluster.Position=UDim2.fromOffset(clusterX,6)
        titleCluster.Size=UDim2.fromOffset(clusterWidth,24)
        local requestedTitle=w._brandBaseTitle
        local legacyTitle=requestedTitle:lower()
        brand.Text=(legacyTitle=="ryou" or legacyTitle:match("^ryou%s*|")) and "RyouHub" or requestedTitle
        brand.TextSize=compact and 16 or 20
        brand.TextTruncate=Enum.TextTruncate.AtEnd
        local measuredBrand=math.ceil(TextService:GetTextSize(brand.Text,brand.TextSize,brand.Font,Vector2.new(850,24)).X)
        local measuredStatus=math.ceil(TextService:GetTextSize(statusLabel.Text,11,statusLabel.Font,Vector2.new(150,24)).X)
        brand.Size=UDim2.fromOffset(math.min(measuredBrand+2,clusterWidth),24)
        statusLabel.Position=UDim2.fromOffset(measuredBrand+9,0)
        statusLabel.Size=UDim2.fromOffset(measuredStatus+4,24)
        statusLabel.Visible=statusLabel.Text~="" and measuredBrand+measuredStatus+13<=clusterWidth
        author.Position=UDim2.fromOffset(clusterX,28)
        author.Size=UDim2.fromOffset(math.min(110,clusterWidth),14)
        author.TextXAlignment=Enum.TextXAlignment.Left
        author.TextTruncate=Enum.TextTruncate.AtEnd
        subtitle.Position=UDim2.fromOffset(clusterX+119,30)
        subtitle.Size=UDim2.fromOffset(math.max(0,clusterWidth-119),14)
        subtitle.TextTruncate=Enum.TextTruncate.AtEnd
        subtitle.Visible=not compact and clusterWidth>=225 and o.Subtitle~=nil and inferredGameLabel~=subtitleGame

        sidebar.Position=UDim2.fromOffset(inset,dockY)
        sidebar.Size=UDim2.new(1,-2*inset,0,dockHeight)
        sidebar.Visible=true

        content.Position=UDim2.fromOffset(inset,contentY)
        content.Size=UDim2.new(1,-2*inset,0,math.max(0,contentEnd-contentY))
        -- El buscador vive en el encabezado, delante de minimizar/cerrar.
        if searchBox.Parent~=top then searchBox.Parent=top end
        local searchWidth=math.clamp(math.floor(width*.29),115,310)
        local controlGap=inset+76+12
        searchBox.Position=UDim2.new(1,-searchWidth-controlGap,0,math.floor((topHeight-36)*.5))
        searchBox.Size=UDim2.fromOffset(searchWidth,36)
        -- Usar toda la superficie debajo de las pestañas para contenido.
        pageTitle.Visible=false
        sectionPicker.Visible=false
        count.Visible=false
        pageDesc.Visible=false
        pages.Position=UDim2.fromOffset(0,0)
        pages.Size=UDim2.fromScale(1,1)

        openButton.Size=UDim2.fromOffset(bounds.X<380 and 130 or 146,44)
        if not w._launcherMoved then
            local launcherWidth=openButton.Size.X.Offset
            local launchWidth=launcherSurface.AbsoluteSize.X
            openButton.Position=UDim2.fromOffset(math.max(0,math.floor((launchWidth-launcherWidth)*.5)),16)
        end

        clampRoot()
        clampLauncher()
        for _,tab in ipairs(w.Tabs) do
            if tab._fitConcept then tab._fitConcept() end
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
        if previous then previous.Query=search.Text end
        self:_closePopup()
        self.CurrentTab=target
        for _,tab in ipairs(self.Tabs) do
            local selected=tab==target
            tab.Page.Visible=selected
            uiTween(tab.NavButton,{
                BackgroundColor3=selected and C.Hover or self.ThemeDef.Visuals.NavButtonIdle,
                BackgroundTransparency=selected and Glass.NavActive or Glass.NavIdle
            },.19)
            tab.NavTitle.TextColor3=selected and C.Text or C.Muted
            if tab.Number then tab.Number.TextColor3=selected and C.Text or C.Faint end
            if tab.NavIcon then tab.NavIcon.ImageColor3=selected and C.Text or C.Faint end
            if tab.SelectionBar then
                tab.SelectionBar.Visible=selected
                tab.SelectionBar.BackgroundColor3=self.ThemeName=="Blanco" and C.Text or C.White
                tab.SelectionBar.BackgroundTransparency=selected and 0 or 1
            end
        end
        pageTitle.Text=target.Title; pageDesc.Text=target.Desc
        sectionName.Text=target.Title
        search.Text=target.Query or ""; clear.Visible=search.Text~=""
        self:_drawer(false)
        if target._fitConcept then target._fitConcept() end
        if target._refreshCompanions then target._refreshCompanions() end
        if target._refreshStats then target._refreshStats() end
        target:_filter()
        if previous~=target then
            if self._pageTween then self._pageTween:Cancel() end
            if previous then previous.Page.Position=UDim2.fromOffset(0,0) end
            if self.Opened then
                target.Page.Position=UDim2.fromOffset(12,0)
                self._pageTween=TweenService:Create(target.Page,TweenInfo.new(.23,Enum.EasingStyle.Quart),
                    {Position=UDim2.fromOffset(0,0)})
                self._pageTween:Play()
            end
            task.defer(function()
                if self.Destroyed or self.CurrentTab~=target or not sidebar.Visible or not target.NavButton.Visible then return end
                local left=nav.AbsolutePosition.X
                local right=left+nav.AbsoluteWindowSize.X
                local start=target.NavButton.AbsolutePosition.X
                local finish=start+target.NavButton.AbsoluteSize.X
                local delta=start<left and start-left or math.max(0,finish-right)
                if delta~=0 then scrollTabs(delta) end
            end)
        end
        return target
    end
    function w:_tab(options,holder)
        local opt=options or {}; local title=plain(opt.Title or "Pestaña")
        local index=#self.Tabs+1
        local tab=setmetatable({Window=self,Title=title,Desc=opt.Desc or DESCRIPTIONS[title] or "Personaliza tus opciones.",
            Elements={},_order=0,Query="",Index=index},Tab)
        local page=new("Frame",{Name=title,BackgroundTransparency=1,Size=UDim2.fromScale(1,1),Visible=false},pages)
        -- RyouHub Concept C: exactamente la misma estructura modular para todas las pestañas.
        -- No existen ventanas emergentes de secciones: el usuario cambia arriba.
        local shell=scroll(page,{Name="ConceptCShell",ScrollingDirection=Enum.ScrollingDirection.Y,
            AutomaticCanvasSize=Enum.AutomaticSize.None,ScrollBarThickness=3,
            ScrollBarImageColor3=C.White})
        local conceptPanelSkins={}
        local function conceptPanel(name)
            local p=new("Frame",{Name=name,BackgroundColor3=C.Panel,BackgroundTransparency=.09,
                ClipsDescendants=true},shell)
            round(p,20)
            local edge=stroke(p,C.Border); edge.Transparency=.16
            local panelGradient=new("UIGradient",{Rotation=102,Color=ColorSequence.new(
                Color3.fromRGB(22,43,45),Color3.fromRGB(9,19,23))},p)
            table.insert(conceptPanelSkins,{Panel=p,Edge=edge,Gradient=panelGradient})
            return p
        end
        local mainCard=conceptPanel("SettingsCard")
        local quickCard=conceptPanel("QuickActionsCard")
        local statsCard=conceptPanel("SessionCard")
        local cardHeadings={}
        local function cardTitle(card,titleText,caption,iconKey)
            local iconChip=new("Frame",{Name="IconTile",Position=UDim2.fromOffset(15,15),
                Size=UDim2.fromOffset(39,39),BackgroundColor3=C.Field},card)
            round(iconChip,13)
            local iconEdge=stroke(iconChip,C.White);iconEdge.Transparency=.42
            local fallback=label(iconChip,"•",16,C.White,{Size=UDim2.fromScale(1,1),
                TextXAlignment=Enum.TextXAlignment.Center,Font=BOLD})
            local picture=remoteIcon(iconChip,iconKey,22,C.White,function()
                if fallback.Parent then fallback.Visible=false end
            end)
            picture.AnchorPoint=Vector2.new(.5,.5)
            picture.Position=UDim2.fromScale(.5,.5)
            local heading=label(card,titleText,16,C.Text,{Position=UDim2.fromOffset(65,14),
                Size=UDim2.new(1,-76,0,28),Font=BOLD,
                TextTruncate=Enum.TextTruncate.AtEnd})
            local hint=label(card,caption,10,C.Muted,{Position=UDim2.fromOffset(65,40),
                Size=UDim2.new(1,-76,0,22),TextTruncate=Enum.TextTruncate.AtEnd})
            local rule=new("Frame",{Name="CardRule",BackgroundColor3=C.Border,BackgroundTransparency=.45,
                Position=UDim2.fromOffset(15,74),Size=UDim2.new(1,-30,0,1)},card)
            cardHeadings[#cardHeadings+1]={Card=card,Icon=iconChip,Heading=heading,Hint=hint,Rule=rule}
            return hint
        end
        local mainCaption=cardTitle(mainCard,title,tab.Desc,opt.Icon or "layout-grid")
        cardTitle(quickCard,"Acciones rápidas","Abre otra sección.","zap")
        cardTitle(statsCard,"Sesión actual","Información en tiempo real.","clock-3")
        local list=scroll(mainCard,{Name="Options",Position=UDim2.fromOffset(13,82),
            Size=UDim2.new(1,-26,1,-94),AutomaticCanvasSize=Enum.AutomaticSize.None,
            ScrollBarThickness=3,ScrollBarImageColor3=C.White})
        vertical(list,10); padding(list,2,3)
        local empty=label(mainCard,"Sin coincidencias. Prueba otra búsqueda.",12,C.Muted,{
            Position=UDim2.fromOffset(24,98),Size=UDim2.new(1,-48,0,50),
            TextWrapped=true,Visible=false,ZIndex=5})
        local quickButtons={}
        for i=1,3 do
            local link=button(quickCard,"",{Name="QuickLink"..i,
                BackgroundColor3=C.Row,Size=UDim2.new(1,-26,0,44),
                Position=UDim2.fromOffset(13,86+(i-1)*56)})
            round(link,13)
            local edge=stroke(link,C.Border);edge.Transparency=.28
            label(link,"›",23,C.White,{Position=UDim2.new(1,-36,0,0),
                Size=UDim2.fromOffset(27,44),TextXAlignment=Enum.TextXAlignment.Center})
            local textLink=label(link,"",12,C.Text,{Position=UDim2.fromOffset(15,0),
                Size=UDim2.new(1,-54,1,0),Font=MEDIUM,
                TextTruncate=Enum.TextTruncate.AtEnd})
            hover(self,link,C.Row,Glass.Row,C.Hover,.02)
            quickButtons[i]={Button=link,Text=textLink,Target=nil}
            connect(self,link.Activated,function()
                local data=quickButtons[i]
                if data and data.Target then self:SelectTab(data.Target) end
            end)
        end
        local statValues={}
        for i,spec in ipairs({{"Tiempo activo","00:00"},{"Jugadores","0"},{"Opciones","0"}}) do
            local y=92+(i-1)*37
            label(statsCard,spec[1],11,C.Muted,{Position=UDim2.fromOffset(17,y),
                Size=UDim2.new(.56,-17,0,29)})
            statValues[i]=label(statsCard,spec[2],14,C.White,{Position=UDim2.new(.56,0,0,y),
                Size=UDim2.new(.44,-17,0,29),Font=BOLD,
                TextXAlignment=Enum.TextXAlignment.Right})
        end
        label(statsCard,"Presets",16,C.Text,{Font=BOLD,
            Position=UDim2.fromOffset(17,210),Size=UDim2.new(1,-34,0,27)})
        label(statsCard,"Carga o guarda tu configuración.",11,C.Muted,{
            Position=UDim2.fromOffset(17,241),Size=UDim2.new(1,-34,0,32),
            TextWrapped=true})
        local presetsButton=button(statsCard,"Predeterminado    ▾",{
            BackgroundColor3=C.Field,Size=UDim2.new(1,-34,0,39),
            Position=UDim2.fromOffset(17,287),TextSize=12,Font=MEDIUM})
        round(presetsButton,12)
        local presetStroke=stroke(presetsButton,C.Border)
        presetStroke.Transparency=.28
        hover(self,presetsButton,C.Field,Glass.Field,C.Hover,.02)
        connect(self,presetsButton.Activated,function() self:SelectTab("Configuración") end)
        tab._refreshCompanions=function()
            local available={}
            for _,other in ipairs(self.Tabs) do
                if other~=tab then table.insert(available,other) end
            end
            for i,entry in ipairs(quickButtons) do
                local choice=available[((tab.Index+i-2)%math.max(1,#available))+1]
                entry.Target=choice
                entry.Button.Visible=choice~=nil
                entry.Text.Text=choice and choice.Title or ""
            end
        end
        tab._refreshStats=function()
            local seconds=math.floor(os.clock()-self._conceptStart)
            statValues[1].Text=string.format("%02d:%02d",math.floor(seconds/60),seconds%60)
            statValues[2].Text=tostring(#Players:GetPlayers())
            local count=0
            for _,item in ipairs(tab.Elements) do
                if not item.Destroyed and item.__type~="Section" and item.ElementFrame.Visible then
                    count+=1
                end
            end
            statValues[3].Text=tostring(count)
        end
        local function fitConcept()
            local area=page.AbsoluteSize
            local width,height=area.X,area.Y
            if width<1 or height<1 then return end
            local gap,pad=12,3
            if width>=770 then
                local aw=width-2*pad-2*gap
                local a=math.floor(aw*.51)
                local b=math.floor(aw*.23)
                local c=aw-a-b
                mainCard.Position=UDim2.fromOffset(pad,pad)
                mainCard.Size=UDim2.fromOffset(a,height-2*pad)
                quickCard.Position=UDim2.fromOffset(pad+a+gap,pad)
                quickCard.Size=UDim2.fromOffset(b,height-2*pad)
                statsCard.Position=UDim2.fromOffset(pad+a+gap+b+gap,pad)
                statsCard.Size=UDim2.fromOffset(c,height-2*pad)
                shell.ScrollingEnabled=false
                shell.CanvasSize=UDim2.fromOffset(0,height)
            elseif width>=610 then
                local aw=width-2*pad-gap
                local a=math.floor(aw*.62)
                local b=aw-a
                local quickHeight=math.max(190,math.floor((height-2*pad-gap)*.49))
                local statsHeight=math.max(205,height-quickHeight-2*pad-gap)
                mainCard.Position=UDim2.fromOffset(pad,pad)
                mainCard.Size=UDim2.fromOffset(a,height-2*pad)
                quickCard.Position=UDim2.fromOffset(pad+a+gap,pad)
                quickCard.Size=UDim2.fromOffset(b,quickHeight)
                statsCard.Position=UDim2.fromOffset(pad+a+gap,quickHeight+pad+gap)
                statsCard.Size=UDim2.fromOffset(b,statsHeight)
                shell.ScrollingEnabled=true
                shell.CanvasSize=UDim2.fromOffset(0,math.max(height,statsCard.Position.Y.Offset+statsHeight+pad))
            else
                local a=width-2*pad-5
                local mainHeight=math.max(310,height-10)
                mainCard.Position=UDim2.fromOffset(pad,pad)
                mainCard.Size=UDim2.fromOffset(a,mainHeight)
                quickCard.Position=UDim2.fromOffset(pad,pad+mainHeight+gap)
                quickCard.Size=UDim2.fromOffset(a,290)
                statsCard.Position=UDim2.fromOffset(pad,pad+mainHeight+gap+290+gap)
                statsCard.Size=UDim2.fromOffset(a,367)
                shell.ScrollingEnabled=true
                shell.CanvasSize=UDim2.fromOffset(0,mainHeight+290+367+3*gap+2*pad)
            end
            list.Size=UDim2.new(1,-26,0,math.max(100,mainCard.Size.Y.Offset-94))
            for _,head in ipairs(cardHeadings) do
                local small=head.Card.Size.X.Offset<225
                head.Icon.Position=UDim2.fromOffset(small and 11 or 15,14)
                head.Icon.Size=UDim2.fromOffset(small and 32 or 39,small and 32 or 39)
                head.Heading.Position=UDim2.fromOffset(small and 49 or 65,11)
                head.Heading.Size=UDim2.new(1,small and -57 or -76,0,28)
                head.Heading.TextSize=small and 12 or 16
                head.Hint.Visible=not small
                head.Hint.Position=UDim2.fromOffset(65,40)
                head.Rule.Position=UDim2.fromOffset(15,small and 56 or 74)
            end
        end
        tab._fitConcept=fitConcept
        tab.ConceptShell=shell
        tab._applyConceptTheme=function()
            local light=self.ThemeName=="Blanco"
            for _,skin in ipairs(conceptPanelSkins) do
                if skin.Panel and skin.Panel.Parent then
                    skin.Panel.BackgroundColor3=light and Color3.fromRGB(241,245,247) or C.Panel
                    skin.Edge.Color=light and Color3.fromRGB(190,206,209) or C.Border
                    skin.Gradient.Color=light and ColorSequence.new(
                        Color3.fromRGB(254,255,255),Color3.fromRGB(229,238,241))
                        or ColorSequence.new(
                            Color3.fromRGB(22,43,45),Color3.fromRGB(9,19,23))
                end
            end
        end
        connect(self,page:GetPropertyChangedSignal("AbsoluteSize"),function()
            fitConcept()
            tab:_queueFilter()
        end)
        task.defer(fitConcept)
        local hasIcon=opt.Icon~=nil and tostring(opt.Icon)~=""
        local labelX=hasIcon and 34 or 12
        local titleWidth=math.ceil(TextService:GetTextSize(title,12,MEDIUM,Vector2.new(300,22)).X)
        local navWidth=math.clamp(titleWidth+labelX+12,76,204)
        self._navOrder+=1
        local navButton=button(holder or nav,"",{Name=title,Size=UDim2.fromOffset(navWidth,37),
            BackgroundColor3=self.ThemeDef.Visuals.NavButtonIdle,BackgroundTransparency=Glass.NavIdle,LayoutOrder=self._navOrder})
        round(navButton,15)
        local selectionBar=new("Frame",{Name="Selected",Position=UDim2.new(0,10,1,-4),Size=UDim2.new(1,-20,0,2),
            BackgroundColor3=C.White,BackgroundTransparency=0,Visible=false,ZIndex=3},navButton); round(selectionBar,2)
        local navIcon
        local numberLabel=label(navButton,string.format("%02d",index),10,C.Faint,{
            Position=UDim2.fromOffset(9,0),Size=UDim2.new(0,15,1,0),Visible=false})
        if hasIcon then
            local placeholder=label(navButton,"·",17,C.Faint,{Position=UDim2.fromOffset(9,0),Size=UDim2.new(0,15,1,0),
                TextXAlignment=Enum.TextXAlignment.Center})
            navIcon=remoteIcon(navButton,opt.Icon,16,C.Faint,function()
                if placeholder.Parent then placeholder.Visible=false end
            end)
            navIcon.Position=UDim2.fromOffset(10,9)
        end
        local titleLabel=label(navButton,title,12,C.Muted,{Position=UDim2.fromOffset(labelX,-1),Size=UDim2.new(1,-labelX-10,1,0),
            Font=MEDIUM,TextTruncate=Enum.TextTruncate.AtEnd})
        tab.Page,tab.Content,tab.Empty=page,list,empty; tab.NavButton,tab.NavTitle=navButton,titleLabel
        tab.ConceptCards={mainCard,quickCard,statsCard}
        tab.Number=numberLabel; tab.NavIcon=navIcon; tab.SelectionBar=selectionBar
        table.insert(self.Tabs,tab)
        connect(self,navButton.Activated,function() self:SelectTab(tab) end)
        connect(self,navButton.MouseEnter,function()
            if self.CurrentTab~=tab then
                navButton.BackgroundColor3=self.ThemeDef.Visuals.NavButtonHover
                navButton.BackgroundTransparency=Glass.NavHover
            end
        end)
        connect(self,navButton.MouseLeave,function()
            if self.CurrentTab~=tab then
                navButton.BackgroundColor3=self.ThemeDef.Visuals.NavButtonIdle
                navButton.BackgroundTransparency=Glass.NavIdle
            end
        end)
        connect(self,list:GetPropertyChangedSignal("AbsoluteSize"),function() tab:_queueFilter() end)
        if not self.CurrentTab then self:SelectTab(tab) end
        return tab
    end
    function w:Tab(options) return self:_tab(options) end
    function w:Section(options)
        -- Grupo lógico para compatibilidad; pestañas sin títulos intermedios.
        local section={Window=self,ElementFrame=nav,Title=plain((options or {}).Title or "")}
        function section:Tab(config) return self.Window:_tab(config,nav) end
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

        if active then
            statusLabel.Text=active.." activos"
        end

        if self._fit then
            self._fit(true)
        else
            brand.Text=self._brandBaseTitle
        end
        return self
    end
    function w:SetAuthor(text) self.Author=plain(text); author.Text=self.Author end
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
        Nox.UIScale=self.UIScale; fit(); return self
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
        if config.Title then openLabel.Text=plain(config.Title) end
        return self
    end
    function w:GetTheme()
        return self.ThemeName or CURRENT_THEME_NAME
    end
    function w:SetTheme(name, silent)
        local resolved = canonicalThemeName(name)
        local themeDef = getThemeDefinition(resolved)
        self.ThemeName = resolved
        self.ThemeDef = themeDef
        applyThemeDefinition(resolved)

        root.BackgroundColor3 = themeDef.Visuals.RootBase
        root.BackgroundTransparency = Glass.Root
        rootStroke.Color = themeDef.Visuals.RootStroke
        rootGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, themeDef.Visuals.RootGradient[1]),
            ColorSequenceKeypoint.new(.52, themeDef.Visuals.RootGradient[2]),
            ColorSequenceKeypoint.new(1, themeDef.Visuals.RootGradient[3])
        })
        glowA.BackgroundColor3 = themeDef.Visuals.BackdropGlowA
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
        applyThemeRolesRecursive(gui)
        applyThemeRolesRecursive(launcherGui)
        for _,tab in ipairs(self.Tabs) do
            if tab._applyConceptTheme then tab._applyConceptTheme() end
        end
        if self.CurrentTab then
            self:SelectTab(self.CurrentTab)
        end
        for _, tab in ipairs(self.Tabs) do
            for _, control in ipairs(tab.Elements or {}) do
                if control.ApplyTheme then control:ApplyTheme() end
            end
        end
        if not silent and Nox.Notify and Nox.Window == self then
            Nox:Notify({Title = "Tema", Content = "Interfaz cambiada a " .. (resolved == "Blanco" and "Blanco" or "Oscuro")})
        end
        return self
    end
    function w:OnDestroy(callback) table.insert(self._onDestroy,callback); return self end
    function w:OnOpen(callback) table.insert(self._onOpen,callback); return self end
    function w:OnClose(callback) table.insert(self._onClose,callback); return self end
    local windowTween
    local function animateWindow(opened)
        if windowTween then windowTween:Cancel() end
        if opened then
            if not root.Visible then mount.Position=UDim2.fromOffset(0,9) end
            root.Visible=true
        end
        root.Interactable=opened
        windowTween=TweenService:Create(mount,
            TweenInfo.new(opened and .29 or .19,Enum.EasingStyle.Quart,opened and Enum.EasingDirection.Out or Enum.EasingDirection.In),
            {Position=UDim2.fromOffset(0,opened and 0 or 9)})
        windowTween:Play()
        if not opened then
            local closing=windowTween
            task.delay(.19,function()
                if not w.Destroyed and not w.Opened and windowTween==closing then root.Visible=false end
            end)
        end
    end
    function w:Open()
        if self.Destroyed then return self end
        local changed=not self.Opened
        self.Opened=true
        if changed then animateWindow(true) else root.Visible=true end
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
        if windowTween then windowTween:Cancel() end
        if self._pageTween then self._pageTween:Cancel() end
        for _,callback in ipairs(self._onDestroy) do invoke(callback) end
        gui:Destroy(); launcherGui:Destroy()
        if env.__NOX_UI==self then env.__NOX_UI=nil end
        if Nox.Window==self then Nox.Window=nil end
    end
    function w:Dialog(config)
        local cfg=config or {}; local panel=self:_popup(plain(cfg.Title or "Ryou"),350,230,nil)
        local body=scroll(panel,{Position=UDim2.fromOffset(18,58),Size=UDim2.new(1,-36,1,-122)})
        label(body,plain(cfg.Content or cfg.Desc),13,C.Muted,{Size=UDim2.new(1,-6,0,0),AutomaticSize=Enum.AutomaticSize.Y,TextWrapped=true,TextYAlignment=Enum.TextYAlignment.Top})
        local buttons=cfg.Buttons or {{Title="Aceptar"}}
        for i,entry in ipairs(buttons) do
            local b=button(panel,entry.Title or "Aceptar",{Position=UDim2.new((i-1)/#buttons,16,1,-54),Size=UDim2.new(1/#buttons,-22,0,36)})
            round(b,8)
            connect(self,b.Activated,function() self:_closePopup(); invoke(entry.Callback) end,self._popupConnections)
        end
        return {Close=function() self:_closePopup() end}
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
            if delta.Magnitude>5 then moved=true end
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
            local maxScreenW=math.max(260,bounds.X)
            local maxScreenH=math.max(220,bounds.Y)
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
        if input.Position.X < controls.AbsolutePosition.X then drag(input,root,true) end
    end)
    connect(w,openButton.InputBegan,function(input) w._skipOpen=false; drag(input,openButton,false) end)
    connect(w,openButton.Activated,function() if not w._skipOpen then w:Toggle() end end)
    connect(w,Input.InputChanged,function(input)
        local d=w._drag
        if d and ((d.Input.UserInputType==Enum.UserInputType.Touch and input==d.Input)
            or (d.Input.UserInputType==Enum.UserInputType.MouseButton1 and input.UserInputType==Enum.UserInputType.MouseMovement)) then d.Update(input.Position) end
    end)
    connect(w,Input.InputEnded,function(input)
        local d=w._drag
        if d and (input==d.Input or (d.Input.UserInputType==Enum.UserInputType.MouseButton1 and input.UserInputType==Enum.UserInputType.MouseButton1)) then w:_endDrag() end
    end)
    connect(w,Input.WindowFocusReleased,function() w:_endDrag() end)
    local conceptClock=0
    connect(w,RunService.Heartbeat,function(delta)
        if not w.Opened or w.Destroyed then return end
        conceptClock+=delta
        if conceptClock>=1 then
            conceptClock=0
            if w.CurrentTab and w.CurrentTab._refreshStats then
                w.CurrentTab._refreshStats()
            end
        end
    end)
    connect(w,Input.InputBegan,function(input,processed)
        if input.KeyCode==Enum.KeyCode.Escape and w._popupLayer then w:_closePopup(); return end
        if processed or Input:GetFocusedTextBox() then return end
        if input.KeyCode==w.ToggleKey then w:Toggle() end
    end)
    connect(w,surface:GetPropertyChangedSignal("AbsoluteSize"),fit)
    connect(w,launcherSurface:GetPropertyChangedSignal("AbsoluteSize"),clampLauncher)
    connect(w,gui.Destroying,function() if not w.Destroyed then w:Destroy() end end)
    if o.OpenButton then w:EditOpenButton(o.OpenButton) end
    if o.Author then w:SetAuthor(o.Author) end
    w:SetTheme(resolvedTheme, true)
    task.defer(function()
        fit()
        if not w.Destroyed and w.Opened and not windowTween then
            mount.Position=UDim2.fromOffset(0,9)
            animateWindow(true)
        end
    end)
    return w
end
-- Public icon helpers. Game hubs normally only need Icon="name" in control configs.
Nox.Icons = XERO_ICON_FILES
function Nox:GetIconAsset(name) return cachedIconAsset(name) end
function Nox:PreloadIcon(name, callback) requestIconAsset(name, callback); return self end

function Nox:SetTheme(name)
    local resolved = canonicalThemeName(name)
    applyThemeDefinition(resolved)
    local publicName = resolved == "Xero" and "Ryou" or resolved
    self.Theme = {Name = publicName, Accent = C.White, Background = C.Window, Text = C.Text}
    if self.Window and not self.Window.Destroyed and self.Window.SetTheme then
        self.Window:SetTheme(resolved, true)
    end
    return self.Theme
end
function Nox:GetCurrentTheme()
    if self.Window and not self.Window.Destroyed and self.Window.GetTheme then
        return self.Window:GetTheme()
    end
    return CURRENT_THEME_NAME
end
function Nox:GetThemes()
    return {
        Ryou = {Name = "Ryou"},
        Xero = {Name = "Ryou"}, -- legacy alias
        Nox = {Name = "Ryou"},  -- legacy alias
        Onyx = {Name = "Ryou"}, -- legacy alias
        Blanco = {Name = "Blanco"},
        White = {Name = "Blanco"},
    }
end
function Nox:Notify(options)
    if not self.Window then return end
    local w=self.Window; local o=options or {}
    if w.Destroyed then return end
    if w._notice then w._notice:Destroy() end
    local holder=new("Frame",{Name="RyouNotice",BackgroundColor3=C.Window,AnchorPoint=Vector2.new(1,0),
        Position=UDim2.new(1,384,0,64),Size=UDim2.new(1,-24,0,0),AutomaticSize=Enum.AutomaticSize.Y,ZIndex=100},w.ScreenGui)
    new("UISizeConstraint",{MaxSize=Vector2.new(360,math.huge)},holder)
    round(holder,12); stroke(holder); padding(holder,16,12); vertical(holder,4)
    local accent=new("Frame",{Name="NoticeAccent",BackgroundColor3=C.White,Size=UDim2.fromOffset(28,2),LayoutOrder=0},holder)
    round(accent,2)
    label(holder,plain(o.Title or "Ryou"),13,C.Text,{Font=BOLD,LayoutOrder=1})
    label(holder,plain(o.Content or o.Desc),12,C.Muted,{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,TextWrapped=true,LayoutOrder=2})
    local tweenService=game:GetService("TweenService")
    tweenService:Create(holder,TweenInfo.new(.18,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),
        {Position=UDim2.new(1,-12,0,64)}):Play()
    w._notice=holder
    task.delay(math.clamp(tonumber(o.Duration) or 2,1,8),function()
        if holder.Parent then
            local exitTween=tweenService:Create(holder,TweenInfo.new(.14,Enum.EasingStyle.Quint,Enum.EasingDirection.In),
                {Position=UDim2.new(1,384,0,64)})
            exitTween:Play()
            exitTween.Completed:Wait()
            if holder.Parent then holder:Destroy() end
        end
        if w._notice==holder then w._notice=nil end
    end)
    return {Close=function() if holder.Parent then holder:Destroy() end end}
end
Nox:SetTheme("Ryou")
return Nox
