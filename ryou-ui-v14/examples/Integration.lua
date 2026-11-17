-- Funciona con el objeto UI obtenido por require o por un cargador compatible.
return function(UI, state, persist)
    local window = UI:CreateWindow({ Title = "Ajustes del proyecto", Open = false })
    local tab = window:Tab({ Title = "Preferencias", Icon = "sliders" })
    local contrast = tab:Toggle({ Title = "Tema claro", Value = state.light == true, Callback = function(enabled)
        state.light = enabled
        window:SetTheme(enabled and "Light" or "Dark")
        persist(state)
    end })
    window:SetTheme(contrast:Get() and "Light" or "Dark")
    window:Open()
    return window
end
