# Temas

Cada ventana mantiene su paleta. Usa `Dark` o `Light`. Los nombres heredados `Xero`, `Nox`, `Onyx` y `Ryou` resuelven a oscuro, y `Blanco` y `White` a claro.

```lua
window:SetTheme({ Name = "Dark", Background = Color3.fromRGB(20, 22, 24),
    Accent = Color3.fromRGB(132, 241, 198) })
print(window:GetTheme())
```

`UI:SetTheme(config)` actualiza la ventana vigente y deja la configuración como valor inicial de la siguiente. `window:SetTheme(config)` aplica el cambio solo a esa ventana. La configuración se reconstruye desde el tema base en cada llamada. Los dos colores personalizados son opcionales y deben ser `Color3`. Usa un fondo cercano al tema base para conservar el contraste del texto y revisa el acento sobre las superficies del tema.
