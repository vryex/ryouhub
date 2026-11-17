-- ModuleScript opcional de ejemplo. La función recibe la biblioteca de cualquier host compatible.
return function(UI, options)
    local config=table.clone(options or {})
    config.Title=config.Title or "Ryou UI"
    config.Subtitle=config.Subtitle or "Created by Ryou"
    if config.Open == nil then config.Open = false end
    local w=UI:CreateWindow(config)
    local function page(title, icon)
        return w:Tab({Title=title,Id=title,Icon=icon,ShowTitle=title=="Controles",
            Desc=title=="Controles" and "Componentes interactivos de Neo Sidebar" or nil})
    end
    local home=page("Inicio","home")
    local controls=page("Controles","grid")
    local outfits=page("Apariencia","user")
    local sky=page("Skybox","image")
    local prefs=page("Ajustes","sliders")
    local function toast(title,text)
        w:Notify({Title=title,Content=text,Type="success"})
    end

    home:Banner({Title="Ryou",AccentText="UI",Subtitle="Biblioteca visual para Luau"})
    local action,status=home:Columns({Split=.53,MinWidth=334})
    action:Button({Title="Acción de prueba",Desc="Muestra un aviso de Neo Sidebar.",Icon="bell",
        Action="Mostrar aviso",Primary=true,Callback=function() toast("Todo listo","El showcase está activo.") end})
    status:Section({Title="Estado",Icon="activity",Badge="Listo"})
    status:Stats({{Icon="layers",Value="V14",Text="Versión"},{Icon="activity",Value="Estable",Text="Estado"},
        {Icon="palette",Value="Neo",Text="Diseño"}})
    home:Section({Title="Accesos rápidos",Icon="grid"})
    local left,middle,right=home:Columns({Count=3,MinWidth=360,Cards=false})
    left:Button({Title="Controles",Icon="grid",Compact=true,Callback=function() controls:Select() end})
    middle:Button({Title="Apariencia",Icon="user",Compact=true,Callback=function() outfits:Select() end})
    right:Button({Title="Ajustes",Icon="sliders",Compact=true,Callback=function() prefs:Select() end})

    prefs:Banner({Title="Ajustes",Subtitle="Configuración y preferencias",Height=83})
    local presets,settings=prefs:Columns({Split=.43,MinWidth=405})
    settings:Section({Title="Apariencia de interfaz",Icon="sliders"})
    local theme = settings:Dropdown({Title="Tema",Values={"Oscuro","Claro"},
        Value=w:GetTheme()=="Light" and "Claro" or "Oscuro",
        Callback=function(value) w:SetTheme(value=="Claro" and "Light" or "Dark") end})
    local neon = settings:Toggle({Title="Efectos neón",Value=w:GetNeon(),
        Callback=function(value) w:SetNeon(value) end})
    local motionModes = {Completas="Full",Reducidas="Reduced",Desactivadas="Off"}
    local motionLabels = {Full="Completas",Reduced="Reducidas",Off="Desactivadas"}
    local motion = settings:Dropdown({Title="Animaciones",Values={"Completas","Reducidas","Desactivadas"},
        Value=motionLabels[w:GetMotion()],Callback=function(value) w:SetMotion(motionModes[value]) end})
    local scale = settings:Slider({Title="Escala de interfaz (%)",Min=85,Max=120,Step=5,
        Default=w:GetScale()*100,Callback=function(value) w:SetScale(value/100) end})
    local intensity = settings:Slider({Title="Intensidad de decoración (%)",Min=0,Max=100,Step=5,
        Default=w:GetDecorationIntensity()*100,Callback=function(value) w:SetDecorationIntensity(value/100) end})
    presets:Section({Title="Presets",Icon="layers"})
    presets:Button({Title="Restablecer apariencia",Icon="success",Compact=true,Callback=function()
        theme:Set("Oscuro")
        neon:Set(true)
        motion:Set("Completas")
        scale:Set(100)
        intensity:Set(100)
        w:SetTheme("Dark"):SetNeon(true):SetMotion("Full"):SetScale(1):SetDecorationIntensity(1)
    end})
    presets:Section({Title="Preferencias de muestra"})
    local notifications=true
    presets:Toggle({Title="Notificaciones",Desc="Muestra avisos de preferencias.",Value=notifications,
        Callback=function(value) notifications=value end})
    presets:Input({Title="Nombre del perfil",Placeholder="Mi perfil",Callback=function(value)
        if notifications then toast("Perfil actualizado",value) end
    end})

    local basics,selection=controls:Columns({Split=.48,MinWidth=372})
    basics:Section({Title="Básicos",Icon="info"})
    basics:Toggle({Title="Activar prueba",Desc="Cambia el estado de este control.",Value=true})
    basics:Toggle({Title="Alternar selección",Value=false})
    local demoIntensity=basics:Slider({Title="Intensidad",Min=0,Max=100,Default=75,Step=1})
    basics:Slider({Title="Velocidad",Min=0,Max=3,Default=1.5,Step=.05})
    basics:Button({Title="Restablecer",Icon="activity",Compact=true,Primary=true,Callback=function()
        demoIntensity:Set(75)
        toast("Valores restablecidos","Intensidad: 75")
    end})
    selection:Section({Title="Entrada y selección",Icon="sliders"})
    selection:Input({Title="Nombre personalizado",Placeholder="Ingresa un nombre..."})
    selection:Dropdown({Title="Modo de interfaz",MultiSelect=true,Values={"Moderno","Compacto","Clásico","Minimalista","Experimental"},
        Value={"Moderno","Compacto"}})
    selection:Colorpicker({Title="Visuales",Value=Color3.fromRGB(73,245,184),Callback=function(color)
        w:SetTheme({Name=w:GetTheme(),Accent=color})
    end})

    outfits:Banner({Title="Apariencia",Subtitle="Prueba la galería de outfits",Height=83})
    local wardrobe={}
    local styles={"Menta","Carbón","Bruma","Cereza","Tinta","Perla","Violeta","Sol","Óxido","Pino","Nube","Lila"}
    local palette={0x55D9AB,0x354747,0xB0BAC0,0xCF7F9D,0x191922,0xE9E8E5,0x8961CD,0xEBC666}
    local function swatch(value)
        return Color3.fromRGB(bit32.extract(value,16,8),bit32.extract(value,8,8),bit32.extract(value,0,8))
    end
    for index,title in ipairs(styles) do
        wardrobe[index]={Id="demo-"..index,Title=title,Art="Avatar",Tint=swatch(palette[(index-1)%#palette+1])}
    end
    outfits:Gallery({Title="Outfits de muestra",Icon="grid",Items=wardrobe,OnApply=function(item)
        toast("Outfit seleccionado",item.Title.." · "..item.Id)
    end})

    sky:Banner({Title="Skybox",Subtitle="Explora las muestras de cielo",Height=92})
    local chosen=sky:Paragraph({Title="Skybox actual",Desc="Cielo azul · muestra visual",Icon="image"})
    local samples={
        {Id="day",Title="Cielo azul",Desc="Azul profundo con reflejos fríos",Art="Swatch",Tint=swatch(0x48ADFF)},
        {Id="sunset",Title="Atardecer",Desc="Naranja cálido con sombra violeta",Art="Swatch",Tint=swatch(0xF5A45C)},
        {Id="galaxy",Title="Galaxia",Desc="Índigo con bandas violetas",Art="Swatch",Tint=swatch(0x956FFF)},
        {Id="aurora",Title="Aurora",Desc="Verde menta en fondo frío",Art="Swatch",Tint=swatch(0x3CE7AC)},
        {Id="storm",Title="Tormenta",Desc="Azul grisáceo y carbón",Art="Swatch",Tint=swatch(0x738AA7)},
    }
    sky:Catalog({Title="Biblioteca de cielos",DialogTitle="Seleccionar Skybox",DialogDesc="Explora el catálogo de muestra.",
        Items=samples,Value="day",OnApply=function(item)
            chosen:SetDesc(item.Title.." · muestra visual")
            toast("Muestra aplicada",item.Title)
        end})
    return w
end
