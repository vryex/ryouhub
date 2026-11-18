# Ryou UI 14.4.0 · Neo Sidebar V10 · Validación

**Creador:** Ryou · Basado en V9 (PR #28).

## Cambios que deben verificarse en Android

- Imagen oficial `logo_hero` restaurada en el banner de Inicio. No reaparece la R junto al título de cabecera.
- El patrón del rail está anclado a coordenadas locales fijas (posición superior 225 px) y usa recorte interior; el fondo de contenido también tiene dimensiones fijas. El resize no debe desplazar el arte, aunque sí cambia qué parte queda visible.
- `Window:GetWallpaperLayer()` devuelve un `ImageLabel` dentro del contenido, debajo de las páginas; sirve para imágenes de usuarios sin tapar títulos y botones.
- El icono `pinterest` aparece en `UI:GetIcons()`, y en elementos que pidan `Icon="pinterest"`.
- `Tab:Paragraph` y `Tab:Section` evitan duplicar títulos que ya muestra la pestaña.
- El sistema de menús de V9 se conserva.

## Casos de regresión

1. Ajustar ventana de estrecha a amplia y variar la altura. Verificar que la decoración permanezca fija y sin salto alrededor de Información.
2. Verificar el logo de Inicio después de cargar con la carpeta de caché vacía y con imágenes cacheadas.
3. Importar una URL PNG o JPG de Pinterest (i.pinimg.com) y otra web: fondo visible bajo los controles.
4. Abrir Colorpicker, dropdowns, Outfits y modales; comprobar que siempre queden interactivos.
5. Entrar en Auto Shoot y TP Slash y confirmar una sola cabecera.
6. Ejecutar `tests/NeoState.lua` con el mock y hacer una prueba real en Roblox Android.

**No hay verificación física de Android ni certificación de Luau CLI en este cambio.**