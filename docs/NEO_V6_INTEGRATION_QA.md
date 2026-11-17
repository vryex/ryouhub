# RyouHub V14 · Neo Sidebar V6 · integración

**Autor:** Ryou  
**Rama:** `ryouhub-v14-neo-v6-integrated`  
**Base:** PR #21 (`ryouhub-v14-neo-v5-integrated`)  
**Biblioteca:** PR #22 (`ryou-ui-v14-neo-v6-visual`), commit fijo `947c167c0355f9a376b70956467265e0a7a98919`.

## Cambios

- El script principal carga por URL RAW la biblioteca visual Neo Sidebar V6 (versión `14.0.0` y variante `Neo Sidebar V6`), con validación explícita de versión y variante.
- La galería anterior, creada manualmente con frames, se reemplazó por `Tab:Gallery` de la biblioteca V6. Se conserva la búsqueda por username o Outfit ID, miniaturas reales, vista previa y el motor original de aplicación del outfit.
- Se conserva la opción `Ver skins del usuario`, que inicia la consulta y desplaza el scroll hasta la galería integrada.
- El selector corporal de Auto Shoot deja de crear un `ScreenGui` de pantalla completa. Ahora se aloja dentro del panel de RyouHub.
- Dropdowns, buscador de cabecera, redimensionado y ajustes visuales siguen implementados por la biblioteca independiente del PR #22.
- Noclip permanece eliminado. No se sustituyó el hub por la demo.

## Verificación realizada

- Comprobadas las referencias a la biblioteca V6, su API `Tab:Gallery`, `Tab:Dropdown` y `Variant`.
- Comprobada la conservación de las referencias a los motores del script principal y la retirada del antiguo `RyouOutfitsUserV11` y del `ScreenGui` de selector corporal.
- Los archivos Lua y TXT son copias idénticas.
- **No se ha ejecutado Roblox Android en este entorno.** La validación estática de esta integración no sustituye una prueba real de interfaz y callbacks en el cliente.

## Checklist manual en Roblox Android

1. Ejecutar el loadstring en una sesión limpia, comprobar animación inicial y reabrir/minimizar sin duplicar UI.
2. Verificar lupa junto a minimizar, búsqueda de pestañas/controles y teclado táctil.
3. Abrir y cerrar dropdowns de varias pestañas; confirmar que nunca salgan del panel ni queden cortados.
4. En Apariencia, probar clonación por jugador, por username, búsqueda de outfits por usuario y por Outfit ID. Seleccionar miniatura, revisar vista previa y aplicar.
5. Cambiar de modo oscuro a claro y escala 85/100/120 %, comprobar nitidez de textos, imágenes y posiciones.
6. Redimensionar la ventana, verificar que el fondo decorativo no se separe por el borde izquierdo y que la galería adapte sus columnas.
7. Abrir selector corporal en Auto Shoot, confirmar que el modal queda dentro del panel y que se aplican las selecciones.
8. Probar scroll táctil, teclado móvil y cierres de menús en Android horizontal.
9. Confirmar que TP Slash, Auto Shoot, ESP, Hitbox, Movimiento, Animaciones R15, Skybox y Fondo siguen operativos con los mismos callbacks.

No fusionar sin completar las pruebas reales.
