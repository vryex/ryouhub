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

En móvil, arrastra el encabezado para mover la ventana o la esquina inferior derecha para redimensionarla. El botón flotante aparece al cerrar y puede permanecer visible junto al marco cuando hay espacio. Su umbral de 9 px distingue un toque de un arrastre. En PC, Shift derecho alterna el panel por defecto. Puedes cambiarlo con `SetToggleKey(Enum.KeyCode.F8)` o inhabilitarlo con `nil`. Si desactivas también el launcher, conserva algún camino en tu script para llamar `Open()`.

## Minimizar y cerrar

`w:Minimize()` oculta el panel con una animación hacia el launcher cuando está habilitado. El launcher reabre el panel. Con el launcher deshabilitado se puede volver con la tecla configurada o con `w:Open()`.

La X llama a `w:Close()` y usa la transición corta de cierre de V14. Ambas acciones conservan la pestaña, los valores y las conexiones. `OnClose` se emite una vez por cierre de una ventana abierta. `w:Destroy()` elimina la ventana y libera sus conexiones.

## Preferencias visuales

```lua
local w = UI:CreateWindow({
    Theme = "Light", Neon = true, Motion = "Reduced",
    Scale = 0.95, DecorationIntensity = 0.7,
})
w:SetNeon(false):SetScale(1.05)
```

`SetScale` conserva el tamaño lógico de `GetSize()`. La biblioteca calcula los límites con el tamaño visible del panel. El launcher conserva su área táctil. Los setters aplican los cambios en la ventana actual. Para restaurarlos entre sesiones, guarda las preferencias en tu consumidor y vuelve a pasarlas a `CreateWindow`.

`SetNeon(false)` desactiva la iluminación decorativa, el sweep y los reflejos extra. Los gradientes base, la selección, el acento y los logos siguen visibles. El PNG circular incluye su propio brillo. En modo sin neón se atenúa mediante tinte, con la misma forma y el mismo archivo.

La apertura por toque parte visualmente del launcher. En `Full` la primera secuencia dura hasta unos 740 ms y solapa las fases. Después usa 210 ms. `Reduced` acorta las transiciones y omite la puesta en escena inicial, y `Off` aplica el estado final de inmediato.
