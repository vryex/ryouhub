-- Ryou | Knife Slash TP
-- Creador: Ryou
-- TP bajo los pies + mirada hacia arriba durante la ventana activa del slash.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local UI_URL = "https://raw.githubusercontent.com/vryex/ryouhub/main/ui/compat.lua"

local okUI, UI = pcall(function()
    local source = game:HttpGet(UI_URL)
    assert(type(source) == "string" and #source > 1000, "La UI de Ryou no respondió correctamente.")
    local chunk, err = loadstring(source)
    assert(chunk, err)
    return chunk()
end)

if not okUI or type(UI) ~= "table" or type(UI.CreateWindow) ~= "function" then
    warn("[Ryou Knife] No se pudo cargar la UI:", UI)
    return
end

local Window = UI:CreateWindow({
    Title = "Ryou | KNIFE",
    Subtitle = "KNIFE",
    Theme = "Ryou",
    Author = "by Ryou",
    Size = UDim2.fromOffset(560, 355),
    MinSize = Vector2.new(330, 285),
    Resizable = true,
    OpenButton = {
        Title = "RYOU",
        Enabled = true,
    },
})

local MainSection = Window:Section({
    Title = "Slash TP",
    Opened = true,
})

local SettingsSection = Window:Section({
    Title = "Ajustes",
    Opened = true,
})

local Main = MainSection:Tab({
    Title = "Kill All",
    Icon = "skull",
})

local Settings = SettingsSection:Tab({
    Title = "Configuración",
    Icon = "settings",
})

local Credits = SettingsSection:Tab({
    Title = "Créditos",
    Icon = "badge-info",
})

local State = {
    Running = false,
    StopRequested = false,

    Depth = 2.8,
    HoldTime = 0.45,
    BetweenTargets = 0.20,
    PreSlashFrames = 1,

    ReturnAfter = true,
    NoclipDuringTP = true,
}

local function notify(message)
    if UI.Notify then
        pcall(function()
            UI:Notify({
                Title = "Ryou",
                Content = tostring(message),
                Duration = 2,
            })
        end)
    end
end

local function characterData(player)
    local character = player and player.Character
    if not character then return end

    local root = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if not root or not humanoid or humanoid.Health <= 0 then
        return
    end

    return character, root, humanoid
end

local function getSlashRemote()
    local character = LocalPlayer.Character
    if not character then return end

    local knife = character:FindFirstChild("Knife")
    if not knife then
        return
    end

    local knifeServer = knife:FindFirstChild("KnifeServer")
    if not knifeServer then
        return
    end

    local slashStart = knifeServer:FindFirstChild("SlashStart")

    if slashStart and slashStart:IsA("RemoteEvent") then
        return slashStart
    end
end

local function targetUnderCFrame(targetRoot, targetHumanoid)
    -- HumanoidRootPart está sobre los pies. Calculamos el piso corporal
    -- aproximado y colocamos nuestro HRP todavía más abajo.
    local feetOffset = targetHumanoid.HipHeight + (targetRoot.Size.Y * 0.5)

    local feetPosition = targetRoot.Position - Vector3.new(0, feetOffset, 0)
    local position = feetPosition - Vector3.new(0, State.Depth, 0)

    -- La dirección hacia el torso es prácticamente vertical.
    -- Usamos el LookVector del objetivo como referencia "up" para evitar
    -- la degeneración de CFrame.lookAt cuando miramos recto hacia arriba.
    local upReference = targetRoot.CFrame.LookVector

    if math.abs(upReference:Dot((targetRoot.Position - position).Unit)) > 0.98 then
        upReference = targetRoot.CFrame.RightVector
    end

    return CFrame.lookAt(
        position,
        targetRoot.Position,
        upReference
    )
end

local function setVelocityZero(root)
    pcall(function()
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end)
end

local function captureCollisions(character)
    local states = {}

    for _, object in ipairs(character:GetDescendants()) do
        if object:IsA("BasePart") then
            states[object] = object.CanCollide
        end
    end

    return states
end

local function applyNoclip(states)
    for part in pairs(states) do
        if part and part.Parent then
            part.CanCollide = false
        end
    end
end

local function restoreCollisions(states)
    for part, canCollide in pairs(states or {}) do
        if part and part.Parent then
            part.CanCollide = canCollide
        end
    end
end

local function waitFrames(count)
    for _ = 1, math.max(0, math.floor(count or 0)) do
        RunService.Heartbeat:Wait()
    end
end

local function pinUnderTarget(localRoot, targetRoot, targetHumanoid, duration)
    local finishAt = os.clock() + math.max(0.03, duration)

    repeat
        if State.StopRequested then
            break
        end

        if not localRoot.Parent
            or not targetRoot.Parent
            or not targetHumanoid.Parent
            or targetHumanoid.Health <= 0 then
            break
        end

        localRoot.CFrame = targetUnderCFrame(targetRoot, targetHumanoid)
        setVelocityZero(localRoot)

        RunService.Heartbeat:Wait()
    until os.clock() >= finishAt
end

local function validTargets()
    local list = {}

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local _, root, humanoid = characterData(player)

            if root and humanoid then
                table.insert(list, player)
            end
        end
    end

    table.sort(list, function(a, b)
        return string.lower(a.Name) < string.lower(b.Name)
    end)

    return list
end

local function runSlashTP(targets)
    if State.Running then
        notify("Ya hay una secuencia activa.")
        return
    end

    local localCharacter, localRoot, localHumanoid = characterData(LocalPlayer)

    if not localCharacter or not localRoot or not localHumanoid then
        notify("Tu personaje no está listo.")
        return
    end

    local slashStart = getSlashRemote()

    if not slashStart then
        notify("Equipa el cuchillo primero.")
        return
    end

    if #targets == 0 then
        notify("No encontré objetivos vivos.")
        return
    end

    State.Running = true
    State.StopRequested = false

    local origin = localRoot.CFrame
    local collisionStates = captureCollisions(localCharacter)

    if State.NoclipDuringTP then
        applyNoclip(collisionStates)
    end

    notify("Slash TP iniciado · " .. tostring(#targets) .. " objetivo(s)")

    local completed = 0

    for _, targetPlayer in ipairs(targets) do
        if State.StopRequested then
            break
        end

        local _, targetRoot, targetHumanoid = characterData(targetPlayer)

        if targetRoot and targetHumanoid then
            local currentSlash = getSlashRemote()

            if currentSlash then
                -- Inicia la ventana del slash.
                currentSlash:FireServer()

                -- Conservamos el timing que ya confirmó daño en la prueba.
                waitFrames(State.PreSlashFrames)

                -- Nos quedamos físicamente bajo sus pies mirando hacia arriba.
                pinUnderTarget(
                    localRoot,
                    targetRoot,
                    targetHumanoid,
                    State.HoldTime
                )

                completed += 1

                if State.ReturnAfter and localRoot.Parent then
                    localRoot.CFrame = origin
                    setVelocityZero(localRoot)
                end

                if not State.StopRequested and State.BetweenTargets > 0 then
                    task.wait(State.BetweenTargets)
                end
            end
        end
    end

    if localRoot and localRoot.Parent and State.ReturnAfter then
        localRoot.CFrame = origin
        setVelocityZero(localRoot)
    end

    restoreCollisions(collisionStates)

    State.Running = false

    if State.StopRequested then
        notify("Secuencia detenida.")
    else
        notify("Terminado · " .. tostring(completed) .. " objetivo(s)")
    end
end

local function runAsync(targets)
    task.spawn(function()
        local ok, err = pcall(runSlashTP, targets)

        if not ok then
            State.Running = false
            warn("[Ryou Knife] Slash TP:", err)
            notify("Error en Slash TP.")
        end
    end)
end

Main:Paragraph({
    Title = "Slash TP",
    Desc = "Inicia SlashStart, espera la ventana del ataque y te mantiene debajo de los pies del objetivo mirando hacia arriba.",
    Gothic = true,
    BadgeText = "RYOU",
    DecorText = "RYOU",
})

Main:Section({
    Title = "Acciones",
})

Main:Button({
    Title = "Probar con un jugador",
    Desc = "Usa el primer jugador vivo disponible y vuelve a tu posición al terminar.",
    Callback = function()
        local targets = validTargets()

        if targets[1] then
            runAsync({ targets[1] })
        else
            notify("No encontré otro jugador vivo.")
        end
    end,
})

Main:Button({
    Title = "Kill All",
    Desc = "Recorre todos los jugadores vivos con Slash TP.",
    Callback = function()
        runAsync(validTargets())
    end,
})

Main:Button({
    Title = "Detener",
    Desc = "Cancela la secuencia activa y permite regresar a la posición original.",
    Callback = function()
        State.StopRequested = true
    end,
})

Settings:Section({
    Title = "Posición",
})

Settings:Slider({
    Title = "Profundidad bajo los pies",
    Desc = "Distancia adicional bajo la posición aproximada de los pies del objetivo.",
    Value = {
        Min = 0.5,
        Max = 6,
        Default = State.Depth,
    },
    Step = 0.1,
    Callback = function(value)
        State.Depth = tonumber(value) or State.Depth
    end,
})

Settings:Slider({
    Title = "Tiempo bajo el objetivo",
    Desc = "Cuánto tiempo permaneces fijado debajo mientras la hitbox del slash está activa.",
    Value = {
        Min = 0.05,
        Max = 1.5,
        Default = State.HoldTime,
    },
    Step = 0.05,
    Callback = function(value)
        State.HoldTime = tonumber(value) or State.HoldTime
    end,
})

Settings:Slider({
    Title = "Pausa entre jugadores",
    Desc = "Espera después de cada objetivo antes de comenzar el siguiente slash.",
    Value = {
        Min = 0,
        Max = 1.5,
        Default = State.BetweenTargets,
    },
    Step = 0.05,
    Callback = function(value)
        State.BetweenTargets = tonumber(value) or State.BetweenTargets
    end,
})

Settings:Slider({
    Title = "Frames antes del TP",
    Desc = "Heartbeat(s) entre SlashStart y el TP. El valor 1 conserva el timing que ya te funcionó.",
    Value = {
        Min = 0,
        Max = 4,
        Default = State.PreSlashFrames,
    },
    Step = 1,
    Callback = function(value)
        State.PreSlashFrames = math.floor(tonumber(value) or State.PreSlashFrames)
    end,
})

Settings:Section({
    Title = "Comportamiento",
})

Settings:Toggle({
    Title = "Volver al origen",
    Desc = "Regresa a tu posición original después de cada objetivo.",
    Value = State.ReturnAfter,
    Callback = function(value)
        State.ReturnAfter = value == true
    end,
})

Settings:Toggle({
    Title = "Noclip durante Slash TP",
    Desc = "Evita que el piso o las piezas te empujen mientras estás debajo del objetivo.",
    Value = State.NoclipDuringTP,
    Callback = function(value)
        State.NoclipDuringTP = value == true
    end,
})

Credits:Paragraph({
    Title = "Ryou",
    Desc = "Knife Slash TP · Creador Ryou",
    Gothic = true,
    BadgeText = "RYOU",
    DecorText = "R",
})

notify("Knife Slash TP listo.")
