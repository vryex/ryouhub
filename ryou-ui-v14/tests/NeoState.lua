-- Fixture de Luau CLI, ejecutada junto al mock y la biblioteca por run-cli.py.
local w=UI:CreateWindow({Open=false,Motion="Off",Size=Vector2.new(1040,615)})
local root=w:Tab({Title="Inicio",ShowTitle=false})
local controls=w:Tab("Controles")
local outfits=w:Tab("Apariencia")
w.screen.AbsoluteSize=Vector2.new(596,394)
assert(not w.Compact and controls.titleLabel.Visible and outfits.titleLabel.Visible)
assert(controls.titleLabel.Text=="Controles" and outfits.titleLabel.Text=="Apariencia")
assert(outfits.labelWidths[outfits.titleLabel.TextSize]<=w.rail.Size.X.Offset-58)
local longTab=w:Tab("Preferencias avanzadas")
assert(w.Compact and not longTab.titleLabel.Visible)
w.screen.AbsoluteSize=Vector2.new(525,394)
assert(w.Compact and not outfits.titleLabel.Visible and outfits.glyph.Position.X.Scale==.5)
root:Select()
root:Banner({Title="Inicio",Subtitle="Prueba"})
local a,b=root:Columns({Split=.53})
a:Button({Title="Abrir",Compact=true})
b:Stats({{Value="V14",Text="Versión"}})
w:Open()
local selected=root:Dropdown({Title="Perfil",Items={},Values={"Menta","Oscuro"},Multi=true})
w.panel.AbsolutePosition=Vector2.new(70,40)
local trigger
for _, child in ipairs(selected.row:GetChildren()) do
    if child:IsA("TextButton") then trigger=child end
end
root.scroller.AbsolutePosition=Vector2.new(70,80)
root.scroller.AbsoluteWindowSize=Vector2.new(400,280)
trigger.AbsolutePosition=Vector2.new(250,315)
trigger.AbsoluteSize=Vector2.new(140,33)
selected:Open()
assert(selected.expanded and selected.popupPanel.Parent==w.popupLayer)
assert(selected.popupPanel.Position.Y.Offset<trigger.AbsolutePosition.Y-w.panel.AbsolutePosition.Y)
assert(selected.popupPanel.Position.Y.Offset+selected.popupPanel.Size.Y.Offset<=w.panel.Size.Y.Offset)
w.popupLayer:FindFirstChild("DismissPopup").Activated:Fire()
assert(not selected.expanded and not w.popup and not w.popupLayer.Visible)
selected:Open()
controls:Select()
assert(not selected.expanded)
local headerSearch=w.header:FindFirstChild("HeaderSearch")
headerSearch.Activated:Fire()
assert(w.popup and w.popup.panel.Name=="SearchPopup")
local searchPopup=w.popup.panel
local query, found
for _, child in ipairs(searchPopup:GetChildren()) do
    if child:IsA("TextBox") then query=child end
end
query.Text="perfil"
for _, child in ipairs(searchPopup:GetDescendants()) do
    if child:IsA("TextButton") and child.Text=="Inicio · Perfil" then found=child end
end
assert(found)
found.Activated:Fire()
assert(w.CurrentTab==root and not w.popup)
selected:Open()
selected:Destroy()
assert(not w.popup and not w.popupLayer.Visible)
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
    local bounds=Vector2.new(w.panel.Size.X.Offset,w.panel.Size.Y.Offset)
    w.frame.AbsoluteSize=bounds
    catalog:Open()
    local layer=w.panel:FindFirstChild("ModalVeil")
    local card=layer:GetChildren()[1]
    local found = false
    for _, node in ipairs(card:GetDescendants()) do
        if node.Name=="ToolDialog" then found=true end
    end
    assert(found)
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
local closes = 0
w:OnClose(function() closes += 1 end)
local minimize, close = w.header:FindFirstChild("Minimize"), w.header:FindFirstChild("Close")
assert(minimize:FindFirstChild("Plate").Size.X.Offset < minimize.Size.X.Offset)
minimize.Activated:Fire()
assert(not w.Opened and w.launcher.Visible and not w.Destroyed and closes==1)
w:Open()
close.Activated:Fire()
assert(not w.Opened and w.CurrentTab==root and gallery:Get()==33 and not w.Destroyed and closes==2)
w:SetTheme("Light")
assert(w:GetTheme()=="Light")
w:Destroy()
assert(not UI.Window and not w.dismissModal and next(w.tweens)==nil)
print("Neo Sidebar state, HSV, catalogue, resize and launcher: OK")


local touch = Enum.UserInputType.Touch
local move = Enum.UserInputType.MouseMovement
local ui = UI:CreateWindow({Open=false,Motion="Off",Size=Vector2.new(500,300),Scale=1.1,Neon=false})
ui.screen.AbsoluteSize = Vector2.new(900,550)
ui:Open()
assert(ui.frame.Size.X.Offset==550 and ui.panel.Size.X.Offset==500 and ui.panelScale.Scale==1.1)
assert(not ui:GetNeon() and not ui.headerRibbon.Visible and ui:GetMotion()=="Off")
local function at(x,y,kind)
    return {Position={X=x,Y=y},UserInputType=kind}
end
local function moveTo(event,x,y)
    event.Position = {X=x,Y=y}
    input.InputChanged:Fire(event)
end
local first = at(395,148,touch)
local second = at(700,165,touch)
local centerX,centerY = ui.frame.Position.X.Offset,ui.frame.Position.Y.Offset
assert(ui.dragZone.ZIndex<ui.header:FindFirstChild("Minimize").ZIndex)
assert(ui.dragZone.ZIndex<ui.headerTools[1].ZIndex and ui.dragZone.BackgroundTransparency==1)
ui.header:FindFirstChild("Minimize").InputBegan:Fire(first)
assert(not ui.gesture)
ui.dragZone.InputBegan:Fire(first)
assert(ui.frame.Position.X.Offset==centerX and ui.frame.Position.Y.Offset==centerY)
ui.dragZone.InputBegan:Fire(second)
moveTo(second,800,240)
input.InputEnded:Fire(second)
assert(ui.gesture.event==first and ui.frame.Position.X.Offset==centerX)
moveTo(first,421,166)
assert(ui.frame.Position.X.Offset==centerX+26 and ui.frame.Position.Y.Offset==centerY+18)
moveTo(first,9900,9900)
assert(ui.frame.Position.X.Offset+ui.frame.Size.X.Offset/2==892)
input.InputEnded:Fire(first)
assert(not ui.gesture)
ui:SetPosition(Vector2.new(450,275))
local resize = at(695,429,touch)
ui.resize.InputBegan:Fire(resize)
moveTo(resize,728,451)
input.InputEnded:Fire(resize)
assert(not ui.gesture and math.abs(ui:GetSize().X-530)<.001 and math.abs(ui:GetSize().Y-320)<.001)
local mouse = at(417,173,Enum.UserInputType.MouseButton1)
local afterResize = ui.frame.Position
ui.dragZone.InputBegan:Fire(mouse)
input.InputChanged:Fire(at(410,177,move))
assert(ui.frame.Position.X.Offset==afterResize.X.Offset-7 and ui.frame.Position.Y.Offset==afterResize.Y.Offset+4)
input.InputEnded:Fire(mouse)
local scaleTab=ui:Tab("Escala")
local scaleControl=scaleTab:Slider({Title="Escala",Min=85,Max=120,
    Callback=function(value) ui:SetScale(value/100) end})
local area
for _, node in ipairs(scaleControl.row:GetChildren()) do
    if node:IsA("TextButton") then area=node end
end
assert(area)
local finger=at(200,20,touch)
area.InputBegan:Fire(finger)
assert(ui.gesture and ui.gesture.event==finger)
moveTo(finger,760,20)
assert(ui:GetScale()>1.1 and ui.gesture)
input.InputEnded:Fire(finger)
assert(not ui.gesture and scaleTab.scroller.ScrollingEnabled)
ui:Minimize()
assert(not ui.panel.Interactable and ui.launcher.Visible)
ui:Open()
assert(ui.panel.Interactable)
ui:SetScale(.5)
assert(ui:GetScale()==.85)
ui:SetScale(2)
assert(ui:GetScale()==1.2 and ui.frame.Size.X.Offset<=884)
ui:SetTheme("Light")
assert(ui.theme.Text.R<.10 and ui.theme.Muted.G<.35 and ui.theme.Primary.G>.82)
assert(not ui.headerRibbon.Visible)
ui:SetNeon(true)
assert(ui.headerRibbon.Visible and ui.headerRibbon.ImageTransparency==.92)
ui:SetNeon(false)
assert(not ui.headerRibbon.Visible)
ui:Destroy()
assert(next(ui.bindings)==nil and next(ui.tracked)==nil)

-- Keep tweens pending so interruption and launcher-origin geometry are exercised.
local tweenService=game:GetService("TweenService")
local immediate=tweenService.Create
function tweenService:Create(object,_,goal)
    local tween={Completed=signal(),Object=object,Goal=goal}
    function tween:Play() end
    function tween:Cancel() self.Cancelled=true end
    function tween:Destroy() end
    return tween
end
ui=UI:CreateWindow({Open=false,Motion="Full",Size=Vector2.new(470,280)})
ui:Tab("Inicio")
local launcherTap=at(700,550,touch)
ui.launcher.InputBegan:Fire(launcherTap)
input.InputEnded:Fire(launcherTap)
assert(ui.Opened and ui.panel.Interactable and ui.panel.Position.X.Offset>0 and ui.panelScale.Scale<1)
local entering=ui.tweens[ui.panel].tween
ui:Minimize()
assert(entering.Cancelled and not ui.panel.Interactable and ui.launcher.Visible)
local minimizing=ui.tweens[ui.panel].tween
ui.launcher.InputBegan:Fire(launcherTap)
input.InputEnded:Fire(launcherTap)
assert(minimizing.Cancelled and ui.Opened and ui.panel.Interactable)
ui:Close()
ui:Open()
ui:SetMotion("Reduced")
assert(ui.panel.Visible and ui.panel.Interactable and ui.panelScale.Scale==1 and next(ui.tweens)==nil)
ui:Close()
ui:SetMotion("Off")
assert(not ui.panel.Visible and not ui.panel.Interactable and ui.launcher.Visible and next(ui.tweens)==nil)
ui:Destroy()
tweenService.Create=immediate
print("Neo Sidebar V5: touch ownership, scale, neon, theme and interrupted motion OK")


-- V7: personalización en vivo sin reconstrucción ni pérdida de pestañas.
local presets = UI:GetThemePresets()
assert(#presets==8 and UI:GetThemes()["Violeta"] ~= nil)
assert(#UI:GetFontStyles()>=3)
local customWindow=UI:CreateWindow({
    Open=false,Motion="Off",ThemePreset="Violeta",AnimationSpeed=1.5,SurfaceTransparency=.18,
})
local customTab=customWindow:Tab("Personalización")
local customButton=customTab:Button({Title="Prueba"})
assert(customWindow:GetThemePreset()=="Violeta")
assert(customWindow:GetAccent():ToHex()=="AF76FF")
assert(math.abs(customWindow:GetAnimationSpeed()-1.5)<.001)
assert(math.abs(customWindow:GetSurfaceTransparency()-.18)<.001)
customWindow:SetFontStyle("Arial")
assert(customWindow:GetFontStyle()=="Arial")
assert(customButton.title.Font==Enum.Font.ArialBold)
customWindow:SetAccent(Color3.fromHex("AABBCC"))
assert(customWindow:GetAccent():ToHex()=="AABBCC")
customWindow:SetBackgroundColor(Color3.fromHex("101820"))
customWindow:SetAnimationSpeed(3)
assert(customWindow:GetAnimationSpeed()==2)
customWindow:SetSurfaceTransparency(.9)
assert(customWindow:GetSurfaceTransparency()==.35)
local snapshot=customWindow:ExportAppearance()
customWindow:SetThemePreset("Perla")
assert(customWindow:GetTheme()=="Light")
customWindow:ImportAppearance(snapshot)
assert(customWindow:GetThemePreset()=="Violeta")
assert(customWindow:GetAccent():ToHex()=="AABBCC")
assert(customWindow:GetBackgroundColor():ToHex()=="101820")
assert(customWindow:GetFontStyle()=="Arial")
assert(customWindow:GetSurfaceTransparency()==.35)
assert(customWindow.CurrentTab==customTab)
customWindow:Destroy()
print("Neo Sidebar V7 personalization state: OK")
