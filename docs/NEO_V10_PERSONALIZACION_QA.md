# RyouHub V14 · Neo Sidebar V10 · Fondos y Personalización

**Creador:** Ryou  
**Origen:** PR #29 (V9 integrado).  
**Biblioteca independiente:** Neo Sidebar V10, revisión exacta `41c1fcda721f25bb69140ab72b7f0c2ccabd9354`.  
**Archivos:** `scripts/RyouHub_V14_NeoSidebar_V10.lua` y `.txt` idénticos.

## Funcionalidad

- En **Inicio** vuelve la R ilustrada original en el banner. La cabecera conserva «RyouHub», con Hub teñido según el tema y sin icono duplicado.
- Los fondos artísticos de la barra lateral y contenido usan dimensiones locales fijas para no escalar ni desplazarse al redimensionar.
- La nueva pestaña **Personalización** reúne presets, acento, fondo base, fuentes, transparencia, velocidad y escala de animación y fondos personalizados.
- **Fondo** sigue como acceso rápido a Personalización, para no perder esa entrada en la barra lateral.
- **Configuración** queda reservada para el Gestor de Configs. Los ajustes se siguen guardando como `UIAppearance` y `Fondo`, compatibles con el esquema de configuración anterior.
- Incluye un icono de Pinterest rojo y blanco, campo de URL y botón para aplicar.
- Acepta PNG/JPEG por HTTPS. Si el enlace es una página, intenta obtener la URL de su etiqueta OG o una referencia pública de `i.pinimg.com`. No ejecuta JavaScript de terceros.
- Los archivos se guardan bajo `Ryou/Assets/UserWallpapers/` con un hash determinista de la URL y se reutilizan cuando el entorno ofrece `isfile`, `writefile`, `readfile` y `getcustomasset`/`getsynasset`.
- Las páginas que requieren sesión o bloquean la lectura pueden no funcionar. En Pinterest, normalmente conviene usar la URL directa de la imagen en `i.pinimg.com`.
- Se ocultan los encabezados repetidos en páginas cuando coinciden exactamente con la pestaña, y Auto Shoot deja solo la descripción bajo su título.

## QA necesario en Roblox Android

1. Abrir Inicio con caché fría/caliente y confirmar la R grande oficial del banner.
2. Redimensionar ancho y alto, comparar el arte en Información y la barra lateral: debe permanecer fijo.
3. Probar un enlace directo `https://i.pinimg.com/...` a PNG/JPG, sin autenticar.
4. Probar una página Pinterest pública y otra web con `og:image`, y observar error claro si no permiten lectura.
5. Reiniciar y reaplicar el mismo enlace sin nueva descarga, cuando hay acceso a archivos.
6. Guardar/restaurar config, comprobar `UIAppearance` y `Fondo` sin romper presets, slider ni dropdown.
7. Entrar en Auto Shoot y TP Slash: deben mostrar una cabecera de pestaña, sin título duplicado.
8. Verificar que la imagen de fondo nunca tape controles, Outfits, modales ni buscador.
9. Comprobar icono Pinterest y restauración del fondo predeterminado.
10. Repetir la prueba del hub completo (ESP, Auto Shoot, TP Slash, Movimiento, Skybox, outfits, animaciones R15).

**Estado:** inspección estática disponible. No se ejecutaron pruebas en cliente Roblox Android ni compilación Luau CLI en el entorno de preparación. Mantener PR como borrador hasta probarlas.
