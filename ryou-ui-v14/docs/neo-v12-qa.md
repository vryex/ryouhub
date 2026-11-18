# Neo Sidebar V12 · QA

**Creador:** Ryou. La biblioteca base de la UI está separada del hub completo.

- Se crea una ventana nueva con Glass activado por defecto, a menos que `LiquidGlass=false` o los ajustes importados indiquen otra cosa.
- El banner de Inicio puede sustituir su logo con `Window:SetBrandLogo(contentId)`; `SetBrandLogo(nil)` restaura la R ilustrada.
- `Tab:Stats` admite `Thumbnail` (GameIcon Roblox) y etiquetas actualizables `Stat1/Value`, `Stat2/Value`, etc.
- `SetVisualEffects` ofrece Suave, Destellos o Desactivados sin RenderStepped. Un único tween de UIGradient sirve para Destellos y se destruye al cambiar de modo o cerrar la UI.
- El icono Pinterest usa `PINTEREST_BADGE_RED_64.png`, almacenado en el repositorio en una revisión inmutable.

## Pruebas pendientes
1. Probar en Roblox Android la carga del badge auténtico de Pinterest con caché limpia.
2. Comprobar que al aplicar un logo propio al banner no cambia el logo del título ni la pastilla.
3. Probar Destellos, Suave y Desactivados repetidamente y confirmar que no crean tweens adicionales.
4. Abrir y cerrar varias veces, restaurar preferencias de V11 y comprobar Glass por defecto en instalación nueva.
5. Validar miniatura de juego y texto en pantallas angostas; ejecutar tests Luau CLI antes de fusionar.

**No se han ejecutado pruebas en Roblox Android ni Luau CLI en este entorno.**