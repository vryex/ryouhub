-- Fixture de Luau CLI, ejecutada junto al mock y la biblioteca por run-cli.py.
local w=UI:CreateWindow({Open=false,Motion="Off",Size=Vector2.new(1040,615)})
local root=w:Tab({Title="Inicio",ShowTitle=false})
local controls=w:Tab("Controles")
local outfits=w:Tab("Apariencia")
local longTab=w:Tab("Una pestaña con un nombre especialmente largo")
w.screen.AbsoluteSize=Vector2.new(596,394)
assert(not w.Compact and controls.titleLabel.Visible and outfits.titleLabel.Visible)
assert(controls.titleLabel.Text=="Controles" and outfits.titleLabel.Text=="Apariencia")
assert(outfits.labelWidths[outfits.titleLabel.TextSize]<=w.rail.Size.X.Offset-58)
assert(longTab.titleLabel.TextWrapped and longTab.slot.Size.Y.Offset>37)
w.screen.AbsoluteSize=Vector2.new(525,394)
assert(w.Compact and not outfits.titleLabel.Visible and outfits.glyph.Position.X.Scale==.5)
root:Select()
root:Banner({Title="Inicio",Subtitle="Prueba"})
local a,b=root:Columns({Split=.53})
a:Button({Title="Abrir",Compact=true})
b:Stats({{Value="V14",Text="Versión"}})
local selected=root:Dropdown({Title="Perfil",Items={},Values={"Menta","Oscuro"},Multi=true})
selected:Open()
assert(selected.expanded)
selected:Close()
assert(not selected.expanded)
local gallery=root:Gallery({Items={{Id=1,Title="Uno",Art="Avatar"},{Id=2,Title="Dos"}}})
assert(gallery:Get()==1)
gallery:Set(2)
assert(gallery:Get()==2)
gallery:SetStatus("loading"):SetStatus("error","Sin conexión"):SetStatus("ready")
gallery:Refresh({{Id=1,Title="Uno"}})
assert(gallery:Get()==nil)
local selectedAvatar, appliedAvatar
local avatar={Id=33,Title="Avatar",Thumbnail="rbxthumb://type=Avatar&id=33&w=150&h=150",Preview="rbxassetid://123"}
gallery.Callback=function(id) selectedAvatar=id end
gallery:Refresh({avatar})
gallery:Set(33)
local pane=gallery.ElementFrame:FindFirstChild("OutfitPane")
local function imageIn(parent)
    for _, node in ipairs(parent:GetDescendants()) do
        if node.Name=="AvatarImage" then return node end
    end
end
assert(selectedAvatar==33 and imageIn(pane:FindFirstChild("OutfitGrid")).Image==avatar.Thumbnail)
assert(imageIn(pane:FindFirstChild("OutfitPreview")).Image==avatar.Preview)
local avatarGallery=root:Gallery({Items={avatar},OnApply=function(item) appliedAvatar=item end})
local avatarPreview=avatarGallery.ElementFrame:FindFirstChild("OutfitPane"):FindFirstChild("OutfitPreview")
for _, node in ipairs(avatarPreview:GetChildren()) do
    if node:IsA("TextButton") and node.Text=="Aplicar" then node.Activated:Fire() end
end
assert(appliedAvatar==avatar)
local count=0
local catalog=root:Catalog({Title="Sky",Items={{Id="a",Title="Azul",Art="Swatch"}},Value="a",
    OnApply=function() count+=1 end})
local color=root:Colorpicker({Value=Color3.fromHex("FF0000"),Callback=function() count+=1 end})
local function findButton(text)
    local modal=w.panel:FindFirstChild("ModalVeil")
    for _, node in ipairs(modal:GetDescendants()) do
        if node:IsA("TextButton") and node.Text==text then return node end
    end
    error("Missing "..text)
end
w:Open()
catalog:Open()
assert(w.dismissModal)
findButton("Vista previa").Activated:Fire()
assert(findButton("Volver a la lista"))
findButton("Aplicar").Activated:Fire()
assert(not w.dismissModal and catalog:Get()=="a" and count==1)
color:Open()
assert(w.dismissModal and color:Get():ToHex()=="FF0000")
findButton("Cancelar").Activated:Fire()
assert(not w.dismissModal and count==1)
color:Open()
for _, node in ipairs(w.panel:GetDescendants()) do
    if node:IsA("TextBox") and node.PlaceholderText=="#RRGGBB" then
        node.Text="#00FF00"
        node.FocusLost:Fire(true)
    end
end
findButton("Aplicar").Activated:Fire()
assert(color:Get():ToHex()=="00FF00" and count==2 and not w.dismissModal)
for _, viewport in ipairs({Vector2.new(1672,941), Vector2.new(1536,709), Vector2.new(853,394)}) do
    w.screen.AbsoluteSize=viewport
    local bounds=Vector2.new(w.frame.Size.X.Offset,w.frame.Size.Y.Offset)
    w.frame.AbsoluteSize=bounds
    catalog:Open()
    local card=w.panel:FindFirstChild("ModalVeil"):FindFirstChild("ToolDialog")
    local apply=findButton("Aplicar")
    local dx, dy=card.Size.X.Offset/2, card.Size.Y.Offset/2
    assert(card.Position.X.Offset-dx>=0 and card.Position.X.Offset+dx<=bounds.X)
    assert(dy<=bounds.Y/2)
    assert(apply.Parent.Position.Y.Offset+apply.Parent.Size.Y.Offset<=0 and apply.Active)
    catalog:Close()
end
catalog:Open()
w:Close()
assert(not w.Opened and not w.dismissModal and w.launcher.Visible)
w.screen.AbsoluteSize=Vector2.new(530,300)
assert(w.Compact)
w.screen.AbsoluteSize=Vector2.new(1300,900)
assert(not w.Compact)
local function pointerEvent(x,y,kind)
    return {Position={X=x,Y=y},UserInputState=Enum.UserInputState.End,
        UserInputType=kind or Enum.UserInputType.MouseButton1}
end
local start=pointerEvent(300,200)
w.launcher.InputBegan:Fire(start)
input.InputChanged:Fire(pointerEvent(340,220,Enum.UserInputType.MouseMovement))
input.InputEnded:Fire(start)
assert(not w.Opened,"A drag must not open the window")
w.launcher.InputBegan:Fire(start)
input.InputEnded:Fire(start)
assert(w.Opened,"A tap must open the window")
w:SetTheme("Light")
assert(w:GetTheme()=="Light")
w:Destroy()
assert(not UI.Window and not w.dismissModal and next(w.tweens)==nil)
print("Neo Sidebar state, HSV, catalogue, resize and launcher: OK")
