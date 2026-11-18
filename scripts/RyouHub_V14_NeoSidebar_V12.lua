-- RyouHub | Juego actual - TP Slash
-- Creador: Ryou
-- Interfaz: Ryou UI V14 Neo Sidebar V12 (biblioteca visual remota, commit fijo).
-- Lógica del juego: conservada de RyouHub V13.
-- UI compartida desde vryex/ryouhub, rama de rediseño.
--
-- TP Slash:
--   * Toggle global.
--   * Solo ataca jugadores vivos que NO sean de tu equipo.
--   * Solo funciona si el cuchillo ya está equipado en Character.
--   * No usa KnifeServer.SlashStart.
--   * Dispara señales de tap móvil + Tool.Activated, sin mouse ni teclado.
--   * Se queda debajo del objetivo mirando hacia arriba hasta confirmar daño real.
--   * Al confirmar daño restaura posición, estado y velocidad inmediatamente.
--
-- Ataque individual:
--   * Se mantiene aparte mediante dropdown.
--   * Usa exactamente la misma lógica de ataque.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local VirtualInputManager
pcall(function()
    VirtualInputManager = game:GetService("VirtualInputManager")
end)


local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    return
end

local WindUI

local RYOU_UI_URL =
    "https://raw.githubusercontent.com/vryex/ryouhub/8a29db883560dfc79bbf1789a7e783af7ff3d87b/ryou-ui-v14/RyouUI.lua"

local ATTACK_Y_OFFSET = -4.60
local SLASH_RETRY_DELAY = 0.16
local BETWEEN_TARGETS_DELAY = 0.035
local NO_TARGETS_DELAY = 0.12

local state = {
    Alive = true,
    Busy = false,
    CancelRequested = false,
    SelectedPlayer = nil,

    TPSlashEnabled = false,
    TPSlashGeneration = 0,
    RoundWasActive = false,
}


local function notify(message, duration)
    if WindUI and type(WindUI.Notify) == "function" then
        pcall(function()
            WindUI:Notify({
                Title = "Ryou",
                Content = tostring(message or ""),
                Duration = tonumber(duration) or 2,
            })
        end)
    else
        warn("[Ryou] " .. tostring(message))
    end
end

local function getLocalCharacter()
    local character = LocalPlayer.Character
    if not character then
        return nil, nil, nil
    end

    return character,
        character:FindFirstChild("HumanoidRootPart"),
        character:FindFirstChildOfClass("Humanoid")
end

local KNIFE_WORDS = {
    "knife",
    "cuchillo",
    "blade",
    "dagger",
    "kunai",
}

local function isKnifeTool(tool)
    if not tool or not tool:IsA("Tool") then
        return false
    end

    -- Esto solo sirve para RECONOCER el Tool. No usamos ningún Remote.
    if tool:FindFirstChild("KnifeServer", true)
        or tool:FindFirstChild("KnifeClient", true)
    then
        return true
    end

    local lowered = string.lower(tool.Name)
    for _, word in ipairs(KNIFE_WORDS) do
        if string.find(lowered, word, 1, true) then
            return true
        end
    end

    return false
end

local function getEquippedKnife()
    local character = LocalPlayer.Character
    if not character then
        return nil
    end

    -- Intencionalmente NO revisa Backpack.
    -- Si no está en Character, no está "en mano" y TP Slash no actúa.
    for _, object in ipairs(character:GetChildren()) do
        if isKnifeTool(object) then
            return object
        end
    end

    return nil
end

local function freezeRoot(root)
    if not root or not root.Parent then
        return
    end

    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
end

local function getAttackCFrame(targetRoot)
    if not targetRoot or not targetRoot.Parent then
        return nil
    end

    return targetRoot.CFrame
        * CFrame.new(0, ATTACK_Y_OFFSET, 0)
        * CFrame.Angles(math.rad(90), 0, 0)
end

local function placeUnderTarget(character, root, targetRoot)
    local attackCF = getAttackCFrame(targetRoot)
    if not attackCF then
        return false
    end

    character:PivotTo(attackCF)
    freezeRoot(root)
    return true
end

local function getConnectionFunction(connection)
    if not connection then
        return nil
    end

    local fn

    pcall(function()
        fn = connection.Function
    end)

    if type(fn) ~= "function" then
        pcall(function()
            fn = connection.Callback
        end)
    end

    return type(fn) == "function" and fn or nil
end

local function getSignalCallbacks(signal)
    if type(getconnections) ~= "function" then
        return {}
    end

    local ok, connections = pcall(getconnections, signal)
    if not ok or type(connections) ~= "table" then
        return {}
    end

    local callbacks = {}

    for _, connection in ipairs(connections) do
        local fn = getConnectionFunction(connection)
        if fn then
            callbacks[#callbacks + 1] = fn
        end
    end

    return callbacks
end

local function fireSignalCallbacks(signal, ...)
    local callbacks = getSignalCallbacks(signal)
    local fired = false
    local args = table.pack(...)

    for _, callback in ipairs(callbacks) do
        local ok = pcall(function()
            callback(table.unpack(args, 1, args.n))
        end)
        fired = fired or ok
    end

    return fired
end

local function fireSignalCompat(signal, ...)
    local args = table.pack(...)

    if type(firesignal) == "function" then
        local ok = pcall(function()
            firesignal(signal, table.unpack(args, 1, args.n))
        end)

        if ok then
            return true
        end
    end

    return fireSignalCallbacks(
        signal,
        table.unpack(args, 1, args.n)
    )
end

local function releaseKnife(knife)
    if not knife or not knife.Parent then
        return
    end

    if type(firesignal) == "function" then
        pcall(function()
            firesignal(knife.Deactivated)
        end)
    end

    fireSignalCallbacks(knife.Deactivated)

    pcall(function()
        knife:Deactivate()
    end)
end

local slashRoute = 0

local TOUCH_HOLD_TIME = 0.055
local touchSerial = 6100
local confirmedTouchCandidate = nil
local nextTouchCandidate = 1

-- Tu captura física buena fue aproximadamente:
--   x = 190 / 853 ~= 0.223
--   y = 108 / 394 ~= 0.274
-- y llegó con gameProcessedEvent=false desde InputBegan hasta TouchTap.
--
-- Las demás posiciones son respaldos altos/centrales para evitar
-- joystick, salto y botones de UI.
local TOUCH_CANDIDATES = {
    Vector2.new(0.223, 0.274),
    Vector2.new(0.300, 0.230),
    Vector2.new(0.410, 0.215),
    Vector2.new(0.185, 0.390),
    Vector2.new(0.515, 0.225),
}

local function getViewportSize()
    local camera = workspace.CurrentCamera
    return camera and camera.ViewportSize or Vector2.new(853, 394)
end

local function candidateToScreen(candidate)
    local viewport = getViewportSize()

    return Vector2.new(
        math.floor(viewport.X * candidate.X),
        math.floor(viewport.Y * candidate.Y)
    )
end

local function getNextTouchCandidate()
    if confirmedTouchCandidate then
        return confirmedTouchCandidate
    end

    local candidate = TOUCH_CANDIDATES[nextTouchCandidate]
        or TOUCH_CANDIDATES[1]

    nextTouchCandidate += 1
    if nextTouchCandidate > #TOUCH_CANDIDATES then
        nextTouchCandidate = 1
    end

    return candidate
end

local function sendRealMobileTap()
    if not VirtualInputManager then
        return false, nil
    end

    local candidate = getNextTouchCandidate()
    local position = candidateToScreen(candidate)

    touchSerial += 1
    if touchSerial > 9000 then
        touchSerial = 6101
    end

    local touchId = touchSerial
    local observed = false
    local processed = nil

    -- Escuchamos el InputBegan que produce NUESTRO touch virtual.
    -- Si Roblox/UI lo consume, cambiamos automáticamente de zona.
    local observer
    observer = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        local delta =
            Vector2.new(input.Position.X, input.Position.Y)
            - position

        if delta.Magnitude <= 10 then
            observed = true
            processed = gameProcessed == true

            if observer then
                observer:Disconnect()
                observer = nil
            end
        end
    end)

    local began = pcall(function()
        VirtualInputManager:SendTouchEvent(
            touchId,
            Enum.UserInputState.Begin.Value,
            position.X,
            position.Y
        )
    end)

    if not began then
        if observer then
            observer:Disconnect()
        end
        return false, nil
    end

    -- Tu tap físico que sí activó el cuchillo duró ~52 ms.
    -- Imitamos ese tiempo en vez de soltar al siguiente frame.
    task.wait(TOUCH_HOLD_TIME)

    pcall(function()
        VirtualInputManager:SendTouchEvent(
            touchId,
            Enum.UserInputState.End.Value,
            position.X,
            position.Y
        )
    end)

    -- Damos un instante mínimo para que llegue InputBegan/TouchTap.
    task.wait()

    if observer then
        observer:Disconnect()
        observer = nil
    end

    if observed and processed == false then
        confirmedTouchCandidate = candidate
    elseif observed and processed == true then
        -- La UI consumió esta zona. La próxima activación probará otra.
        if confirmedTouchCandidate == candidate then
            confirmedTouchCandidate = nil
        end
    end

    return true, processed
end

local function performKnifeSlash(knife)
    if not knife or not knife.Parent then
        return false
    end

    local enabled = true
    pcall(function()
        enabled = knife.Enabled
    end)

    if enabled == false then
        return false
    end

    releaseKnife(knife)

    -- Ruta principal:
    -- genera Begin/End Touch real, con duración y coordenada basadas
    -- en el toque físico que capturamos en el LAB.
    local touchSent, touchProcessed = sendRealMobileTap()

    if touchSent and touchProcessed ~= true then
        return true
    end

    -- Si esa coordenada fue consumida por UI o el ejecutor no expone VIM,
    -- reforzamos sin usar mouse/teclado. El siguiente retry volverá a probar
    -- otra coordenada móvil.
    local fired = false

    fired = fireSignalCompat(knife.Activated) or fired
    fired = fireSignalCallbacks(knife.Activated) or fired

    local okActivate = pcall(function()
        knife:Activate()
    end)
    fired = okActivate or fired

    if fired then
        task.defer(function()
            RunService.Heartbeat:Wait()
            releaseKnife(knife)
        end)
    end

    return fired
end

local WAIT_TEAM_WORDS = {
    "lobby",
    "spectat",
    "espectador",
    "menu",
    "dead",
    "wait",
    "waiting",
    "intermission",
}

local function teamLooksInactive(team)
    if not team then
        return false
    end

    local name = string.lower(tostring(team.Name or ""))
    for _, word in ipairs(WAIT_TEAM_WORDS) do
        if string.find(name, word, 1, true) then
            return true
        end
    end

    return false
end

local function isRoundActive()
    local character, root, humanoid = getLocalCharacter()

    if not character
        or not root
        or not humanoid
        or humanoid.Health <= 0
    then
        return false
    end

    -- En la espera de ronda este juego permite sacar el cuchillo,
    -- pero bloquea caminar. Esa señal evita cualquier TP prematuro.
    if humanoid.WalkSpeed <= 0 then
        return false
    end

    if root.Anchored
        or humanoid.PlatformStand
        or character:FindFirstChildOfClass("ForceField")
    then
        return false
    end

    if teamLooksInactive(LocalPlayer.Team) then
        return false
    end

    return true
end

local function getTeamId(playerObject)
    if not playerObject then
        return nil
    end

    local value = playerObject:GetAttribute("TeamId")
    if value == nil then
        value = playerObject:GetAttribute("teamId")
            or playerObject:GetAttribute("TeamID")
            or playerObject:GetAttribute("teamID")
    end

    return tonumber(value) or value
end

local function isSameTeam(otherPlayer)
    if not otherPlayer then
        return false
    end

    -- Este juego no usa Player.Team para la ronda.
    -- El probe confirmó que TeamId es la clasificación real:
    -- mismo TeamId = aliado, distinto TeamId = enemigo.
    local myTeamId = getTeamId(LocalPlayer)
    local theirTeamId = getTeamId(otherPlayer)

    if myTeamId ~= nil and theirTeamId ~= nil then
        return myTeamId == theirTeamId
    end

    -- Fallback por si TeamId todavía no replicó al entrar.
    local myTeam = LocalPlayer.Team
    local theirTeam = otherPlayer.Team

    if myTeam ~= nil and theirTeam ~= nil then
        return myTeam == theirTeam
    end

    return false
end

local function isEnemyAliveBasic(otherPlayer)
    if not otherPlayer
        or otherPlayer == LocalPlayer
        or not otherPlayer.Parent
    then
        return false
    end

    local myTeamId = getTeamId(LocalPlayer)
    local theirTeamId = getTeamId(otherPlayer)

    if myTeamId == nil
        or theirTeamId == nil
        or myTeamId == theirTeamId
    then
        return false
    end

    local character = otherPlayer.Character
    if not character or not character.Parent then
        return false
    end

    local humanoid =
        character:FindFirstChildOfClass("Humanoid")

    return humanoid ~= nil
        and humanoid.Health > 0
end

local function isValidAliveTarget(otherPlayer)
    if not otherPlayer
        or otherPlayer == LocalPlayer
        or not otherPlayer.Parent
    then
        return false
    end

    local myTeamId = getTeamId(LocalPlayer)
    local theirTeamId = getTeamId(otherPlayer)

    -- Mientras TeamId no haya replicado, no arriesgamos pegarle a un aliado.
    if myTeamId == nil or theirTeamId == nil then
        return false
    end

    if myTeamId == theirTeamId then
        return false
    end

    local character = otherPlayer.Character
    if not character or not character.Parent then
        return false
    end

    if character:FindFirstChildOfClass("ForceField") then
        return false
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")

    return humanoid ~= nil
        and root ~= nil
        and humanoid.Health > 0
        and humanoid.WalkSpeed > 0
        and not root.Anchored
        and not teamLooksInactive(otherPlayer.Team)
end

local function getRoundEnemies()
    local enemies = {}

    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if isValidAliveTarget(otherPlayer) then
            table.insert(enemies, otherPlayer)
        end
    end

    table.sort(enemies, function(a, b)
        return string.lower(a.Name) < string.lower(b.Name)
    end)

    return enemies
end


-- HEAD HITBOX ENEMIES -------------------------------------------------------

local hitboxSettings = {
    Enabled = false,
    Size = 3.25,
}

local originalHeadState = setmetatable({}, {__mode = "k"})
local hitboxConnection = nil
local hitboxAccumulator = 0
local HITBOX_UPDATE_INTERVAL = 0.04

local function saveHeadState(head)
    if not head or originalHeadState[head] then
        return
    end

    local state = {
        Size = head.Size,
        CanCollide = head.CanCollide,
        Massless = head.Massless,
    }

    pcall(function()
        state.CanQuery = head.CanQuery
    end)

    originalHeadState[head] = state
end

local function restoreHead(head)
    local original = head and originalHeadState[head]
    if not head or not original then
        return
    end

    if head.Parent then
        pcall(function()
            head.Size = original.Size
            head.CanCollide = original.CanCollide
            head.Massless = original.Massless

            if original.CanQuery ~= nil then
                head.CanQuery = original.CanQuery
            end
        end)
    end

    originalHeadState[head] = nil
end

local function restoreAllHitboxes()
    for head in pairs(originalHeadState) do
        restoreHead(head)
    end
end

local function applyHeadHitbox(playerObject)
    if not isEnemyAliveBasic(playerObject) then
        local character = playerObject and playerObject.Character
        local head = character and character:FindFirstChild("Head")

        if head then
            restoreHead(head)
        end

        return
    end

    local character = playerObject.Character
    local head = character and character:FindFirstChild("Head")

    if not head or not head:IsA("BasePart") then
        return
    end

    saveHeadState(head)

    local size = math.clamp(
        tonumber(hitboxSettings.Size) or 3.25,
        2.2,
        35.0
    )

    pcall(function()
        -- Solo ampliamos el volumen de la cabeza.
        -- No tocamos CFrame, Position, Anchored, velocidad ni humanoid.
        head.Size = Vector3.new(size, size, size)
        head.CanCollide = false
        head.Massless = true
        head.CanQuery = true
    end)
end

local function refreshHitboxes()
    if not hitboxSettings.Enabled then
        restoreAllHitboxes()
        return
    end

    local seenHeads = {}

    for _, playerObject in ipairs(Players:GetPlayers()) do
        if playerObject ~= LocalPlayer then
            local character = playerObject.Character
            local head = character and character:FindFirstChild("Head")

            if head then
                seenHeads[head] = true
            end

            applyHeadHitbox(playerObject)
        end
    end

    for head in pairs(originalHeadState) do
        if not seenHeads[head] or not head.Parent then
            restoreHead(head)
        end
    end
end

local function updateHitboxConnection()
    if hitboxSettings.Enabled then
        if not hitboxConnection then
            hitboxAccumulator = 0

            hitboxConnection =
                RunService.Heartbeat:Connect(function(dt)
                    hitboxAccumulator += dt

                    if hitboxAccumulator < HITBOX_UPDATE_INTERVAL then
                        return
                    end

                    hitboxAccumulator = 0
                    refreshHitboxes()
                end)
        end

        refreshHitboxes()
        return
    end

    if hitboxConnection then
        hitboxConnection:Disconnect()
        hitboxConnection = nil
    end

    restoreAllHitboxes()
end

-- ESP ENEMIES ---------------------------------------------------------------

local ESP_COLOR_DEFAULT = Color3.fromRGB(255, 80, 112)

local espSettings = {
    Enabled = false,
    Glow = true,
    Name = true,
    Distance = true,
    Box = false,
    HealthBar = false,
    Lines = false,
    Color = ESP_COLOR_DEFAULT,
}

local espEntries = {}
local drawingAvailable = type(Drawing) == "table" and type(Drawing.new) == "function"
local espRenderConnection = nil
local espAccumulator = 0
local ESP_RENDER_INTERVAL = 1 / 30

local function removeDrawing(object)
    if object then
        pcall(function()
            object.Visible = false
            object:Remove()
        end)
    end
end

local function hideESPEntry(entry)
    if not entry then
        return
    end

    if entry.Highlight then
        entry.Highlight.Enabled = false
    end

    if entry.Billboard then
        entry.Billboard.Enabled = false
    end

    for _, key in ipairs({"Box", "HealthBg", "Health", "Line"}) do
        local drawing = entry[key]
        if drawing then
            drawing.Visible = false
        end
    end
end

local function destroyESPEntry(playerObject)
    local entry = espEntries[playerObject]
    if not entry then
        return
    end

    if entry.Highlight then
        pcall(function()
            entry.Highlight:Destroy()
        end)
    end

    if entry.Billboard then
        pcall(function()
            entry.Billboard:Destroy()
        end)
    end

    removeDrawing(entry.Box)
    removeDrawing(entry.HealthBg)
    removeDrawing(entry.Health)
    removeDrawing(entry.Line)

    espEntries[playerObject] = nil
end

local function createESPEntry(playerObject)
    local entry = espEntries[playerObject]
    if entry then
        return entry
    end

    entry = {}
    espEntries[playerObject] = entry

    if drawingAvailable then
        local box = Drawing.new("Square")
        box.Filled = false
        box.Thickness = 1.4
        box.Transparency = 0.95
        box.Visible = false
        entry.Box = box

        local healthBg = Drawing.new("Line")
        healthBg.Thickness = 4
        healthBg.Transparency = 0.85
        healthBg.Color = Color3.fromRGB(20, 20, 24)
        healthBg.Visible = false
        entry.HealthBg = healthBg

        local health = Drawing.new("Line")
        health.Thickness = 2
        health.Transparency = 1
        health.Visible = false
        entry.Health = health

        local line = Drawing.new("Line")
        line.Thickness = 1.25
        line.Transparency = 0.9
        line.Visible = false
        entry.Line = line
    end

    return entry
end

local function ensureCharacterESP(entry, playerObject, character, head)
    if entry.Character ~= character then
        if entry.Highlight then
            pcall(function()
                entry.Highlight:Destroy()
            end)
            entry.Highlight = nil
        end

        if entry.Billboard then
            pcall(function()
                entry.Billboard:Destroy()
            end)
            entry.Billboard = nil
        end

        entry.Character = character
    end

    if not entry.Highlight or entry.Highlight.Parent ~= character then
        local highlight = Instance.new("Highlight")
        highlight.Name = "RyouEnemyESP"
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillTransparency = 0.82
        highlight.OutlineTransparency = 0.05
        highlight.Enabled = false
        highlight.Parent = character
        entry.Highlight = highlight
    end

    if head and (not entry.Billboard or entry.Billboard.Adornee ~= head) then
        if entry.Billboard then
            pcall(function()
                entry.Billboard:Destroy()
            end)
        end

        local billboard = Instance.new("BillboardGui")
        billboard.Name = "RyouEnemyLabel"
        billboard.AlwaysOnTop = true
        billboard.LightInfluence = 0
        billboard.Size = UDim2.fromOffset(180, 44)
        billboard.StudsOffsetWorldSpace = Vector3.new(0, 2.5, 0)
        billboard.Adornee = head
        billboard.Enabled = false
        billboard.Parent = character

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Name = "Name"
        nameLabel.BackgroundTransparency = 1
        nameLabel.Size = UDim2.new(1, 0, 0, 21)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 13
        nameLabel.TextStrokeTransparency = 0.35
        nameLabel.TextColor3 = espSettings.Color
        nameLabel.Text = playerObject.DisplayName
        nameLabel.Parent = billboard

        local infoLabel = Instance.new("TextLabel")
        infoLabel.Name = "Info"
        infoLabel.BackgroundTransparency = 1
        infoLabel.Position = UDim2.fromOffset(0, 20)
        infoLabel.Size = UDim2.new(1, 0, 0, 18)
        infoLabel.Font = Enum.Font.GothamMedium
        infoLabel.TextSize = 11
        infoLabel.TextStrokeTransparency = 0.4
        infoLabel.TextColor3 = Color3.fromRGB(235, 235, 240)
        infoLabel.Text = ""
        infoLabel.Parent = billboard

        entry.Billboard = billboard
        entry.NameLabel = nameLabel
        entry.InfoLabel = infoLabel
    end
end

local function getCharacterScreenBox(camera, character)
    local ok, cf, size = pcall(function()
        local cframe, extents = character:GetBoundingBox()
        return cframe, extents
    end)

    if not ok or not cf or not size then
        return nil
    end

    local half = size * 0.5
    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    local visibleCorners = 0

    for x = -1, 1, 2 do
        for y = -1, 1, 2 do
            for z = -1, 1, 2 do
                local world =
                    cf:PointToWorldSpace(
                        Vector3.new(
                            half.X * x,
                            half.Y * y,
                            half.Z * z
                        )
                    )

                local screen, onScreen =
                    camera:WorldToViewportPoint(world)

                if screen.Z > 0.05 then
                    minX = math.min(minX, screen.X)
                    minY = math.min(minY, screen.Y)
                    maxX = math.max(maxX, screen.X)
                    maxY = math.max(maxY, screen.Y)

                    if onScreen then
                        visibleCorners += 1
                    end
                end
            end
        end
    end

    if minX == math.huge or visibleCorners == 0 then
        return nil
    end

    local width = math.max(4, maxX - minX)
    local height = math.max(8, maxY - minY)

    return minX, minY, width, height
end

local function refreshESP()
    local camera = workspace.CurrentCamera
    if not camera then
        return
    end

    local localCharacter = LocalPlayer.Character
    local localRoot =
        localCharacter
        and localCharacter:FindFirstChild("HumanoidRootPart")

    local seen = {}

    for _, playerObject in ipairs(Players:GetPlayers()) do
        if playerObject ~= LocalPlayer then
            seen[playerObject] = true

            local entry = createESPEntry(playerObject)
            local enemy = espSettings.Enabled and isEnemyAliveBasic(playerObject)
            local character = playerObject.Character
            local humanoid =
                character
                and character:FindFirstChildOfClass("Humanoid")
            local root =
                character
                and character:FindFirstChild("HumanoidRootPart")
            local head =
                character
                and character:FindFirstChild("Head")

            if enemy and character and humanoid and root then
                ensureCharacterESP(
                    entry,
                    playerObject,
                    character,
                    head
                )

                local color = espSettings.Color

                if entry.Highlight then
                    entry.Highlight.FillColor = color
                    entry.Highlight.OutlineColor = color
                    entry.Highlight.Enabled = espSettings.Glow
                end

                local distance = 0
                if localRoot then
                    distance =
                        (root.Position - localRoot.Position).Magnitude
                end

                if entry.Billboard then
                    entry.Billboard.Enabled =
                        espSettings.Name
                        or espSettings.Distance
                        or espSettings.HealthBar

                    if entry.NameLabel then
                        entry.NameLabel.Visible = espSettings.Name
                        entry.NameLabel.TextColor3 = color
                        entry.NameLabel.Text =
                            playerObject.DisplayName
                    end

                    if entry.InfoLabel then
                        local pieces = {}

                        if espSettings.Distance then
                            pieces[#pieces + 1] =
                                string.format("%.0f studs", distance)
                        end

                        if espSettings.HealthBar then
                            pieces[#pieces + 1] =
                                string.format(
                                    "%.0f HP",
                                    humanoid.Health
                                )
                        end

                        entry.InfoLabel.Text =
                            table.concat(pieces, "  ·  ")
                        entry.InfoLabel.Visible = #pieces > 0
                    end
                end

                if drawingAvailable then
                    local rootScreen, rootOnScreen =
                        camera:WorldToViewportPoint(
                            root.Position
                        )

                    local boxX, boxY, boxW, boxH =
                        getCharacterScreenBox(
                            camera,
                            character
                        )

                    local hasBox =
                        boxX ~= nil
                        and rootOnScreen
                        and rootScreen.Z > 0

                    if entry.Box then
                        if espSettings.Box and hasBox then
                            entry.Box.Position =
                                Vector2.new(boxX, boxY)
                            entry.Box.Size =
                                Vector2.new(boxW, boxH)
                            entry.Box.Color = color
                            entry.Box.Visible = true
                        else
                            entry.Box.Visible = false
                        end
                    end

                    if entry.HealthBg and entry.Health then
                        if espSettings.HealthBar and hasBox then
                            local maxHealth =
                                math.max(
                                    1,
                                    humanoid.MaxHealth
                                )

                            local alpha =
                                math.clamp(
                                    humanoid.Health / maxHealth,
                                    0,
                                    1
                                )

                            local x = boxX - 6
                            local bottom = boxY + boxH
                            local top = boxY
                            local healthTop =
                                bottom
                                - boxH * alpha

                            entry.HealthBg.From =
                                Vector2.new(x, bottom)
                            entry.HealthBg.To =
                                Vector2.new(x, top)
                            entry.HealthBg.Visible = true

                            entry.Health.From =
                                Vector2.new(x, bottom)
                            entry.Health.To =
                                Vector2.new(x, healthTop)
                            entry.Health.Color =
                                Color3.fromRGB(
                                    math.floor(255 * (1 - alpha)),
                                    math.floor(255 * alpha),
                                    80
                                )
                            entry.Health.Visible = true
                        else
                            entry.HealthBg.Visible = false
                            entry.Health.Visible = false
                        end
                    end

                    if entry.Line then
                        if espSettings.Lines
                            and rootOnScreen
                            and rootScreen.Z > 0
                        then
                            local viewport =
                                camera.ViewportSize

                            entry.Line.From =
                                Vector2.new(
                                    viewport.X * 0.5,
                                    viewport.Y - 2
                                )

                            entry.Line.To =
                                Vector2.new(
                                    rootScreen.X,
                                    rootScreen.Y
                                )

                            entry.Line.Color = color
                            entry.Line.Visible = true
                        else
                            entry.Line.Visible = false
                        end
                    end
                end
            else
                hideESPEntry(entry)
            end
        end
    end

    for playerObject in pairs(espEntries) do
        if not seen[playerObject]
            or not playerObject.Parent
        then
            destroyESPEntry(playerObject)
        end
    end
end

local function updateESPConnection()
    if espSettings.Enabled then
        if not espRenderConnection then
            espAccumulator = 0
            espRenderConnection =
                RunService.RenderStepped:Connect(
                    function(dt)
                        espAccumulator += dt

                        if espAccumulator
                            < ESP_RENDER_INTERVAL
                        then
                            return
                        end

                        espAccumulator = 0
                        refreshESP()
                    end
                )
        end

        refreshESP()
        return
    end

    if espRenderConnection then
        espRenderConnection:Disconnect()
        espRenderConnection = nil
    end

    for _, entry in pairs(espEntries) do
        hideESPEntry(entry)
    end
end


-- AUTO SHOOT ONLY -----------------------------------------------------------
-- Stable direct ShootStart implementation from the version that fired correctly.
local aimSettings = { AutoShoot = false }

local TARGET_BODY_ORDER = {
    "Cabeza",
    "Torso superior",
    "Torso inferior",
    "Brazo izquierdo",
    "Brazo derecho",
    "Pierna izquierda",
    "Pierna derecha",
}

local TARGET_BODY_GROUPS = {
    ["Cabeza"] = {"Head"},
    ["Torso superior"] = {"UpperTorso", "Torso"},
    ["Torso inferior"] = {"LowerTorso", "Torso", "HumanoidRootPart"},
    ["Brazo izquierdo"] = {
        "LeftUpperArm", "LeftLowerArm", "LeftHand", "LeftArm",
    },
    ["Brazo derecho"] = {
        "RightUpperArm", "RightLowerArm", "RightHand", "RightArm",
    },
    ["Pierna izquierda"] = {
        "LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "LeftLeg",
    },
    ["Pierna derecha"] = {
        "RightUpperLeg", "RightLowerLeg", "RightFoot", "RightLeg",
    },
}

local targetSelections = {
    AutoShoot = { ["Cabeza"] = true },
}

local targetPartNameCache = { AutoShoot = {"Head"} }

local targetPartCache = {
    AutoShoot = setmetatable({}, {__mode = "k"}),
}

local targetSelectionVersion = { AutoShoot = 1 }

local bodySelector = nil
local bodySelectorGui = nil

local function rebuildTargetPartNames(mode)
    local selected = targetSelections[mode] or {}
    local names = {}
    local seen = {}

    for _, groupName in ipairs(TARGET_BODY_ORDER) do
        if selected[groupName] then
            local group = TARGET_BODY_GROUPS[groupName]

            for _, partName in ipairs(group) do
                if not seen[partName] then
                    seen[partName] = true
                    names[#names + 1] = partName
                end
            end
        end
    end

    if #names == 0 then
        names[1] = "Head"
    end

    targetPartNameCache[mode] = names
    return names
end

local function getTargetSelectionArray(mode)
    local result = {}
    local selected = targetSelections[mode] or {}

    for _, groupName in ipairs(TARGET_BODY_ORDER) do
        if selected[groupName] then
            result[#result + 1] = groupName
        end
    end

    return result
end

local function refreshBodySelector()
    if not bodySelector then
        return
    end

    rebuildTargetPartNames(bodySelector.Mode)

    local selected =
        targetSelections[bodySelector.Mode]
        or {}

    for _, name in ipairs(TARGET_BODY_ORDER) do
        local active = selected[name] == true

        local segment =
            bodySelector.Segments[name]

        if segment then
            segment.Button.BackgroundColor3 =
                active
                and Color3.fromHex("#E6E9EC")
                or Color3.fromHex("#24262A")

            segment.Stroke.Color =
                active
                and Color3.fromHex("#FFFFFF")
                or Color3.fromHex("#4B5057")

            segment.Stroke.Transparency =
                active and 0.05 or 0.35
        end

        local row =
            bodySelector.Rows[name]

        if row then
            row.Text =
                (active and "✓  " or "○  ")
                .. name

            row.BackgroundColor3 =
                active
                and Color3.fromHex("#34373C")
                or Color3.fromHex("#1C1E21")

            row.TextColor3 =
                active
                and Color3.fromHex("#FFFFFF")
                or Color3.fromHex("#B9BEC5")
        end
    end
end

local function setTargetSelection(mode, value)
    local selected = targetSelections[mode]
    if not selected then
        return
    end

    table.clear(selected)

    local function enable(name)
        if TARGET_BODY_GROUPS[name] then
            selected[name] = true
        end
    end

    if type(value) == "table" then
        for _, name in ipairs(value) do
            enable(name)
        end
    elseif value == "Cabeza" then
        enable("Cabeza")
    elseif value == "Torso" then
        enable("Torso superior")
        enable("Torso inferior")
    elseif value == "Cuerpo Completo" then
        for _, name in ipairs(TARGET_BODY_ORDER) do
            enable(name)
        end
    elseif type(value) == "string" then
        enable(value)
    end

    if not next(selected) then
        selected["Cabeza"] = true
    end

    rebuildTargetPartNames(mode)

    targetSelectionVersion[mode] =
        (targetSelectionVersion[mode] or 0) + 1

    local cache =
        targetPartCache[mode]

    if cache then
        table.clear(cache)
    end

    refreshBodySelector()
end

local function collectTargetParts(character, mode)
    if not character then
        return nil
    end

    local modeCache =
        targetPartCache[mode]

    local version =
        targetSelectionVersion[mode] or 1

    local cached =
        modeCache
        and modeCache[character]

    if cached
        and cached.Version == version
    then
        return cached.Parts
    end

    local parts = {}
    local seen = {}

    local names =
        targetPartNameCache[mode]
        or rebuildTargetPartNames(mode)

    for _, partName in ipairs(names) do
        local part =
            character:FindFirstChild(partName)

        if part
            and part:IsA("BasePart")
            and not seen[part]
        then
            seen[part] = true
            parts[#parts + 1] = part
        end
    end

    if #parts == 0 then
        local fallback =
            character:FindFirstChild("Head")
            or character:FindFirstChild(
                "HumanoidRootPart"
            )

        if fallback then
            parts[1] = fallback
        end
    end

    if modeCache
        and #parts > 0
    then
        modeCache[character] = {
            Version = version,
            Parts = parts,
        }
    end

    return parts
end

-- --------------------------------------------------------------------------
-- Selector corporal visual, replicando el mecanismo/UI del Duels:
-- mini ventana, figura clickeable, lista, Todo/Limpiar/Aplicar.
-- --------------------------------------------------------------------------

local function applyBodySelectorResponsiveLayout()
    local selector = bodySelector
    if not selector then
        return 1
    end

    local bounds =
        selector.Overlay.AbsoluteSize

    if bounds.X < 1
        or bounds.Y < 1
    then
        local camera =
            workspace.CurrentCamera

        bounds =
            camera
            and camera.ViewportSize
            or Vector2.new(800, 600)
    end

    local margin =
        math.clamp(
            math.floor(
                math.min(bounds.X, bounds.Y)
                * 0.025
            ),
            6,
            14
        )

    local rawAvailableW =
        math.max(
            1,
            bounds.X - margin * 2
        )

    local rawAvailableH =
        math.max(
            1,
            bounds.Y - margin * 2
        )

    local availableW =
        math.max(240, rawAvailableW)

    local availableH =
        math.max(260, rawAvailableH)

    local portrait =
        availableW < 470
        or (
            availableW
            / math.max(1, availableH)
        ) < 1.05

    if not portrait then
        selector.Card.Size =
            UDim2.fromOffset(440, 360)

        selector.Title.Position =
            UDim2.fromOffset(18, 14)

        selector.Title.Size =
            UDim2.new(1, -88, 0, 24)

        selector.Title.TextSize = 15

        selector.Subtitle.Position =
            UDim2.fromOffset(18, 39)

        selector.Subtitle.Size =
            UDim2.new(1, -36, 0, 28)

        selector.Subtitle.TextSize = 10

        selector.CloseButton.Position =
            UDim2.new(1, -42, 0, 12)

        selector.Figure.Position =
            UDim2.fromOffset(18, 74)

        selector.Figure.Size =
            UDim2.fromOffset(160, 220)

        selector.List.Position =
            UDim2.fromOffset(190, 74)

        selector.List.Size =
            UDim2.fromOffset(232, 220)

        selector.List.CanvasSize =
            UDim2.fromOffset(0, 210)

        for index, name in ipairs(
            TARGET_BODY_ORDER
        ) do
            local row =
                selector.Rows[name]

            if row then
                row.Size =
                    UDim2.new(1, 0, 0, 27)

                row.Position =
                    UDim2.fromOffset(
                        0,
                        (index - 1) * 30
                    )

                row.TextSize = 10
            end
        end

        selector.SelectAllButton.Size =
            UDim2.fromOffset(74, 32)

        selector.SelectAllButton.Position =
            UDim2.new(0, 18, 1, -42)

        selector.ClearButton.Size =
            UDim2.fromOffset(78, 32)

        selector.ClearButton.Position =
            UDim2.new(0, 98, 1, -42)

        selector.DoneButton.Size =
            UDim2.fromOffset(92, 32)

        selector.DoneButton.Position =
            UDim2.new(0, 330, 1, -42)

        local targetScale =
            math.min(
                1,
                availableW / 440,
                availableH / 360
            )

        selector.Scale.Scale =
            targetScale

        return targetScale
    end

    local cardW =
        math.min(420, availableW)

    local cardH =
        math.min(620, availableH)

    cardH =
        math.max(360, cardH)

    selector.Card.Size =
        UDim2.fromOffset(
            cardW,
            cardH
        )

    local portraitScale =
        math.min(
            1,
            rawAvailableW / cardW,
            rawAvailableH / cardH
        )

    portraitScale =
        math.max(
            0.55,
            portraitScale
        )

    selector.Scale.Scale =
        portraitScale

    selector.Title.Position =
        UDim2.fromOffset(14, 12)

    selector.Title.Size =
        UDim2.new(1, -58, 0, 22)

    selector.Title.TextSize =
        cardW < 330 and 12 or 14

    selector.Title.TextTruncate =
        Enum.TextTruncate.AtEnd

    selector.Subtitle.Position =
        UDim2.fromOffset(14, 35)

    selector.Subtitle.Size =
        UDim2.new(1, -28, 0, 32)

    selector.Subtitle.TextSize =
        cardW < 330 and 9 or 10

    selector.CloseButton.Position =
        UDim2.new(1, -40, 0, 10)

    local figureY = 72

    selector.Figure.Size =
        UDim2.fromOffset(160, 220)

    selector.Figure.Position =
        UDim2.fromOffset(
            math.floor(
                (cardW - 160) / 2
            ),
            figureY
        )

    local listY =
        figureY + 228

    local actionsY =
        cardH - 42

    local listH =
        math.max(
            58,
            actionsY - listY - 8
        )

    selector.List.Position =
        UDim2.fromOffset(
            14,
            listY
        )

    selector.List.Size =
        UDim2.new(
            1,
            -28,
            0,
            listH
        )

    local rowHeight =
        cardH < 520 and 25 or 27

    local rowStep =
        rowHeight + 3

    selector.List.CanvasSize =
        UDim2.fromOffset(
            0,
            #TARGET_BODY_ORDER
                * rowStep
        )

    for index, name in ipairs(
        TARGET_BODY_ORDER
    ) do
        local row =
            selector.Rows[name]

        if row then
            row.Size =
                UDim2.new(
                    1,
                    -3,
                    0,
                    rowHeight
                )

            row.Position =
                UDim2.fromOffset(
                    0,
                    (index - 1)
                        * rowStep
                )

            row.TextSize = 10
        end
    end

    local gap = 7

    local buttonW =
        math.floor(
            (
                cardW
                - 28
                - gap * 2
            ) / 3
        )

    selector.SelectAllButton.Size =
        UDim2.fromOffset(
            buttonW,
            32
        )

    selector.SelectAllButton.Position =
        UDim2.fromOffset(
            14,
            actionsY
        )

    selector.ClearButton.Size =
        UDim2.fromOffset(
            buttonW,
            32
        )

    selector.ClearButton.Position =
        UDim2.fromOffset(
            14 + buttonW + gap,
            actionsY
        )

    selector.DoneButton.Size =
        UDim2.fromOffset(
            buttonW,
            32
        )

    selector.DoneButton.Position =
        UDim2.fromOffset(
            14
                + (buttonW + gap) * 2,
            actionsY
        )

    return portraitScale
end

local function ensureBodySelector()
    if bodySelectorGui
        and bodySelectorGui.Parent
    then
        return
    end

    -- Modal del selector corporal alojado dentro de Neo Sidebar,
    -- sin ScreenGui/CoreGui externo al RyouHub.
    local activeWindow = WindUI and WindUI.Window
    local parent = activeWindow and activeWindow.panel
    if not parent or not parent.Parent then
        warn("[Ryou] No se encontró la ventana V6 para el selector corporal.")
        return
    end
    local gui = Instance.new("Frame")
    gui.Name = "Ryou_BodySelector"
    gui.Size = UDim2.fromScale(1, 1)
    gui.BackgroundTransparency = 1
    gui.BorderSizePixel = 0
    gui.ZIndex = 399
    gui.Parent = parent
    bodySelectorGui = gui

    local overlay =
        Instance.new("Frame")

    overlay.Name = "Overlay"
    overlay.Size =
        UDim2.fromScale(1, 1)

    overlay.BackgroundColor3 =
        Color3.fromHex("#000000")

    overlay.BackgroundTransparency =
        0.36

    overlay.Visible = false
    overlay.Active = true
    overlay.ZIndex = 400
    overlay.Parent = gui

    local card =
        Instance.new("CanvasGroup")

    card.AnchorPoint =
        Vector2.new(0.5, 0.5)

    card.Position =
        UDim2.fromScale(0.5, 0.5)

    card.Size =
        UDim2.fromOffset(440, 360)

    card.BackgroundColor3 =
        Color3.fromHex("#111214")

    card.BorderSizePixel = 0
    card.ZIndex = 401
    card.Parent = overlay

    Instance.new(
        "UICorner",
        card
    ).CornerRadius =
        UDim.new(0, 22)

    local stroke =
        Instance.new("UIStroke")

    stroke.Color =
        Color3.fromHex("#5E636A")

    stroke.Transparency = 0.35
    stroke.Thickness = 1
    stroke.Parent = card

    local scale =
        Instance.new("UIScale")

    scale.Scale = 1
    scale.Parent = card

    local title =
        Instance.new("TextLabel")

    title.Size =
        UDim2.new(1, -88, 0, 24)

    title.Position =
        UDim2.fromOffset(18, 14)

    title.BackgroundTransparency = 1
    title.Text = "Selector corporal"
    title.TextColor3 =
        Color3.fromHex("#F7F8F9")

    title.Font =
        Enum.Font.GothamBold

    title.TextSize = 15
    title.TextXAlignment =
        Enum.TextXAlignment.Left

    title.ZIndex = 402
    title.Parent = card

    local closeSelector =
        Instance.new("TextButton")

    closeSelector.Name = "Close"
    closeSelector.Size =
        UDim2.fromOffset(28, 28)

    closeSelector.Position =
        UDim2.new(1, -42, 0, 12)

    closeSelector.BackgroundColor3 =
        Color3.fromHex("#25272B")

    closeSelector.BorderSizePixel = 0
    closeSelector.Text = "×"
    closeSelector.TextColor3 =
        Color3.fromHex("#E7E7E7")

    closeSelector.Font =
        Enum.Font.GothamBold

    closeSelector.TextSize = 16
    closeSelector.AutoButtonColor = false
    closeSelector.ZIndex = 405
    closeSelector.Parent = card

    Instance.new(
        "UICorner",
        closeSelector
    ).CornerRadius =
        UDim.new(0, 9)

    closeSelector.Activated:
        Connect(function()
            overlay.Visible = false
        end)

    local subtitle =
        Instance.new("TextLabel")

    subtitle.Size =
        UDim2.new(1, -36, 0, 28)

    subtitle.Position =
        UDim2.fromOffset(18, 39)

    subtitle.BackgroundTransparency = 1

    subtitle.Text =
        "Toca varias zonas del cuerpo. Las partes activas se iluminan al instante."

    subtitle.TextColor3 =
        Color3.fromHex("#9DA3AB")

    subtitle.Font =
        Enum.Font.Gotham

    subtitle.TextSize = 10
    subtitle.TextWrapped = true

    subtitle.TextXAlignment =
        Enum.TextXAlignment.Left

    subtitle.TextYAlignment =
        Enum.TextYAlignment.Top

    subtitle.ZIndex = 402
    subtitle.Parent = card

    local figure =
        Instance.new("Frame")

    figure.Size =
        UDim2.fromOffset(160, 220)

    figure.Position =
        UDim2.fromOffset(18, 74)

    figure.BackgroundColor3 =
        Color3.fromHex("#090A0C")

    figure.BackgroundTransparency =
        0.08

    figure.BorderSizePixel = 0
    figure.ZIndex = 402
    figure.Parent = card

    Instance.new(
        "UICorner",
        figure
    ).CornerRadius =
        UDim.new(0, 14)

    bodySelector = {
        Mode = "AutoShoot",
        Segments = {},
        Rows = {},
        Overlay = overlay,
        Card = card,
        Scale = scale,
        Title = title,
        Subtitle = subtitle,
        CloseButton = closeSelector,
        Figure = figure,
        List = nil,
    }

    local function toggle(name)
        local selected =
            targetSelections[
                bodySelector.Mode
            ]

        selected[name] =
            not selected[name]
            or nil

        refreshBodySelector()
    end

    local function segment(
        name,
        x,
        y,
        width,
        height,
        radius
    )
        local button =
            Instance.new("TextButton")

        button.Name = name

        button.Size =
            UDim2.fromOffset(
                width,
                height
            )

        button.Position =
            UDim2.fromOffset(x, y)

        button.BackgroundColor3 =
            Color3.fromHex("#24262A")

        button.BorderSizePixel = 0
        button.Text = ""
        button.AutoButtonColor = false
        button.ZIndex = 404
        button.Parent = figure

        Instance.new(
            "UICorner",
            button
        ).CornerRadius =
            UDim.new(
                0,
                radius or 10
            )

        local segmentStroke =
            Instance.new("UIStroke")

        segmentStroke.Color =
            Color3.fromHex("#4B5057")

        segmentStroke.Transparency =
            0.35

        segmentStroke.Thickness = 1
        segmentStroke.Parent = button

        bodySelector.Segments[name] = {
            Button = button,
            Stroke = segmentStroke,
        }

        button.Activated:
            Connect(function()
                toggle(name)
            end)
    end

    segment(
        "Cabeza",
        59, 8, 42, 42, 21
    )

    segment(
        "Torso superior",
        46, 55, 68, 45, 11
    )

    segment(
        "Torso inferior",
        50, 104, 60, 32, 9
    )

    segment(
        "Brazo izquierdo",
        20, 58, 20, 78, 10
    )

    segment(
        "Brazo derecho",
        120, 58, 20, 78, 10
    )

    segment(
        "Pierna izquierda",
        49, 143, 25, 66, 11
    )

    segment(
        "Pierna derecha",
        86, 143, 25, 66, 11
    )

    local list =
        Instance.new("ScrollingFrame")

    list.Name = "BodyPartList"

    list.Size =
        UDim2.fromOffset(232, 220)

    list.Position =
        UDim2.fromOffset(190, 74)

    list.BackgroundTransparency = 1
    list.BorderSizePixel = 0
    list.ScrollBarThickness = 2

    list.ScrollBarImageColor3 =
        Color3.fromHex("#6E737A")

    list.CanvasSize =
        UDim2.fromOffset(0, 210)

    list.ScrollingDirection =
        Enum.ScrollingDirection.Y

    list.ElasticBehavior =
        Enum.ElasticBehavior.Never

    list.ZIndex = 402
    list.Parent = card
    bodySelector.List = list

    for index, name in ipairs(
        TARGET_BODY_ORDER
    ) do
        local row =
            Instance.new("TextButton")

        row.Size =
            UDim2.new(1, 0, 0, 27)

        row.Position =
            UDim2.fromOffset(
                0,
                (index - 1) * 30
            )

        row.BackgroundColor3 =
            Color3.fromHex("#1C1E21")

        row.BorderSizePixel = 0

        row.TextColor3 =
            Color3.fromHex("#E7E7E7")

        row.Font =
            Enum.Font.GothamMedium

        row.TextSize = 10

        row.TextXAlignment =
            Enum.TextXAlignment.Left

        row.AutoButtonColor = false
        row.ZIndex = 403
        row.Parent = list

        Instance.new(
            "UICorner",
            row
        ).CornerRadius =
            UDim.new(0, 10)

        local padding =
            Instance.new("UIPadding")

        padding.PaddingLeft =
            UDim.new(0, 12)

        padding.Parent = row

        bodySelector.Rows[name] =
            row

        row.Activated:
            Connect(function()
                toggle(name)
            end)
    end

    local function action(
        text,
        x,
        width,
        callback
    )
        local button =
            Instance.new("TextButton")

        button.Size =
            UDim2.fromOffset(
                width,
                32
            )

        button.Position =
            UDim2.new(
                0,
                x,
                1,
                -42
            )

        button.BackgroundColor3 =
            Color3.fromHex("#25272B")

        button.BorderSizePixel = 0
        button.Text = text

        button.TextColor3 =
            Color3.fromHex("#F2F3F5")

        button.Font =
            Enum.Font.GothamBold

        button.TextSize = 10
        button.AutoButtonColor = false
        button.ZIndex = 403
        button.Parent = card

        Instance.new(
            "UICorner",
            button
        ).CornerRadius =
            UDim.new(0, 11)

        button.Activated:
            Connect(callback)

        return button
    end

    bodySelector.SelectAllButton =
        action(
            "Todo",
            18,
            74,
            function()
                local selected =
                    targetSelections[
                        bodySelector.Mode
                    ]

                for _, name in ipairs(
                    TARGET_BODY_ORDER
                ) do
                    selected[name] = true
                end

                refreshBodySelector()
            end
        )

    bodySelector.ClearButton =
        action(
            "Limpiar",
            98,
            78,
            function()
                table.clear(
                    targetSelections[
                        bodySelector.Mode
                    ]
                )

                refreshBodySelector()
            end
        )

    bodySelector.DoneButton =
        action(
            "Aplicar",
            330,
            92,
            function()
                local mode =
                    bodySelector.Mode

                local selected =
                    targetSelections[mode]

                if not next(selected) then
                    selected["Cabeza"] =
                        true
                end

                setTargetSelection(
                    mode,
                    getTargetSelectionArray(mode)
                )

                overlay.Visible = false

                notify(
                    "Auto Shoot: selección corporal aplicada.",
                    2
                )
            end
        )

    bodySelector.DoneButton.BackgroundColor3 =
        Color3.fromHex("#E6E9EC")

    bodySelector.DoneButton.TextColor3 =
        Color3.fromHex("#111214")

    overlay:GetPropertyChangedSignal(
        "AbsoluteSize"
    ):Connect(function()
        if overlay.Visible
            and bodySelector
        then
            applyBodySelectorResponsiveLayout()
        end
    end)
end

local function openBodySelector(mode)
    ensureBodySelector()
    if not bodySelector or not bodySelector.Overlay.Parent then return end

    bodySelector.Mode = mode

    bodySelector.Title.Text =
        "Selector corporal · Auto Shoot"

    refreshBodySelector()

    bodySelector.Overlay.Visible =
        true

    local targetScale =
        applyBodySelectorResponsiveLayout()

    bodySelector.Scale.Scale =
        targetScale * 0.965

    bodySelector.Card.GroupTransparency =
        0.12

    TweenService:Create(
        bodySelector.Scale,
        TweenInfo.new(
            0.16,
            Enum.EasingStyle.Quint,
            Enum.EasingDirection.Out
        ),
        {
            Scale = targetScale,
        }
    ):Play()

    TweenService:Create(
        bodySelector.Card,
        TweenInfo.new(
            0.14,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        ),
        {
            GroupTransparency = 0,
        }
    ):Play()
end

local function syncPartControls(mode)
    if bodySelector
        and bodySelector.Mode == mode
    then
        refreshBodySelector()
    end
end

-- --------------------------------------------------------------------------
local function getEquippedGun()
    local character = LocalPlayer.Character
    if not character then
        return nil
    end

    for _, child in ipairs(character:GetChildren()) do
        if child:IsA("Tool") then
            local gunServer = child:FindFirstChild("GunServer", true)
            local shootStart =
                gunServer
                and gunServer:FindFirstChild("ShootStart")

            if shootStart
                and shootStart:IsA("RemoteEvent")
            then
                return child, shootStart
            end
        end
    end

    return nil
end

local gunRaycastParams = RaycastParams.new()
gunRaycastParams.FilterType = Enum.RaycastFilterType.Exclude
gunRaycastParams.IgnoreWater = true

local function nativeGunShootAt(targetPosition)
    if typeof(targetPosition) ~= "Vector3" then
        return false
    end

    local character = LocalPlayer.Character
    if not character then
        return false
    end

    -- GunClient original aborta cuando este atributo está activo.
    if character:GetAttribute("noWeapons") == true then
        return false
    end

    local gun, shootStart = getEquippedGun()
    if not gun or not shootStart then
        return false
    end

    local originPart =
        character:FindFirstChild("Head")
        or character:FindFirstChild("HumanoidRootPart")

    if not originPart then
        return false
    end

    local delta = targetPosition - originPart.Position
    if delta.Magnitude <= 0.01 then
        return false
    end

    gunRaycastParams.FilterDescendantsInstances = {
        character,
    }

    -- Misma lógica observada en GunClient:
    -- raycast desde Head/HRP hasta 2500 studs.
    local direction = delta.Unit * 2500

    local result = workspace:Raycast(
        originPart.Position,
        direction,
        gunRaycastParams
    )

    local hitPosition =
        result
        and result.Position
        or originPart.Position + direction

    local hitInstance =
        result
        and result.Instance
        or nil

    local ok = pcall(function()
        shootStart:FireServer(
            hitPosition,
            hitInstance
        )
    end)

    return ok
end


-- Auto Shoot: restored original working GunServer.ShootStart route.
-- No hookfunction, no __namecall, no TouchEnded callback patches.
local aimState = {
    Target = nil,
    Gun = nil,
    LastShotAt = -math.huge,
    Connection = nil,
}

-- GunClient original includes 0.5s shoot animation + 2.5s reload wait.
-- Maintain the previously working firing interval, with immediate first shot.
local GUN_SHOT_INTERVAL = 3.05
local MAX_AIM_DISTANCE_SQ = 800 * 800
local autoRaycastParams = RaycastParams.new()
autoRaycastParams.FilterType = Enum.RaycastFilterType.Exclude
autoRaycastParams.IgnoreWater = true

local function selectAutoShootTarget()
    local character = LocalPlayer.Character
    local originPart = character and (
        character:FindFirstChild("Head")
        or character:FindFirstChild("HumanoidRootPart")
    )
    if not originPart then return nil end

    autoRaycastParams.FilterDescendantsInstances = {character}
    local origin = originPart.Position
    local bestPart, bestDistanceSq = nil, math.huge

    for _, playerObject in ipairs(Players:GetPlayers()) do
        if isEnemyAliveBasic(playerObject) then
            local enemyCharacter = playerObject.Character
            local parts = collectTargetParts(enemyCharacter, "AutoShoot")
            if parts then
                for _, part in ipairs(parts) do
                    if part and part.Parent then
                        local delta = part.Position - origin
                        local distSq = delta:Dot(delta)
                        if distSq > 0.01
                            and distSq < bestDistanceSq
                            and distSq <= MAX_AIM_DISTANCE_SQ
                        then
                            local hit = workspace:Raycast(origin, delta, autoRaycastParams)
                            if not hit or hit.Instance:IsDescendantOf(enemyCharacter) then
                                bestDistanceSq = distSq
                                bestPart = part
                            end
                        end
                    end
                end
            end
        end
    end
    return bestPart
end

local function updateAimTargets()
    if not aimSettings.AutoShoot or not isRoundActive() then
        aimState.Target = nil
        return nil
    end
    local gun = getEquippedGun()
    if not gun then
        aimState.Target = nil
        aimState.Gun = nil
        return nil
    end
    aimState.Gun = gun
    aimState.Target = selectAutoShootTarget()
    return aimState.Target
end

local function stepAutoShoot()
    if not aimSettings.AutoShoot then return end
    if os.clock() - aimState.LastShotAt < GUN_SHOT_INTERVAL then return end

    local target = updateAimTargets()
    if target and target.Parent then
        if nativeGunShootAt(target.Position) then
            aimState.LastShotAt = os.clock()
        end
    end
end

local function updateAimConnection()
    if aimSettings.AutoShoot then
        if not aimState.Connection then
            aimState.Connection = RunService.RenderStepped:Connect(stepAutoShoot)
        end
        stepAutoShoot()
    else
        if aimState.Connection then
            aimState.Connection:Disconnect()
            aimState.Connection = nil
        end
        aimState.Target = nil
        aimState.Gun = nil
    end
end

local function restoreLocalMovement(
    character,
    root,
    humanoid,
    originalCFrame,
    originalLinearVelocity,
    originalAngularVelocity,
    originalAutoRotate,
    originalPlatformStand,
    originalState,
    originalMoveDirection
)
    if humanoid and humanoid.Parent then
        humanoid.AutoRotate = originalAutoRotate
        humanoid.PlatformStand = originalPlatformStand
    end

    if character and character.Parent and root and root.Parent then
        -- No llamamos freezeRoot aquí. Esa era una causa del micro-trabón.
        character:PivotTo(originalCFrame)

        root.AssemblyLinearVelocity = originalLinearVelocity
        root.AssemblyAngularVelocity = originalAngularVelocity
    end

    if humanoid and humanoid.Parent then
        pcall(function()
            if originalState
                and originalState ~= Enum.HumanoidStateType.Dead
            then
                humanoid:ChangeState(originalState)
            end
        end)

        pcall(function()
            if originalMoveDirection then
                humanoid:Move(originalMoveDirection, false)
            end
        end)
    end
end

local function attackPlayer(targetPlayer, keepRunning)
    if state.Busy then
        return false, "Ya hay un ataque en curso."
    end

    if not targetPlayer
        or targetPlayer == LocalPlayer
        or not targetPlayer.Parent
    then
        return false, "Objetivo inválido."
    end

    if isSameTeam(targetPlayer) then
        return false, "Ese jugador es de tu equipo."
    end

    local character, root, humanoid = getLocalCharacter()
    if not character
        or not root
        or not humanoid
        or humanoid.Health <= 0
    then
        return false, "Tu personaje no está listo."
    end

    if not isRoundActive() then
        return false, "La ronda todavía no está activa."
    end

    local knife = getEquippedKnife()
    if not knife then
        return false, "Equipa el cuchillo en la mano."
    end

    local targetCharacter = targetPlayer.Character
    local targetRoot =
        targetCharacter
        and targetCharacter:FindFirstChild("HumanoidRootPart")
    local targetHumanoid =
        targetCharacter
        and targetCharacter:FindFirstChildOfClass("Humanoid")

    if not targetCharacter
        or not targetRoot
        or not targetHumanoid
        or targetHumanoid.Health <= 0
    then
        return false, "El objetivo ya no está disponible."
    end

    state.Busy = true
    state.CancelRequested = false

    local originalCFrame = root.CFrame
    local originalLinearVelocity = root.AssemblyLinearVelocity
    local originalAngularVelocity = root.AssemblyAngularVelocity
    local originalAutoRotate = humanoid.AutoRotate
    local originalPlatformStand = humanoid.PlatformStand
    local originalState = humanoid:GetState()
    local originalMoveDirection = humanoid.MoveDirection

    local initialHealth = targetHumanoid.Health
    local damageRegistered = false
    local resultMessage = "Ataque cancelado."

    local healthConnection =
        targetHumanoid.HealthChanged:Connect(function(newHealth)
            if newHealth < initialHealth then
                damageRegistered = true
            end
        end)

    local ok, err = pcall(function()
        humanoid.AutoRotate = false

        if not placeUnderTarget(
            character,
            root,
            targetRoot
        ) then
            resultMessage = "No pude llegar al objetivo."
            return
        end

        -- Dispara Tool.Activated inmediatamente después del PivotTo.
        -- No esperamos un Heartbeat y no inyectamos ningún tipo de input.
        if not performKnifeSlash(knife) then
            resultMessage = "No pude activar la lógica del cuchillo."
            return
        end

        local lastSlashAt = os.clock()

        while state.Alive
            and state.Busy
            and not state.CancelRequested
            and targetPlayer.Parent
            and targetCharacter.Parent
            and targetRoot.Parent
            and targetHumanoid.Parent
            and targetHumanoid.Health > 0
            and not damageRegistered
        do
            if keepRunning
                and not keepRunning()
            then
                resultMessage = "TP Slash desactivado."
                break
            end

            if not isRoundActive() then
                resultMessage = "La ronda terminó o volvió a espera."
                break
            end

            -- Relee el Tool en cada pulso. Algunos rounds recrean el cuchillo.
            local currentKnife = getEquippedKnife()
            if not currentKnife then
                resultMessage = "El cuchillo dejó de estar equipado."
                break
            end

            if currentKnife ~= knife then
                releaseKnife(knife)
                knife = currentKnife
                slashRoute = 0
            end

            local currentMyTeamId = getTeamId(LocalPlayer)
            local currentTargetTeamId = getTeamId(targetPlayer)

            if currentMyTeamId == nil
                or currentTargetTeamId == nil
                or currentMyTeamId == currentTargetTeamId
            then
                resultMessage = "El jugador pertenece a tu equipo."
                break
            end

            if targetHumanoid.Health < initialHealth then
                damageRegistered = true
                break
            end

            if not placeUnderTarget(
                character,
                root,
                targetRoot
            ) then
                resultMessage = "Se perdió el objetivo."
                break
            end

            -- Si el primer slash no produjo daño, repetimos la señal
            -- Activated mientras seguimos fijados debajo del objetivo.
            if os.clock() - lastSlashAt >= SLASH_RETRY_DELAY then
                if performKnifeSlash(knife) then
                    lastSlashAt = os.clock()
                end
            end

            RunService.Heartbeat:Wait()
        end

        if targetHumanoid.Parent
            and targetHumanoid.Health < initialHealth
        then
            damageRegistered = true
        end

        if damageRegistered then
            resultMessage =
                string.format(
                    "Daño confirmado: %.0f → %.0f HP.",
                    initialHealth,
                    math.max(0, targetHumanoid.Health)
                )
        elseif state.CancelRequested then
            resultMessage = "Ataque cancelado."
        elseif not targetPlayer.Parent then
            resultMessage = "El jugador salió."
        elseif not targetCharacter.Parent then
            resultMessage = "El objetivo desapareció."
        elseif targetHumanoid.Health <= 0 then
            -- Si murió por otra causa mientras estábamos ahí, soltamos de inmediato.
            resultMessage = "El objetivo murió."
        end
    end)

    if healthConnection then
        healthConnection:Disconnect()
    end

    -- Restauración inmediata, sin freezeRoot y sin task.wait extra.
    restoreLocalMovement(
        character,
        root,
        humanoid,
        originalCFrame,
        originalLinearVelocity,
        originalAngularVelocity,
        originalAutoRotate,
        originalPlatformStand,
        originalState,
        originalMoveDirection
    )

    state.Busy = false
    state.CancelRequested = false

    if not ok then
        return false, tostring(err)
    end

    return damageRegistered, resultMessage
end

local function stopTPSlash()
    state.TPSlashEnabled = false
    state.TPSlashGeneration += 1
    state.CancelRequested = true
end

local function startTPSlash()
    state.TPSlashGeneration += 1
    local generation = state.TPSlashGeneration

    task.spawn(function()
        while state.Alive
            and state.TPSlashEnabled
            and generation == state.TPSlashGeneration
        do
            local roundActive = isRoundActive()

            if not roundActive then
                if state.RoundWasActive then
                    state.RoundWasActive = false
                    state.CancelRequested = true
                    state.Busy = false

                    local oldKnife = getEquippedKnife()
                    if oldKnife then
                        releaseKnife(oldKnife)
                    end
                end

                task.wait(0.12)
                continue
            end

            if not state.RoundWasActive then
                state.RoundWasActive = true
                state.CancelRequested = false
                state.Busy = false
            end

            local knife = getEquippedKnife()

            if not knife then
                -- Silencioso: no spameamos avisos cada vez que guardas/sacas cuchillo.
                task.wait(0.10)
                continue
            end

            local enemies = getRoundEnemies()
            if #enemies == 0 then
                task.wait(NO_TARGETS_DELAY)
                continue
            end

            for _, targetPlayer in ipairs(enemies) do
                if not state.Alive
                    or not state.TPSlashEnabled
                    or generation ~= state.TPSlashGeneration
                then
                    break
                end

                if not getEquippedKnife() then
                    break
                end

                if isValidAliveTarget(targetPlayer) then
                    attackPlayer(
                        targetPlayer,
                        function()
                            return state.Alive
                                and state.TPSlashEnabled
                                and generation == state.TPSlashGeneration
                        end
                    )

                    -- El ataque ya restauró movimiento antes de llegar aquí.
                    task.wait(BETWEEN_TARGETS_DELAY)
                end
            end

            RunService.Heartbeat:Wait()
        end
    end)
end

-- MOVIMIENTO | Velocidad de caminar ------------------------------------------
-- No interviene con GunClient/Auto Shoot/TP Slash.
-- Respeta WalkSpeed=0 del lobby y los bloqueos de movimiento del juego.

local movementSettings = {
    Enabled = false,
    WalkSpeed = 16,
    OriginalHumanoid = nil,
    OriginalSpeed = nil,
    Accumulated = 0,
}

local function restoreWalkSpeed()
    local humanoid = movementSettings.OriginalHumanoid
    local original = movementSettings.OriginalSpeed

    if humanoid and humanoid.Parent
        and humanoid.Health > 0
        and humanoid.WalkSpeed > 0
        and original and original > 0
        and not state.Busy
    then
        pcall(function()
            humanoid.WalkSpeed = original
        end)
    end

    movementSettings.OriginalHumanoid = nil
    movementSettings.OriginalSpeed = nil
end

local function updateWalkSpeed()
    if not state.Alive or not movementSettings.Enabled then
        return
    end

    local character, root, humanoid = getLocalCharacter()
    if not character or not root or not humanoid
        or humanoid.Health <= 0 or state.Busy
    then
        return
    end

    -- La espera de ronda deja WalkSpeed=0. Nunca la desbloqueamos.
    if humanoid.WalkSpeed <= 0 or root.Anchored
        or humanoid.PlatformStand
        or character:FindFirstChildOfClass("ForceField")
        or teamLooksInactive(LocalPlayer.Team)
    then
        return
    end

    if movementSettings.OriginalHumanoid ~= humanoid then
        movementSettings.OriginalHumanoid = humanoid
        movementSettings.OriginalSpeed = humanoid.WalkSpeed
    end

    local wanted = math.clamp(
        tonumber(movementSettings.WalkSpeed) or 16,
        16,
        100
    )

    if math.abs(humanoid.WalkSpeed - wanted) > 0.01 then
        humanoid.WalkSpeed = wanted
    end
end

local walkSpeedConnection = RunService.Heartbeat:Connect(function(dt)
    if not movementSettings.Enabled then
        return
    end

    movementSettings.Accumulated += dt
    if movementSettings.Accumulated < 0.12 then
        return
    end

    movementSettings.Accumulated = 0
    updateWalkSpeed()
end)

-- MOVIMIENTO | Omitir contador (independiente) -------------------------------
-- Durante el contador WalkSpeed=0, que también sirve como señal de ronda.
-- Preservamos esa señal para que TP Slash y Auto Shoot NO se activen antes.
-- En lugar de mover el RootPart por CFrame, aplicamos velocidad física y
-- Humanoid:Move; la animación se obtiene del Animate del propio avatar.
-- Si el servidor valida/limita la posición, puede haber corrección igualmente.

local countdownWalkSettings = {
    Enabled = false,
    Controls = nil,
    ControlsFetched = false,
    WalkTrack = nil,
    TrackHumanoid = nil,
    TrackAnimation = nil,
    MovementApplied = false,
}

local function getCountdownControls()
    if countdownWalkSettings.Controls then
        return countdownWalkSettings.Controls
    end

    if countdownWalkSettings.ControlsFetched then
        return nil
    end

    countdownWalkSettings.ControlsFetched = true

    local ok, result = pcall(function()
        local scripts = LocalPlayer:FindFirstChild("PlayerScripts")
        local module = scripts and scripts:FindFirstChild("PlayerModule")
        if not module then return nil end
        local playerModule = require(module)
        if type(playerModule) ~= "table" or type(playerModule.GetControls) ~= "function" then
            return nil
        end
        return playerModule:GetControls()
    end)

    if ok and result then
        countdownWalkSettings.Controls = result
    end

    return countdownWalkSettings.Controls
end

local function getCountdownMoveDirection(humanoid)
    local direction = humanoid.MoveDirection
    if direction.Magnitude > 0.04 then
        return Vector3.new(direction.X, 0, direction.Z)
    end

    -- Alternativa para controles táctiles si MoveDirection permanece en cero.
    local controls = getCountdownControls()
    if not controls or type(controls.GetMoveVector) ~= "function" then
        return Vector3.zero
    end

    local ok, move = pcall(function()
        return controls:GetMoveVector()
    end)

    if not ok or typeof(move) ~= "Vector3" or move.Magnitude < 0.04 then
        return Vector3.zero
    end

    local camera = workspace.CurrentCamera
    if not camera then
        return Vector3.zero
    end

    local look = Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z)
    if look.Magnitude < 0.01 then
        return Vector3.zero
    end
    look = look.Unit

    local right = Vector3.new(camera.CFrame.RightVector.X, 0, camera.CFrame.RightVector.Z)
    if right.Magnitude < 0.01 then
        right = Vector3.new(-look.Z, 0, look.X)
    else
        right = right.Unit
    end

    return right * move.X - look * move.Z
end

local function stopCountdownWalkAnimation(resetTrack)
    local track = countdownWalkSettings.WalkTrack
    if track then
        pcall(function()
            if track.IsPlaying then
                track:Stop(0.12)
            end
            if resetTrack then
                track:Destroy()
            end
        end)
    end

    if resetTrack then
        countdownWalkSettings.WalkTrack = nil
        countdownWalkSettings.TrackHumanoid = nil
        countdownWalkSettings.TrackAnimation = nil
    end
end

local function getCountdownWalkTrack(character, humanoid)
    if countdownWalkSettings.TrackHumanoid == humanoid then
        return countdownWalkSettings.WalkTrack
    end

    stopCountdownWalkAnimation(true)
    countdownWalkSettings.TrackHumanoid = humanoid

    local animate = character:FindFirstChild("Animate")
    if not animate then
        return nil
    end

    -- Usa las propias animaciones del avatar, R15 o R6, sin IDs inventados.
    local walk = animate:FindFirstChild("walk")
    local run = animate:FindFirstChild("run")
    local animation = walk and walk:FindFirstChildWhichIsA("Animation")
        or run and run:FindFirstChildWhichIsA("Animation")

    if not animation or animation.AnimationId == "" then
        return nil
    end

    local animator = humanoid:FindFirstChildOfClass("Animator")
    if not animator then
        return nil
    end

    local ok, track = pcall(function()
        return animator:LoadAnimation(animation)
    end)

    if ok and track then
        track.Looped = true
        track.Priority = Enum.AnimationPriority.Movement
        countdownWalkSettings.WalkTrack = track
        countdownWalkSettings.TrackAnimation = animation
        return track
    end

    return nil
end

local function playCountdownWalkAnimation(character, humanoid, speed)
    local track = getCountdownWalkTrack(character, humanoid)
    if not track then
        return
    end

    pcall(function()
        if not track.IsPlaying then
            track:Play(0.12, 1, 1)
        end
        track:AdjustSpeed(math.clamp(speed / 16, 0.65, 2.5))
    end)
end

local function stopCountdownMovement(_humanoid, _root)
    -- El movimiento por CFrame no deja velocidad residual que haya que
    -- forzar a cero. Paramos únicamente la animación del contador.
    stopCountdownWalkAnimation(false)
    countdownWalkSettings.MovementApplied = false
end

local countdownWalkConnection = RunService.Heartbeat:Connect(function(dt)
    if not state.Alive then
        return
    end

    if not countdownWalkSettings.Enabled then
        if countdownWalkSettings.MovementApplied then
            stopCountdownMovement()
        end
        return
    end

    local character, root, humanoid = getLocalCharacter()
    if not character or not root or not humanoid or humanoid.Health <= 0 then
        stopCountdownWalkAnimation(true)
        countdownWalkSettings.MovementApplied = false
        return
    end

    -- Se conserva WalkSpeed=0 como señal de espera de ronda.
    -- Así TP Slash / Auto Shoot siguen usando sus propias reglas.
    if humanoid.WalkSpeed > 0 then
        stopCountdownMovement()
        return
    end

    -- Recuperamos las comprobaciones de la versión que sí se movía.
    -- No usamos Humanoid:Move ni AssemblyLinearVelocity: con WalkSpeed=0
    -- el controlador del personaje puede anular ambos.
    if humanoid.PlatformStand or humanoid.Sit then
        stopCountdownMovement()
        return
    end

    local direction = getCountdownMoveDirection(humanoid)
    if direction.Magnitude <= 0.04 then
        stopCountdownMovement()
        return
    end

    local amount = math.min(1, direction.Magnitude)
    local wantedSpeed = movementSettings.Enabled
        and movementSettings.WalkSpeed or 16
    wantedSpeed = math.clamp(tonumber(wantedSpeed) or 16, 8, 100)

    -- MISMO desplazamiento CFrame que tenía el anticontador funcional,
    -- sin modificar el WalkSpeed ni los estados de ronda.
    local step = direction.Unit * wantedSpeed
        * math.clamp(dt, 0, 0.05) * amount

    local moved = pcall(function()
        root.CFrame = root.CFrame + step
    end)

    if moved then
        countdownWalkSettings.MovementApplied = true
        -- Extra visual: reproducir la propia animación walk/run del avatar.
        playCountdownWalkAnimation(character, humanoid, wantedSpeed * amount)
    end
end)


-- MOVIMIENTO | Salto infinito -----------------------------------------------
-- Se activa con JumpRequest, igual en móvil y PC. No altera la pistola.
-- El listener vive fuera del personaje, por lo que funciona tras respawn.

local infiniteJumpSettings = {
    Enabled = false,
    LastJumpAt = 0,
}

local infiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
    if not state.Alive or not infiniteJumpSettings.Enabled or state.Busy then
        return
    end

    -- No desbloquear saltos durante el lobby ni cuando el juego inmoviliza.
    if not isRoundActive() then
        return
    end

    local character, root, humanoid = getLocalCharacter()
    if not character or not root or not humanoid then
        return
    end

    local currentState = humanoid:GetState()
    if currentState == Enum.HumanoidStateType.Dead
        or currentState == Enum.HumanoidStateType.Seated
        or currentState == Enum.HumanoidStateType.Swimming
        or currentState == Enum.HumanoidStateType.Climbing
        or currentState == Enum.HumanoidStateType.Ragdoll
    then
        return
    end

    -- Control sencillo de rebotes por señales Touch duplicadas en móvil.
    local now = os.clock()
    if now - infiniteJumpSettings.LastJumpAt < 0.085 then
        return
    end
    infiniteJumpSettings.LastJumpAt = now

    pcall(function()
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end)
end)

-- UI RYOU · V9: reutilizar el módulo ya cargado y el archivo validado.
do
    local UI_CACHE_PATH = "RyouUI-14.6.0-8a29db8835.lua"
    local UI_SIZE, UI_ADLER = 144349, 1923315147
    local CACHE_KEY = "__RyouHub_NeoSidebarV12_8a29db8835"

    local function validLibrarySource(source)
        if type(source)~="string" or #source~=UI_SIZE then return false end
        local a,b=1,0
        for i=1,#source do
            a=(a+string.byte(source,i))%65521
            b=(b+a)%65521
        end
        return b*65536+a==UI_ADLER
    end

    local function instantiateLibrary(source)
        local chunk,compileError=loadstring(source)
        if not chunk then error("Luau: "..tostring(compileError)) end
        local ui=chunk()
        if type(ui)~="table" or type(ui.CreateWindow)~="function"
            or tostring(ui.Version)~="14.6.0"
            or tostring(ui.Variant)~="Neo Sidebar V12" then
            error("La biblioteca no es Neo Sidebar V12.")
        end
        return ui
    end

    local ok,result=pcall(function()
        local hostEnv
        if type(getgenv)=="function" then
            local success,env=pcall(getgenv)
            if success and type(env)=="table" then hostEnv=env end
        end
        if not hostEnv and type(shared)=="table" then hostEnv=shared end

        local inMemory=hostEnv and hostEnv[CACHE_KEY]
        if type(inMemory)=="table" and inMemory.Version=="14.6.0"
            and inMemory.Variant=="Neo Sidebar V12"
            and type(inMemory.CreateWindow)=="function" then
            return inMemory
        end

        if type(readfile)=="function" then
            local readOk,cached=pcall(readfile,UI_CACHE_PATH)
            if readOk and validLibrarySource(cached) then
                local loaded,ui=pcall(instantiateLibrary,cached)
                if loaded then
                    if hostEnv then hostEnv[CACHE_KEY]=ui end
                    return ui
                end
            end
        end

        local source=game:HttpGet(RYOU_UI_URL)
        if not validLibrarySource(source) then
            error("Archivo V12 remoto distinto de la revisión fijada.")
        end
        local ui=instantiateLibrary(source)
        if hostEnv then hostEnv[CACHE_KEY]=ui end
        if type(writefile)=="function" then pcall(writefile,UI_CACHE_PATH,source) end
        return ui
    end)
    if not ok then
        warn("[Ryou] Error cargando Neo Sidebar V12: "..tostring(result))
        return
    end
    WindUI=result
end

-- AVATAR R15 | ANIMACIONES INTEGRADAS ----------------------------------------
-- La lógica vive aquí, NO en ui/compat.lua.
-- Conserva los 24 paquetes del catálogo de Duels y no depende de un módulo.
-- La UI solo crea los controles; este script cambia Animate del avatar local.

local ryouExtras = {}

do
local avatarAnimationPacks = {
    ["Old School"] = { Walk = 10921244891, Run = 10921240218, Jump = 10921242013, Fall = 10921241244, SwimIdle = 10921244018, Swim = 10921243048, Idle = 10921230744, Idle2 = 10921232093, Climb = 10921229866 },
    ["Adidas Sports"] = { Walk = 18537392113, Run = 18537384940, Jump = 18537380791, Fall = 18537367238, SwimIdle = 18537387180, Swim = 18537389531, Idle = 18537376492, Idle2 = 18537371272, Climb = 18537363391 },
    ["Adidas Community"] = { Walk = 122150855457006, Run = 82598234841035, Jump = 75290611992385, Fall = 98600215928904, SwimIdle = 109346520324160, Swim = 133308483266208, Idle = 122257458498464, Idle2 = 102357151005774, Climb = 88763136693023 },
    ["Adidas Aura"] = { Walk = 83842218823011, Run = 118320322718866, Jump = 109996626521204, Fall = 95603166884636, SwimIdle = 94922130551805, Swim = 134530128383903, Idle = 110211186840347, Idle2 = 114191137265065, Climb = 97824616490448 },
    ["Wicked Popular"] = { Walk = 92072849924640, Run = 72301599441680, Jump = 104325245285198, Fall = 121152442762481, Idle = 118832222982049, Idle2 = 76049494037641, SwimIdle = 113199415118199, Swim = 99384245425157, Climb = 131326830509784 },
    ["Elder"] = { Walk = 10921111375, Run = 10921104374, Jump = 10921107367, Fall = 10921105765, SwimIdle = 10921110146, Swim = 10921108971, Idle = 10921101664, Idle2 = 10921102574, Climb = 10921100400 },
    ["Zombie"] = { Walk = 10921355261, Run = 616163682, Jump = 10921351278, Fall = 10921350320, SwimIdle = 10921353442, Swim = 10921352344, Idle = 10921344533, Idle2 = 10921345304, Climb = 10921343576 },
    ["Mage"] = { Walk = 10921152678, Run = 10921148209, Jump = 10921149743, Fall = 10921148939, SwimIdle = 10921151661, Swim = 10921150788, Idle = 10921144709, Idle2 = 10921145797, Climb = 10921143404 },
    ["Catwalk Glam"] = { Walk = 109168724482748, Run = 81024476153754, Jump = 116936326516985, Fall = 92294537340807, SwimIdle = 98854111361360, Swim = 134591743181628, Idle = 133806214992291, Idle2 = 94970088341563, Climb = 119377220967554 },
    ["Astronaut"] = { Walk = 10921046031, Run = 10921039308, Jump = 10921042494, Fall = 10921040576, SwimIdle = 10921045006, Swim = 10921044000, Idle = 10921034824, Idle2 = 10921036806, Climb = 10921032124 },
    ['Wicked "Dancing Through Life"'] = { Walk = 73718308412641, Run = 135515454877967, Jump = 78508480717326, Fall = 78147885297412, SwimIdle = 129183123083281, Swim = 110657013921774, Idle = 92849173543269, Idle2 = 132238900951109, Climb = 129447497744818 },
    ["Werewolf"] = { Walk = 10921342074, Run = 10921336997, Fall = 10921337907, SwimIdle = 10921341319, Swim = 10921340419, Idle = 10921330408, Idle2 = 10921333667, Climb = 10921329322 },
    ["Superhero"] = { Walk = 10921298616, Run = 10921291831, Jump = 10921294559, Fall = 10921293373, SwimIdle = 10921297391, Swim = 10921295495, Idle = 10921288909, Idle2 = 10921290167, Climb = 10921286911 },
    ["Toy"] = { Walk = 10921312010, Run = 10921306285, Jump = 10921308158, Fall = 10921307241, SwimIdle = 10921310341, Swim = 10921309319, Idle = 10921301576, Climb = 10921300839 },
    ["No Boundaries"] = { Walk = 18747074203, Run = 18747070484, Jump = 18747069148, Fall = 18747062535, SwimIdle = 18747071682, Swim = 18747073181, Idle = 18747067405, Idle2 = 18747063918, Climb = 18747060903 },
    ["NFL"] = { Walk = 110358958299415, Run = 117333533048078, Jump = 119846112151352, Fall = 129773241321032, SwimIdle = 79090109939093, Swim = 132697394189921, Idle = 92080889861410, Idle2 = 74451233229259, Climb = 134630013742019 },
    ["Amazon Unboxed"] = { Walk = 90478085024465, Run = 134824450619865, Jump = 121454505477205, Fall = 94788218468396, SwimIdle = 129126268464847, Swim = 105962919001086, Idle = 98281136301627, Climb = 121145883950231 },
    ["Vampire"] = { Walk = 10921326949, Run = 10921320299, Jump = 10921322186, Fall = 10921321317, SwimIdle = 10921325443, Swim = 10921324408, Idle = 10921315373, Climb = 10921314188 },
    ["Ninja"] = { Walk = 656121766, Run = 656118852, Jump = 656117878, Fall = 656115606, SwimIdle = 656121397, Swim = 656119721, Idle = 656117400, Idle2 = 656118341, Climb = 656114359 },
    ["Robot"] = { Walk = 616095330, Run = 616091570, Jump = 616090535, Fall = 616087089, SwimIdle = 616094091, Swim = 616092998, Idle = 616088211, Idle2 = 616089559, Climb = 616086039 },
    ["Levitation"] = { Walk = 616013216, Run = 616010382, Jump = 616008936, Fall = 616005863, SwimIdle = 616012453, Swim = 616011509, Idle = 616006778, Idle2 = 616008087, Climb = 616003713 },
    ["Stylish"] = { Walk = 616146177, Run = 616140816, Jump = 616139451, Fall = 616134815, SwimIdle = 616144772, Swim = 616143378, Idle = 616136790, Idle2 = 616138447, Climb = 616133594 },
    ["Bubbly"] = { Walk = 910034870, Run = 910025107, Jump = 910016857, Fall = 910001910, SwimIdle = 910030921, Swim = 910028158, Idle = 910004836, Idle2 = 910009958, Climb = 909997997 },
    ["Cartoon"] = { Walk = 742640026, Run = 742638842, Jump = 742637942, Fall = 742637151, SwimIdle = 742639812, Swim = 742639220, Idle = 742637544, Idle2 = 742638445, Climb = 742636889 }
}

local avatarAnimationSlots = {
    { Folder = "idle", Animation = "Animation1", Key = "Idle", Title = "Reposo" },
    { Folder = "idle", Animation = "Animation2", Key = "Idle2" },
    { Folder = "walk", Animation = "WalkAnim", Key = "Walk", Title = "Caminar" },
    { Folder = "run", Animation = "RunAnim", Key = "Run", Title = "Correr" },
    { Folder = "jump", Animation = "JumpAnim", Key = "Jump", Title = "Saltar" },
    { Folder = "fall", Animation = "FallAnim", Key = "Fall", Title = "Caer" },
    { Folder = "climb", Animation = "ClimbAnim", Key = "Climb", Title = "Escalar" },
    { Folder = "swim", Animation = "Swim", Key = "Swim", Title = "Nadar" },
    { Folder = "swimidle", Animation = "SwimIdle", Key = "SwimIdle", Title = "Flotar en el agua" },
}

local avatarAnimationNames = {"Original"}
do
    local packs = {}
    for name in pairs(avatarAnimationPacks) do
        packs[#packs + 1] = name
    end
    table.sort(packs)
    for _, name in ipairs(packs) do
        avatarAnimationNames[#avatarAnimationNames + 1] = name
    end
end

local function mountAvatarAnimationsInline(window, animationsTab, playerObject)
    local originalByAnimation = setmetatable({}, { __mode = "k" })
    local appliedOverrides = {}
    local mixChoices = {}
    local appliedMix = {}
    local mode = "Original" -- Original, Paquete, Mezcla
    local selectedPackage = "Original"
    local activePackage = "Original"
    local currentGeneration = 0
    local destroyed = false
    local dropdowns = {}
    local connections = {}

    local function isCurrent(character, token)
        return not destroyed
            and not window.Destroyed
            and state.Alive
            and playerObject.Character == character
            and currentGeneration == token
    end

    local function safeNotify(message)
        if not destroyed then
            notify("Animaciones: " .. message, 3)
        end
    end

    local function applyToCharacter(character, overrides)
        if not character then
            return false, 0, 0
        end

        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local animate = character:FindFirstChild("Animate")
        if not humanoid or not animate
            or humanoid.RigType ~= Enum.HumanoidRigType.R15
        then
            return false, 0, 0
        end

        local changes, matching = 0, 0
        local changedAnimations = {}

        for _, slot in ipairs(avatarAnimationSlots) do
            local folder = animate:FindFirstChild(slot.Folder)
            local animation = folder and folder:FindFirstChild(slot.Animation)
            if animation and animation:IsA("Animation") then
                local before = animation.AnimationId
                local history = originalByAnimation[animation]
                if history and before ~= history.Applied
                    and before ~= history.Original
                then
                    -- Otro sistema cambió la animación: respetar su valor actual.
                    history = nil
                    originalByAnimation[animation] = nil
                end

                local assetId = overrides[slot.Key]
                if assetId then matching += 1 end
                local wanted = assetId and ("rbxassetid://" .. tostring(assetId))
                    or (history and history.Original)

                if wanted then
                    if before ~= wanted then
                        animation.AnimationId = wanted
                        changedAnimations[animation] = true
                        changes += 1
                    end
                    if assetId then
                        originalByAnimation[animation] = {
                            Original = history and history.Original or before,
                            Applied = wanted,
                        }
                    else
                        originalByAnimation[animation] = nil
                    end
                else
                    originalByAnimation[animation] = nil
                end
            end
        end

        -- Detener solo animaciones modificadas, nunca todas las pistas del jugador.
        local animator = humanoid:FindFirstChildOfClass("Animator")
        if animator and next(changedAnimations) then
            pcall(function()
                for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                    if track.Animation and changedAnimations[track.Animation] then
                        track:Stop(0.12)
                    end
                end
            end)
        end
        return true, changes, matching
    end

    local function updateOverridesFromMode()
        local resolved = {}
        if mode == "Paquete" then
            local pack = avatarAnimationPacks[activePackage]
            if pack then
                resolved = table.clone(pack)
            end
        elseif mode == "Mezcla" then
            for key, packName in pairs(appliedMix) do
                local pack = avatarAnimationPacks[packName]
                if pack and pack[key] then
                    resolved[key] = pack[key]
                    if key == "Idle" then
                        resolved.Idle2 = pack.Idle2 or pack.Idle
                    end
                end
            end
        end
        appliedOverrides = resolved
        return resolved
    end

    local function applyCurrent(showStatus)
        currentGeneration += 1
        local token = currentGeneration
        local character = playerObject.Character
        if not character then
            if showStatus then safeNotify("El personaje aún no ha cargado.") end
            return
        end
        task.spawn(function()
            local overrides = appliedOverrides
            if next(overrides) then
                if not character:FindFirstChildOfClass("Humanoid") then
                    character:WaitForChild("Humanoid", 5)
                end
                if not isCurrent(character, token) then return end
                if not character:FindFirstChild("Animate") then
                    character:WaitForChild("Animate", 5)
                end
            end
            if not isCurrent(character, token) then return end
            local supported, changed, matches = applyToCharacter(character, overrides)
            if showStatus then
                if not supported then
                    safeNotify("Requiere un avatar R15 con Animate estándar.")
                elseif not next(overrides) then
                    safeNotify(changed > 0 and "Movimientos originales restaurados."
                        or "No había movimientos que restaurar.")
                elseif matches == 0 then
                    safeNotify("Este avatar no tiene las ranuras de animación esperadas.")
                elseif changed > 0 then
                    safeNotify("Movimientos actualizados.")
                else
                    safeNotify("Los movimientos ya están aplicados.")
                end
            elseif supported and next(overrides) then
                -- Un Animate que aún se completa tras el respawn puede reescribir
                -- sus AnimationId. Reintentar una vez sin generar conexiones extra.
                task.delay(0.35, function()
                    if isCurrent(character, token) then
                        applyToCharacter(character, appliedOverrides)
                    end
                end)
            end
        end)
    end

    local function restoreCharacter(character)
        if character and next(originalByAnimation) then
            applyToCharacter(character, {})
        end
    end

    local function applyWholePackage()
        if selectedPackage == "Original" then
            mode = "Original"
            activePackage = "Original"
        else
            mode = "Paquete"
            activePackage = selectedPackage
        end
        updateOverridesFromMode()
        applyCurrent(true)
    end

    local function applyMix()
        local nextMix = {}
        for _, slot in ipairs(avatarAnimationSlots) do
            if slot.Title then
                local value = mixChoices[slot.Key]
                if avatarAnimationPacks[value] then
                    nextMix[slot.Key] = value
                end
            end
        end
        appliedMix = nextMix
        mode = next(nextMix) and "Mezcla" or "Original"
        updateOverridesFromMode()
        applyCurrent(true)
    end

    local function restoreOriginal()
        mode = "Original"
        activePackage = "Original"
        selectedPackage = "Original"
        appliedMix = {}
        mixChoices = {}
        if dropdowns.Bundle then dropdowns.Bundle:Set("Original", true) end
        for key, control in pairs(dropdowns.Mix or {}) do
            control:Set("Original", true)
        end
        updateOverridesFromMode()
        applyCurrent(true)
    end

    animationsTab:Paragraph({
        Title = "Animaciones R15",
        Desc = "Elige un estilo completo o personaliza cada movimiento. "
            .. "Puedes volver a tu estilo original cuando quieras.",
    })
    animationsTab:Section({ Title = "Paquetes completos" })
    dropdowns.Bundle = animationsTab:Dropdown({
        Title = "Elegir paquete",
        Values = avatarAnimationNames,
        Value = "Original",
        Callback = function(value)
            selectedPackage = tostring(value or "Original")
        end,
    })
    animationsTab:Button({
        Title = "Aplicar paquete completo",
        Desc = "Cambia tus movimientos al estilo elegido.",
        Callback = applyWholePackage,
    })
    animationsTab:Button({
        Title = "Restaurar animaciones originales",
        Desc = "Vuelve a tus movimientos originales.",
        Callback = restoreOriginal,
    })
    animationsTab:Section({ Title = "Mezclador de animaciones" })
    dropdowns.Mix = {}
    for _, slot in ipairs(avatarAnimationSlots) do
        if slot.Title then
            local key = slot.Key
            mixChoices[key] = "Original"
            dropdowns.Mix[key] = animationsTab:Dropdown({
                Title = slot.Title,
                Values = avatarAnimationNames,
                Value = "Original",
                Callback = function(value)
                    mixChoices[key] = tostring(value or "Original")
                end,
            })
        end
    end
    animationsTab:Button({
        Title = "Combinar y aplicar",
        Desc = "Combina estilos distintos para caminar, correr y más.",
        Callback = applyMix,
    })

    local function disconnectAll()
        if destroyed then return end
        destroyed = true
        currentGeneration += 1
        for _, connection in ipairs(connections) do
            if connection.Connected then
                connection:Disconnect()
            end
        end
        restoreCharacter(playerObject.Character)
    end

    connections[#connections + 1] = playerObject.CharacterAdded:Connect(function()
        if next(appliedOverrides) then
            applyCurrent(false)
        end
    end)
    connections[#connections + 1] = playerObject.CharacterRemoving:Connect(function(character)
        currentGeneration += 1
        restoreCharacter(character)
    end)
    window:OnDestroy(disconnectAll)

    return {
        Save = function()
            return {
                Mode = mode,
                Package = activePackage,
                Mix = table.clone(appliedMix),
            }
        end,
        Load = function(data)
            if type(data) ~= "table" or destroyed then return end
            local requestedMode = data.Mode
            if requestedMode ~= "Paquete" and requestedMode ~= "Mezcla" then
                requestedMode = "Original"
            end
            local requestedPackage = tostring(data.Package or "Original")
            if not avatarAnimationPacks[requestedPackage] then
                requestedPackage = "Original"
            end
            selectedPackage = requestedPackage
            activePackage = requestedPackage
            mode = requestedMode
            if mode == "Paquete" and activePackage == "Original" then
                mode = "Original"
            end
            appliedMix = {}
            mixChoices = {}
            if type(data.Mix) == "table" then
                for _, slot in ipairs(avatarAnimationSlots) do
                    if slot.Title and avatarAnimationPacks[data.Mix[slot.Key]] then
                        appliedMix[slot.Key] = data.Mix[slot.Key]
                    end
                end
            end
            if mode == "Mezcla" and not next(appliedMix) then
                mode = "Original"
            end
            if dropdowns.Bundle then dropdowns.Bundle:Set(selectedPackage, true) end
            for key, control in pairs(dropdowns.Mix) do
                local selection = appliedMix[key] or "Original"
                mixChoices[key] = selection
                control:Set(selection, true)
            end
            updateOverridesFromMode()
            applyCurrent(false)
        end,
        Destroy = disconnectAll,
    }
end

ryouExtras.mountAnimations = mountAvatarAnimationsInline
end

local avatarAnimations

-- RYOUHUB | SKYBOX + FONDO DEL MENU ------------------------------------------
-- Sistemas visuales autocontenidos del juego. ui/compat.lua sigue visual.

do
local Lighting = game:GetService("Lighting")

local RYOU_SKY_FACE_KEYS = {"bk", "dn", "ft", "lf", "rt", "up"}
local RYOU_SKY_PROPS = {"SkyboxBk", "SkyboxDn", "SkyboxFt", "SkyboxLf", "SkyboxRt", "SkyboxUp"}
local RYOU_SKYBOX_BASE = tostring(((getgenv and getgenv()) or _G).RYOU_SKYBOX_BASE_URL
    or "https://raw.githubusercontent.com/vryex/ryouhub/refs/heads/main/skyboxes"):gsub("/+$", "")

local function ryouAssetFunction()
    if type(getcustomasset) == "function" then return getcustomasset end
    if type(getsynasset) == "function" then return getsynasset end
    if syn and type(syn.getcustomasset) == "function" then return syn.getcustomasset end
    return nil
end

local function ryouFolderTree(path)
    if type(makefolder) ~= "function" then return end
    local current = ""
    for chunk in tostring(path):gmatch("[^/]+") do
        current = current == "" and chunk or current .. "/" .. chunk
        local exists = false
        if type(isfolder) == "function" then
            pcall(function() exists = isfolder(current) end)
        end
        if not exists then pcall(makefolder, current) end
    end
end

local function ryouHttpGet(url)
    if type(url) ~= "string" or not url:match("^https://") then
        return nil, "Solo se aceptan URLs HTTPS"
    end
    local req = (syn and syn.request) or (http and http.request) or http_request or request
    if type(req) == "function" then
        local ok, response = pcall(req, {Url=url, Method="GET"})
        if ok and response then
            local status = tonumber(response.StatusCode or response.Status or 200) or 200
            if status >= 200 and status < 300 and type(response.Body) == "string" then
                return response.Body
            end
        end
    end
    local ok, body = pcall(function() return game:HttpGet(url) end)
    if ok and type(body) == "string" then return body end
    return nil, "No se pudo descargar el recurso"
end

local function ryouSaveAsset(data, path)
    if type(writefile) ~= "function" or not ryouAssetFunction() then
        return nil, "El entorno requiere writefile y getcustomasset/getsynasset"
    end
    ryouFolderTree(path:match("^(.*)/[^/]+$") or "Ryou")
    local exists = false
    if type(isfile) == "function" then pcall(function() exists = isfile(path) end) end
    if not exists then
        local ok, err = pcall(writefile, path, data)
        if not ok then return nil, tostring(err) end
    end
    local ok, result = pcall(ryouAssetFunction(), path)
    if not ok or type(result) ~= "string" then return nil, tostring(result) end
    return result
end

local function ryouB64Decode(value)
    value = tostring(value or ""):gsub("%s+", "")
    local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local map = {}
    for i = 1, #alphabet do map[alphabet:sub(i,i)] = i-1 end
    local bytes = table.create(math.floor(#value * .75))
    for i = 1, #value, 4 do
        local a = map[value:sub(i,i)] or 0
        local b = map[value:sub(i+1,i+1)] or 0
        local cChar = value:sub(i+2,i+2)
        local dChar = value:sub(i+3,i+3)
        local c = map[cChar] or 0
        local d = map[dChar] or 0
        local triplet = a * 262144 + b * 4096 + c * 64 + d
        bytes[#bytes+1] = string.char(bit32.band(bit32.rshift(triplet,16), 255))
        if cChar ~= "=" and cChar ~= "" then
            bytes[#bytes+1] = string.char(bit32.band(bit32.rshift(triplet,8),255))
        end
        if dChar ~= "=" and dChar ~= "" then
            bytes[#bytes+1] = string.char(bit32.band(triplet,255))
        end
    end
    return table.concat(bytes)
end

local RYOU_BG_BASE64 = [==[
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
]==]

local ryouMenuBackground = {
    Enabled = true, Transparency = .12,
    Mode = "RyouHub",CustomURL = "",LogoURL = "",
    Image = nil,OriginalWordmark = nil,
}

-- Todas las imágenes ya existen en vryex/ryouhub/assets/backgrounds.
-- La biblioteca ui/compat.lua no contiene lógica de descarga ni del menú.
-- Colección Ryou V12: fondos propios anime, sin presets de Xero.
local RYOU_BG_PRESETS = {
    {Name="RyouHub", File="ryouhub-bg.jpg"},
    {Name="Rei Brush", File="rei-brush.png"},
    {Name="Ryou Sakura", File="ryou-sakura.png"},
    {Name="Estación nocturna", File="anime/ryou_estacion_nocturna.jpg"},
    {Name="Santuario violeta", File="anime/ryou_santuario_violeta.jpg"},
    {Name="Estación bajo lluvia", File="anime/ryou_estacion_lluvia.jpg"},
    {Name="Jardín lunar", File="anime/ryou_jardin_luna.jpg"},
}
local RYOU_BG_REPO = "https://raw.githubusercontent.com/vryex/ryouhub/ryouhub-v14-neo-v12-studio/assets/backgrounds/"

local function mountRyouMenuBackground(window, tab)
    -- V10: usar la capa del motor ubicada DETRÁS de las pestañas.
    -- La antigua UIElements.Main no existía en V9 y el fondo quedaba desconectado.
    local image = window.GetWallpaperLayer and window:GetWallpaperLayer()
    if not image then
        tab:Paragraph({Title="Fondos no disponibles",
            Desc="La biblioteca visual actual no expone la capa de wallpapers."})
        return {Save=function() return {} end,Load=function() end}
    end
    image.Visible=false
    image.Image=""
    image.ScaleType=Enum.ScaleType.Crop
    image.ImageTransparency=.12
    ryouMenuBackground.Image=image
    ryouMenuBackground.OriginalWordmark=nil

    local destroyed = false
    local assets = {}
    local loading = {}
    local customAsset
    local refreshBackground
    local selector

    local function isImage(bytes)
        if type(bytes) ~= "string" or #bytes < 50 or #bytes > 8000000 then return false end
        return bytes:sub(1,8)=="\137PNG\r\n\26\n" or bytes:sub(1,3)=="\255\216\255"
    end

    local function cachedAsset(path)
        if type(isfile) ~= "function" or not ryouAssetFunction() then return nil end
        local ok, found = pcall(isfile, path)
        if not ok or not found then return nil end
        local assetFunc = ryouAssetFunction()
        local loaded, asset = pcall(assetFunc, path)
        if loaded and type(asset)=="string" and asset~="" then return asset end
        return nil
    end

    local function wallpaperFallback()
        local path = "Ryou/Assets/ryouhub_generated_mint_v1.jpg"
        local existing = cachedAsset(path)
        if existing then return existing end
        local bytes = ryouB64Decode(RYOU_BG_BASE64)
        return select(1, ryouSaveAsset(bytes,path))
    end

    refreshBackground = function()
        if destroyed or not image.Parent then return end
        local selection = ryouMenuBackground.Mode
        local selected = selection=="Personalizado" and customAsset or assets[selection]
        local enabled = ryouMenuBackground.Enabled and selected ~= nil
        -- V11 aplica la imagen a toda la ventana y oculta el arte de Ryou
        -- de la cabecera/sidebar cuando existe un fondo activo.
        window:SetWallpaper(enabled and selected or nil,ryouMenuBackground.Transparency)
    end

    local function loadPreset(name)
        local file
        for _,entry in ipairs(RYOU_BG_PRESETS) do
            if entry.Name == name then file=entry.File; break end
        end
        if not file then return end
        if assets[name] then refreshBackground(); return end
        if loading[name] then return end
        loading[name] = true
        task.spawn(function()
            local path="Ryou/Assets/Backgrounds/ryou_v12_"..file:gsub("[^%w%._%-]","_")
            local asset=cachedAsset(path)
            local errorMessage
            if not asset then
                local bytes, err=ryouHttpGet(RYOU_BG_REPO..file)
                if isImage(bytes) then
                    asset,errorMessage=ryouSaveAsset(bytes,path)
                else
                    errorMessage=err or "Archivo de imagen inválido"
                end
            end
            if name=="RyouHub" and not asset then
                asset=wallpaperFallback()
            end
            loading[name] = nil
            if destroyed then return end
            if asset then
                assets[name]=asset
                refreshBackground()
            elseif ryouMenuBackground.Mode == name then
                notify("No se pudo cargar el fondo "..name..": "..tostring(errorMessage),3)
            end
        end)
    end

    local function selectPreset(name)
        ryouMenuBackground.Mode=name
        refreshBackground()
        loadPreset(name)
    end

    -- Caché determinista por URL, independiente del tema y la escala.
    local function urlHash(value)
        local hash=0
        for i=1,#value do
            -- Arithmetic below 2^53, deterministic on mobile and desktop.
            hash=(hash*131+string.byte(value,i))%2147483647
        end
        return string.format("%08x",hash)
    end

    local function validateWebURL(value)
        local url=tostring(value or ""):match("^%s*(.-)%s*$")
        if #url>1200 or not url:match("^https://") then
            return nil,"Pega un enlace HTTPS válido."
        end
        local host=url:match("^https://([^/%?#]+)")
        if not host or host:find("[@:%s]") or host:lower()=="localhost"
            or host:match("^%d+%.%d+%.%d+%.%d+$") or not host:find("%.") then
            return nil,"Dominio no permitido para fondos."
        end
        return url
    end

    local function parsePageImage(html,pageURL)
        if type(html)~="string" or #html>2500000 then return nil end
        -- OG:image admite que property/content aparezcan en cualquier orden.
        for meta in html:gmatch("<[Mm][Ee][Tt][Aa]%s+[^>]->") do
            if meta:lower():find("og:image",1,true)
                or meta:lower():find("twitter:image",1,true) then
                local found=meta:match('[Cc][Oo][Nn][Tt][Ee][Nn][Tt]%s*=%s*"(.-)"')
                    or meta:match("[Cc][Oo][Nn][Tt][Ee][Nn][Tt]%s*=%s*'(.-)'")
                if found then
                    found=found:gsub("&amp;","&"):gsub("&#38;","&")
                    found=found:gsub("&#x26;","&")
                    local valid=validateWebURL(found)
                    if valid then return valid end
                end
            end
        end
        -- Algunas páginas Pinterest incrustan la miniatura pinimg sin meta OG.
        if pageURL:find("pinterest.com",1,true) or pageURL:find("pin.it",1,true) then
            local normalized=html:gsub("\\/","/")
            local url=normalized:match([[https://i%.pinimg%.com/[^"'%s<>]+]])
            if url then
                url=url:gsub("&amp;","&")
                local valid=validateWebURL(url)
                if valid then return valid end
            end
        end
        return nil
    end

    local function loadCustomURL(value)
        local url,validationError=validateWebURL(value)
        if not url then return false,validationError end
        local cacheBase="Ryou/Assets/UserWallpapers/url_"..urlHash(url)
        local cachedPNG=cachedAsset(cacheBase..".png")
        local cachedJPG=cachedAsset(cacheBase..".jpg")
        local cached=cachedPNG or cachedJPG
        if cached then
            if destroyed then return false,"Ventana cerrada." end
            customAsset=cached
            ryouMenuBackground.CustomURL=url
            ryouMenuBackground.Mode="Personalizado"
            if selector then selector:Set("Personalizado",true) end
            refreshBackground()
            return true
        end

        local bytes,err=ryouHttpGet(url)
        if not isImage(bytes) then
            -- Si se compartió una página (Pinterest o cualquier web),
            -- intentar su imagen OG. No se ejecuta JavaScript ni HTML remoto.
            local linked=parsePageImage(bytes,url)
            if not linked then
                return false,err or "La página no expone una imagen PNG/JPG pública. En Pinterest copia el enlace directo de i.pinimg.com."
            end
            local imageURL,imageErr=validateWebURL(linked)
            if not imageURL or imageURL==url then return false,imageErr or "No se encontró imagen descargable." end
            bytes,err=ryouHttpGet(imageURL)
        end
        if not isImage(bytes) then
            return false,err or "La URL no entregó una imagen PNG/JPG pública (máximo 8 MB)."
        end
        local ext=bytes:sub(1,8)=="\137PNG\r\n\26\n" and ".png" or ".jpg"
        local asset,saveError=ryouSaveAsset(bytes,cacheBase..ext)
        if not asset then return false,saveError end
        if destroyed then return false,"Ventana cerrada." end
        customAsset=asset
        ryouMenuBackground.CustomURL=url
        ryouMenuBackground.Mode="Personalizado"
        if selector then selector:Set("Personalizado",true) end
        refreshBackground()
        return true
    end

    local function loadLogoURL(value)
        local url,validationError=validateWebURL(value)
        if not url then return false,validationError end
        local cacheBase="Ryou/Assets/UserWallpapers/logo_"..urlHash(url)
        local asset=cachedAsset(cacheBase..".png") or cachedAsset(cacheBase..".jpg")
        if not asset then
            local bytes,err=ryouHttpGet(url)
            if not isImage(bytes) then
                local linked=parsePageImage(bytes,url)
                local resolved=linked and validateWebURL(linked)
                if not resolved or resolved==url then
                    return false,err or "Necesitas una imagen PNG o JPG pública."
                end
                bytes,err=ryouHttpGet(resolved)
            end
            if not isImage(bytes) then
                return false,err or "El enlace no entrega un PNG/JPG público (máximo 8 MB)."
            end
            local ext=bytes:sub(1,8)=="\137PNG\r\n\26\n" and ".png" or ".jpg"
            asset,err=ryouSaveAsset(bytes,cacheBase..ext)
            if not asset then return false,err end
        end
        if destroyed then return false,"Ventana cerrada." end
        window:SetBrandLogo(asset)
        ryouMenuBackground.LogoURL=url
        return true
    end

    tab:Section({Title="Fondo del menú"})
    tab:Paragraph({Title="Fondos de RyouHub",Desc="Elige una imagen de la colección o usa tu propio enlace."})
    local names={}
    for _,entry in ipairs(RYOU_BG_PRESETS) do names[#names+1]=entry.Name end
    names[#names+1]="Personalizado"
    selector=tab:Dropdown({
        Title="Elegir fondo", Desc="Colección completa disponible en RyouHub",
        Values=names, Value="RyouHub",
        Callback=function(value)
            local selection=type(value)=="table" and value[1] or value
            if type(selection)=="string" then selectPreset(selection) end
        end,
    })
    local toggle=tab:Toggle({Title="Mostrar imagen de fondo",Value=true,Callback=function(on)
        ryouMenuBackground.Enabled=on==true
        refreshBackground()
    end})
    local opacity=tab:Slider({Title="Transparencia del fondo",Desc="0 = visible; 95 = casi invisible",Step=1,
        Value={Min=0,Max=95,Default=12},Callback=function(value)
            ryouMenuBackground.Transparency=math.clamp((tonumber(value) or 12)/100,0,.95)
            refreshBackground()
        end})
    local urlInput=""
    tab:Section({Title="Pinterest y otras páginas",Icon="pinterest"})
    tab:Paragraph({Title="Fondo desde Internet",
        Desc="Pega un enlace de Pinterest, una página con imagen pública o una URL directa PNG/JPG."})
    local urlField=tab:Input({
        Title="Enlace de imagen",
        Placeholder="https://i.pinimg.com/… o https://pinterest.com/pin/…",
        Callback=function(value) urlInput=tostring(value or "") end,
    })
    local applying=false
    tab:Button({Title="Aplicar imagen de Pinterest o web",Icon="pinterest",
        Desc="Guarda la imagen en caché y la muestra detrás de los controles.",
        Callback=function()
            if applying then return end
            applying=true
            local entered=(urlField.TextBox and urlField.TextBox.Text) or urlInput
            task.spawn(function()
                local success,ok,err=pcall(loadCustomURL,entered)
                applying=false
                if not destroyed then
                    notify(success and ok and "Fondo personalizado aplicado."
                        or ("No se pudo cargar el fondo: "..tostring(success and err or ok)),3)
                end
            end)
        end,
    })
    tab:Button({Title="Restaurar fondo RyouHub",Callback=function()
        selector:Set("RyouHub",true)
        selectPreset("RyouHub")
        notify("Fondo original restaurado.",2)
    end})

    tab:Section({Title="Logo personalizado",Icon="image"})
    local logoInput=tab:Input({
        Title="URL del logo",
        Placeholder="https://raw.githubusercontent.com/.../logo.png",
    })
    local loadingLogo=false
    tab:Button({
        Title="Aplicar logo",
        Desc="PNG/JPG público desde GitHub, Discord o tu propio servidor.",
        Callback=function()
            if loadingLogo then return end
            loadingLogo=true
            local url=logoInput.TextBox and logoInput.TextBox.Text or ""
            task.spawn(function()
                local ok,applied,err=pcall(loadLogoURL,url)
                loadingLogo=false
                if not destroyed then
                    notify(ok and applied and "Logo actualizado."
                        or ("No se pudo cargar el logo: "..tostring(ok and err or applied)),3)
                end
            end)
        end,
    })
    tab:Button({Title="Restaurar logo R",Callback=function()
        window:SetBrandLogo(nil)
        ryouMenuBackground.LogoURL=""
        if logoInput then logoInput:Set("",true) end
        notify("Logo original restaurado.",2)
    end})
    tab:Button({Title="Guía de logos y fondos",Icon="info",
        Callback=function()
            local guide="https://github.com/vryex/ryouhub/blob/ryouhub-v14-neo-v12-studio/docs/ASSETS_Y_PERSONALIZACION_V12.md"
            if type(setclipboard)=="function" then
                pcall(setclipboard,guide)
                notify("Enlace a la guía copiado.",2)
            else
                notify("Abre el repositorio vryex/ryouhub y consulta docs/ASSETS_Y_PERSONALIZACION_V12.md",4)
            end
        end,
    })

    window:OnDestroy(function()
        destroyed=true
        if image.Parent then image:Destroy() end
    end)
    loadPreset("RyouHub")
    refreshBackground()
    return {
        Save=function()
            return {Enabled=ryouMenuBackground.Enabled,Transparency=ryouMenuBackground.Transparency,
                Mode=ryouMenuBackground.Mode,CustomURL=ryouMenuBackground.CustomURL,
                LogoURL=ryouMenuBackground.LogoURL}
        end,
        Load=function(data)
            if type(data)~="table" then return end
            if type(data.LogoURL)=="string" and data.LogoURL~="" then
                task.spawn(function()
                    local ok,err=loadLogoURL(data.LogoURL)
                    if not ok then warn("[Ryou] Logo no restaurado: "..tostring(err)) end
                end)
            elseif data.LogoURL=="" then
                window:SetBrandLogo(nil)
                ryouMenuBackground.LogoURL=""
            end
            if data.Transparency~=nil then
                ryouMenuBackground.Transparency=math.clamp(tonumber(data.Transparency) or .12,0,.95)
                opacity:Set(math.floor(ryouMenuBackground.Transparency*100+.5),true)
            end
            if data.Enabled~=nil then
                ryouMenuBackground.Enabled=data.Enabled==true
                toggle:Set(ryouMenuBackground.Enabled,true)
            end
            if data.Mode=="Personalizado" and type(data.CustomURL)=="string" and data.CustomURL~="" then
                task.spawn(function()
                    local ok=loadCustomURL(data.CustomURL)
                    if not ok and not destroyed then selectPreset("RyouHub") end
                end)
            else
                local found=false
                for _,entry in ipairs(RYOU_BG_PRESETS) do
                    if entry.Name==data.Mode then found=true; break end
                end
                local mode=found and data.Mode or "RyouHub"
                selector:Set(mode,true)
                selectPreset(mode)
            end
        end,
    }
end

local RYOU_SKY_PRESETS = {
    ["Atardecer"] = {"323494035", "323494368", "323494130", "323494252", "323494067", "323493360"},
    ["Noche tropical"] = {"169210090", "169210108", "169210121", "169210133", "169210143", "169210149"},
}
local ryouSkybox = {
    Active = "Original",
    Selected = "Original",
    Custom = {"92427017914292","92427017914292","92427017914292","92427017914292","92427017914292","92427017914292"},
    Owned = nil,
    Hidden = {},
    ChildConnection = nil,
    Remote = {},
}

local function restoreRyouSky()
    if ryouSkybox.ChildConnection then
        ryouSkybox.ChildConnection:Disconnect()
        ryouSkybox.ChildConnection = nil
    end
    if ryouSkybox.Owned then
        pcall(function() ryouSkybox.Owned:Destroy() end)
        ryouSkybox.Owned = nil
    end
    for object in pairs(ryouSkybox.Hidden) do
        if object and not object.Parent then
            pcall(function() object.Parent = Lighting end)
        end
    end
    table.clear(ryouSkybox.Hidden)
    ryouSkybox.Active = "Original"
end

local function ryouNormalizeId(value)
    local s = tostring(value or "")
    if s:match("^rbxassetid://%d+$") then return s end
    local id = s:match("%d+")
    return id and "rbxassetid://"..id or nil
end

local function ryouRemoteSkyFaces(preset)
    local asset = ryouAssetFunction()
    if not asset or type(writefile) ~= "function" then
        return nil, "El dispositivo no admite estos cielos descargados."
    end
    local faces = {}
    for index, key in ipairs(RYOU_SKY_FACE_KEYS) do
        local filename = tostring(preset.Files[key] or "")
        if not filename:match("^[%w_.%-]+$") then
            return nil, "Imagen no válida: " .. key
        end
        local folder = tostring(preset.Folder or "")
        if not folder:match("^[%w_.%-]+$") then
            return nil, "Carpeta no válida"
        end
        local ext = filename:match("(%.[%w]+)$") or ".png"
        local localPath = "Ryou/Skyboxes/" .. folder .. "_" .. key .. "_v2" .. ext
        local exists = false
        if type(isfile) == "function" then
            pcall(function() exists = isfile(localPath) end)
        end
        -- Usa los skyboxes que Xero ya descargó, incluso sin conexión.
        local legacySuffix = folder == "xerohub-rei-brush" and "_visible2" or ""
        local legacyPath = "XeroHub/skybox_cache_fix3/xero_" .. folder .. legacySuffix .. "_" .. key .. ext
        local activePath = localPath
        if not exists and type(isfile)=="function" then
            local ok, hasLegacy = pcall(isfile, legacyPath)
            if ok and hasLegacy then
                activePath = legacyPath
                exists = true
            end
        end
        if not exists then
            local bytes, err = ryouHttpGet(RYOU_SKYBOX_BASE .. "/" .. folder .. "/" .. filename)
            if not bytes or #bytes < 64 then
                return nil, err or "No se pudo descargar el cielo " .. folder
            end
            ryouFolderTree("Ryou/Skyboxes")
            local ok, saveErr = pcall(writefile, localPath, bytes)
            if not ok then return nil, tostring(saveErr) end
        end
        local ok, localAsset = pcall(asset, activePath)
        if not ok or type(localAsset)~="string" or localAsset=="" then
            return nil, "No se pudo cargar una imagen del cielo."
        end
        faces[index] = localAsset
    end
    return faces
end

local function applyRyouSky(name)
    if name == "Original" or not name or name == "" then
        restoreRyouSky()
        return true
    end
    local faces = nil
    local values = RYOU_SKY_PRESETS[name]
    if name == "Personalizado (6 caras)" then values = ryouSkybox.Custom end
    if values then
        faces = {}
        for i=1,6 do
            faces[i]=ryouNormalizeId(values[i])
            if not faces[i] then return false, "Falta un ID para " .. RYOU_SKY_FACE_KEYS[i] end
        end
    elseif ryouSkybox.Remote[name] then
        local err
        faces,err = ryouRemoteSkyFaces(ryouSkybox.Remote[name])
        if not faces then return false,err end
    else
        return false, "Cielo desconocido"
    end
    restoreRyouSky()
    local sky = Instance.new("Sky")
    sky.Name = "RyouHub_Skybox"
    sky.CelestialBodiesShown = false
    sky.StarCount = 0
    for index, property in ipairs(RYOU_SKY_PROPS) do sky[property] = faces[index] end
    local previous = {}
    for _, child in ipairs(Lighting:GetChildren()) do
        if child:IsA("Sky") and child ~= sky then
            previous[child] = true
            child.Parent = nil
        end
    end
    ryouSkybox.Hidden = previous
    ryouSkybox.Owned = sky
    sky.Parent = Lighting
    ryouSkybox.ChildConnection=Lighting.ChildAdded:Connect(function(object)
        if ryouSkybox.Owned == sky and object:IsA("Sky") and object ~= sky then
            ryouSkybox.Hidden[object] = true
            task.defer(function()
                if ryouSkybox.Owned == sky and object.Parent == Lighting then object.Parent = nil end
            end)
        end
    end)
    ryouSkybox.Active = name
    return true
end

local function ryouLoadSkyManifest()
    local json, err=ryouHttpGet(RYOU_SKYBOX_BASE .. "/manifest.json")
    if not json then return false, err end
    local ok, obj = pcall(function() return HttpService:JSONDecode(json) end)
    if not ok or type(obj)~="table" then return false,"El manifest no es JSON válido" end
    local list = obj.skyboxes or obj
    if type(list)~="table" then return false,"El catálogo no es válido" end
    local count = 0
    for _,item in ipairs(list) do
        if type(item)=="table" and type(item.name)=="string" and type(item.folder)=="string"
           and item.folder:match("^[%w_.%-]+$") then
            local files = {}
            local valid = true
            for _,key in ipairs(RYOU_SKY_FACE_KEYS) do
                local v = item.files and item.files[key] or (key .. ".png")
                if type(v)~="string" or not v:match("^[%w_.%-]+$") then valid=false break end
                files[key]=v
            end
            local display = "Skybox · " .. item.name
            if valid and not ryouSkybox.Remote[display] then
                ryouSkybox.Remote[display]={Folder=item.folder,Files=files}
                count+=1
            end
        end
    end
    return true,count
end

local function mountRyouSkybox(window, tab)
    -- Mismo mecanismo de Xero: catálogo remoto -> nombres -> selección.
    -- No se piden seis IDs ni se muestran campos técnicos.
    local DEFAULT_REPO_SKY = "Skybox · XeroHub Rei Brush"
    if not ryouSkybox.Remote[DEFAULT_REPO_SKY] then
        ryouSkybox.Remote[DEFAULT_REPO_SKY] = {
            Folder = "xerohub-rei-brush",
            Files = {bk="bk.png",dn="dn.png",ft="ft.png",lf="lf.png",rt="rt.png",up="up.png"},
        }
    end

    tab:Paragraph({
        Title = "Cielos de Xero",
        Desc = "Elige un cielo de la colección. Se aplicará automáticamente.",
    })
    tab:Section({Title = "Colección de cielos"})

    local selector
    local selectionSerial = 0
    local destroyed = false
    local loadingCatalog = false
    local loadedCatalog = false

    local function sortedNames()
        local names = {"Original"}
        local remote = {}
        for name in pairs(ryouSkybox.Remote) do
            remote[#remote + 1] = name
        end
        table.sort(remote, function(a,b)
            return string.lower(a) < string.lower(b)
        end)
        for _, name in ipairs(remote) do
            names[#names + 1] = name
        end
        return names
    end

    local function refreshList()
        if destroyed or not selector then return end
        selector:Refresh(sortedNames())
        selector:Set(ryouSkybox.Selected, true)
    end

    local catalogStatus = tab:Paragraph({
        Title = "Colección",
        Desc = "Buscando los cielos disponibles...",
    })

    local function showCatalogStatus(message)
        if destroyed or not catalogStatus then return end
        pcall(function()
            if type(catalogStatus.SetDesc) == "function" then
                catalogStatus:SetDesc(message)
            end
        end)
    end

    local function fetchCatalog(onDone)
        if destroyed then return end
        if loadedCatalog then
            if onDone then onDone(true) end
            return
        end
        if loadingCatalog then
            -- El caller puede reintentar al recibir su selección.
            if onDone then
                task.spawn(function()
                    while loadingCatalog and not destroyed do task.wait(.1) end
                    if not destroyed then onDone(loadedCatalog) end
                end)
            end
            return
        end
        loadingCatalog = true
        task.spawn(function()
            local ok, count = ryouLoadSkyManifest()
            if destroyed then return end
            loadedCatalog = ok == true
            loadingCatalog = false
            refreshList()
            if ok then
                local countAll = #sortedNames() - 1
                showCatalogStatus(tostring(countAll) .. " cielos disponibles para elegir.")
            else
                showCatalogStatus("No se pudo actualizar la colección. Puedes usar los cielos guardados.")
            end
            if onDone then onDone(ok == true) end
        end)
    end

    local function chooseSky(name)
        if destroyed then return end
        name = tostring(name or "Original")
        selectionSerial += 1
        local serial = selectionSerial
        ryouSkybox.Selected = name
        if name == "Original" then
            restoreRyouSky()
            return
        end
        if not ryouSkybox.Remote[name] then
            fetchCatalog(function()
                if destroyed or serial ~= selectionSerial then return end
                if not ryouSkybox.Remote[name] then
                    notify("Ese cielo ya no está disponible en la colección.",3)
                    return
                end
                chooseSky(name)
            end)
            return
        end
        task.spawn(function()
            -- Descarga las seis imágenes originales en la caché, igual que Xero.
            local faces, err = ryouRemoteSkyFaces(ryouSkybox.Remote[name])
            if destroyed or serial ~= selectionSerial then return end
            if not faces then
                notify("No se pudo cargar ese cielo. Revisa tu conexión o prueba otro.",3)
                return
            end
            -- Reutiliza applyRyouSky para restaurar Lighting correctamente.
            -- Ya están en caché, así que no vuelve a descargarlas.
            local ok, reason = applyRyouSky(name)
            if destroyed or serial ~= selectionSerial then return end
            if not ok then
                notify("No se pudo aplicar ese cielo: " .. tostring(reason), 3)
            end
        end)
    end

    selector = tab:Dropdown({
        Title = "Skybox",
        Desc = "Selecciona un cielo de la colección.",
        Values = sortedNames(),
        Value = "Original",
        Callback = function(value)
            chooseSky(type(value)=="table" and value[1] or value)
        end,
    })

    tab:Button({
        Title = "Restaurar cielo original",
        Desc = "Vuelve al cielo normal del juego.",
        Callback = function()
            selectionSerial += 1
            restoreRyouSky()
            ryouSkybox.Selected = "Original"
            selector:Set("Original", true)
            notify("Cielo original restaurado.",2)
        end,
    })
    tab:Button({
        Title = "Actualizar colección",
        Desc = "Busca los nuevos cielos del repositorio.",
        Callback = function()
            loadedCatalog = false
            showCatalogStatus("Actualizando colección...")
            fetchCatalog(function(ok)
                if not destroyed then
                    notify(ok and "Colección de cielos actualizada." or "No se pudo actualizar la colección.", 2)
                end
            end)
        end,
    })

    window:OnDestroy(function()
        destroyed = true
        selectionSerial += 1
        restoreRyouSky()
    end)

    -- En Xero el catálogo se cargaba al ejecutar, no después de pulsar un botón.
    fetchCatalog()

    return {
        Save = function()
            return {
                Active = ryouSkybox.Active,
                Selected = ryouSkybox.Selected,
            }
        end,
        Load = function(data)
            if type(data) ~= "table" then return end
            local name = tostring(data.Active or data.Selected or "Original")
            if not ryouSkybox.Remote[name] and name ~= "Original" then
                -- Configuraciones previas de cielo personalizado ya no
                -- generan campos de ID; restaura el cielo por defecto.
                if name == "Personalizado (6 caras)" or RYOU_SKY_PRESETS[name] then
                    name = "Original"
                end
            end
            selector:Set(name, true)
            chooseSky(name)
        end,
    }
end


ryouExtras.mountSkybox = mountRyouSkybox
ryouExtras.mountBackground = mountRyouMenuBackground
ryouExtras.httpGet = ryouHttpGet
end

-- RYOUHUB | CLONADOR DE SKIN -----------------------------------------------
-- Clon visual sincronizado con R6/R15, sin ApplyDescription sobre el personaje.
-- Permite jugador del servidor, @username y outfits guardados públicos.

do
local ryouHttpGet = ryouExtras.httpGet
-- Xero Duels: motor ORIGINAL de clonador de avatar (copiado, sin reimplementar joints).
-- Sus capas de limiteds son opcionales en RyouHub; quedan sin efecto aqui.
local player = LocalPlayer
local runtime = {
    Alive = true,
    Appearance = {
        Enabled = {},
        OriginalFace = setmetatable({}, {__mode = "k"}),
        OriginalHead = setmetatable({}, {__mode = "k"}),
        HeadBaseVisuals = setmetatable({}, {__mode = "k"}),
        HairVisualCache = setmetatable({}, {__mode = "k"}),
        FaceClassicVisuals = setmetatable({}, {__mode = "k"}),
        RespawnGeneration = 0,
        AttachmentCache = setmetatable({}, {__mode = "k"}),
        ActiveAccessories = {},
        AvatarClone = {
        Active = false,
        KeepOnRespawn = true,
        Applying = false,
        TargetUserId = nil,
        TargetName = nil,
        Template = nil,
        Overlay = nil,
        DriverRig = nil,
        BaseCharacter = nil,
        BaseVisualCache = setmetatable({}, {__mode = "k"}),

        BaseHiddenParts = {},
        BaseHiddenTextures = {},
        BaseHiddenEffects = {},
        BaseHiddenIndex = setmetatable({}, {__mode = "k"}),
        ToolVisualConnections = setmetatable({}, {__mode = "k"}),
        OverlayVisualCache = setmetatable({}, {__mode = "k"}),
        MotorPairs = {},

        NativeTransparencyPairs = {},
        NativeEffectPairs = {},
        NativeTransparencyBindName = nil,
        NativeCameraTransparencyLast = nil,
        NativeAppliedTransparencyLast = nil,
        NativeLayerSignatureLast = nil,
        AnimationConnection = nil,
        RenderAnimationConnection = nil,
        BaseDescendantConnection = nil,

        RespawnMaskConnection = nil,
        RespawnMaskDescendantConnection = nil,
        RespawnMaskTopologyConnection = nil,
        RespawnMaskGeneration = nil,
        RespawnMaskPending = false,
        VisualContainer = nil,
        SelectedServerPlayer = nil,
        UsernameInput = "",
    },
    },
}
local function showBottomMessage(message)
    notify(message, 3)
end
-- Dependencias visuales de Xero que NO existen en Ryou (no afectan al clonado).
local function ryouNoAppearanceLayer() end
runtime.EnforceBodyAppearance = ryouNoAppearanceLayer
runtime.ApplyHairRemoval = ryouNoAppearanceLayer
runtime.EnsureAppearanceAccessories = ryouNoAppearanceLayer
runtime.RebuildAppearanceBodyGuards = ryouNoAppearanceLayer
runtime.ApplyFaceLayer = ryouNoAppearanceLayer
runtime.ApplyHeadlessLayer = ryouNoAppearanceLayer
runtime.ApplyKorbloxLayer = ryouNoAppearanceLayer
runtime.DestroyFaceClassicVisual = ryouNoAppearanceLayer
runtime.SyncFaceClassicVisual = ryouNoAppearanceLayer
-- Las capas de avatar externas a CloneAvatar son independientes del juego.
-- Se mantienen conectadas al sistema visual propio de RyouHub.
runtime.FastEnsureAppearanceAccessories = ryouNoAppearanceLayer
-- Xero Duels consulta estos dos helpers durante el respawn. RyouHub no
-- incluye el catálogo adicional de limiteds ni los presets de cara de Xero.
local function hasEnabledAppearanceAccessory()
    return false
end
runtime.GetActiveFaceKey = function()
    return nil
end

function runtime.FaceClassicUsesAvatarCloneSync(model)
    local state = runtime.Appearance and runtime.Appearance.AvatarClone
    return model ~= nil
        and state ~= nil
        and state.Overlay == model
        and model.Parent ~= nil
end


local function isHairAccessory(accessory)
    if not accessory or not accessory:IsA("Accessory") then
        return false
    end

    local isHair = false
    pcall(function()
        isHair = accessory.AccessoryType == Enum.AccessoryType.Hair
    end)

    if isHair then
        return true
    end

    local handle = accessory:FindFirstChild("Handle")
    if handle and handle:FindFirstChild("HairAttachment") then
        return true
    end

    return false
end

function runtime.GetHumanoidDescriptionFromUserIdSafe(userId)
    userId = tonumber(userId)
    if not userId or userId <= 0 then return nil, "UserId inválido" end

    local ok, result = pcall(function()
        return Players:GetHumanoidDescriptionFromUserIdAsync(userId)
    end)
    if ok and result then return result end

    ok, result = pcall(function()
        return Players:GetHumanoidDescriptionFromUserId(userId)
    end)
    if ok and result then return result end

    return nil, tostring(result or "No se pudo obtener la apariencia")
end

function runtime.ReapplyAppearanceLayers(char)
    char = char or player.Character
    if not char or not char.Parent then return end

    runtime.EnforceBodyAppearance(char)
    runtime.ApplyHairRemoval(char)
    runtime.EnsureAppearanceAccessories(char)
    runtime.RebuildAppearanceBodyGuards(char)
end

function runtime.PrepareAvatarCloneTemplate(model)
    if not model or not model:IsA("Model") then return nil end

    model.Name = "iLunX_AvatarCloneTemplate"
    model.Archivable = true
    model:SetAttribute("iLunXAvatarClone", true)

    for _, object in ipairs(model:GetDescendants()) do
        if object:IsA("Script") or object:IsA("LocalScript") or object:IsA("ModuleScript")
            or object:IsA("Tool") or object:IsA("ForceField") or object:IsA("BillboardGui") then
            pcall(function() object:Destroy() end)
        elseif object:IsA("BasePart") then
            object.CanCollide = false
            object.CanTouch = false
            object.CanQuery = false
            object.Massless = true
            object.Anchored = false
        end
    end

    local humanoid = model:FindFirstChildOfClass("Humanoid")
    if humanoid then
        pcall(function() humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None end)
        pcall(function() humanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff end)
        pcall(function() humanoid.NameDisplayDistance = 0 end)
        pcall(function() humanoid.HealthDisplayDistance = 0 end)
        pcall(function() humanoid.AutoRotate = false end)
        pcall(function() humanoid.PlatformStand = true end)
        pcall(function() humanoid.BreakJointsOnDeath = false end)
        pcall(function() humanoid.RequiresNeck = false end)

        local animator = humanoid:FindFirstChildOfClass("Animator")
        if animator then pcall(function() animator:Destroy() end) end
    end

    return model
end

function runtime.CreateAvatarCloneTemplateFromDescription(description, rigType)
    if not description or not description:IsA("HumanoidDescription") then
        return nil, "Descripción inválida"
    end

    rigType = rigType or Enum.HumanoidRigType.R15
    local ok, model = pcall(function()
        return Players:CreateHumanoidModelFromDescriptionAsync(
            description,
            rigType,
            Enum.AssetTypeVerification.Default
        )
    end)

    if (not ok or not model) then
        ok, model = pcall(function()
            return Players:CreateHumanoidModelFromDescription(
                description,
                rigType,
                Enum.AssetTypeVerification.Default
            )
        end)
    end

    if not ok or not model then
        return nil, tostring(model or "No se pudo construir el avatar")
    end

    return runtime.PrepareAvatarCloneTemplate(model)
end

function runtime.CreateAvatarCloneTemplateFromUserId(userId, rigType)
    userId = tonumber(userId)
    if not userId or userId <= 0 then return nil, "UserId inválido" end

    local description, descriptionError = runtime.GetHumanoidDescriptionFromUserIdSafe(userId)
    if description then
        local model, modelError = runtime.CreateAvatarCloneTemplateFromDescription(description, rigType)
        pcall(function() description:Destroy() end)
        if model then return model end
        descriptionError = modelError or descriptionError
    end

    local ok, model = pcall(function()
        return Players:CreateHumanoidModelFromUserIdAsync(userId)
    end)
    if (not ok or not model) then
        ok, model = pcall(function()
            return Players:CreateHumanoidModelFromUserId(userId)
        end)
    end

    if not ok or not model then
        return nil, tostring(model or descriptionError or "No se pudo construir el avatar")
    end

    local prepared = runtime.PrepareAvatarCloneTemplate(model)
    local sourceHumanoid = prepared and prepared:FindFirstChildOfClass("Humanoid")
    if sourceHumanoid and rigType and sourceHumanoid.RigType ~= rigType then
        pcall(function() prepared:Destroy() end)
        return nil, "El avatar usa un rig incompatible con este personaje"
    end

    return prepared
end

function runtime.AvatarCloneRestoreOverlayVisuals()
    local state = runtime.Appearance.AvatarClone
    for object, original in pairs(state.OverlayVisualCache) do
        if object and object.Parent then
            pcall(function()
                if original.LocalTransparencyModifier ~= nil and object:IsA("BasePart") then
                    object.LocalTransparencyModifier = original.LocalTransparencyModifier
                end
                if original.Transparency ~= nil and (object:IsA("Decal") or object:IsA("Texture")) then
                    object.Transparency = original.Transparency
                end
                if original.Enabled ~= nil then
                    object.Enabled = original.Enabled
                end
            end)
        end
    end
end

function runtime.AvatarCloneCaptureOverlayVisuals(overlay)
    local state = runtime.Appearance.AvatarClone
    state.OverlayVisualCache = setmetatable({}, {__mode = "k"})

    for _, object in ipairs(overlay:GetDescendants()) do
        if object:IsA("BasePart") then
            state.OverlayVisualCache[object] = {
                LocalTransparencyModifier = object.LocalTransparencyModifier,
            }
        elseif object:IsA("Decal") or object:IsA("Texture") then
            state.OverlayVisualCache[object] = {
                Transparency = object.Transparency,
            }
        elseif object:IsA("ParticleEmitter") or object:IsA("Trail") or object:IsA("Beam")
            or object:IsA("Smoke") or object:IsA("Fire") or object:IsA("Sparkles") then
            state.OverlayVisualCache[object] = {
                Enabled = object.Enabled,
            }
        end
    end
end

function runtime.UpdateAvatarCloneLayers()
    local state = runtime.Appearance.AvatarClone
    local overlay = state.Overlay
    if not overlay or not overlay.Parent then return end

    runtime.AvatarCloneRestoreOverlayVisuals()

    runtime.ApplyFaceLayer(overlay)

    if runtime.Appearance.Enabled.Headless then
        local head = overlay:FindFirstChild("Head")
        if head and head:IsA("BasePart") then
            head.LocalTransparencyModifier = 1
            for _, object in ipairs(head:GetDescendants()) do
                if object:IsA("Decal") or object:IsA("Texture") then
                    object.Transparency = 1
                end
            end
        end
    end

    if runtime.Appearance.Enabled.Korblox then
        for _, partName in ipairs({"RightUpperLeg", "RightLowerLeg", "RightFoot"}) do
            local part = overlay:FindFirstChild(partName)
            if part and part:IsA("BasePart") then
                part.LocalTransparencyModifier = 1
            end
        end
    end

    if runtime.Appearance.Enabled.HideHair then
        for _, object in ipairs(overlay:GetChildren()) do
            if isHairAccessory(object) then
                for _, visual in ipairs(object:GetDescendants()) do
                    if visual:IsA("BasePart") then
                        visual.LocalTransparencyModifier = 1
                    elseif visual:IsA("ParticleEmitter") or visual:IsA("Trail") or visual:IsA("Beam")
                        or visual:IsA("Smoke") or visual:IsA("Fire") or visual:IsA("Sparkles") then
                        visual.Enabled = false
                    end
                end
            end
        end
    end
end

function runtime.AvatarCloneResolveNativeSourcePart(char, overlay, clonePart)
    if not char or not overlay or not clonePart then return nil, nil end

    if clonePart.Parent == overlay then
        return char:FindFirstChild(clonePart.Name), nil
    end

    local accessory = clonePart:FindFirstAncestorWhichIsA("Accoutrement")
    if accessory and accessory:IsDescendantOf(overlay) then
        local handle = accessory:FindFirstChild("Handle")
        if handle and handle:IsA("BasePart") then
            local preferred = handle:FindFirstChild("AccessoryWeld")
                or handle:FindFirstChild("iLunXAppearanceWeld")

            if preferred and preferred:IsA("Weld") and preferred.Part1 then
                local realPart = char:FindFirstChild(preferred.Part1.Name)
                if realPart and realPart:IsA("BasePart") then
                    return realPart, accessory
                end
            end

            for _, joint in ipairs(handle:GetChildren()) do
                if (joint:IsA("Weld") or joint:IsA("Motor6D")) and joint.Part1 then
                    local realPart = char:FindFirstChild(joint.Part1.Name)
                    if realPart and realPart:IsA("BasePart") then
                        return realPart, accessory
                    end
                end
            end

            local attachment = handle:FindFirstChildWhichIsA("Attachment")
            if attachment then
                for _, bodyPart in ipairs(overlay:GetChildren()) do
                    if bodyPart:IsA("BasePart") and bodyPart:FindFirstChild(attachment.Name) then
                        local realPart = char:FindFirstChild(bodyPart.Name)
                        if realPart and realPart:IsA("BasePart") then
                            return realPart, accessory
                        end
                    end
                end
            end
        end

        local realHead = char:FindFirstChild("Head")
        return realHead and realHead:IsA("BasePart") and realHead or nil, accessory
    end

    local parentPart = clonePart.Parent
    while parentPart and parentPart ~= overlay do
        if parentPart:IsA("BasePart") then
            local realPart = char:FindFirstChild(parentPart.Name)
            if realPart and realPart:IsA("BasePart") then
                return realPart, nil
            end
        end
        parentPart = parentPart.Parent
    end

    return nil, nil
end

function runtime.AvatarCloneBuildNativeTransparencyMap(char, overlay)
    local state = runtime.Appearance.AvatarClone
    table.clear(state.NativeTransparencyPairs)
    table.clear(state.NativeEffectPairs)
    state.NativeAppliedTransparencyLast = nil
    state.NativeLayerSignatureLast = nil

    if not char or not char.Parent or not overlay or not overlay.Parent then return false end

    for _, object in ipairs(overlay:GetDescendants()) do
        if object:IsA("BasePart") then
            local accessory = object:FindFirstAncestorWhichIsA("Accoutrement")
            local original = state.OverlayVisualCache[object]
            state.NativeTransparencyPairs[#state.NativeTransparencyPairs + 1] = {
                ClonePart = object,
                Accessory = accessory,
                BaseLTM = original and tonumber(original.LocalTransparencyModifier)
                    or tonumber(object.LocalTransparencyModifier)
                    or 0,
            }
        elseif object:IsA("ParticleEmitter") or object:IsA("Trail") or object:IsA("Beam")
            or object:IsA("Smoke") or object:IsA("Fire") or object:IsA("Sparkles") then
            local accessory = object:FindFirstAncestorWhichIsA("Accoutrement")
            local original = state.OverlayVisualCache[object]
            state.NativeEffectPairs[#state.NativeEffectPairs + 1] = {
                Effect = object,
                Accessory = accessory,
                BaseEnabled = original and original.Enabled ~= false or object.Enabled,
            }
        end
    end

    return #state.NativeTransparencyPairs > 0
end

function runtime.AvatarCloneNativeLayerHidden(pair)
    local part = pair and pair.ClonePart
    if not part then return false end

    if runtime.Appearance.Enabled.Headless and part.Name == "Head"
        and part.Parent == runtime.Appearance.AvatarClone.Overlay then
        return true
    end

    if runtime.Appearance.Enabled.Korblox and part.Parent == runtime.Appearance.AvatarClone.Overlay
        and (part.Name == "RightUpperLeg" or part.Name == "RightLowerLeg" or part.Name == "RightFoot") then
        return true
    end

    if runtime.Appearance.Enabled.HideHair and pair.Accessory and isHairAccessory(pair.Accessory) then
        return true
    end

    return false
end

function runtime.AvatarCloneSyncNativeTransparency(char, overlay, dt, boundHumanoid)
    local state = runtime.Appearance.AvatarClone
    if state.Overlay ~= overlay or not overlay or not overlay.Parent or not char or not char.Parent then return end

    local currentCamera = workspace.CurrentCamera
    local humanoid = boundHumanoid
    if not humanoid or humanoid.Parent ~= char then
        humanoid = char:FindFirstChildOfClass("Humanoid")
    end
    local subject = currentCamera and currentCamera.CameraSubject
    local cameraOwnsCharacter = currentCamera and humanoid and (
        subject == humanoid
        or subject == char
        or (subject and subject:IsDescendantOf(char))
    )

    local transparency = 0
    if cameraOwnsCharacter and currentCamera then

        local cameraDelta = currentCamera.Focus.Position - currentCamera.CFrame.Position
        local distanceSq = cameraDelta:Dot(cameraDelta)
        if distanceSq < 4 then
            local distance = math.sqrt(distanceSq)
            transparency = 1 - (distance - 0.5) / 1.5
            if transparency < 0.5 then transparency = 0 end
        end

        local last = state.NativeCameraTransparencyLast
        if last ~= nil and transparency < 1 and last < 0.95 then
            local maxDelta = 2.8 * math.max(tonumber(dt) or 0, 0)
            transparency = last + math.clamp(transparency - last, -maxDelta, maxDelta)
        end

        transparency = math.clamp(math.floor(transparency * 100 + 0.5) / 100, 0, 1)
    end

    state.NativeCameraTransparencyLast = transparency

    local layerSignature = (runtime.Appearance.Enabled.Headless and 1 or 0)
        + (runtime.Appearance.Enabled.Korblox and 2 or 0)
        + (runtime.Appearance.Enabled.HideHair and 4 or 0)
    local visualStateChanged = state.NativeAppliedTransparencyLast ~= transparency
        or state.NativeLayerSignatureLast ~= layerSignature

    if visualStateChanged then
        state.NativeAppliedTransparencyLast = transparency
        state.NativeLayerSignatureLast = layerSignature

        for i = 1, #state.NativeTransparencyPairs do
            local pair = state.NativeTransparencyPairs[i]
            local clonePart = pair.ClonePart
            if clonePart and clonePart.Parent then
                local layerLTM = runtime.AvatarCloneNativeLayerHidden(pair) and 1
                    or math.clamp(tonumber(pair.BaseLTM) or 0, 0, 1)
                local desired = math.max(transparency, layerLTM)
                if clonePart.LocalTransparencyModifier ~= desired then
                    clonePart.LocalTransparencyModifier = desired
                end
            end
        end

        for i = 1, #state.NativeEffectPairs do
            local pair = state.NativeEffectPairs[i]
            local effect = pair.Effect
            if effect and effect.Parent then
                local hiddenByLayer = runtime.Appearance.Enabled.HideHair
                    and pair.Accessory and isHairAccessory(pair.Accessory)
                local desired = pair.BaseEnabled == true and transparency < 0.95 and not hiddenByLayer
                if effect.Enabled ~= desired then effect.Enabled = desired end
            end
        end
    end
end

function runtime.AvatarCloneBindNativeTransparency(char, overlay)
    local state = runtime.Appearance.AvatarClone
    local oldName = state.NativeTransparencyBindName
    if oldName then
        pcall(function() RunService:UnbindFromRenderStep(oldName) end)
        state.NativeTransparencyBindName = nil
    end

    if not runtime.AvatarCloneBuildNativeTransparencyMap(char, overlay) then return false end

    local bindName = "XeroHub_AvatarCloneNativeTransparency"
    pcall(function() RunService:UnbindFromRenderStep(bindName) end)
    state.NativeTransparencyBindName = bindName
    state.NativeCameraTransparencyLast = nil

    local boundHumanoid = char:FindFirstChildOfClass("Humanoid")

    local ok = pcall(function()
        RunService:BindToRenderStep(
            bindName,
            Enum.RenderPriority.Camera.Value + 1,
            function(dt)
                if not runtime.Alive or player.Character ~= char
                    or state.Overlay ~= overlay or not overlay.Parent then
                    return
                end
                runtime.AvatarCloneSyncNativeTransparency(char, overlay, dt, boundHumanoid)

                runtime.AvatarCloneEnforceBaseHiddenParts(char)
            end
        )
    end)

    if not ok then
        state.NativeTransparencyBindName = nil
        return false
    end

    runtime.AvatarCloneSyncNativeTransparency(char, overlay, 0, boundHumanoid)
    return true
end

function runtime.AvatarCloneSuspendLocalLayers(char)
    local headless = runtime.Appearance.Enabled.Headless == true
    local korblox = runtime.Appearance.Enabled.Korblox == true
    local hideHair = runtime.Appearance.Enabled.HideHair == true

    if headless then
        runtime.Appearance.Enabled.Headless = false
        runtime.ApplyHeadlessLayer(char)
    end
    if korblox then
        runtime.Appearance.Enabled.Korblox = false
        runtime.ApplyKorbloxLayer(char)
    end
    if hideHair then
        runtime.Appearance.Enabled.HideHair = false
        runtime.ApplyHairRemoval(char)
    end

    return headless, korblox, hideHair
end

function runtime.AvatarCloneResumeLocalLayers(char, headless, korblox, hideHair)
    runtime.Appearance.Enabled.Headless = headless == true
    runtime.Appearance.Enabled.Korblox = korblox == true
    runtime.Appearance.Enabled.HideHair = hideHair == true

    runtime.EnforceBodyAppearance(char)
    runtime.ApplyHairRemoval(char)
end

function runtime.AvatarCloneFindWeaponRoot(object, char)
    if not object then return nil end
    char = char or player.Character

    local tool = object:IsA("Tool") and object or object:FindFirstAncestorWhichIsA("Tool")
    if tool and (not char or tool:IsDescendantOf(char)) then
        return tool
    end

    local node = object
    while node and node ~= char do
        local name = string.lower(tostring(node.Name or ""))
        local strongWeaponName =
            name == "gun"
            or name == "knife"
            or name == "pistol"
            or name == "revolver"
            or name == "blade"
            or name == "weapon"
            or string.find(name, "defaultgun", 1, true) ~= nil
            or string.find(name, "defaultknife", 1, true) ~= nil
            or string.find(name, "gunpartsfolder", 1, true) ~= nil
            or string.find(name, "knifepartsfolder", 1, true) ~= nil

        local hasKillSignal = false
        if node.Parent == char or strongWeaponName then
            hasKillSignal = node:FindFirstChild("GunKill", true) ~= nil
                or node:FindFirstChild("KnifeKill", true) ~= nil
                or node:FindFirstChild("Stab", true) ~= nil
        end

        local hasHandle = false
        if node:IsA("BasePart") and name == "handle" then
            hasHandle = true
        else
            local handle = node:FindFirstChild("Handle")
            hasHandle = handle ~= nil and handle:IsA("BasePart")
        end

        local directLooseHandle = node:IsA("BasePart") and name == "handle" and node.Parent == char

        if directLooseHandle
            or hasKillSignal
            or (strongWeaponName and (hasHandle or node:IsA("BasePart") or node:IsA("Model") or node:IsA("Folder") or node:IsA("Accoutrement"))) then
            if not char or node:IsDescendantOf(char) then
                return node
            end
        end

        node = node.Parent
    end

    return nil
end

function runtime.AvatarCloneIsToolVisual(object, char)
    return runtime.AvatarCloneFindWeaponRoot(object, char) ~= nil
end

function runtime.AvatarCloneResetBaseVisualTracking()
    local state = runtime.Appearance.AvatarClone
    table.clear(state.BaseHiddenParts)
    table.clear(state.BaseHiddenTextures)
    table.clear(state.BaseHiddenEffects)
    state.BaseHiddenIndex = setmetatable({}, {__mode = "k"})
end

function runtime.AvatarCloneTrackHiddenObject(object)
    if not object then return end
    local state = runtime.Appearance.AvatarClone
    if state.BaseHiddenIndex[object] then return end

    local list
    if object:IsA("BasePart") then
        list = state.BaseHiddenParts
    elseif object:IsA("Decal") or object:IsA("Texture") then
        list = state.BaseHiddenTextures
    elseif object:IsA("ParticleEmitter") or object:IsA("Trail") or object:IsA("Beam")
        or object:IsA("Smoke") or object:IsA("Fire") or object:IsA("Sparkles") then
        list = state.BaseHiddenEffects
    end
    if not list then return end

    list[#list + 1] = object
    state.BaseHiddenIndex[object] = {List = list, Index = #list}
end

function runtime.AvatarCloneUntrackHiddenObject(object)
    if not object then return end
    local state = runtime.Appearance.AvatarClone
    local slot = state.BaseHiddenIndex[object]
    if not slot then return end

    local list = slot.List
    local index = slot.Index
    local lastIndex = #list
    local lastObject = list[lastIndex]

    list[index] = lastObject
    list[lastIndex] = nil
    state.BaseHiddenIndex[object] = nil

    if lastObject and lastObject ~= object then
        local lastSlot = state.BaseHiddenIndex[lastObject]
        if lastSlot then lastSlot.Index = index end
    end
end

function runtime.AvatarCloneClearToolVisualGuards()
    local state = runtime.Appearance.AvatarClone
    for tool, bundle in pairs(state.ToolVisualConnections) do
        if bundle then
            if bundle.DescendantAdded then
                pcall(function() bundle.DescendantAdded:Disconnect() end)
            end
            if bundle.AncestryChanged then
                pcall(function() bundle.AncestryChanged:Disconnect() end)
            end
        end
        state.ToolVisualConnections[tool] = nil
    end
end

function runtime.AvatarCloneRestoreCachedVisual(object, cache)
    cache = cache or runtime.Appearance.AvatarClone.BaseVisualCache
    local original = cache and cache[object]
    if not original or not object or not object.Parent then
        if cache and object then cache[object] = nil end
        runtime.AvatarCloneUntrackHiddenObject(object)
        return
    end

    pcall(function()
        if original.LocalTransparencyModifier ~= nil and object:IsA("BasePart") then
            object.LocalTransparencyModifier = original.LocalTransparencyModifier
        end
        if original.Transparency ~= nil and (object:IsA("Decal") or object:IsA("Texture")) then
            object.Transparency = original.Transparency
        end
        if original.Enabled ~= nil then
            object.Enabled = original.Enabled
        end
    end)

    cache[object] = nil
    runtime.AvatarCloneUntrackHiddenObject(object)
end

function runtime.AvatarCloneReleaseToolVisuals(char, specificRoot)
    local state = runtime.Appearance.AvatarClone
    local cache = state.BaseVisualCache
    if not cache then return end

    local function releaseObject(object)
        if object and cache[object] then
            runtime.AvatarCloneRestoreCachedVisual(object, cache)
        end
    end

    local function releaseRoot(root)
        if not root then return end
        if char and not root:IsDescendantOf(char) then return end
        releaseObject(root)
        for _, object in ipairs(root:GetDescendants()) do
            releaseObject(object)
        end
    end

    if specificRoot then
        releaseRoot(specificRoot)
        return
    end

    char = char or player.Character
    if not char then return end
    local released = setmetatable({}, {__mode = "k"})
    for _, child in ipairs(char:GetChildren()) do
        local root = runtime.AvatarCloneFindWeaponRoot(child, char)
        if root and not released[root] then
            released[root] = true
            releaseRoot(root)
        end
    end
end

function runtime.AvatarCloneBindToolVisualGuard(char, tool)
    local state = runtime.Appearance.AvatarClone
    if not char or not tool or not tool:IsA("Tool") or not tool:IsDescendantOf(char) then return end
    if state.ToolVisualConnections[tool] then return end

    local bundle = {}
    state.ToolVisualConnections[tool] = bundle

    runtime.AvatarCloneReleaseToolVisuals(char, tool)

    bundle.DescendantAdded = tool.DescendantAdded:Connect(function(object)
        if state.BaseCharacter ~= char or not state.Active then return end
        if state.BaseVisualCache[object] then
            runtime.AvatarCloneRestoreCachedVisual(object, state.BaseVisualCache)
        end
    end)

    bundle.AncestryChanged = tool.AncestryChanged:Connect(function()
        if tool:IsDescendantOf(char) then return end
        local current = state.ToolVisualConnections[tool]
        if current ~= bundle then return end
        state.ToolVisualConnections[tool] = nil
        if bundle.DescendantAdded then
            pcall(function() bundle.DescendantAdded:Disconnect() end)
        end
        if bundle.AncestryChanged then
            pcall(function() bundle.AncestryChanged:Disconnect() end)
        end
    end)
end

function runtime.AvatarCloneCacheAndHideObject(object, cache)
    if not object or not object.Parent then return end

    if runtime.AvatarCloneIsToolVisual(object, player.Character) then
        runtime.AvatarCloneRestoreCachedVisual(object, cache)
        return
    end

    if cache[object] then
        if object:IsA("BasePart") then
            if runtime.Appearance.Enabled.Korblox and object.Name == "RightUpperLeg"
                and object.Parent == player.Character then
                return
            end
            object.LocalTransparencyModifier = 1
        elseif object:IsA("Decal") or object:IsA("Texture") then
            object.Transparency = 1
        elseif object:IsA("ParticleEmitter") or object:IsA("Trail") or object:IsA("Beam")
            or object:IsA("Smoke") or object:IsA("Fire") or object:IsA("Sparkles") then
            object.Enabled = false
        end
        return
    end

    if object:IsA("BasePart") then
        local originalLTM = object.LocalTransparencyModifier
        local hairOriginal = runtime.Appearance.HairVisualCache[object]
        if hairOriginal and hairOriginal.LocalTransparencyModifier ~= nil then
            originalLTM = hairOriginal.LocalTransparencyModifier
        end
        cache[object] = {LocalTransparencyModifier = originalLTM}
        runtime.AvatarCloneTrackHiddenObject(object)

        if not (runtime.Appearance.Enabled.Korblox and object.Name == "RightUpperLeg"
            and object.Parent == player.Character) then
            object.LocalTransparencyModifier = 1
        end
    elseif object:IsA("Decal") or object:IsA("Texture") then
        cache[object] = {Transparency = object.Transparency}
        runtime.AvatarCloneTrackHiddenObject(object)
        object.Transparency = 1
    elseif object:IsA("ParticleEmitter") or object:IsA("Trail") or object:IsA("Beam")
        or object:IsA("Smoke") or object:IsA("Fire") or object:IsA("Sparkles") then
        local originalEnabled = object.Enabled
        local hairOriginal = runtime.Appearance.HairVisualCache[object]
        if hairOriginal and hairOriginal.Enabled ~= nil then
            originalEnabled = hairOriginal.Enabled
        end
        cache[object] = {Enabled = originalEnabled}
        runtime.AvatarCloneTrackHiddenObject(object)
        object.Enabled = false
    end
end

function runtime.AvatarCloneHideBase(char)
    char = char or player.Character
    if not char or not char.Parent then return false end

    local state = runtime.Appearance.AvatarClone
    if state.BaseCharacter ~= char then
        runtime.AvatarCloneClearToolVisualGuards()
        state.BaseCharacter = char
        state.BaseVisualCache = setmetatable({}, {__mode = "k"})
        runtime.AvatarCloneResetBaseVisualTracking()
    end

    local cache = state.BaseVisualCache
    local firstHide = next(cache) == nil
    local wasHeadless, wasKorblox, wasHideHair

    if firstHide then
        wasHeadless, wasKorblox, wasHideHair = runtime.AvatarCloneSuspendLocalLayers(char)
    end

    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Tool") then

            runtime.AvatarCloneBindToolVisualGuard(char, child)
        elseif child:IsA("BasePart") and child.Name ~= "HumanoidRootPart" then
            runtime.AvatarCloneCacheAndHideObject(child, cache)
            for _, visual in ipairs(child:GetDescendants()) do
                if visual:IsA("Decal") or visual:IsA("Texture") then
                    runtime.AvatarCloneCacheAndHideObject(visual, cache)
                end
            end
        elseif child:IsA("Accoutrement") and child:GetAttribute("iLunXAppearanceKey") == nil then
            for _, visual in ipairs(child:GetDescendants()) do
                runtime.AvatarCloneCacheAndHideObject(visual, cache)
            end
        end
    end

    if firstHide then
        runtime.AvatarCloneResumeLocalLayers(char, wasHeadless, wasKorblox, wasHideHair)
    end

    return true
end

function runtime.AvatarCloneRestoreBase(char)
    local state = runtime.Appearance.AvatarClone
    char = char or state.BaseCharacter or player.Character
    if not char then
        runtime.AvatarCloneClearToolVisualGuards()
        state.BaseCharacter = nil
        state.BaseVisualCache = setmetatable({}, {__mode = "k"})
        runtime.AvatarCloneResetBaseVisualTracking()
        return
    end

    local wasHeadless, wasKorblox, wasHideHair = runtime.AvatarCloneSuspendLocalLayers(char)

    for object, original in pairs(state.BaseVisualCache) do
        if object and object.Parent then
            pcall(function()
                if original.LocalTransparencyModifier ~= nil and object:IsA("BasePart") then
                    object.LocalTransparencyModifier = original.LocalTransparencyModifier
                end
                if original.Transparency ~= nil and (object:IsA("Decal") or object:IsA("Texture")) then
                    object.Transparency = original.Transparency
                end
                if original.Enabled ~= nil then
                    object.Enabled = original.Enabled
                end
            end)
        end
    end

    runtime.AvatarCloneClearToolVisualGuards()
    state.BaseCharacter = nil
    state.BaseVisualCache = setmetatable({}, {__mode = "k"})
    runtime.AvatarCloneResetBaseVisualTracking()
    runtime.AvatarCloneResumeLocalLayers(char, wasHeadless, wasKorblox, wasHideHair)
end

function runtime.AvatarCloneDisconnectAnimation()
    local state = runtime.Appearance.AvatarClone
    runtime.AvatarCloneClearToolVisualGuards()
    if state.NativeTransparencyBindName then
        pcall(function() RunService:UnbindFromRenderStep(state.NativeTransparencyBindName) end)
        state.NativeTransparencyBindName = nil
    end
    table.clear(state.NativeTransparencyPairs)
    table.clear(state.NativeEffectPairs)
    state.NativeCameraTransparencyLast = nil
    state.NativeAppliedTransparencyLast = nil
    state.NativeLayerSignatureLast = nil
    if state.AnimationConnection then
        pcall(function() state.AnimationConnection:Disconnect() end)
        state.AnimationConnection = nil
    end
    if state.RenderAnimationConnection then
        pcall(function() state.RenderAnimationConnection:Disconnect() end)
        state.RenderAnimationConnection = nil
    end
    if state.BaseDescendantConnection then
        pcall(function() state.BaseDescendantConnection:Disconnect() end)
        state.BaseDescendantConnection = nil
    end
    if state.RespawnMaskConnection then
        pcall(function() state.RespawnMaskConnection:Disconnect() end)
        state.RespawnMaskConnection = nil
    end
    if state.RespawnMaskDescendantConnection then
        pcall(function() state.RespawnMaskDescendantConnection:Disconnect() end)
        state.RespawnMaskDescendantConnection = nil
    end
    if state.RespawnMaskTopologyConnection then
        pcall(function() state.RespawnMaskTopologyConnection:Disconnect() end)
        state.RespawnMaskTopologyConnection = nil
    end
    state.RespawnMaskPending = false
    state.RespawnMaskGeneration = nil
    if state.DriverRig then
        pcall(function() state.DriverRig:Destroy() end)
        state.DriverRig = nil
    end
    table.clear(state.MotorPairs)
end

function runtime.AvatarCloneDestroyOverlay(restoreBase)
    local state = runtime.Appearance.AvatarClone
    runtime.AvatarCloneDisconnectAnimation()

    if state.Overlay then
        runtime.DestroyFaceClassicVisual(state.Overlay)
        runtime.Appearance.OriginalFace[state.Overlay] = nil
        runtime.Appearance.OriginalHead[state.Overlay] = nil
        runtime.Appearance.HeadBaseVisuals[state.Overlay] = nil
        pcall(function() state.Overlay:Destroy() end)
        state.Overlay = nil
    end
    state.OverlayVisualCache = setmetatable({}, {__mode = "k"})

    if restoreBase then
        runtime.AvatarCloneRestoreBase(player.Character)
    end
end

function runtime.AvatarCloneEnforceBaseHiddenParts(char)
    local state = runtime.Appearance.AvatarClone
    char = char or state.BaseCharacter or player.Character
    if not char or state.BaseCharacter ~= char then return end

    local cache = state.BaseVisualCache
    local korblox = runtime.Appearance.Enabled.Korblox == true
    local parts = state.BaseHiddenParts
    local i = 1
    while i <= #parts do
        local object = parts[i]
        if not object or not object.Parent or not cache[object] then
            runtime.AvatarCloneUntrackHiddenObject(object)
        elseif runtime.AvatarCloneIsToolVisual(object, char) then

            runtime.AvatarCloneRestoreCachedVisual(object, cache)
        else
            if not (korblox and object.Name == "RightUpperLeg" and object.Parent == char)
                and object.LocalTransparencyModifier ~= 1 then
                object.LocalTransparencyModifier = 1
            end
            i += 1
        end
    end
end

function runtime.AvatarCloneEnforceBaseHidden(char)
    local state = runtime.Appearance.AvatarClone
    char = char or state.BaseCharacter or player.Character
    if not char or state.BaseCharacter ~= char then return end

    runtime.AvatarCloneEnforceBaseHiddenParts(char)

    local cache = state.BaseVisualCache
    local textures = state.BaseHiddenTextures
    local i = 1
    while i <= #textures do
        local object = textures[i]
        if not object or not object.Parent or not cache[object] then
            runtime.AvatarCloneUntrackHiddenObject(object)
        elseif runtime.AvatarCloneIsToolVisual(object, char) then
            runtime.AvatarCloneRestoreCachedVisual(object, cache)
        else
            if object.Transparency ~= 1 then object.Transparency = 1 end
            i += 1
        end
    end

    local effects = state.BaseHiddenEffects
    i = 1
    while i <= #effects do
        local object = effects[i]
        if not object or not object.Parent or not cache[object] then
            runtime.AvatarCloneUntrackHiddenObject(object)
        elseif runtime.AvatarCloneIsToolVisual(object, char) then
            runtime.AvatarCloneRestoreCachedVisual(object, cache)
        else
            if object.Enabled then object.Enabled = false end
            i += 1
        end
    end
end

function runtime.AvatarCloneBuildMotorSync(char, overlay)
    local state = runtime.Appearance.AvatarClone

    local baseHumanoid = char:FindFirstChildOfClass("Humanoid")
    local baseRoot = char:FindFirstChild("HumanoidRootPart")
    local overlayRoot = overlay:FindFirstChild("HumanoidRootPart")
    if not baseHumanoid or not baseRoot or not overlayRoot then
        return false, "El personaje todavía no tiene un rig válido"
    end

    local driverRig
    local driverError

    local okDescription, baseDescription = pcall(function()
        return baseHumanoid:GetAppliedDescription()
    end)

    if okDescription and baseDescription then
        driverRig, driverError =
            runtime.CreateAvatarCloneTemplateFromDescription(
                baseDescription,
                baseHumanoid.RigType
            )
        pcall(function() baseDescription:Destroy() end)
    end

    if not driverRig then
        driverRig, driverError =
            runtime.CreateAvatarCloneTemplateFromUserId(
                player.UserId,
                baseHumanoid.RigType
            )
    end

    if not driverRig then
        return false, "No se pudo construir el rig de referencia: " .. tostring(driverError or "desconocido")
    end

    runtime.AvatarCloneDisconnectAnimation()
    state.Overlay = overlay
    state.DriverRig = driverRig

    for _, object in ipairs(overlay:GetDescendants()) do
        if object:IsA("BasePart") then
            object.CanCollide = false
            object.CanTouch = false
            object.CanQuery = false
            object.Massless = true
            object.AssemblyLinearVelocity = Vector3.zero
            object.AssemblyAngularVelocity = Vector3.zero

            if object.Parent == overlay then
                object.Anchored = true
            elseif object.Parent and object.Parent:IsA("Accoutrement") then

                object.Anchored = false
            end
        elseif object:IsA("Motor6D") then

            pcall(function() object.Enabled = false end)
        end
    end

    overlayRoot.Anchored = true
    overlayRoot.Transparency = 1
    overlayRoot.LocalTransparencyModifier = 1

    local baseParts = {}
    local cloneParts = {}
    local driverParts = {}

    for _, object in ipairs(char:GetChildren()) do
        if object:IsA("BasePart") then baseParts[object.Name] = object end
    end
    for _, object in ipairs(overlay:GetChildren()) do
        if object:IsA("BasePart") then cloneParts[object.Name] = object end
    end
    for _, object in ipairs(driverRig:GetChildren()) do
        if object:IsA("BasePart") then driverParts[object.Name] = object end
    end

    local r15Joints = {
        {"HumanoidRootPart", "LowerTorso"},
        {"LowerTorso", "UpperTorso"},
        {"UpperTorso", "Head"},

        {"UpperTorso", "LeftUpperArm"},
        {"LeftUpperArm", "LeftLowerArm"},
        {"LeftLowerArm", "LeftHand"},

        {"UpperTorso", "RightUpperArm"},
        {"RightUpperArm", "RightLowerArm"},
        {"RightLowerArm", "RightHand"},

        {"LowerTorso", "LeftUpperLeg"},
        {"LeftUpperLeg", "LeftLowerLeg"},
        {"LeftLowerLeg", "LeftFoot"},

        {"LowerTorso", "RightUpperLeg"},
        {"RightUpperLeg", "RightLowerLeg"},
        {"RightLowerLeg", "RightFoot"},
    }

    local r6Joints = {
        {"HumanoidRootPart", "Torso"},
        {"Torso", "Head"},
        {"Torso", "Left Arm"},
        {"Torso", "Right Arm"},
        {"Torso", "Left Leg"},
        {"Torso", "Right Leg"},
    }

    local jointSpecs =
        baseHumanoid.RigType == Enum.HumanoidRigType.R15
        and r15Joints
        or r6Joints

    local function findSharedRigAttachment(part0, part1)
        if not part0 or not part1 then return nil, nil end

        for _, object in ipairs(part0:GetChildren()) do
            if object:IsA("Attachment")
                and string.find(object.Name, "RigAttachment", 1, true) then

                local other = part1:FindFirstChild(object.Name)
                if other and other:IsA("Attachment") then
                    return object, other
                end
            end
        end

        return nil, nil
    end

    local liveMotorMap = {}
    for _, object in ipairs(char:GetDescendants()) do
        if object:IsA("Motor6D") and object.Part0 and object.Part1 then
            liveMotorMap[object.Part0.Name .. ">" .. object.Part1.Name] = object
        end
    end

    for _, spec in ipairs(jointSpecs) do
        local parentName = spec[1]
        local childName = spec[2]

        local realParent = baseParts[parentName]
        local realChild = baseParts[childName]
        local cloneParent = cloneParts[parentName]
        local cloneChild = cloneParts[childName]
        local driverParent = driverParts[parentName]
        local driverChild = driverParts[childName]
        local liveMotor = liveMotorMap[parentName .. ">" .. childName]
        if liveMotor and (liveMotor.Part0 ~= realParent or liveMotor.Part1 ~= realChild) then
            liveMotor = nil
        end

        if realParent and realChild and cloneParent and cloneChild then

            local cloneA0, cloneA1 =
                findSharedRigAttachment(cloneParent, cloneChild)

            local realA0, realA1 =
                findSharedRigAttachment(realParent, realChild)

            local driverA0, driverA1 =
                findSharedRigAttachment(driverParent, driverChild)

            if cloneA0 and cloneA1
                and ((realA0 and realA1) or (driverA0 and driverA1)) then

                table.insert(state.MotorPairs, {
                    RealParent = realParent,
                    RealChild = realChild,
                    CloneParent = cloneParent,
                    CloneChild = cloneChild,
                    LiveMotor = liveMotor,

                    CloneC0 = cloneA0.CFrame,
                    CloneC1 = cloneA1.CFrame,
                    CloneC1Inverse = cloneA1.CFrame:Inverse(),

                    RealC0 = realA0 and realA0.CFrame or nil,
                    RealC1 = realA1 and realA1.CFrame or nil,

                    DriverC0 = driverA0 and driverA0.CFrame or nil,
                    DriverC0Inverse = driverA0 and driverA0.CFrame:Inverse() or nil,
                    DriverC1 = driverA1 and driverA1.CFrame or nil,
                })
            end
        end
    end

    if #state.MotorPairs == 0 and baseHumanoid.RigType == Enum.HumanoidRigType.R6 then
        for _, spec in ipairs(r6Joints) do
            local realParent = baseParts[spec[1]]
            local realChild = baseParts[spec[2]]
            local cloneParent = cloneParts[spec[1]]
            local cloneChild = cloneParts[spec[2]]

            if realParent and realChild and cloneParent and cloneChild then
                table.insert(state.MotorPairs, {
                    RealParent = realParent,
                    RealChild = realChild,
                    CloneParent = cloneParent,
                    CloneChild = cloneChild,
                    R6Fallback = true,
                    InitialRealRelative = realParent.CFrame:ToObjectSpace(realChild.CFrame),
                    InitialRealRelativeInverse = realParent.CFrame:ToObjectSpace(realChild.CFrame):Inverse(),
                    InitialCloneRelative = cloneParent.CFrame:ToObjectSpace(cloneChild.CFrame),
                })
            end
        end
    end

    if #state.MotorPairs == 0 then
        return false, "No se pudieron encontrar pivotes de cuerpo compatibles"
    end

    local function syncPose()
        if not runtime.Alive
            or state.Overlay ~= overlay
            or not overlay.Parent
            or player.Character ~= char then
            return
        end

        overlayRoot.CFrame = baseRoot.CFrame

        pcall(function()
            for i = 1, #state.MotorPairs do
                local pair = state.MotorPairs[i]
                local realParent = pair.RealParent
                local realChild = pair.RealChild
                local cloneParent = pair.CloneParent
                local cloneChild = pair.CloneChild

                if realParent and realParent.Parent
                    and realChild and realChild.Parent
                    and cloneParent and cloneParent.Parent
                    and cloneChild and cloneChild.Parent then

                    if pair.R6Fallback then
                        local currentRelative = realParent.CFrame:ToObjectSpace(realChild.CFrame)
                        local delta = pair.InitialRealRelativeInverse * currentRelative
                        cloneChild.CFrame = cloneParent.CFrame * pair.InitialCloneRelative * delta
                    else
                        local poseTransform
                        local liveMotor = pair.LiveMotor
                        if liveMotor and liveMotor.Parent
                            and liveMotor.Part0 == realParent and liveMotor.Part1 == realChild then
                            poseTransform = liveMotor.Transform
                        elseif pair.RealC0 and pair.RealC1 then
                            local parentJointWorld = realParent.CFrame * pair.RealC0
                            local childJointWorld = realChild.CFrame * pair.RealC1
                            poseTransform = parentJointWorld:ToObjectSpace(childJointWorld)
                        else
                            poseTransform = pair.DriverC0Inverse
                                * realParent.CFrame:Inverse()
                                * realChild.CFrame
                                * pair.DriverC1
                        end

                        cloneChild.CFrame = cloneParent.CFrame
                            * pair.CloneC0
                            * poseTransform
                            * pair.CloneC1Inverse
                    end
                end
            end
        end)

        if runtime.Appearance.FaceClassicVisuals[overlay] then
            runtime.SyncFaceClassicVisual(overlay)
        end

        if not state.NativeTransparencyBindName then
            runtime.AvatarCloneEnforceBaseHidden(char)
        end

    end

    state.AnimationConnection = RunService.RenderStepped:Connect(syncPose)

    state.BaseDescendantConnection = char.DescendantAdded:Connect(function(object)
        if state.Overlay ~= overlay or not state.Active then return end
        if object:IsDescendantOf(overlay) then return end

        local weaponRoot = runtime.AvatarCloneFindWeaponRoot(object, char)
        if weaponRoot then
            local tool = weaponRoot:IsA("Tool") and weaponRoot or weaponRoot:FindFirstAncestorWhichIsA("Tool")
            if tool then runtime.AvatarCloneBindToolVisualGuard(char, tool) end
            runtime.AvatarCloneReleaseToolVisuals(char, weaponRoot)
            return
        end

        local acc = object:FindFirstAncestorWhichIsA("Accoutrement")
        if acc and acc:GetAttribute("iLunXAppearanceKey") ~= nil then
            return
        end

        if object:IsA("BasePart") then
            if object.Name ~= "HumanoidRootPart" then
                runtime.AvatarCloneCacheAndHideObject(object, state.BaseVisualCache)
            end
        elseif object:IsA("Decal") or object:IsA("Texture")
            or object:IsA("ParticleEmitter") or object:IsA("Trail") or object:IsA("Beam")
            or object:IsA("Smoke") or object:IsA("Fire") or object:IsA("Sparkles") then
            runtime.AvatarCloneCacheAndHideObject(object, state.BaseVisualCache)
        end
    end)

    syncPose()
    return true
end

function runtime.GetAvatarCloneVisualContainer()
    local state = runtime.Appearance.AvatarClone
    local folder = state.VisualContainer

    if folder and folder.Parent then
        return folder
    end

    folder = workspace:FindFirstChild("iLunX_LocalAvatarClones")
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = "iLunX_LocalAvatarClones"
        folder.Parent = workspace
    end

    state.VisualContainer = folder
    return folder
end

function runtime.ApplyAvatarCloneTemplate(char, template)
    char = char or player.Character
    if not char or not char.Parent or not template then
        return false, "Personaje o avatar no disponible"
    end

    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local ownRoot = char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not ownRoot then
        return false, "El personaje todavía no terminó de cargar"
    end

    local state = runtime.Appearance.AvatarClone
    if state.Applying then return false, "Ya se está aplicando otro avatar" end
    state.Applying = true

    local previousOverlay = state.Overlay
    local handoffVisualCache = nil

    local ok, result = pcall(function()
        local overlay = template:Clone()
        overlay.Name = "iLunX_AvatarCloneOverlay"
        overlay:SetAttribute("iLunXAvatarClone", true)
        runtime.PrepareAvatarCloneTemplate(overlay)

        local sourceRoot = overlay:FindFirstChild("HumanoidRootPart")
        local sourceHumanoid = overlay:FindFirstChildOfClass("Humanoid")
        if not sourceRoot or not sourceHumanoid then
            overlay:Destroy()
            error("El avatar generado no tiene un rig válido")
        end
        if sourceHumanoid.RigType ~= humanoid.RigType then
            overlay:Destroy()
            error("El rig del avatar no coincide con el personaje actual")
        end

        pcall(function()
            sourceHumanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            sourceHumanoid.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
            sourceHumanoid.NameDisplayDistance = 0
            sourceHumanoid.HealthDisplayDistance = 0
            sourceHumanoid.AutoRotate = false
            sourceHumanoid.PlatformStand = true
            sourceHumanoid.BreakJointsOnDeath = false
            sourceHumanoid.RequiresNeck = false
        end)

        local sourceAnimator = sourceHumanoid:FindFirstChildOfClass("Animator")
        if sourceAnimator then
            pcall(function() sourceAnimator:Destroy() end)
        end

        for _, object in ipairs(overlay:GetDescendants()) do
            if object:IsA("BasePart") then
                object.Anchored = true
                object.CanCollide = false
                object.CanTouch = false
                object.CanQuery = false
                object.Massless = true
                object.AssemblyLinearVelocity = Vector3.zero
                object.AssemblyAngularVelocity = Vector3.zero
            end
        end

        if previousOverlay and previousOverlay.Parent then
            handoffVisualCache = setmetatable({}, {__mode = "k"})
            for _, object in ipairs(overlay:GetDescendants()) do
                if object:IsA("BasePart") then
                    handoffVisualCache[object] = {
                        LocalTransparencyModifier = object.LocalTransparencyModifier,
                    }
                    object.LocalTransparencyModifier = 1
                elseif object:IsA("Decal") or object:IsA("Texture") then
                    handoffVisualCache[object] = {Transparency = object.Transparency}
                    object.Transparency = 1
                elseif object:IsA("ParticleEmitter") or object:IsA("Trail") or object:IsA("Beam")
                    or object:IsA("Smoke") or object:IsA("Fire") or object:IsA("Sparkles") then
                    handoffVisualCache[object] = {Enabled = object.Enabled}
                    object.Enabled = false
                end
            end
        end

        overlay.Parent = runtime.GetAvatarCloneVisualContainer()
        overlay:PivotTo(ownRoot.CFrame)

        RunService.Heartbeat:Wait()
        if not overlay.Parent then
            error("El avatar visual desapareció durante la carga")
        end

        if not handoffVisualCache then
            runtime.AvatarCloneCaptureOverlayVisuals(overlay)
        end

        local synced, syncError = runtime.AvatarCloneBuildMotorSync(char, overlay)
        if not synced then
            overlay:Destroy()
            if state.Overlay == overlay then state.Overlay = nil end
            error(syncError or "No se pudo sincronizar la pose del avatar")
        end

        if handoffVisualCache then
            state.OverlayVisualCache = handoffVisualCache
            runtime.AvatarCloneRestoreOverlayVisuals()
        end

        if previousOverlay and previousOverlay ~= overlay and previousOverlay.Parent then
            runtime.DestroyFaceClassicVisual(previousOverlay)
            runtime.Appearance.OriginalFace[previousOverlay] = nil
            runtime.Appearance.OriginalHead[previousOverlay] = nil
            runtime.Appearance.HeadBaseVisuals[previousOverlay] = nil
            pcall(function() previousOverlay:Destroy() end)
        end

        runtime.ReapplyAppearanceLayers(char)
        runtime.AvatarCloneHideBase(char)
        runtime.UpdateAvatarCloneLayers()
        runtime.AvatarCloneBindNativeTransparency(char, overlay)
    end)

    state.Applying = false

    if not ok then
        runtime.AvatarCloneDestroyOverlay(false)
        if previousOverlay and previousOverlay.Parent then
            runtime.DestroyFaceClassicVisual(previousOverlay)
            runtime.Appearance.OriginalFace[previousOverlay] = nil
            runtime.Appearance.OriginalHead[previousOverlay] = nil
            runtime.Appearance.HeadBaseVisuals[previousOverlay] = nil
            pcall(function() previousOverlay:Destroy() end)
        end

        runtime.AvatarCloneRestoreBase(char)
        runtime.ReapplyAppearanceLayers(char)

        return false, tostring(result)
    end

    return true
end

function runtime.SetClonedAvatarTemplate(template, userId, targetName, silent, outfitId)
    if not template then return false, "No se recibió un avatar válido" end

    local state = runtime.Appearance.AvatarClone
    if state.Applying then return false, "Ya se está aplicando otro avatar" end

    local previousTemplate = state.Template
    local previousUserId = state.TargetUserId
    local previousName = state.TargetName
    local previousOutfitId = state.TargetOutfitId
    local previousActive = state.Active == true

    local ok, err = runtime.ApplyAvatarCloneTemplate(player.Character, template)
    if not ok then
        if previousTemplate then
            pcall(function() runtime.ApplyAvatarCloneTemplate(player.Character, previousTemplate) end)
        end
        pcall(function() template:Destroy() end)
        state.Template = previousTemplate
        state.TargetUserId = previousUserId
        state.TargetName = previousName
        state.TargetOutfitId = previousOutfitId
        state.Active = previousActive
        return false, err
    end

    state.Template = template
    state.TargetUserId = tonumber(userId)
    state.TargetName = tostring(targetName or userId or "Avatar")
    state.TargetOutfitId = tonumber(outfitId)
    state.Active = true

    if previousTemplate and previousTemplate ~= template then
        pcall(function() previousTemplate:Destroy() end)
    end

    if runtime.MarkAvatarThumbnailSpoofDirty then
        runtime.MarkAvatarThumbnailSpoofDirty()
    end

    if not silent then
        showBottomMessage("Avatar clonado: " .. state.TargetName)
    end
    return true
end

function runtime.CloneAvatarFromPlayer(targetPlayer, silent)
    if not targetPlayer or not targetPlayer:IsA("Player") then
        return false, "Jugador no válido"
    end

    local char = player.Character
    local ownHumanoid = char and char:FindFirstChildOfClass("Humanoid")
    if not ownHumanoid then return false, "Tu personaje todavía no cargó" end

    local template
    local targetHumanoid = targetPlayer.Character and targetPlayer.Character:FindFirstChildOfClass("Humanoid")
    if targetHumanoid then
        local ok, description = pcall(function()
            return targetHumanoid:GetAppliedDescription()
        end)
        if ok and description then
            template = select(1, runtime.CreateAvatarCloneTemplateFromDescription(description, ownHumanoid.RigType))
            pcall(function() description:Destroy() end)
        end
    end

    if not template then
        local model, err = runtime.CreateAvatarCloneTemplateFromUserId(targetPlayer.UserId, ownHumanoid.RigType)
        if not model then return false, err end
        template = model
    end

    return runtime.SetClonedAvatarTemplate(
        template,
        targetPlayer.UserId,
        targetPlayer.Name,
        silent
    )
end

function runtime.CloneAvatarByUsername(username, silent)
    username = tostring(username or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if username == "" then return false, "Escribe un username" end

    local okId, userId = pcall(function()
        return Players:GetUserIdFromNameAsync(username)
    end)
    if not okId or not userId then
        return false, "No se encontró ese usuario"
    end

    local char = player.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false, "Tu personaje todavía no cargó" end

    local template, err = runtime.CreateAvatarCloneTemplateFromUserId(userId, humanoid.RigType)
    if not template then return false, err end

    local resolvedName = username
    pcall(function()
        resolvedName = Players:GetNameFromUserIdAsync(userId)
    end)

    return runtime.SetClonedAvatarTemplate(template, userId, resolvedName, silent)
end

function runtime.RestoreAvatarClone(silent)
    local state = runtime.Appearance.AvatarClone
    if state.Applying then return false, "La apariencia todavía se está aplicando" end

    state.Applying = true
    runtime.AvatarCloneDestroyOverlay(true)

    if state.Template then
        pcall(function() state.Template:Destroy() end)
        state.Template = nil
    end

    state.Active = false
    state.TargetUserId = nil
    state.TargetName = nil
    state.TargetOutfitId = nil
    state.Applying = false

    runtime.ReapplyAppearanceLayers(player.Character)
    if runtime.MarkAvatarThumbnailSpoofDirty then
        runtime.MarkAvatarThumbnailSpoofDirty()
    end

    if not silent then
        showBottomMessage("Tu avatar original fue restaurado.")
    end
    return true
end



-- XERO DUELS: mascara de respawn + reset original, SIN REIMPLEMENTAR.
function runtime.BeginAvatarCloneRespawnMask(char, generation)
    local state = runtime.Appearance.AvatarClone
    if not state or not state.Active or not state.KeepOnRespawn or not state.Template then
        return false
    end
    if not char or not char.Parent then return false end

    if state.RespawnMaskGeneration == generation
        and (state.RespawnMaskPending or state.RespawnMaskConnection) then
        return true
    end

    if state.RespawnMaskConnection then
        pcall(function() state.RespawnMaskConnection:Disconnect() end)
        state.RespawnMaskConnection = nil
    end
    if state.RespawnMaskDescendantConnection then
        pcall(function() state.RespawnMaskDescendantConnection:Disconnect() end)
        state.RespawnMaskDescendantConnection = nil
    end
    if state.RespawnMaskTopologyConnection then
        pcall(function() state.RespawnMaskTopologyConnection:Disconnect() end)
        state.RespawnMaskTopologyConnection = nil
    end

    state.RespawnMaskGeneration = generation
    state.RespawnMaskPending = true

    task.spawn(function()
        local function valid()
            return runtime.Alive
                and char
                and char.Parent
                and player.Character == char
                and state.Active
                and state.KeepOnRespawn
                and state.Template
                and state.RespawnMaskGeneration == generation
                and (not generation or generation == runtime.Appearance.RespawnGeneration)
        end

        if not valid() then
            if state.RespawnMaskGeneration == generation then
                state.RespawnMaskPending = false
            end
            return
        end

        local root = char:FindFirstChild("HumanoidRootPart")
            or char:WaitForChild("HumanoidRootPart", 1.5)
        local humanoid = char:FindFirstChildOfClass("Humanoid")
            or char:WaitForChild("Humanoid", 1.5)

        if not valid() or not root or not root:IsA("BasePart") or not humanoid then
            if state.RespawnMaskGeneration == generation then
                state.RespawnMaskPending = false
            end
            return
        end

        local overlay = state.Overlay
        if not overlay or not overlay.Parent then
            overlay = state.Template:Clone()
            overlay.Name = "iLunX_AvatarCloneOverlay"
            overlay:SetAttribute("iLunXAvatarClone", true)
            runtime.PrepareAvatarCloneTemplate(overlay)

            for _, object in ipairs(overlay:GetDescendants()) do
                if object:IsA("BasePart") then
                    local accessory = object:FindFirstAncestorWhichIsA("Accoutrement")
                    object.Anchored = accessory == nil
                    object.CanCollide = false
                    object.CanTouch = false
                    object.CanQuery = false
                    object.Massless = true
                    object.AssemblyLinearVelocity = Vector3.zero
                    object.AssemblyAngularVelocity = Vector3.zero
                elseif object:IsA("Motor6D") then
                    pcall(function() object.Enabled = false end)
                end
            end

            overlay.Parent = runtime.GetAvatarCloneVisualContainer()
            state.Overlay = overlay
            runtime.AvatarCloneCaptureOverlayVisuals(overlay)
        else
            for _, object in ipairs(overlay:GetDescendants()) do
                if object:IsA("BasePart") then
                    local accessory = object:FindFirstAncestorWhichIsA("Accoutrement")
                    object.Anchored = accessory == nil
                    object.CanCollide = false
                    object.CanTouch = false
                    object.CanQuery = false
                    object.Massless = true
                    object.AssemblyLinearVelocity = Vector3.zero
                    object.AssemblyAngularVelocity = Vector3.zero
                elseif object:IsA("Motor6D") then
                    pcall(function() object.Enabled = false end)
                end
            end
        end

        if not valid() or state.Overlay ~= overlay or not overlay.Parent then
            return
        end

        local overlayRoot = overlay:FindFirstChild("HumanoidRootPart")
        if not overlayRoot or not overlayRoot:IsA("BasePart") then
            if state.RespawnMaskGeneration == generation then
                state.RespawnMaskPending = false
            end
            return
        end
        overlayRoot.Anchored = true
        overlayRoot.Transparency = 1
        overlayRoot.LocalTransparencyModifier = 1

        pcall(function() overlay:PivotTo(root.CFrame) end)

        local jointSpecs
        if humanoid.RigType == Enum.HumanoidRigType.R15 then
            jointSpecs = {
                {"HumanoidRootPart", "LowerTorso"},
                {"LowerTorso", "UpperTorso"},
                {"UpperTorso", "Head"},

                {"UpperTorso", "LeftUpperArm"},
                {"LeftUpperArm", "LeftLowerArm"},
                {"LeftLowerArm", "LeftHand"},

                {"UpperTorso", "RightUpperArm"},
                {"RightUpperArm", "RightLowerArm"},
                {"RightLowerArm", "RightHand"},

                {"LowerTorso", "LeftUpperLeg"},
                {"LeftUpperLeg", "LeftLowerLeg"},
                {"LeftLowerLeg", "LeftFoot"},

                {"LowerTorso", "RightUpperLeg"},
                {"RightUpperLeg", "RightLowerLeg"},
                {"RightLowerLeg", "RightFoot"},
            }
        else
            jointSpecs = {
                {"HumanoidRootPart", "Torso"},
                {"Torso", "Head"},
                {"Torso", "Left Arm"},
                {"Torso", "Right Arm"},
                {"Torso", "Left Leg"},
                {"Torso", "Right Leg"},
            }
        end

        local function findSharedRigAttachment(part0, part1)
            if not part0 or not part1 then return nil, nil end
            for _, object in ipairs(part0:GetChildren()) do
                if object:IsA("Attachment")
                    and string.find(object.Name, "RigAttachment", 1, true) then

                    local other = part1:FindFirstChild(object.Name)
                    if other and other:IsA("Attachment") then
                        return object, other
                    end
                end
            end
            return nil, nil
        end

        local cloneMotorIndex = {}
        for _, object in ipairs(overlay:GetDescendants()) do
            if object:IsA("Motor6D") and object.Part0 and object.Part1 then
                local row = cloneMotorIndex[object.Part0.Name]
                if not row then
                    row = {}
                    cloneMotorIndex[object.Part0.Name] = row
                end
                row[object.Part1.Name] = object
            end
        end

        local cloneJointData = {}
        for i = 1, #jointSpecs do
            local parentName, childName = jointSpecs[i][1], jointSpecs[i][2]
            local cloneParent = overlay:FindFirstChild(parentName)
            local cloneChild = overlay:FindFirstChild(childName)

            if cloneParent and cloneParent:IsA("BasePart")
                and cloneChild and cloneChild:IsA("BasePart") then

                local motorRow = cloneMotorIndex[parentName]
                local cloneMotor = motorRow and motorRow[childName] or nil
                local cloneC0, cloneC1

                if cloneMotor then
                    cloneC0 = cloneMotor.C0
                    cloneC1 = cloneMotor.C1
                else
                    local a0, a1 = findSharedRigAttachment(cloneParent, cloneChild)
                    if a0 and a1 then
                        cloneC0 = a0.CFrame
                        cloneC1 = a1.CFrame
                    end
                end

                if cloneC0 and cloneC1 then
                    cloneJointData[i] = {
                        ParentName = parentName,
                        ChildName = childName,
                        CloneParent = cloneParent,
                        CloneChild = cloneChild,
                        CloneC0 = cloneC0,
                        CloneC1 = cloneC1,
                        CloneC1Inverse = cloneC1:Inverse(),
                    }
                end
            end
        end

        runtime.AvatarCloneHideBase(char)
        runtime.UpdateAvatarCloneLayers()
        runtime.AvatarCloneBindNativeTransparency(char, overlay)

        local bodyPartNames = {}
        for i = 1, #jointSpecs do
            bodyPartNames[jointSpecs[i][1]] = true
            bodyPartNames[jointSpecs[i][2]] = true
        end

        local posePairs = {}
        local poseCacheDirty = true

        local function isPoseTopologyObject(object)
            if not object then return false end
            if object:IsA("Motor6D") then return true end
            if object:IsA("BasePart") then
                return bodyPartNames[object.Name] == true
            end
            if object:IsA("Attachment")
                and string.find(object.Name, "RigAttachment", 1, true) then
                local parentPart = object.Parent
                return parentPart and parentPart:IsA("BasePart")
                    and bodyPartNames[parentPart.Name] == true
            end
            return false
        end

        local function rebuildRespawnPoseCache()
            if not valid() or state.Overlay ~= overlay or not overlay.Parent then
                return false
            end

            local partsByName = {}
            for _, object in ipairs(char:GetChildren()) do
                if object:IsA("BasePart") and bodyPartNames[object.Name] then
                    partsByName[object.Name] = object
                end
            end

            local liveMotorMap = {}
            for _, object in ipairs(char:GetDescendants()) do
                if object:IsA("Motor6D") and object.Part0 and object.Part1 then
                    liveMotorMap[object.Part0.Name .. ">" .. object.Part1.Name] = object
                end
            end

            local rebuilt = {}
            for i = 1, #jointSpecs do
                local data = cloneJointData[i]
                if data then
                    local realParent = partsByName[data.ParentName]
                    local realChild = partsByName[data.ChildName]
                    local liveMotor = liveMotorMap[data.ParentName .. ">" .. data.ChildName]

                    if liveMotor
                        and (liveMotor.Part0 ~= realParent or liveMotor.Part1 ~= realChild) then
                        liveMotor = nil
                    end

                    if realParent and realChild
                        and data.CloneParent and data.CloneParent.Parent
                        and data.CloneChild and data.CloneChild.Parent then

                        local realC0, realC1
                        if not liveMotor then
                            local realA0, realA1 = findSharedRigAttachment(realParent, realChild)
                            if realA0 and realA1 then
                                realC0 = realA0.CFrame
                                realC1 = realA1.CFrame
                            end
                        end

                        rebuilt[#rebuilt + 1] = {
                            Data = data,
                            RealParent = realParent,
                            RealChild = realChild,
                            LiveMotor = liveMotor,
                            RealC0 = realC0,
                            RealC1 = realC1,
                        }
                    end
                end
            end

            posePairs = rebuilt
            root = partsByName.HumanoidRootPart or root
            poseCacheDirty = false
            return true
        end

        local function hideNewVisual(object)
            if not valid() or state.Overlay ~= overlay then return end
            if object:IsDescendantOf(overlay) then return end

            if isPoseTopologyObject(object) then
                poseCacheDirty = true
            end

            local weaponRoot = runtime.AvatarCloneFindWeaponRoot(object, char)
            if weaponRoot then
                local tool = weaponRoot:IsA("Tool") and weaponRoot or weaponRoot:FindFirstAncestorWhichIsA("Tool")
                if tool then runtime.AvatarCloneBindToolVisualGuard(char, tool) end
                runtime.AvatarCloneReleaseToolVisuals(char, weaponRoot)
                return
            end

            local acc = object:FindFirstAncestorWhichIsA("Accoutrement")
            if acc and acc:GetAttribute("iLunXAppearanceKey") ~= nil then
                return
            end

            if object:IsA("BasePart") then
                if object.Name ~= "HumanoidRootPart" then
                    runtime.AvatarCloneCacheAndHideObject(object, state.BaseVisualCache)
                end
            elseif object:IsA("Decal") or object:IsA("Texture")
                or object:IsA("ParticleEmitter") or object:IsA("Trail") or object:IsA("Beam")
                or object:IsA("Smoke") or object:IsA("Fire") or object:IsA("Sparkles") then
                runtime.AvatarCloneCacheAndHideObject(object, state.BaseVisualCache)
            end
        end

        state.RespawnMaskDescendantConnection = char.DescendantAdded:Connect(hideNewVisual)
        state.RespawnMaskTopologyConnection = char.DescendantRemoving:Connect(function(object)
            if isPoseTopologyObject(object) then
                poseCacheDirty = true
            end
        end)

        rebuildRespawnPoseCache()
        local poseSafetyElapsed = 0

        state.RespawnMaskConnection = RunService.RenderStepped:Connect(function(deltaTime)
            if not valid() or state.Overlay ~= overlay or not overlay.Parent then
                return
            end

            poseSafetyElapsed = poseSafetyElapsed + (tonumber(deltaTime) or 0)
            if not poseCacheDirty and poseSafetyElapsed >= 0.5 then
                poseSafetyElapsed = 0
                for i = 1, #posePairs do
                    local pair = posePairs[i]
                    local motor = pair.LiveMotor
                    if not pair.RealParent.Parent
                        or not pair.RealChild.Parent
                        or not pair.Data.CloneParent.Parent
                        or not pair.Data.CloneChild.Parent
                        or (motor and (not motor.Parent
                            or motor.Part0 ~= pair.RealParent
                            or motor.Part1 ~= pair.RealChild)) then
                        poseCacheDirty = true
                        break
                    end
                end
            end

            if poseCacheDirty then
                rebuildRespawnPoseCache()
                poseSafetyElapsed = 0
            end

            if root and root.Parent then
                overlayRoot.CFrame = root.CFrame
            end

            pcall(function()
                for i = 1, #posePairs do
                    local pair = posePairs[i]
                    local data = pair.Data
                    local realParent = pair.RealParent
                    local realChild = pair.RealChild
                    local cloneParent = data.CloneParent
                    local cloneChild = data.CloneChild

                    local poseTransform
                    local liveMotor = pair.LiveMotor

                    if liveMotor then
                        poseTransform = liveMotor.Transform
                    elseif pair.RealC0 and pair.RealC1 then
                        local parentJointWorld = realParent.CFrame * pair.RealC0
                        local childJointWorld = realChild.CFrame * pair.RealC1
                        poseTransform = parentJointWorld:ToObjectSpace(childJointWorld)
                    end

                    if poseTransform then
                        cloneChild.CFrame = cloneParent.CFrame
                            * data.CloneC0
                            * poseTransform
                            * data.CloneC1Inverse
                    end
                end
            end)

            if runtime.Appearance.FaceClassicVisuals[overlay] then
                runtime.SyncFaceClassicVisual(overlay)
            end

            if not state.NativeTransparencyBindName then
                runtime.AvatarCloneEnforceBaseHidden(char)
            end
        end)

        state.RespawnMaskPending = false
    end)

    return true
end

function runtime.AvatarCloneResetForRespawn(char, generation)
    local state = runtime.Appearance.AvatarClone

    local keepMask = state.Active
        and state.KeepOnRespawn
        and state.Template
        and state.Overlay
        and state.Overlay.Parent

    runtime.AvatarCloneDisconnectAnimation()
    state.BaseCharacter = nil
    state.BaseVisualCache = setmetatable({}, {__mode = "k"})
    runtime.AvatarCloneResetBaseVisualTracking()

    if keepMask then
        runtime.BeginAvatarCloneRespawnMask(char, generation)
    else
        if state.Overlay then
            runtime.DestroyFaceClassicVisual(state.Overlay)
            runtime.Appearance.OriginalFace[state.Overlay] = nil
            runtime.Appearance.OriginalHead[state.Overlay] = nil
            runtime.Appearance.HeadBaseVisuals[state.Overlay] = nil
            pcall(function() state.Overlay:Destroy() end)
            state.Overlay = nil
        end
        state.OverlayVisualCache = setmetatable({}, {__mode = "k"})

        if state.Active and state.KeepOnRespawn and state.Template then
            runtime.BeginAvatarCloneRespawnMask(char, generation)
        end
    end
end


-- XERO DUELS: rig readiness, estabilizacion y guarda de respawn originales.
function runtime.AvatarCloneRigReady(char, humanoid)
    if not char or not humanoid then return false end

    local requiredParts
    if humanoid.RigType == Enum.HumanoidRigType.R15 then
        requiredParts = {
            "HumanoidRootPart", "LowerTorso", "UpperTorso", "Head",
            "LeftUpperArm", "LeftLowerArm", "LeftHand",
            "RightUpperArm", "RightLowerArm", "RightHand",
            "LeftUpperLeg", "LeftLowerLeg", "LeftFoot",
            "RightUpperLeg", "RightLowerLeg", "RightFoot",
        }
    else
        requiredParts = {
            "HumanoidRootPart", "Torso", "Head",
            "Left Arm", "Right Arm", "Left Leg", "Right Leg",
        }
    end

    for i = 1, #requiredParts do
        local part = char:FindFirstChild(requiredParts[i])
        if not part or not part:IsA("BasePart") then
            return false
        end
    end

    return true
end

function runtime.WaitForAvatarCloneRigReady(char, humanoid, generation, maxWait)
    local deadline = os.clock() + (tonumber(maxWait) or 1.5)

    repeat
        if not runtime.Alive
            or not char
            or not char.Parent
            or player.Character ~= char
            or (generation and generation ~= runtime.Appearance.RespawnGeneration) then
            return false
        end

        if runtime.AvatarCloneRigReady(char, humanoid) then
            return true
        end

        RunService.Heartbeat:Wait()
    until os.clock() >= deadline

    return runtime.AvatarCloneRigReady(char, humanoid)
end

function runtime.WaitForAvatarCloneSpawnStable(char, humanoid, generation, maxWait)
    local deadline = os.clock() + (tonumber(maxWait) or 6)
    local startedAt = os.clock()
    local stableFrames = 0
    local lastRoot = nil
    local lastPosition = nil

    while runtime.Alive and os.clock() < deadline do
        if not char or not char.Parent or player.Character ~= char
            or (generation and generation ~= runtime.Appearance.RespawnGeneration) then
            return false
        end

        humanoid = humanoid or char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if not humanoid or not root or humanoid.Health <= 0 then
            stableFrames = 0
            RunService.Heartbeat:Wait()
            continue
        end

        local stateType = humanoid:GetState()
        local blockedState =
            stateType == Enum.HumanoidStateType.Dead
            or stateType == Enum.HumanoidStateType.PlatformStanding
            or stateType == Enum.HumanoidStateType.Physics
            or stateType == Enum.HumanoidStateType.FallingDown

        local elapsed = os.clock() - startedAt
        local airborneSpawnWindow =
            humanoid.FloorMaterial == Enum.Material.Air
            and elapsed < 4.5

        local sameRoot = lastRoot == nil or lastRoot == root
        local teleported = false
        if lastPosition and sameRoot then
            teleported = (root.Position - lastPosition).Magnitude > 10
        end

        if root.Anchored or blockedState or airborneSpawnWindow or not sameRoot or teleported then
            stableFrames = 0
        else
            stableFrames += 1
            if stableFrames >= 6 then
                return true
            end
        end

        lastRoot = root
        lastPosition = root.Position
        RunService.Heartbeat:Wait()
    end

    return false
end

function runtime.AvatarCloneIsBoundToCharacter(char)
    local state = runtime.Appearance.AvatarClone
    if not state or not char or state.BaseCharacter ~= char then return false end
    local overlay = state.Overlay
    if not overlay or not overlay.Parent then return false end

    local connectionAlive = false
    if state.AnimationConnection then
        pcall(function()
            connectionAlive = state.AnimationConnection.Connected == true
        end)
    end
    if not connectionAlive or #state.MotorPairs == 0 then return false end

    for i = 1, #state.MotorPairs do
        local pair = state.MotorPairs[i]
        local realParent = pair.RealParent
        local realChild = pair.RealChild
        local cloneParent = pair.CloneParent
        local cloneChild = pair.CloneChild

        if not realParent or not realChild or not cloneParent or not cloneChild
            or not realParent.Parent or not realChild.Parent
            or not cloneParent.Parent or not cloneChild.Parent
            or realParent ~= char:FindFirstChild(realParent.Name)
            or realChild ~= char:FindFirstChild(realChild.Name)
            or not cloneParent:IsDescendantOf(overlay)
            or not cloneChild:IsDescendantOf(overlay) then
            return false
        end
    end

    return true
end

function runtime.GuardAvatarCloneAfterRespawn(char, generation)

    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        humanoid = char and char:WaitForChild("Humanoid", 1)
    end
    if not humanoid then return end

    if not runtime.WaitForAvatarCloneSpawnStable(char, humanoid, generation, 7) then
        return
    end

    local deadline = os.clock() + 6
    local nextRetryAt = 0

    while runtime.Alive
        and char
        and char.Parent
        and player.Character == char
        and (not generation or generation == runtime.Appearance.RespawnGeneration)
        and os.clock() < deadline do

        local state = runtime.Appearance.AvatarClone
        if not state.Active or not state.KeepOnRespawn or not state.Template then
            return
        end

        if not runtime.AvatarCloneIsBoundToCharacter(char)
            and not state.Applying
            and os.clock() >= nextRetryAt then

            nextRetryAt = os.clock() + 0.45

            if runtime.WaitForAvatarCloneRigReady(char, humanoid, generation, 0.8)
                and runtime.WaitForAvatarCloneSpawnStable(char, humanoid, generation, 1.2) then

                local ok = runtime.ApplyAvatarCloneTemplate(char, state.Template)
                if not ok then
                    runtime.AvatarCloneRestoreBase(char)
                    runtime.ReapplyAppearanceLayers(char)
                end
            end
        end

        task.wait(0.18)
    end
end

function runtime.FastRestoreAppearanceOnRespawn(char, generation)
    if not runtime.Alive or not char or not char.Parent then return end

    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        humanoid = char:WaitForChild("Humanoid", 0.35)
    end
    if not runtime.Alive or not humanoid or not char.Parent then return end
    if generation and generation ~= runtime.Appearance.RespawnGeneration then return end

    if runtime.Appearance.Enabled.Headless or runtime.GetActiveFaceKey() or hasEnabledAppearanceAccessory() then
        if not char:FindFirstChild("Head") then
            char:WaitForChild("Head", 0.35)
        end
    end
    if runtime.Appearance.Enabled.Korblox and humanoid.RigType == Enum.HumanoidRigType.R15 then
        if not char:FindFirstChild("RightUpperLeg") then
            char:WaitForChild("RightUpperLeg", 0.35)
        end
    end

    if not runtime.Alive or not char.Parent then return end
    if generation and generation ~= runtime.Appearance.RespawnGeneration then return end

    runtime.ReapplyAppearanceLayers(char)
    runtime.FastEnsureAppearanceAccessories(char, generation, 0.9)

    local cloneState = runtime.Appearance.AvatarClone
    if cloneState.Active
        and cloneState.KeepOnRespawn
        and cloneState.Template then

        runtime.BeginAvatarCloneRespawnMask(char, generation)

        if not runtime.WaitForAvatarCloneRigReady(char, humanoid, generation, 1.8) then
            return
        end
        if not runtime.WaitForAvatarCloneSpawnStable(char, humanoid, generation, 7) then
            return
        end
    end

    if cloneState.Active
        and cloneState.KeepOnRespawn
        and cloneState.Template
        and not cloneState.Applying then

        local ok = runtime.ApplyAvatarCloneTemplate(char, cloneState.Template)
        if not ok then
            runtime.AvatarCloneRestoreBase(char)
            runtime.ReapplyAppearanceLayers(char)
        end
        if generation and generation ~= runtime.Appearance.RespawnGeneration then return end
    end
end


-- XERO DUELS: serializacion/restauracion original del clon.
function runtime.SerializeAvatarCloneConfig()
    local state = runtime.Appearance and runtime.Appearance.AvatarClone
    if not state then
        return {Active = false, KeepOnRespawn = true}
    end

    return {
        Active = state.Active == true,
        KeepOnRespawn = state.KeepOnRespawn ~= false,
        UserId = tonumber(state.TargetUserId),
        Name = state.TargetName and tostring(state.TargetName) or nil,
        OutfitId = tonumber(state.TargetOutfitId),
    }
end

function runtime.LoadAvatarCloneConfig(data)
    if type(data) ~= "table" then return end

    local state = runtime.Appearance and runtime.Appearance.AvatarClone
    if not state then return end

    state.ConfigLoadSerial = (tonumber(state.ConfigLoadSerial) or 0) + 1
    local serial = state.ConfigLoadSerial
    state.KeepOnRespawn = data.KeepOnRespawn ~= false

    if data.Active ~= true then
        if state.Active and runtime.RestoreAvatarClone then
            pcall(runtime.RestoreAvatarClone, true)
        end
        return
    end

    local savedUserId = tonumber(data.UserId)
    local savedName = tostring(data.Name or "")
    local savedOutfitId = tonumber(data.OutfitId)

    task.spawn(function()

        local deadline = os.clock() + 4
        local char, humanoid

        repeat
            if not runtime.Alive or serial ~= state.ConfigLoadSerial then return end
            char = player.Character
            humanoid = char and char:FindFirstChildOfClass("Humanoid")
            if humanoid then break end
            task.wait(0.08)
        until os.clock() >= deadline

        if not runtime.Alive or serial ~= state.ConfigLoadSerial or not humanoid then
            return
        end

        local template, cloneError

        if savedOutfitId then
            local description
            description, cloneError = runtime.GetHumanoidDescriptionFromOutfitIdSafe(savedOutfitId)
            if description then
                template, cloneError = runtime.CreateAvatarCloneTemplateFromDescription(
                    description,
                    humanoid.RigType
                )
                pcall(function() description:Destroy() end)
            end
        elseif savedUserId then
            template, cloneError = runtime.CreateAvatarCloneTemplateFromUserId(
                savedUserId,
                humanoid.RigType
            )
        elseif savedName ~= "" and runtime.CloneAvatarByUsername then
            local ok, err = runtime.CloneAvatarByUsername(savedName, true)
            if not ok then
                warn("[XeroHub Config] No se pudo restaurar avatar clonado: " .. tostring(err))
            end
            return
        end

        if not runtime.Alive or serial ~= state.ConfigLoadSerial then
            if template then pcall(function() template:Destroy() end) end
            return
        end

        if not template then
            warn("[XeroHub Config] No se pudo reconstruir avatar clonado: " .. tostring(cloneError or "sin template"))
            return
        end

        local displayName = savedName ~= "" and savedName
            or (savedUserId and tostring(savedUserId))
            or "Avatar guardado"

        local ok, err = runtime.SetClonedAvatarTemplate(
            template,
            savedUserId,
            displayName,
            true,
            savedOutfitId
        )

        if not ok then
            warn("[XeroHub Config] No se pudo aplicar avatar clonado: " .. tostring(err))
        end
    end)
end


-- XERO DUELS: outfits originales (descripciones y modelo del clone).
function runtime.GetHumanoidDescriptionFromOutfitIdSafe(outfitId)
    outfitId = tonumber(outfitId)
    if not outfitId then return nil, "Outfit inválido" end

    local ok, description = pcall(function()
        return Players:GetHumanoidDescriptionFromOutfitIdAsync(outfitId)
    end)
    if ok and description then return description end

    ok, description = pcall(function()
        return Players:GetHumanoidDescriptionFromOutfitId(outfitId)
    end)
    if ok and description then return description end

    return nil, tostring(description or "No se pudo cargar ese outfit")
end

function runtime.CloneAvatarFromOutfitId(outfitId, outfitName, ownerUserId, ownerName, silent)
    local char = player.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false, "Tu personaje todavía no cargó" end

    local description, err = runtime.GetHumanoidDescriptionFromOutfitIdSafe(outfitId)
    if not description then return false, err end

    local template, templateErr = runtime.CreateAvatarCloneTemplateFromDescription(description, humanoid.RigType)
    pcall(function() description:Destroy() end)
    if not template then return false, templateErr end

    local displayName = tostring(ownerName or "Usuario") .. " · " .. tostring(outfitName or "Outfit")
    return runtime.SetClonedAvatarTemplate(template, ownerUserId, displayName, silent, outfitId)
end


-- Adaptador minimo para mantener la UI, busqueda de outfits y configuracion de RyouHub.
local ryouSkin = {
    KeepOnRespawn = true,
    SelectedPlayer = nil,
    Username = "",
    Active = false,
    TargetUserId = nil,
    OutfitId = nil,
    TargetName = "",
    ActiveDescription = nil,
    Generation = 0,
}

local function ryouSkinSync()
    local clone = runtime.Appearance.AvatarClone
    ryouSkin.Active = clone.Active == true
    ryouSkin.ActiveDescription = clone.Template
    ryouSkin.TargetUserId = clone.TargetUserId
    ryouSkin.OutfitId = clone.TargetOutfitId
    ryouSkin.TargetName = clone.TargetName or ""
end

local function ryouSkinClearVisuals()
    runtime.AvatarCloneDestroyOverlay(true)
end

local function ryouSkinApplyToCharacter(char, unused, token)
    if not char or char ~= LocalPlayer.Character or (token and token ~= ryouSkin.Generation) then
        return false, "El personaje cambio durante la carga"
    end
    local clone = runtime.Appearance.AvatarClone
    if not clone.Template then return false, "No hay un clon guardado" end
    return runtime.ApplyAvatarCloneTemplate(char, clone.Template)
end

local function ryouSkinClonePlayer(target)
    local ok, err = runtime.CloneAvatarFromPlayer(target, true)
    if ok then ryouSkinSync() end
    return ok, err
end

local function ryouSkinCloneById(userId, username)
    local id = tonumber(userId)
    if not id or id <= 0 then return false, "UserId invalido" end
    local char = LocalPlayer.Character
    local human = char and char:FindFirstChildOfClass("Humanoid")
    if not human then return false, "Tu personaje todavia no cargo" end
    local template, err = runtime.CreateAvatarCloneTemplateFromUserId(id, human.RigType)
    if not template then return false, err end
    local ok, applyErr = runtime.SetClonedAvatarTemplate(template, id, username or tostring(id), true)
    if ok then ryouSkinSync() end
    return ok, applyErr
end

local function ryouSkinCloneByUsername(username)
    username = tostring(username or ""):gsub("^%s+", ""):gsub("%s+$", ""):gsub("^@", "")
    local ok, err = runtime.CloneAvatarByUsername(username, true)
    if ok then ryouSkinSync() end
    return ok, err
end

local function ryouSkinCloneOutfit(outfitId, outfitName, ownerId, ownerName)
    -- API original de Xero Duels, sin reconstruir la ruta de aplicación del outfit.
    local ok, err = runtime.CloneAvatarFromOutfitId(outfitId, outfitName, ownerId, ownerName, true)
    if ok then ryouSkinSync() end
    return ok, err
end

local function ryouSkinRestore()
    ryouSkin.Generation += 1
    local ok, err = runtime.RestoreAvatarClone(true)
    if ok then ryouSkinSync() end
    return ok, err
end

local function ryouSkinHttpJson(url)
    local body,err=ryouHttpGet(url)
    if not body then return nil,err end
    local ok,obj=pcall(function() return HttpService:JSONDecode(body) end)
    if ok and type(obj)=="table" then return obj end
    return nil,"Respuesta JSON inválida"
end

local function ryouSkinGetOutfits(userId)
    local result,seen={},{}
    for page=1,10 do
        local url="https://avatar.roblox.com/v1/users/"..tostring(userId)
            .."/outfits?page="..tostring(page).."&itemsPerPage=50&isEditable=true"
        local decoded,err=ryouSkinHttpJson(url)
        if not decoded then
            if page==1 then return nil,err end
            break
        end
        local data=type(decoded.data)=="table" and decoded.data or {}
        for _,item in ipairs(data) do
            local id=tonumber(item.id)
            if id and not seen[id] then
                result[#result+1]={Id=id,Name=tostring(item.name or "Outfit")}
                seen[id]=true
            end
        end
        if #data<50 then break end
        task.wait(.03)
    end
    return result
end

local function mountRyouSkin(window,tab)
    -- Adaptador VISUAL V13 -> V14: la galería real vive como hermana del
    -- scroll principal. No usa los avatares de ejemplo de NeoShowcase.
    -- Se conserva intacto el motor de outfits y clonación de RyouHub.
    if tab.page and tab.scroller then
        tab.Page = tab.page
        tab.ConceptShell = tab.scroller
    end
    assert(tab.Page and tab.ConceptShell,
        "Ryou UI V14 no expone los contenedores necesarios para Outfits")
    local playerSelected="Sin jugadores"
    local mainConnections={}
    local function playersInServer()
        local values={}
        for _,candidate in ipairs(Players:GetPlayers()) do
            if candidate~=LocalPlayer then values[#values+1]=candidate.Name end
        end
        table.sort(values)
        if #values==0 then values[1]="Sin jugadores" end
        return values
    end
    local names=playersInServer()
    playerSelected=names[1]
    tab:Section({Title="Jugadores del servidor"})
    local dropdown=tab:Dropdown({Title="Seleccionar jugador",Values=names,Value=playerSelected,Callback=function(v)
        playerSelected=tostring(v or "Sin jugadores")
    end})
    local function refreshPlayers()
        local values=playersInServer()
        local remains=table.find(values,playerSelected)~=nil
        if not remains then playerSelected=values[1] end
        dropdown:Refresh(values)
        dropdown:Set(playerSelected,true)
    end
    mainConnections[#mainConnections+1]=Players.PlayerAdded:Connect(refreshPlayers)
    mainConnections[#mainConnections+1]=Players.PlayerRemoving:Connect(function()
        task.defer(refreshPlayers)
    end)
    tab:Button({Title="Clonar jugador seleccionado",Callback=function()
        local target=Players:FindFirstChild(playerSelected)
        if not target or target==LocalPlayer then notify("Selecciona otro jugador.",3) return end
        task.spawn(function()
            local ok,err=ryouSkinClonePlayer(target)
            notify(ok and ("Skin clonada: "..target.Name) or ("No se pudo clonar: "..tostring(err)),3)
        end)
    end})
    tab:Section({Title="Username"})
    tab:Input({Title="Clonar por username",Placeholder="Ej: builderman",Callback=function(v)
        ryouSkin.Username=tostring(v or "")
    end})
    tab:Button({Title="Cargar skin por username",Callback=function()
        task.spawn(function()
            local ok,err=ryouSkinCloneByUsername(ryouSkin.Username)
            notify(ok and ("Skin clonada: "..ryouSkin.TargetName) or ("No se pudo clonar: "..tostring(err)),3)
        end)
    end})
    local function getBrowseUser()
        local username=ryouSkin.Username:gsub("^%s+",""):gsub("%s+$",""):gsub("^@","")
        if username~="" then
            local ok,id=pcall(function() return Players:GetUserIdFromNameAsync(username) end)
            if ok and id then return id,username end
            return nil,nil,"Username inválido"
        end
        local player=Players:FindFirstChild(playerSelected)
        if player and player~=LocalPlayer then return player.UserId,player.Name end
        return nil,nil,"Escribe un username o selecciona un jugador"
    end
    local designerOpenOutfits
    tab:Section({Title="Skins guardadas"})
    tab:Button({Title="Ver skins del usuario",Desc="Galería de outfits con miniaturas y vista previa.",Callback=function()
        if type(designerOpenOutfits)~="function" then
            warn("[Ryou] Galería no inicializada al pulsar Ver skins del usuario")
            notify("Galería no disponible. Revisa consola.",4)
            return
        end
        local ok,err=pcall(designerOpenOutfits)
        if not ok then
            warn("[Ryou] Error al abrir Outfits: "..tostring(err))
            notify("Error abriendo Outfits: "..tostring(err),5)
        end
    end})
    local keep=tab:Toggle({Title="Mantener clon al respawnear",Value=true,Callback=function(v)
        ryouSkin.KeepOnRespawn=v==true
        runtime.Appearance.AvatarClone.KeepOnRespawn=ryouSkin.KeepOnRespawn
    end})
    tab:Button({Title="Restaurar mi skin",Callback=function()
        task.spawn(function()
            local ok,err=ryouSkinRestore()
            notify(ok and "Skin original restaurada." or ("Error: "..tostring(err)),3)
        end)
    end})
    -- Xero Duels: mismo ciclo de reset / mascara / guarda de rig, sin el delay
    -- fijo de Ryou que dejaba ver el personaje y rompía algunos respawns.
    mainConnections[#mainConnections+1]=LocalPlayer.CharacterAdded:Connect(function(char)
        runtime.Appearance.RespawnGeneration += 1
        local generation = runtime.Appearance.RespawnGeneration
        local clone = runtime.Appearance.AvatarClone
        runtime.AvatarCloneResetForRespawn(char, generation)
        if clone.Active and not clone.KeepOnRespawn then
            clone.Active = false
            if clone.Template then pcall(function() clone.Template:Destroy() end) end
            clone.Template = nil
            clone.TargetUserId = nil
            clone.TargetName = nil
            clone.TargetOutfitId = nil
            ryouSkinSync()
        end
        task.spawn(function()
            runtime.FastRestoreAppearanceOnRespawn(char, generation)
            runtime.GuardAvatarCloneAfterRespawn(char, generation)
            ryouSkinSync()
        end)
    end)
    mainConnections[#mainConnections+1]=LocalPlayer.CharacterAppearanceLoaded:Connect(function(char)
        if not runtime.Alive or char ~= LocalPlayer.Character then return end
        local generation = runtime.Appearance.RespawnGeneration
        task.defer(function()
            if not runtime.Alive or not char.Parent or generation ~= runtime.Appearance.RespawnGeneration then return end
            local clone = runtime.Appearance.AvatarClone
            if clone.Active and clone.KeepOnRespawn and clone.Template and not clone.Applying then
                if runtime.AvatarCloneIsBoundToCharacter(char) then
                    runtime.ReapplyAppearanceLayers(char)
                    runtime.AvatarCloneHideBase(char)
                    runtime.UpdateAvatarCloneLayers()
                else
                    runtime.BeginAvatarCloneRespawnMask(char, generation)
                    task.spawn(function()
                        runtime.GuardAvatarCloneAfterRespawn(char, generation)
                    end)
                end
            end
        end)
    end)
    -- Neo Sidebar V7: Outfits usa la galería de la biblioteca visual.
    -- El motor original de clonación y la consulta de outfits permanecen intactos.
    local galleryState = {
        source = "Usuario", token = 0, userId = nil, userName = nil,
    }
    local outfitQueryControl, outfitGallery, galleryStatus
    local function updateGalleryStatus(message)
        if galleryStatus then galleryStatus:SetDesc(tostring(message or "")) end
    end
    local function isCurrentOutfitQuery(token)
        return token == galleryState.token
            and window and not window.Destroyed
            and outfitGallery and not outfitGallery.Destroyed
    end
    tab:Section({Title = "Explorador de outfits", Icon = "shirt"})
    tab:Dropdown({
        Title = "Buscar por",
        Values = {"Usuario", "Outfit ID"},
        Value = "Usuario",
        Callback = function(value)
            galleryState.source = tostring(value or "Usuario")
            galleryState.token += 1
            galleryState.userId, galleryState.userName = nil, nil
            if outfitQueryControl then
                outfitQueryControl:Set("", true)
                if outfitQueryControl.TextBox then
                    outfitQueryControl.TextBox.PlaceholderText =
                        galleryState.source == "Usuario" and "@usuario" or "ID del outfit"
                end
            end
            if outfitGallery then
                outfitGallery:SetStatus("ready")
                outfitGallery:Refresh({})
            end
            updateGalleryStatus("Escribe una consulta para explorar outfits.")
        end,
    })
    outfitQueryControl = tab:Input({
        Title = "Usuario o Outfit ID",
        Desc = "Puedes buscar outfits públicos o abrir uno por ID.",
        Placeholder = "@usuario",
        Value = "",
    })
    tab:Button({
        Title = "Cargar outfits",
        Desc = "Actualiza la galería con los resultados de tu consulta.",
        Action = "Buscar",
        Callback = function()
            if designerOpenOutfits then designerOpenOutfits() end
        end,
    })
    galleryStatus = tab:Paragraph({
        Title = "Resultados",
        Desc = "Busca un usuario o escribe un Outfit ID.",
    })
    outfitGallery = tab:Gallery({
        Title = "Outfits",
        Desc = "Selecciona un outfit para previsualizarlo y aplicarlo.",
        Items = {},
        OnApply = function(item)
            local outfitId = tonumber(item and item.Id)
            if not outfitId or outfitId <= 0 then return end
            local outfitName = tostring(item.Title or ("Outfit #" .. tostring(outfitId)))
            local userId, username = galleryState.userId, galleryState.userName
            task.spawn(function()
                local ok, err = ryouSkinCloneOutfit(outfitId, outfitName, userId, username)
                notify(
                    ok and ("Outfit aplicado: " .. outfitName)
                        or ("No se pudo clonar: " .. tostring(err)),
                    3
                )
            end)
        end,
    })
    local function focusOutfitGallery()
        task.defer(function()
            local host = tab.scrollHost or tab.scroller
            local row = outfitGallery and outfitGallery.ElementFrame
            if not host or not host.Parent or not row or not row.Parent then return end
            local y = row.AbsolutePosition.Y - host.AbsolutePosition.Y + host.CanvasPosition.Y
            host.CanvasPosition = Vector2.new(host.CanvasPosition.X, math.max(0, y - 8))
        end)
    end
    designerOpenOutfits = function()
        galleryState.token += 1
        local token = galleryState.token
        galleryState.userId, galleryState.userName = nil, nil
        local source = galleryState.source
        -- Leer directamente TextBox evita perder la consulta cuando aún tiene foco móvil.
        local query = tostring(outfitQueryControl.TextBox.Text or "")
        query = query:gsub("^%s+", ""):gsub("%s+$", ""):gsub("^@", "")
        outfitGallery:Refresh({})
        outfitGallery:SetStatus("loading", "Buscando outfits…")
        focusOutfitGallery()
        if source == "Outfit ID" then
            local id = tonumber(query)
            if not id or id <= 0 or id % 1 ~= 0 then
                outfitGallery:SetStatus("error", "ID de outfit inválido")
                updateGalleryStatus("Introduce un ID de outfit numérico y válido.")
                return
            end
            id = math.floor(id)
            local name = "Outfit #" .. tostring(id)
            outfitGallery:Refresh({
                {
                    Id = id, Title = name, Desc = "ID " .. tostring(id),
                    Thumbnail = "rbxthumb://type=Outfit&id=" .. tostring(id) .. "&w=150&h=150",
                    Preview = "rbxthumb://type=Outfit&id=" .. tostring(id) .. "&w=420&h=420",
                },
            })
            outfitGallery:SetStatus("ready")
            outfitGallery:Set(id, true)
            updateGalleryStatus("Outfit seleccionado por ID. Confirma la miniatura antes de aplicar.")
            return
        end
        updateGalleryStatus("Buscando outfits públicos…")
        task.spawn(function()
            local userId, username, lookupError
            if query == "" then
                userId, username, lookupError = getBrowseUser()
            else
                local ok, resolvedId = pcall(function()
                    return Players:GetUserIdFromNameAsync(query)
                end)
                if ok then
                    userId, username = resolvedId, query
                else
                    lookupError = "Usuario no encontrado."
                end
            end
            if not isCurrentOutfitQuery(token) then return end
            if not userId then
                local message = lookupError or "Usuario no encontrado."
                outfitGallery:SetStatus("error", message)
                updateGalleryStatus(message)
                return
            end
            local outfits, err = ryouSkinGetOutfits(userId)
            if not isCurrentOutfitQuery(token) then return end
            if not outfits then
                local message = "No se pudieron cargar los outfits."
                outfitGallery:SetStatus("error", message)
                updateGalleryStatus(message)
                notify(err or message, 3)
                return
            end
            local items = {}
            for _, outfit in ipairs(outfits) do
                local id = tonumber(outfit.Id)
                if id and id > 0 then
                    items[#items + 1] = {
                        Id = id, Title = tostring(outfit.Name or ("Outfit #" .. tostring(id))),
                        Desc = "ID " .. tostring(id),
                        Thumbnail = "rbxthumb://type=Outfit&id=" .. tostring(id) .. "&w=150&h=150",
                        Preview = "rbxthumb://type=Outfit&id=" .. tostring(id) .. "&w=420&h=420",
                    }
                end
            end
            galleryState.userId, galleryState.userName = userId, username
            outfitGallery:Refresh(items)
            outfitGallery:SetStatus("ready")
            if #items > 0 then outfitGallery:Set(items[1].Id, true) end
            updateGalleryStatus(tostring(#items) .. " outfits de @" .. tostring(username))
        end)
    end
    window:OnDestroy(function()
        galleryState.token += 1
    end)

    window:OnDestroy(function()
        for _,connection in ipairs(mainConnections) do connection:Disconnect() end
        ryouSkinRestore()
        runtime.Alive = false
    end)
    return {
        Save=function()
            return {Keep=ryouSkin.KeepOnRespawn,Active=ryouSkin.Active,
                UserId=ryouSkin.TargetUserId,OutfitId=ryouSkin.OutfitId,Username=ryouSkin.TargetName}
        end,
        Load=function(data)
            if type(data)~="table" then return end
            if data.Keep~=nil then
                ryouSkin.KeepOnRespawn=data.Keep==true
                runtime.Appearance.AvatarClone.KeepOnRespawn=ryouSkin.KeepOnRespawn
                keep:Set(ryouSkin.KeepOnRespawn,true)
            end
            if data.Active==false then
                ryouSkinRestore()
            elseif data.Active and data.OutfitId then
                task.spawn(function()
                    local ok,err=ryouSkinCloneOutfit(data.OutfitId,data.Username or "Outfit",data.UserId,data.Username)
                    if not ok then warn("[Ryou] Config skin: "..tostring(err)) end
                end)
            elseif data.Active and data.UserId then
                task.spawn(function()
                    local ok,err=ryouSkinCloneById(data.UserId,data.Username)
                    if not ok then warn("[Ryou] Config skin: "..tostring(err)) end
                end)
            end
        end,
    }
end


ryouExtras.mountSkin = mountRyouSkin
end

-- Crear toda la interfaz en su propia función evita el límite de locales
-- del bloque principal en Luau y mantiene las pestañas en el mismo archivo.
local function initializeRyouHubInterface()
local UIRefs = {
    Parts = { AutoShoot = {} },
}

local Window =
    WindUI:CreateWindow({
        Title = "RyouHub",
        Subtitle = "Created by Ryou",
        Theme = "Dark",
        Author = "Created by Ryou",
        Size = UDim2.fromOffset(1040, 600),
        MinSize = Vector2.new(440, 330),
        SafeTopInset = 0,
        ShowStatus = false,
        ShowUtilities = false,
        Resizable = true,
        -- Montar primero todas las pestañas permite animar la entrada completa.
        Open = false,
        Neon = true,
        Motion = "Full",
        Scale = 1,
        DecorationIntensity = 1,
        LiquidGlass = true,
        GlassIntensity = .55,
        VisualEffects = "Suave",
        OpenButton = {
            Title = "RyouHub",
            Enabled = true,
        },
    })

-- Launcher V11: pastilla centrada arriba, táctil y arrastrable.
-- Sin reposicionamiento externo de compat.lua.

local MainSection =
    Window:Section({
        Title = "PRINCIPAL",
        Opened = true,
    })

-- Sin rótulo RYOU separado de las pestañas.
local PersonalSection = MainSection

local HomeTab =
    MainSection:Tab({
        Title = "Inicio",
        Icon = "layout-grid",
    })

local SlashTab =
    MainSection:Tab({
        Title = "TP Slash",
        Icon = "skull",
    })

local AimTab =
    MainSection:Tab({
        Title = "Auto Shoot",
        Icon = "crosshair",
    })

local MovementTab =
    MainSection:Tab({
        Title = "Movimiento",
        Icon = "footprints",
    })

local VisualTab =
    MainSection:Tab({
        Title = "Visuales",
        Icon = "eye",
    })

local AppearanceTab =
    PersonalSection:Tab({
        Title = "Apariencia",
        Icon = "shirt",
    })

local SkyboxTab =
    PersonalSection:Tab({
        Title = "Skybox",
        Icon = "moon-star",
    })

local BackgroundTab =
    PersonalSection:Tab({
        Title = "Fondo",
        Icon = "image",
    })

local AnimationsTab =
    PersonalSection:Tab({
        Title = "Animaciones",
        Icon = "person-standing",
    })

local PersonalizeTab =
    PersonalSection:Tab({
        Title = "Personalización",
        Icon = "palette",
    })

local ConfigTab =
    PersonalSection:Tab({
        Title = "Configuración",
        Icon = "settings",
    })

local InfoTab =
    PersonalSection:Tab({
        Title = "Información",
        Icon = "badge-info",
    })

-- Inicio Neo Sidebar V7. Contenido real vinculado a las pestañas del hub,
-- sin utilizar el showroom ni sus datos ficticios.
HomeTab:Banner({
    Title = "Ryou",
    AccentText = "Hub",
    Subtitle = "Created by Ryou",
    Height = 138,
})
local homeAction, homeStatus = HomeTab:Columns({Split=.53, MinWidth=340})
homeAction:Button({
    Title="Funciones",
    Icon="activity",
    Action="TP Slash",
    Primary=true,
    Callback=function() Window:SelectTab("TP Slash") end,
})
homeStatus:Section({Title="Estado",Icon="activity"})
local currentGameName = tostring(game.Name or "Juego")
if currentGameName=="" or currentGameName=="Game" then currentGameName="Juego actual" end
local universeId=tonumber(game.GameId) or 0
local gameThumb="rbxthumb://type=GameIcon&id="..tostring(universeId>0 and universeId or game.PlaceId).."&w=150&h=150"
local homeStatusRow=homeStatus:Stats({
    {Thumbnail=gameThumb,Value=currentGameName,Text="Juego"},
    {Icon="palette",Value=Window:GetThemePreset(),Text="Tema"},
    {Icon="layers",Value="V14 · 14.6",Text="Versión"},
})
local homeThemeValue=homeStatusRow and homeStatusRow:FindFirstChild("Stat2")
homeThemeValue=homeThemeValue and homeThemeValue:FindFirstChild("Value")
task.spawn(function()
    local ok,info=pcall(function()
        return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
    end)
    if ok and type(info)=="table" and type(info.Name)=="string" and #info.Name>0 then
        local card=homeStatusRow and homeStatusRow:FindFirstChild("Stat1")
        local title=card and card:FindFirstChild("Value")
        if title and title.Parent then title.Text=info.Name end
    end
end)
HomeTab:Section({Title="Accesos rápidos",Icon="grid"})
local shortcutAppearance, shortcutAnimations, shortcutConfig =
    HomeTab:Columns({Count=3, MinWidth=360, Cards=false})
shortcutAppearance:Button({
    Title="Apariencia",Icon="user",Compact=true,
    Callback=function() Window:SelectTab("Apariencia") end
})
shortcutAnimations:Button({
    Title="Animaciones",Icon="activity",Compact=true,
    Callback=function() Window:SelectTab("Animaciones") end
})
shortcutConfig:Button({
    Title="Configuración",Icon="sliders",Compact=true,
    Callback=function() Window:SelectTab("Configuración") end
})

-- Si falla una función estética, las demás pestañas siguen visibles.
local function mountRyouSection(name, tab, factory, ...)
    local ok, result = pcall(factory, ...)
    if ok and type(result) == "table"
        and type(result.Save) == "function"
        and type(result.Load) == "function" then
        return result
    end
    warn("[RyouHub] " .. name .. ": " .. tostring(result))
    pcall(function()
        tab:Paragraph({
            Title = name .. " no disponible",
            Desc = "No se pudo abrir esta sección. Reinicia el menú e inténtalo de nuevo."
        })
    end)
    return {Save=function() return {} end, Load=function() end}
end

avatarAnimations = mountRyouSection(
    "Animaciones", AnimationsTab, ryouExtras.mountAnimations,
    Window, AnimationsTab, LocalPlayer
)
local avatarSkin = mountRyouSection(
    "Apariencia", AppearanceTab, ryouExtras.mountSkin, Window, AppearanceTab
)

local skyboxSystem = mountRyouSection(
    "Skybox", SkyboxTab, ryouExtras.mountSkybox, Window, SkyboxTab
)
-- El sistema de fondos se monta en Personalización, después de los controles
-- de tema; se conserva la estructura de guardado `Fondo` de las configs V9.
local menuBackground

SlashTab:Paragraph({
    Title = "TP Slash",
    Desc =
        "Equipa tu cuchillo y activa la opción. "
        .. "Ryou empezará cuando inicie la ronda y atacará "
        .. "a los enemigos disponibles, sin atacar a tu equipo. "
        .. "",
})

SlashTab:Section({
    Title = "Global",
})

local TPSlashToggle
TPSlashToggle =
    SlashTab:Toggle({
        Title = "TP Slash",
        Desc =
            "Ataca automáticamente a los enemigos de la ronda. "
            .. "No afecta a tus compañeros.",
        Value = false,
        Callback = function(enabled)
            enabled = enabled == true
            state.TPSlashEnabled = enabled

            if enabled then
                state.CancelRequested = false
                notify("TP Slash activado.", 2)
                startTPSlash()
            else
                stopTPSlash()
                notify("TP Slash desactivado.", 2)
            end
        end,
    })

UIRefs.TPSlash = TPSlashToggle

SlashTab:Section({
    Title = "Ataque individual",
})

SlashTab:Paragraph({
    Title = "Objetivo manual",
    Desc =
        "Esta lista es independiente del TP Slash global. "
        .. "Sirve para probar un jugador concreto.",
})

local function getPlayerValues()
    local values = {}

    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= LocalPlayer then
            table.insert(
                values,
                otherPlayer.Name
            )
        end
    end

    table.sort(values, function(a, b)
        return string.lower(a)
            < string.lower(b)
    end)

    if #values == 0 then
        table.insert(
            values,
            "No hay jugadores"
        )
    end

    return values
end

local initialValues = getPlayerValues()
local initialValue = initialValues[1]

if initialValue ~= "No hay jugadores" then
    state.SelectedPlayer =
        Players:FindFirstChild(
            initialValue
        )
end

local PlayerDropdown =
    SlashTab:Dropdown({
        Title = "Jugador",
        Desc =
            "Solo para ataque individual. "
            .. "El TP Slash global no usa esta selección.",
        Values = initialValues,
        Value = initialValue,
        Callback = function(value)
            if value == "No hay jugadores" then
                state.SelectedPlayer = nil
                return
            end

            state.SelectedPlayer =
                Players:FindFirstChild(
                    tostring(value)
                )
        end,
    })

SlashTab:Button({
    Title = "Actualizar jugadores",
    Callback = function()
        local values =
            getPlayerValues()

        if PlayerDropdown
            and type(
                PlayerDropdown.Refresh
            ) == "function"
        then
            PlayerDropdown:
                Refresh(values)
        end

        notify(
            "Lista manual actualizada."
        )
    end,
})

SlashTab:Button({
    Title = "Slash al seleccionado",
    Desc =
        "Hace un solo ataque al jugador elegido. "
        .. "También exige tener el cuchillo en mano.",
    Callback = function()
        if state.TPSlashEnabled then
            notify(
                "Apaga TP Slash global antes de usar el ataque individual.",
                3
            )
            return
        end

        if state.Busy then
            notify(
                "Ya hay un ataque en curso."
            )
            return
        end

        if not getEquippedKnife() then
            notify(
                "Equipa el cuchillo en la mano primero.",
                3
            )
            return
        end

        if not state.SelectedPlayer then
            notify(
                "Selecciona un jugador.",
                3
            )
            return
        end

        task.spawn(function()
            local damaged, message =
                attackPlayer(
                    state.SelectedPlayer
                )

            notify(
                message
                    or (
                        damaged
                        and "Daño confirmado."
                        or "No se confirmó daño."
                    ),
                3
            )
        end)
    end,
})

SlashTab:Button({
    Title = "Cancelar ataque actual",
    Desc =
        "Cancela el objetivo actual y restaura tu movimiento inmediatamente.",
    Callback = function()
        if not state.Busy then
            notify(
                "No hay ataque activo."
            )
            return
        end

        state.CancelRequested = true
    end,
})

AimTab:Paragraph({
    -- La pestaña ya muestra "Auto Shoot" arriba. Dejar solo descripción.
    Title = "",
    Desc =
        "Dispara cuando tengas la pistola equipada. "
        .. "Apunta al enemigo visible más cercano sin mover tu cámara.",
})

AimTab:Section({
    Title = "Auto Shoot",
})

UIRefs.AutoShoot = AimTab:Toggle({
    Title = "Auto Shoot",
    Desc = "Pistola equipada, enemigo visible y partes seleccionadas.",
    Value = false,
    Callback = function(enabled)
        aimSettings.AutoShoot = enabled == true
        updateAimConnection()
    end,
})

AimTab:Button({
    Title = "Selector corporal · Auto Shoot",
    Desc = "Abre la mini ventana para marcar cabeza, torso, brazos o piernas.",
    Callback = function()
        openBodySelector("AutoShoot")
    end,
})

MovementTab:Section({
    Title = "Velocidad",
})

UIRefs.WalkSpeedEnabled = MovementTab:Toggle({
    Title = "Velocidad personalizada",
    Desc = "Cambia qué tan rápido caminas durante la partida.",
    Value = false,
    Callback = function(enabled)
        movementSettings.Enabled = enabled == true

        if movementSettings.Enabled then
            movementSettings.Accumulated = 0
            updateWalkSpeed()
        else
            restoreWalkSpeed()
        end
    end,
})

UIRefs.WalkSpeed = MovementTab:Slider({
    Title = "Velocidad al caminar",
    Desc = "16 es la velocidad normal. Rango de 16 a 100.",
    Step = 1,
    Value = {
        Min = 16,
        Max = 100,
        Default = 16,
    },
    Callback = function(value)
        movementSettings.WalkSpeed =
            math.clamp(tonumber(value) or 16, 16, 100)

        updateWalkSpeed()
    end,
})

UIRefs.SkipCountdown = MovementTab:Toggle({
    Title = "Omitir contador",
    Desc = "Te permite moverte mientras comienza la ronda.",
    Value = false,
    Callback = function(enabled)
        countdownWalkSettings.Enabled = enabled == true
        if countdownWalkSettings.Enabled then
            countdownWalkSettings.ControlsFetched = false
            getCountdownControls()
        else
            local _, root, humanoid = getLocalCharacter()
            stopCountdownMovement(humanoid, root)
        end
    end,
})

UIRefs.InfiniteJump = MovementTab:Toggle({
    Title = "Salto infinito",
    Desc = "Permite volver a saltar mientras estás en el aire. Funciona en móvil y PC.",
    Value = false,
    Callback = function(enabled)
        infiniteJumpSettings.Enabled = enabled == true
        infiniteJumpSettings.LastJumpAt = 0
    end,
})

VisualTab:Section({
    Title = "ESP de enemigos",
})

UIRefs.ESP = VisualTab:Toggle({
    Title = "ESP de enemigos",
    Desc = "Muestra a los jugadores del equipo contrario.",
    Value = false,
    Callback = function(enabled)
        espSettings.Enabled = enabled == true
        updateESPConnection()
    end,
})

UIRefs.ESPColor = VisualTab:Colorpicker({
    Title = "Color del ESP",
    Default = ESP_COLOR_DEFAULT,
    Callback = function(color)
        if typeof(color) == "Color3" then
            espSettings.Color = color
            if espSettings.Enabled then
                refreshESP()
            end
        end
    end,
})

VisualTab:Section({
    Title = "Hitbox Expander",
})

UIRefs.Hitbox = VisualTab:Toggle({
    Title = "Hitbox Expander",
    Desc = "Amplía la hitbox de la cabeza de los enemigos. Tamaño recomendado: hasta 25.",
    Value = false,
    Callback = function(enabled)
        hitboxSettings.Enabled = enabled == true
        updateHitboxConnection()
    end,
})

UIRefs.HitboxSize = VisualTab:Slider({
    Title = "Tamaño de hitbox",
    Desc = "Rango: 2.2 a 35. Máximo donde cuenta daño: 25. Por encima puede no registrar daño.",
    Step = 0.05,
    Value = {
        Min = 2.2,
        Max = 35.0,
        Default = 3.25,
    },
    Callback = function(value)
        hitboxSettings.Size = tonumber(value) or 3.25

        if hitboxSettings.Enabled then
            refreshHitboxes()
        end
    end,
})

VisualTab:Section({
    Title = "Capas",
})

UIRefs.Glow = VisualTab:Toggle({
    Title = "Mostrar Resplandor",
    Value = true,
    Callback = function(enabled)
        espSettings.Glow = enabled == true
        if espSettings.Enabled then refreshESP() end
    end,
})

UIRefs.ESPName = VisualTab:Toggle({
    Title = "Mostrar Nombre",
    Value = true,
    Callback = function(enabled)
        espSettings.Name = enabled == true
        if espSettings.Enabled then refreshESP() end
    end,
})

UIRefs.ESPDistance = VisualTab:Toggle({
    Title = "Mostrar Distancia",
    Value = true,
    Callback = function(enabled)
        espSettings.Distance = enabled == true
        if espSettings.Enabled then refreshESP() end
    end,
})

UIRefs.ESPBox = VisualTab:Toggle({
    Title = "ESP Box 2D",
    Desc = drawingAvailable
        and "Caja alrededor del enemigo."
        or "Esta opción no está disponible en tu dispositivo.",
    Value = false,
    Callback = function(enabled)
        espSettings.Box = enabled == true
        if espSettings.Enabled then refreshESP() end
    end,
})

UIRefs.ESPHealth = VisualTab:Toggle({
    Title = "Barra de vida",
    Value = false,
    Callback = function(enabled)
        espSettings.HealthBar = enabled == true
        if espSettings.Enabled then refreshESP() end
    end,
})

UIRefs.ESPLines = VisualTab:Toggle({
    Title = "Mostrar Líneas",
    Desc = drawingAvailable
        and "Línea desde abajo de la pantalla al enemigo."
        or "Esta opción no está disponible en tu dispositivo.",
    Value = false,
    Callback = function(enabled)
        espSettings.Lines = enabled == true
        if espSettings.Enabled then refreshESP() end
    end,
})

-- Neo Sidebar V7: personalización visual real con APIs públicas.
-- Todos los controles trabajan sobre Window, nunca sobre la lógica del juego.
local appearanceSaveRequested = function() end
local appearanceSyncing = false
local function requestAppearancePersist()
    if not appearanceSyncing then appearanceSaveRequested() end
end
local visualAccent, visualBackground, visualGlass, visualGlassIntensity
PersonalizeTab:Section({Title="Temas y colores",Icon="palette"})
local visualTheme = PersonalizeTab:Dropdown({
    Title="Tema predefinido",
    Desc="Ocho combinaciones. Puedes afinar los colores después.",
    Values=WindUI:GetThemePresets(),Value="Menta Ryou",
    Callback=function(value)
        Window:SetThemePreset(value)
        if homeThemeValue then homeThemeValue.Text=tostring(value) end
        if visualAccent then visualAccent:Set(Window:GetAccent(),true) end
        if visualBackground then visualBackground:Set(Window:GetBackgroundColor(),true) end
        requestAppearancePersist()
    end,
})
visualAccent = PersonalizeTab:Colorpicker({
    Title="Color de acento",
    Desc="Botones, selección, controles, indicadores y títulos destacados.",
    Value=Window:GetAccent(),
    Callback=function(color)
        Window:SetAccent(color)
        if homeThemeValue then homeThemeValue.Text="Personalizado" end
        requestAppearancePersist()
    end,
})
visualBackground = PersonalizeTab:Colorpicker({
    Title="Color del fondo",
    Desc="Personaliza la base del panel sin modificar el juego.",
    Value=Window:GetBackgroundColor(),
    Callback=function(color)
        Window:SetBackgroundColor(color)
        if homeThemeValue then homeThemeValue.Text="Personalizado" end
        requestAppearancePersist()
    end,
})
local visualFont = PersonalizeTab:Dropdown({
    Title="Tipografía",
    Desc="Cambia la fuente de botones, textos y campos sin reconstruir la ventana.",
    Values=WindUI:GetFontStyles(),Value="Gotham",
    Callback=function(value)
        Window:SetFontStyle(value)
        requestAppearancePersist()
    end,
})
local visualOpacity = PersonalizeTab:Slider({
    Title="Transparencia de superficies (%)",
    Desc="0 = sólido. Máximo 35 % para conservar la legibilidad.",
    Min=0,Max=35,Step=5,Default=0,
    Callback=function(value)
        Window:SetSurfaceTransparency(value/100)
        requestAppearancePersist()
    end,
})
PersonalizeTab:Section({Title="Liquid Glass",Icon="layers"})
visualGlass = PersonalizeTab:Toggle({
    Title="Activar Liquid Glass",
    Desc="Superficies translúcidas y brillos suaves, sin desenfocar el juego.",
    Value=Window:GetGlassMode(),
    Callback=function(enabled)
        Window:SetGlassMode(enabled)
        requestAppearancePersist()
    end,
})
visualGlassIntensity = PersonalizeTab:Slider({
    Title="Intensidad Glass (%)",
    Min=0,Max=100,Step=5,Default=55,
    Callback=function(value)
        Window:SetGlassIntensity(value/100)
        requestAppearancePersist()
    end,
})
PersonalizeTab:Section({Title="Efectos",Icon="activity"})
local visualEffects=PersonalizeTab:Dropdown({
    Title="Efectos de interfaz",
    Values={"Suave","Destellos","Desactivados"},
    Value="Suave",
    Callback=function(value)
        Window:SetVisualEffects(value)
        requestAppearancePersist()
    end,
})
PersonalizeTab:Section({Title="Animaciones",Icon="activity"})
local visualMotion = PersonalizeTab:Dropdown({
    Title="Animaciones",
    Values={"Completas","Reducidas","Desactivadas"},
    Value="Completas",
    Callback=function(value)
        local modes={Completas="Full",Reducidas="Reduced",Desactivadas="Off"}
        Window:SetMotion(modes[value] or "Full")
        requestAppearancePersist()
    end,
})
local visualSpeed = PersonalizeTab:Slider({
    Title="Velocidad de animaciones (%)",
    Desc="50 % más pausado; 200 % más rápido.",
    Min=50,Max=200,Step=10,Default=100,
    Callback=function(value)
        Window:SetAnimationSpeed(value/100)
        requestAppearancePersist()
    end,
})
local function syncAppearanceControls()
    local data = Window:ExportAppearance()
    appearanceSyncing = true
    visualTheme:Set(data.Preset or "Menta Ryou",true)
    visualAccent:Set(Window:GetAccent(),true)
    visualBackground:Set(Window:GetBackgroundColor(),true)
    visualFont:Set(data.Font or "Gotham",true)
    visualOpacity:Set(math.round((data.Transparency or 0)*100),true)
    visualGlass:Set(data.LiquidGlass==true,true)
    visualGlassIntensity:Set(math.round((data.GlassIntensity or .55)*100),true)
    visualEffects:Set(data.VisualEffects or "Suave",true)
    if homeThemeValue then homeThemeValue.Text=data.Preset or "Personalizado" end
    local names = {Full="Completas",Reduced="Reducidas",Off="Desactivadas"}
    visualMotion:Set(names[data.Motion] or "Completas",true)
    visualSpeed:Set(math.round((data.Speed or 1)*100),true)
    appearanceSyncing = false
end
PersonalizeTab:Button({
    Title="Restablecer apariencia",Icon="rotate-ccw",
    Callback=function()
        Window:SetThemePreset("Menta Ryou")
        Window:SetFontStyle("Gotham")
        Window:SetSurfaceTransparency(0)
        Window:SetGlassMode(true)
        Window:SetGlassIntensity(.55)
        Window:SetVisualEffects("Suave")
        Window:SetScale(1)
        syncAppearanceControls()
        visualEffects:Set("Suave",true)
        Window:SetNeon(true)
        Window:SetDecorationIntensity(1)
        visualMotion:Set("Completas")
        visualSpeed:Set(100)
        requestAppearancePersist()
    end,
})

-- Fondos se configuran aquí, en una sola sección de personalización.
menuBackground = mountRyouSection(
    "Fondo", PersonalizeTab, ryouExtras.mountBackground, Window, PersonalizeTab
)

BackgroundTab:Paragraph({
    Title="Fondos del hub",
    Desc="Todos los fondos, incluidos Pinterest y enlaces web, están en Personalización.",
})
BackgroundTab:Button({
    Title="Ir a Personalización",
    Desc="Abre temas, colores y fondos personalizados.",
    Callback=function() Window:SelectTab("Personalización") end,
})

ConfigTab:Section({
    Title = "Gestor de Configs",
})

local CONFIG_FOLDER =
    "Ryou_Configs_" .. tostring(game.PlaceId)

local AUTOLOAD_PATH =
    CONFIG_FOLDER .. "/_autoload.json"

local APPEARANCE_PATH = CONFIG_FOLDER .. "/_ui_appearance.json"

local selectedConfig = "Ninguna"
local customConfigName = ""
local autoLoadEnabled = false
local autoLoadConfigName = nil
local configDropdown = nil
local autoLoadToggle = nil
local configDropdownSyncing = false
local autoLoadSyncing = false

local function ensureConfigFolder()
    if type(makefolder) == "function" then
        local exists = false

        if type(isfolder) == "function" then
            pcall(function()
                exists = isfolder(CONFIG_FOLDER)
            end)
        end

        if not exists then
            pcall(
                makefolder,
                CONFIG_FOLDER
            )
        end
    end
end

ensureConfigFolder()

-- Los cambios visuales se escriben como máximo una vez por ráfaga de ajustes.
-- Si el entorno no expone archivos, la personalización sigue funcionando en sesión.
local appearanceSaveGeneration = 0
appearanceSaveRequested = function()
    appearanceSaveGeneration += 1
    local generation = appearanceSaveGeneration
    task.delay(.75,function()
        if generation ~= appearanceSaveGeneration or Window.Destroyed then return end
        if type(writefile) ~= "function" then return end
        ensureConfigFolder()
        local ok, err = pcall(function()
            writefile(APPEARANCE_PATH,HttpService:JSONEncode(Window:ExportAppearance()))
        end)
        if not ok then warn("[Ryou] No se guardó la apariencia: "..tostring(err)) end
    end)
end

local function restoreUIAppearance()
    if type(isfile)~="function" or type(readfile)~="function" then return end
    local ok, saved = pcall(function()
        if not isfile(APPEARANCE_PATH) then return nil end
        return HttpService:JSONDecode(readfile(APPEARANCE_PATH))
    end)
    if ok and type(saved)=="table" then
        local loaded, err = pcall(function()
            Window:ImportAppearance(saved)
            Window:SetScale(1)
            Window:SetNeon(true)
            Window:SetDecorationIntensity(1)
            syncAppearanceControls()
        end)
        if not loaded then warn("[Ryou] Apariencia guardada inválida: "..tostring(err)) end
    end
end
restoreUIAppearance()

local function colorToTable(color)
    return {
        R = color.R,
        G = color.G,
        B = color.B,
    }
end

local function tableToColor(value, fallback)
    if type(value) ~= "table" then
        return fallback
    end

    return Color3.new(
        tonumber(value.R) or fallback.R,
        tonumber(value.G) or fallback.G,
        tonumber(value.B) or fallback.B
    )
end

local function setControl(control, value)
    if control
        and type(control.Set) == "function"
    then
        pcall(function()
            control:Set(value)
        end)
    end
end

local function saveAutoLoadState()
    ensureConfigFolder()

    if type(writefile) ~= "function" then
        return
    end

    local data = {
        Enabled = autoLoadEnabled == true,
        Config = autoLoadConfigName,
    }

    pcall(function()
        writefile(
            AUTOLOAD_PATH,
            HttpService:JSONEncode(data)
        )
    end)
end

local function readAutoLoadState()
    if type(isfile) ~= "function"
        or type(readfile) ~= "function"
    then
        return
    end

    local exists = false
    pcall(function()
        exists = isfile(AUTOLOAD_PATH)
    end)

    if not exists then
        return
    end

    pcall(function()
        local decoded =
            HttpService:JSONDecode(
                readfile(AUTOLOAD_PATH)
            )

        if type(decoded) == "table" then
            autoLoadEnabled =
                decoded.Enabled == true

            if type(decoded.Config) == "string"
                and decoded.Config ~= ""
                and decoded.Config ~= "Ninguna"
            then
                autoLoadConfigName =
                    decoded.Config

                if autoLoadEnabled then
                    selectedConfig =
                        decoded.Config
                end
            end
        end
    end)
end

readAutoLoadState()

local function serializeConfig()
    return {
        Version = 3,
        PlaceId = game.PlaceId,

        TP = {
            TPSlash =
                state.TPSlashEnabled == true,
        },

        Aim = {
            AutoShoot = aimSettings.AutoShoot == true,
            PartsAutoShoot = getTargetSelectionArray("AutoShoot"),
        },

        Animaciones = avatarAnimations.Save(),
        Apariencia = avatarSkin.Save(),
        Skybox = skyboxSystem.Save(),
        Fondo = menuBackground.Save(),
        UIAppearance = Window:ExportAppearance(),

        Movement = {
            Enabled = movementSettings.Enabled == true,
            WalkSpeed = movementSettings.WalkSpeed,
            InfiniteJump = infiniteJumpSettings.Enabled == true,
            SkipCountdown = countdownWalkSettings.Enabled == true,
        },

        Visual = {
            ESP =
                espSettings.Enabled == true,

            Glow =
                espSettings.Glow == true,

            Name =
                espSettings.Name == true,

            Distance =
                espSettings.Distance == true,

            Box =
                espSettings.Box == true,

            HealthBar =
                espSettings.HealthBar == true,

            Lines =
                espSettings.Lines == true,

            ESPColor =
                colorToTable(
                    espSettings.Color
                ),

            HeadHitbox =
                hitboxSettings.Enabled == true,

            HitboxSize =
                tonumber(
                    hitboxSettings.Size
                ) or 3.25,
        },
    }
end

local function applyConfig(data)
    if type(data) ~= "table" then
        return false
    end
    if type(data.UIAppearance) == "table" then
        Window:ImportAppearance(data.UIAppearance)
        Window:SetScale(1)
        Window:SetNeon(true)
        Window:SetDecorationIntensity(1)
        syncAppearanceControls()
        requestAppearancePersist()
    end

    local tp =
        type(data.TP) == "table"
        and data.TP
        or {}

    local aim =
        type(data.Aim) == "table"
        and data.Aim
        or {}

    local visual =
        type(data.Visual) == "table"
        and data.Visual
        or {}

    local movement =
        type(data.Movement) == "table"
        and data.Movement
        or {}

    if type(data.Animaciones) == "table" then
        avatarAnimations.Load(data.Animaciones)
    end

    if type(data.Fondo) == "table" then
        menuBackground.Load(data.Fondo)
    end
    if type(data.Skybox) == "table" then
        skyboxSystem.Load(data.Skybox)
    end
    if type(data.Apariencia) == "table" then
        avatarSkin.Load(data.Apariencia)
    end

    if movement.SkipCountdown ~= nil then
        countdownWalkSettings.Enabled = movement.SkipCountdown == true
        setControl(UIRefs.SkipCountdown, countdownWalkSettings.Enabled)
        if countdownWalkSettings.Enabled then
            countdownWalkSettings.ControlsFetched = false
            getCountdownControls()
        else
            local _, root, humanoid = getLocalCharacter()
            stopCountdownMovement(humanoid, root)
        end
    end

    if movement.InfiniteJump ~= nil then
        infiniteJumpSettings.Enabled = movement.InfiniteJump == true
        infiniteJumpSettings.LastJumpAt = 0
        setControl(UIRefs.InfiniteJump, infiniteJumpSettings.Enabled)
    end

    if movement.WalkSpeed ~= nil then
        movementSettings.WalkSpeed = math.clamp(
            tonumber(movement.WalkSpeed) or 16,
            16,
            100
        )
        setControl(UIRefs.WalkSpeed, movementSettings.WalkSpeed)
    end

    if movement.Enabled ~= nil then
        movementSettings.Enabled = movement.Enabled == true
        setControl(UIRefs.WalkSpeedEnabled, movementSettings.Enabled)

        if movementSettings.Enabled then
            updateWalkSpeed()
        else
            restoreWalkSpeed()
        end
    end

    if tp.TPSlash ~= nil then
        state.TPSlashEnabled =
            tp.TPSlash == true

        setControl(
            UIRefs.TPSlash,
            state.TPSlashEnabled
        )

        if state.TPSlashEnabled then
            state.CancelRequested = false
            startTPSlash()
        else
            stopTPSlash()
        end
    end

    if aim.AutoShoot ~= nil then
        aimSettings.AutoShoot =
            aim.AutoShoot == true

        setControl(
            UIRefs.AutoShoot,
            aimSettings.AutoShoot
        )
    end

    if aim.PartsAutoShoot then
        setTargetSelection(
            "AutoShoot",
            aim.PartsAutoShoot
        )
        syncPartControls("AutoShoot")
    end

    if visual.ESP ~= nil then
        espSettings.Enabled =
            visual.ESP == true

        setControl(
            UIRefs.ESP,
            espSettings.Enabled
        )
    end

    if visual.Glow ~= nil then
        espSettings.Glow =
            visual.Glow == true

        setControl(
            UIRefs.Glow,
            espSettings.Glow
        )
    end

    if visual.Name ~= nil then
        espSettings.Name =
            visual.Name == true

        setControl(
            UIRefs.ESPName,
            espSettings.Name
        )
    end

    if visual.Distance ~= nil then
        espSettings.Distance =
            visual.Distance == true

        setControl(
            UIRefs.ESPDistance,
            espSettings.Distance
        )
    end

    if visual.Box ~= nil then
        espSettings.Box =
            visual.Box == true

        setControl(
            UIRefs.ESPBox,
            espSettings.Box
        )
    end

    if visual.HealthBar ~= nil then
        espSettings.HealthBar =
            visual.HealthBar == true

        setControl(
            UIRefs.ESPHealth,
            espSettings.HealthBar
        )
    end

    if visual.Lines ~= nil then
        espSettings.Lines =
            visual.Lines == true

        setControl(
            UIRefs.ESPLines,
            espSettings.Lines
        )
    end

    if visual.ESPColor then
        espSettings.Color =
            tableToColor(
                visual.ESPColor,
                espSettings.Color
            )

        setControl(
            UIRefs.ESPColor,
            espSettings.Color
        )
    end

    if visual.HeadHitbox ~= nil then
        hitboxSettings.Enabled =
            visual.HeadHitbox == true

        setControl(
            UIRefs.Hitbox,
            hitboxSettings.Enabled
        )
    end

    if visual.HitboxSize ~= nil then
        hitboxSettings.Size =
            math.clamp(
                tonumber(
                    visual.HitboxSize
                ) or 3.25,
                2.2,
                35
            )

        setControl(
            UIRefs.HitboxSize,
            hitboxSettings.Size
        )
    end

    updateAimConnection()
    updateWalkSpeed()

    updateESPConnection()
    if espSettings.Enabled then
        refreshESP()
    end

    updateHitboxConnection()
    if hitboxSettings.Enabled then
        refreshHitboxes()
    end

    return true
end

local function sanitizeConfigName(value)
    local name =
        tostring(value or "")
        :gsub("[^%w%s%-_]", "")
        :gsub("^%s+", "")
        :gsub("%s+$", "")

    return name
end

local function configPath(name)
    return CONFIG_FOLDER
        .. "/"
        .. tostring(name)
        .. ".json"
end

local function listConfigs()
    local list = {}

    if type(listfiles) == "function" then
        pcall(function()
            for _, file in ipairs(
                listfiles(CONFIG_FOLDER)
            ) do
                if file:match("%.json$") then
                    local name =
                        file:match(
                            "([^/\\]+)%.json$"
                        )

                    if name
                        and name ~= "_autoload"
                        and name ~= "_ui_appearance"
                    then
                        list[#list + 1] =
                            name
                    end
                end
            end
        end)
    end

    table.sort(
        list,
        function(a, b)
            return string.lower(a)
                < string.lower(b)
        end
    )

    if #list == 0 then
        list[1] = "Ninguna"
    end

    return list
end

local function refreshConfigs()
    local values = listConfigs()

    if configDropdown
        and type(configDropdown.Refresh)
            == "function"
    then
        pcall(function()
            configDropdown:Refresh(values)
        end)
    end

    local desired = selectedConfig

    if autoLoadEnabled
        and autoLoadConfigName
        and table.find(
            values,
            autoLoadConfigName
        )
    then
        desired = autoLoadConfigName
    end

    if not table.find(values, desired) then
        desired = values[1]
    end

    selectedConfig = desired

    if configDropdown
        and type(configDropdown.Select)
            == "function"
    then
        configDropdownSyncing = true

        pcall(function()
            configDropdown:Select(desired)
        end)

        configDropdownSyncing = false
    end
end

local function saveConfig(name)
    name = sanitizeConfigName(name)

    if name == ""
        or name == "Ninguna"
    then
        notify(
            "Escribe un nombre válido para la config.",
            3
        )
        return false
    end

    if type(writefile) ~= "function" then
        notify(
            "Tu ejecutor no expone writefile.",
            3
        )
        return false
    end

    ensureConfigFolder()

    local ok, err =
        pcall(function()
            writefile(
                configPath(name),
                HttpService:JSONEncode(
                    serializeConfig()
                )
            )
        end)

    if not ok then
        notify(
            "No se pudo guardar: "
            .. tostring(err),
            4
        )
        return false
    end

    selectedConfig = name
    refreshConfigs()

    notify(
        "Config guardada: " .. name,
        3
    )

    return true
end

local function loadConfigByName(name, auto)
    name = tostring(name or "")

    if name == ""
        or name == "Ninguna"
    then
        if not auto then
            notify(
                "Selecciona una config.",
                3
            )
        end
        return false
    end

    if type(isfile) ~= "function"
        or type(readfile) ~= "function"
    then
        notify(
            "Tu ejecutor no expone readfile/isfile.",
            3
        )
        return false
    end

    local path = configPath(name)
    local exists = false

    pcall(function()
        exists = isfile(path)
    end)

    if not exists then
        notify(
            "No existe la config: " .. name,
            3
        )
        return false
    end

    local ok, decoded =
        pcall(function()
            return HttpService:JSONDecode(
                readfile(path)
            )
        end)

    if not ok
        or type(decoded) ~= "table"
    then
        notify(
            "No se pudo leer la config.",
            3
        )
        return false
    end

    applyConfig(decoded)
    selectedConfig = name

    notify(
        auto
            and ("Auto Load: " .. name)
            or ("Config cargada: " .. name),
        3
    )

    return true
end

configDropdown = ConfigTab:Dropdown({
    Title = "Seleccionar Configuración",
    Values = {"Ninguna"},
    Value = "Ninguna",
    Callback = function(value)
        local actual =
            type(value) == "table"
            and value[1]
            or value

        selectedConfig =
            tostring(
                actual or "Ninguna"
            )

        if not configDropdownSyncing
            and autoLoadEnabled
            and selectedConfig
                ~= "Ninguna"
        then
            autoLoadConfigName =
                selectedConfig

            saveAutoLoadState()
        end
    end,
})

autoLoadToggle = ConfigTab:Toggle({
    Title = "Auto Load Config",
    Desc =
        "Carga automáticamente la config seleccionada al ejecutar Ryou.",
    Value = autoLoadEnabled,
    Callback = function(enabled)
        if autoLoadSyncing then
            return
        end

        if enabled then
            if selectedConfig == ""
                or selectedConfig
                    == "Ninguna"
            then
                autoLoadEnabled = false
                autoLoadConfigName = nil
                saveAutoLoadState()

                notify(
                    "Selecciona una config antes de activar Auto Load.",
                    3
                )

                task.defer(function()
                    autoLoadSyncing = true
                    setControl(
                        autoLoadToggle,
                        false
                    )
                    autoLoadSyncing = false
                end)

                return
            end

            autoLoadEnabled = true
            autoLoadConfigName =
                selectedConfig
        else
            autoLoadEnabled = false
        end

        saveAutoLoadState()
    end,
})

ConfigTab:Button({
    Title = "Actualizar Lista",
    Callback = function()
        refreshConfigs()
        notify(
            "Lista de configs actualizada.",
            2
        )
    end,
})

ConfigTab:Input({
    Title = "Nombre para Guardar",
    Placeholder = "Ej: Main, Legit, Mobile...",
    Callback = function(text)
        customConfigName =
            tostring(text or "")
    end,
})

ConfigTab:Button({
    Title = "Guardar Configuración",
    Callback = function()
        local name =
            sanitizeConfigName(
                customConfigName
            )

        if name == "" then
            name = selectedConfig
        end

        saveConfig(name)
    end,
})

ConfigTab:Button({
    Title = "Cargar Configuración",
    Callback = function()
        loadConfigByName(
            selectedConfig,
            false
        )
    end,
})

ConfigTab:Button({
    Title = "Eliminar Configuración",
    Callback = function()
        if selectedConfig == ""
            or selectedConfig
                == "Ninguna"
        then
            notify(
                "Selecciona una config.",
                3
            )
            return
        end

        if type(delfile) ~= "function" then
            notify(
                "Tu ejecutor no expone delfile.",
                3
            )
            return
        end

        local name = selectedConfig
        local path = configPath(name)

        pcall(function()
            if type(isfile) ~= "function"
                or isfile(path)
            then
                delfile(path)
            end
        end)

        if autoLoadConfigName == name then
            autoLoadConfigName = nil
            autoLoadEnabled = false
            saveAutoLoadState()

            autoLoadSyncing = true
            setControl(
                autoLoadToggle,
                false
            )
            autoLoadSyncing = false
        end

        selectedConfig = "Ninguna"
        refreshConfigs()

        notify(
            "Config eliminada: " .. name,
            3
        )
    end,
})

task.spawn(function()
    task.wait(0.8)

    refreshConfigs()

    autoLoadSyncing = true
    setControl(
        autoLoadToggle,
        autoLoadEnabled
    )
    autoLoadSyncing = false

    if autoLoadEnabled
        and autoLoadConfigName
    then
        selectedConfig =
            autoLoadConfigName

        if configDropdown
            and type(configDropdown.Select)
                == "function"
        then
            configDropdownSyncing = true

            pcall(function()
                configDropdown:Select(
                    autoLoadConfigName
                )
            end)

            configDropdownSyncing = false
        end

        task.wait(0.05)

        loadConfigByName(
            autoLoadConfigName,
            true
        )
    end
end)

InfoTab:Paragraph({
    Title = "RyouHub",
    Desc = "Creador: Ryou\nPersonaliza tu experiencia, guarda tus ajustes y elige tu propio estilo.",
})

Players.PlayerRemoving:Connect(function(leavingPlayer)
    if state.SelectedPlayer
        == leavingPlayer
    then
        state.SelectedPlayer = nil
    end
end)

LocalPlayer.CharacterRemoving:Connect(function(character)
    state.CancelRequested = true
    state.Busy = false
    state.RoundWasActive = false

    if character then
        local knife = character:FindFirstChildOfClass("Tool")
        if knife and isKnifeTool(knife) then
            releaseKnife(knife)
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    state.CancelRequested = false
    state.Busy = false
    state.RoundWasActive = false
end)

pcall(function()
    Window:OnDestroy(function()
        state.Alive = false
        stopTPSlash()

        espSettings.Enabled = false
        updateESPConnection()

        hitboxSettings.Enabled = false
        updateHitboxConnection()
        restoreAllHitboxes()

        aimSettings.AutoShoot = false
        updateAimConnection()

        countdownWalkSettings.Enabled = false
        local _, countdownRoot, countdownHumanoid = getLocalCharacter()
        stopCountdownMovement(countdownHumanoid, countdownRoot)
        stopCountdownWalkAnimation(true)
        if countdownWalkConnection then
            countdownWalkConnection:Disconnect()
            countdownWalkConnection = nil
        end

        infiniteJumpSettings.Enabled = false
        if infiniteJumpConnection then
            infiniteJumpConnection:Disconnect()
            infiniteJumpConnection = nil
        end

        movementSettings.Enabled = false
        if walkSpeedConnection then
            walkSpeedConnection:Disconnect()
            walkSpeedConnection = nil
        end
        restoreWalkSpeed()

        if bodySelectorGui then
            pcall(function()
                bodySelectorGui:Destroy()
            end)
            bodySelectorGui = nil
            bodySelector = nil
        end

        for playerObject in pairs(espEntries) do
            destroyESPEntry(playerObject)
        end
    end)
end)

    pcall(function() Window:SelectTab("Inicio") end)

-- Se abre al terminar de montar TODAS las pestañas para que el primer
-- efecto de entrada muestre la navegación y el contenido ya construido.
task.defer(function()
    if state.Alive and Window and not Window.Destroyed then
        local ok,err=pcall(function() Window:Open() end)
        if not ok then warn("[Ryou] No se pudo abrir Neo Sidebar: "..tostring(err)) end
    end
end)

pcall(function() notify("RyouHub V14 listo: Neo Sidebar V12", 3) end)

end

initializeRyouHubInterface()
