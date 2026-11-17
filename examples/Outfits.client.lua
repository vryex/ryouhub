local Players = game:GetService("Players")
local storage = game:GetService("ReplicatedStorage")
local UI = require(storage:WaitForChild("RyouUI"))
local player = Players.LocalPlayer

-- Each StringValue under Catalog has an outfit ID as Value and a title as Name.
-- Optional attributes User and PreviewAssetId supply credit and an approved preview.
local source = script:FindFirstChild("Catalog")
local entries = {}
if source then
    for _, item in ipairs(source:GetChildren()) do
        local id = item:IsA("StringValue") and item.Value:match("^[1-9]%d*$")
        if id then
            table.insert(entries, {
                Id = id, Title = item.Name, User = item:GetAttribute("User") or player.Name,
                Preview = item:GetAttribute("PreviewAssetId"),
            })
        end
    end
    table.sort(entries, function(a,b) return a.Title < b.Title end)
end

local window = UI:CreateWindow({Title = "Apariencia", Subtitle = "Catálogo del proyecto"})
local outfits = window:Tab({Title = "Outfits", Icon = "user", Desc = "Selecciona un outfit y revisa su vista previa."})
local selected, preview
local outfitApplied = script:FindFirstChild("OutfitSelected")
local apply = outfits:FooterButton({Title = "Aplicar", Locked = true, Callback = function()
    if not selected then return end
    if outfitApplied and outfitApplied:IsA("BindableEvent") then
        outfitApplied:Fire(selected.Id)
    end
    window:Notify({Title = selected.Title, Content = "Outfit " .. selected.Id, Type = "success"})
end})

local function selectOutfit(entry)
    selected = entry
    if preview then preview:Destroy() end
    preview = outfits:Paragraph({
        Title = "Seleccionado · " .. entry.Title,
        Desc = "Usuario " .. entry.User .. " · Outfit " .. entry.Id,
        Icon = "check", Gothic = true, ImageAlign = "right", ImageSize = 44,
        Image = type(entry.Preview) == "number" and ("rbxassetid://" .. tostring(entry.Preview)) or nil,
    })
    preview.ElementFrame.LayoutOrder = 0
    apply:Unlock()
end

if #entries == 0 then
    outfits:Paragraph({
        Title = "Catálogo vacío", Icon = "info",
        Desc = "Agrega outfits al Folder Catalog del LocalScript para cargar la galería.",
    })
else
    task.spawn(function()
        for index, entry in ipairs(entries) do
            if window.Destroyed then return end
            outfits:Button({
                Title = entry.Title,
                Desc = entry.User .. " · Outfit " .. entry.Id,
                Icon = entry.Preview or "user",
                Callback = function() selectOutfit(entry) end,
            })
            if index % 12 == 0 then task.wait() end
        end
    end)
end
