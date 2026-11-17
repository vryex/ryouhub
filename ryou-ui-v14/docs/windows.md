# Ventanas

`UI:CreateWindow(options?)` devuelve una ventana. Crear otra con el mismo objeto `UI` destruye la anterior. `Window:Destroy()` libera las conexiones propias, los tweens y los temporizadores de avisos. La GUI vive en `PlayerGui` y se conserva durante el respawn.

```lua
local w = UI:CreateWindow({
    Title = "Archivo", Subtitle = "Mi proyecto", Open = false,
    Size = Vector2.new(640, 380), Launcher = true, Resizable = true,
})
w:Tab({ Title = "Inicio", Icon = "home" })
w:OnClose(function() print("Ventana cerrada") end)
w:Open()
```

`SetSize(Vector2)` interpreta dimensiones en píxeles. También acepta el `UDim2.fromOffset` de V12. `GetSize()` devuelve el tamaño solicitado. La ventana se ajusta al área segura disponible. `SetPosition(Vector2)` fija el centro en coordenadas locales de esa área y `SetToTheCenter()` vuelve al centro automático.

En móvil, arrastra el encabezado para mover la ventana o la esquina inferior derecha para redimensionarla. El botón flotante aparece al cerrar. Su umbral de 9 px distingue un toque de un arrastre. En PC, Shift derecho alterna el panel por defecto. Puedes cambiarlo con `SetToggleKey(Enum.KeyCode.F8)` o inhabilitarlo con `nil`. Si desactivas también el launcher, conserva algún camino en tu script para llamar `Open()`.
