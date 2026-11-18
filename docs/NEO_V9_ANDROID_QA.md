# RyouHub V14 · Neo Sidebar V9 · revisión de Android

**Creador:** Ryou  
**Base:** hub integrado V8 del PR #27  
**Biblioteca independiente:** `ryou-ui-v14-neo-v9-polish`, versión `14.3.0` fijada al commit `87b8898aeba7d8e8b9e75e0dd17de52c43b643f8`

## Correcciones concretas

- **Botones enormes:** el componente V8 calculaba altura con `AbsoluteSize` y podía expandirse demasiado en Android. V9 limita la altura del encabezado de acción a 37 o 53 px y utiliza una flecha de 35 px.
- **Bordes inconsistentes:** se quita el recorte rectangular de la raíz y se usan bordes redondeados independientes en cabecera, rail y arte de fondo para no recortar unas esquinas sí y otras no.
- **Separación visual brusca en Auto Shoot:** la imagen de fondo ahora se atenúa progresivamente al acercarse a la barra lateral.
- **Subir ventana:** se cambia `SafeTopInset=62` a `0`, conservando el área segura propia del dispositivo.
- **«PRINCIPAL» seguido de «RYOU»:** se usa un solo grupo de navegación. Se conservan todas las pestañas originales.
- **Cabecera:** sin R duplicada. El título «RyouHub» usa el color actual de tema en «Hub», y los logos aprobados siguen en Inicio y launcher.
- **Controles de iluminación innecesarios:** se eliminan de Configuración Efectos neón, Intensidad de decoración y Modo ahorro. El motor sigue conservando esas API para compatibilidad; el hub fuerza iluminación activa al recuperar configs antiguas.
- **Reapertura:** la misma ventana se restaura de inmediato con sus pestañas, opciones y scroll; la primera ejecución mantiene la animación original.
- **Caché de biblioteca:** la biblioteca se reutiliza en memoria durante la sesión y puede leerse desde `RyouUI-14.3.0-87b8898aeb.lua` si existe acceso a archivos. Se valida tamaño y Adler-32 contra el código fijado antes de ejecutarla. Si falta o no pasa la validación se obtiene del RAW inmutable de GitHub. Las imágenes conservan la caché de PNG ya existente.

## Regresión Android obligatoria

1. Probar `RyouHub` con el color de tema Menta, Perla, Violeta, Ámbar; revisar el texto `Hub` y la ausencia de R de cabecera.
2. Arrastrar al borde superior del área segura, derecha, izquierda y abajo; comprobar que no se atasca a 62 px.
3. Ampliar y achicar la ventana. Revisar las cuatro esquinas, sombras y trazos.
4. Entrar a Auto Shoot, Visuales y Apariencia; comprobar que el arte de fondo no quede con corte duro junto a la sidebar.
5. Revisar los botones normales de Configuración y TP Slash; confirmar texto legible en un máximo de dos líneas, sin tarjetas altas ni clipping.
6. Minimizar, reabrir y cambiar de pestaña, comprobando que no recarga el arte ni salta el scroll.
7. Reiniciar el script con caché fría y caliente, comprobando que las rutas RAW, caché V9 y los recursos PNG funcionan.
8. Guardar y cargar configuración V9 y V8 anterior. Comprobar que el usuario conserva paleta, tipografía y escala, pero no aparecen controles de ahorro.
9. Repetir Outfits (búsqueda, paginación y Aplicar), dropdowns, colorpickers y el selector corporal dentro del panel.
10. Confirmar que TP Slash, Auto Shoot, ESP, Hitbox, Movimiento, Skybox, Fondo y animaciones R15 siguen funcionando.

## Verificación y limitaciones

Se verificaron el código y las rutas exactas mediante GitHub, el pin y checksum de caché, así como la igualdad de Lua y TXT. Falta compilación Luau CLI y ejecución real en Android, que no están disponibles en el entorno de esta integración. PR en borrador hasta pasar esas pruebas.

**No fusionar automáticamente.**
