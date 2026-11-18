# RyouHub V14 · Neo Sidebar V11 · Wallpaper, Liquid Glass y pastilla

**Creador:** Ryou  
**Base:** PR #31 (hub V10).  
**Biblioteca independiente:** rama `ryou-ui-v14-neo-v11-liquid-glass`, versión `14.5.0`, commit `d2ea81aaaff7182d8c800b21a3c019eb1b9a1890`.

## Mejoras

- Wallpaper de borde a borde en la raíz del panel, visible detrás de header, rail, contenido y todas las páginas. Se ocultan las decoraciones prediseñadas de Ryou cuando hay wallpaper activo.
- Control `Liquid Glass` en Personalización, con slider de 0 a 100 %. Emplea transparencias, gradientes y bordes de la biblioteca, sin desenfocar globalmente Roblox.
- La pastilla `RyouHub` sustituye el launcher circular y se centra arriba por defecto. Se puede arrastrar y reabrir la ventana.
- El controlador de `Fondo` utiliza `Window:SetWallpaper` sin reconstruir la ventana. La caché de URLs de Pinterest y web sigue funcionando.
- El sistema de configuración guarda `LiquidGlass` y `GlassIntensity` dentro de `UIAppearance`, además de los temas y la selección de `Fondo`.
- No cambia la lógica de TP Slash, Auto Shoot, ESP, Hitbox, Movimiento, Outfits, Skybox o animaciones R15.

## Pruebas antes de fusionar

1. Aplicar fondo Pinterest y observar las cuatro zonas: cabecera, sidebar, Inicio y páginas interiores.
2. Confirmar que desaparecen las diagonales decorativas del header y fondo al activar wallpaper; al desactivarlo deben regresar.
3. Cambiar tema oscuro/claro y color de acento; comprobar que no aparece un bloque fijo encima del wallpaper.
4. Activar Glass y ajustar 0/50/100 %. Comprobar contraste y lectura de texto en Android.
5. Minimizar: launcher en forma de pastilla centrada arriba. Arrastrarlo y volver a abrir sin duplicar controles.
6. Redimensionar hub y comprobar que el fondo no queda despegado y que se preservan los bordes.
7. Reiniciar tras guardar preferencias. Deben restaurarse Glass y el último wallpaper, si hay acceso a archivos.
8. Comparar funciones del juego, galería de outfits, búsqueda, menús internos, teclado y scroll.
9. Ejecutar compilación y pruebas de estado Luau CLI en un entorno con binarios; realizar prueba real en Roblox Android.

**Verificación limitada a inspección estática de las rutas, integridad de archivos, APIS y conservación del motor. No se han ejecutado pruebas físicas ni Luau CLI.**
