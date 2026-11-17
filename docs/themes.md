# Temas

`Ryou` usa carbón y menta. `Blanco` usa fondo claro con acento verde oscuro. `Claro`, `Light` y `White` también seleccionan el tema claro. Por compatibilidad, el tema oscuro se devuelve con la clave `Xero`.

```lua
window:SetTheme("Blanco", true)
local current = window:GetTheme()
print(current)
```

Pasa `Accent = Color3.fromRGB(r, g, b)` al crear la ventana para personalizar el acento en ambos temas. Usa un color que contraste con la superficie del tema elegido. El texto principal y secundario conservan sus tonos del tema. Para cambiar el acento después, crea otra ventana y restaura el estado de tus controles. La biblioteca no cambia por sí sola las preferencias del jugador.
