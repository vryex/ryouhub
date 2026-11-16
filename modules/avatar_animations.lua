-- RyouHub · animaciones cosméticas del avatar R15.
-- El consumidor crea la pestaña y pasa su API visual a mount.
local AvatarAnimations = {}

local avatarPacks = {
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

local AVATAR_ORIGINAL = "Original"
local avatarSlots = {
    {"idle","Animation1","Idle","Reposo"}, {"idle","Animation2","Idle2"},
    {"walk","WalkAnim","Walk","Caminar"}, {"run","RunAnim","Run","Correr"},
    {"jump","JumpAnim","Jump","Saltar"}, {"fall","FallAnim","Fall","Caer"},
    {"climb","ClimbAnim","Climb","Escalar"}, {"swim","Swim","Swim","Nadar"},
    {"swimidle","SwimIdle","SwimIdle","Flotar en el agua"},
}

local function applyAvatarAnimations(character, animate, originals, overrides)
    local humanoid=character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.RigType~=Enum.HumanoidRigType.R15 then return 0,0 end
    local count,matching=0,0
    for _,slot in ipairs(avatarSlots) do
        local folder=animate:FindFirstChild(slot[1])
        local animation=folder and folder:FindFirstChild(slot[2])
        if animation and animation:IsA("Animation") then
            local current=animation.AnimationId
            local previous=originals[animation]
            if previous and current~=previous.Applied then previous=nil end
            local id=overrides[slot[3]]
            if id then matching+=1 end
            local nextId=id and ("rbxassetid://"..tostring(id)) or (previous and previous.Original)
            if nextId then
                if current~=nextId then
                    animation.AnimationId=nextId
                    count+=1
                end
                originals[animation]=id and {Original=previous and previous.Original or current,Applied=nextId} or nil
            else
                originals[animation]=nil
            end
        end
    end
    -- Animate picks up the edited slots on its normal transitions.
    return count,matching
end

function AvatarAnimations.mount(window, tab, player, notify)
    local names={}
    for name in pairs(avatarPacks) do table.insert(names,name) end
    table.sort(names)
    table.insert(names,1,AVATAR_ORIGINAL)
    local bundle=AVATAR_ORIGINAL
    local mix={}
    local overrides={}
    local originals=setmetatable({},{__mode="k"})
    local generation=0

    local function report(message)
        if notify then notify({Title="Animaciones",Content=message}) end
    end

    local function applyCurrent(showStatus)
        generation+=1
        local job=generation
        local character=player.Character
        if not character then
            if showStatus then report("El avatar todavía está cargando.") end
            return
        end
        local function isCurrent()
            return not window.Destroyed and generation==job and player.Character==character
        end
        task.spawn(function()
            local selected=overrides
            local animate=character:FindFirstChild("Animate")
            if next(selected) then
                if not character:FindFirstChildOfClass("Humanoid") then character:WaitForChild("Humanoid",5) end
                if not isCurrent() then return end
                animate=animate or character:FindFirstChild("Animate") or character:WaitForChild("Animate",5)
            end
            if not isCurrent() then return end
            if not animate then
                if showStatus then report("No se encontró el controlador Animate del avatar.") end
                return
            end
            local changed,matching=applyAvatarAnimations(character,animate,originals,selected)
            if not showStatus then
                local expected=0
                for _ in pairs(selected) do expected+=1 end
                if matching<expected then
                    task.delay(.2,function()
                        if isCurrent() and animate.Parent==character then
                            applyAvatarAnimations(character,animate,originals,selected)
                        end
                    end)
                end
                return
            end
            do
                local message
                if not next(overrides) then
                    message=changed>0 and "Se restauraron los movimientos originales." or "No había movimientos personalizados por restaurar."
                elseif matching==0 then
                    message="Este avatar requiere un rig R15 con las ranuras estándar de Animate."
                elseif changed>0 then
                    message="Se actualizaron las animaciones del avatar."
                else
                    message="El avatar ya usa esas animaciones."
                end
                report(message)
            end
        end)
    end

    tab:Section({Title="Paquetes de avatar"})
    tab:Dropdown({Title="Elegir paquete",Values=names,Value=bundle,Callback=function(value) bundle=value end})
    tab:Button({Title="Aplicar paquete",Callback=function()
        overrides=avatarPacks[bundle] or {}
        applyCurrent(true)
    end})
    tab:Button({Title="Restaurar original",Callback=function()
        overrides={}
        applyCurrent(true)
    end})
    tab:Section({Title="Mezclador"})
    for _,slot in ipairs(avatarSlots) do
        local key,title=slot[3],slot[4]
        if title then
            tab:Dropdown({Title=title,Values=names,Value=AVATAR_ORIGINAL,Callback=function(value) mix[key]=value end})
        end
    end
    tab:Button({Title="Aplicar mezcla",Callback=function()
        local selected={}
        for key,option in pairs(mix) do
            local pack=avatarPacks[option]
            if pack then
                selected[key]=pack[key]
                if key=="Idle" then selected.Idle2=pack.Idle2 or pack.Idle end
            end
        end
        overrides=selected
        applyCurrent(true)
    end})
    local function restoreCharacter(character)
        if not next(originals) then return end
        local animate=character and character:FindFirstChild("Animate")
        if animate then applyAvatarAnimations(character,animate,originals,{}) end
    end

    local respawn=player.CharacterAdded:Connect(function()
        if next(overrides) then applyCurrent(false) end
    end)
    local removing=player.CharacterRemoving:Connect(function(character)
        generation+=1
        restoreCharacter(character)
    end)
    local disposed=false
    window:OnDestroy(function()
        if disposed then return end
        disposed=true
        generation+=1
        respawn:Disconnect()
        removing:Disconnect()
        restoreCharacter(player.Character)
    end)
end

return AvatarAnimations
