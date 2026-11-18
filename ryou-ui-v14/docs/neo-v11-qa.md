# Neo Sidebar V11 · Pruebas de UI

**Creador:** Ryou · **Biblioteca:** 14.5.0 · **Base:** V10.

## Funcionamiento esperado

- `Window:GetWallpaperLayer()` devuelve ahora el `ImageLabel` que ocupa toda la raíz `w.panel`, detrás del header, rail, body y modales.
- `Window:SetWallpaper(assetId,transparency)` activa el wallpaper y oculta `header_ribbon`, `rail_glow`, `background_artwork`, `hero_orbits` y el arte del banner; preserva el logo R del hero.
- `Window:SetWallpaper(nil)` restaura las decoraciones del tema original sin recargar la biblioteca.
- `SetGlassMode(true)` y `SetGlassIntensity(0…1)` ajustan la transparencia de superficies y botones de forma global. No utiliza desenfoque global que pueda alterar el juego o bajar los FPS.
- Launcher `RyouPillLauncher` (152 × 44 px), centrado por defecto en X=mitad de pantalla, Y=29 dentro del área segura de `ScreenGui`, arrastrable mediante gesto.
- `ExportAppearance` y `ImportAppearance` conservan `LiquidGlass` y `GlassIntensity` junto con temas, fuentes, escala y animaciones.

## Checklist Android

1. Usar imagen directa de Pinterest u otra web y comprobar que llega al header, sidebar y cuerpo sin quedar una franja fija del tema.
2. Con wallpaper activo, abrir Inicio y confirmar que la R ilustrada sigue visible pero no hay adornos diagonales fijos detrás.
3. Seleccionar Violeta, Perla, Menta y colores custom. Revisar contrastes de texto y botones sin efectos verdes residuales.
4. Activar Glass 0/50/100 %, especialmente sobre botones, galerías y menús. Comprobar legibilidad y que no afecta al render del juego.
5. Minimizar el hub: la pastilla debe aparecer centrada arriba. Arrastrarla, tocar para reabrir y verificar que el launcher circular no aparece.
6. Redimensionar y comprobar que todo el wallpaper cubre las cuatro esquinas y no se desplaza solo en una sección.
7. Desactivar wallpaper y confirmar que regresan las decoraciones del tema.
8. Ejecutar pruebas de `tests/NeoState.lua` con mock, compilación Luau y cliente Roblox Android antes de fusionar.

**No se ha ejecutado el cliente Roblox Android ni Luau CLI en este entorno.**
