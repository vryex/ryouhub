# QA · RyouHub V12

**Creador:** Ryou · **Base:** RyouHub V11.

### Funciones y preferencias
- Liquid Glass se activa por defecto en la biblioteca y la integración. Si existe un archivo de preferencias previo que lo desactiva, se respeta esa elección.
- El control de escala se elimina de Personalización. Redimensionar únicamente desde la esquina inferior derecha; versiones antiguas de configs se restauran a `Window:SetScale(1)`.
- El selector `Efectos de interfaz` ofrece Suave, Destellos y Desactivados. Destellos usa un solo tween de gradiente y debe detenerlo al cerrar.
- Estado muestra miniatura del juego actual, Tema y Versión. Juego utiliza el GameId del servidor y obtiene el nombre del PlaceId cuando esté disponible.
- El banner de Inicio mantiene la R original salvo que se aplique un logo público de usuario.
- Fondos Xero eliminados del selector y de `assets/backgrounds`; cuatro nuevos fondos anime originales en `assets/backgrounds/anime/`.
- El icono de Pinterest se carga desde `PINTEREST_BADGE_RED_64.png`, no se dibuja una letra P ficticia.

### Comprobar en Android
1. Arrancar en sesión limpia y verificar Glass activo al 55 % y el menú legible.
2. Abrir Personalización y confirmar que no existe slider de escala.
3. Cambiar Destellos/Suave/Desactivados; observar que no se dupliquen animaciones al reabrir.
4. Revisar la miniatura de Juego actual y tema dinámico, además de la versión V14 · 14.6.
5. Probar los cuatro fondos originales, cambiar entre ellos, redimensionar y restaurar al reiniciar.
6. Pegar PNG/JPG desde `raw.githubusercontent.com` y URL de Pinterest pública como fondos.
7. Subir logo a un fork, usar su RAW en el selector y verificar que sustituye la R del banner. Restaurar R original y probar config.
8. Probar un enlace temporal de Discord y comprobar mensajes de error cuando caduca.
9. Comprobar la ausencia de las imágenes antiguas Xero.
10. Validar Outfits, TP Slash, Auto Shoot, ESP, animaciones, búsqueda, teclados y dropdowns.

## Sincronización con el pulido de la biblioteca (PR #34)

El hub V12 fija la biblioteca en el commit `3234e3f21326e17ee50ec133f224f69b4fa05eed`:
- Tamaño del archivo en UTF-8: `146434` bytes.
- Adler-32: `469485821`.
- Nuevas tarjetas de estados vacíos, sin coincidencias, carga y error; diálogos y galería más adaptables.
- Los destellos se detienen al cerrar o minimizar y no se animan con movimiento reducido.

**Pruebas:** Work informó que compiló Luau y que pasaron las pruebas del cambio; también informó tres fallos antiguos reproducibles en la biblioteca original. Esos resultados no tienen un registro de GitHub Actions asociado al commit, por lo que aún no se han verificado de forma independiente aquí.

**Pendiente:** confirmar funcionamiento en Roblox Android, incluida carga de UI y los controles táctiles.