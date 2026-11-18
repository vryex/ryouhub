# RyouHub V14 · Neo Sidebar V8 · QA visual

**Autor:** Ryou  
**Base:** PR #25 (hub completo V7)  
**Biblioteca:** PR #26, versión `14.2.0` fijada al commit `56ed95d21ece5614fd70d9b69589559e19343a80`

## Correcciones y causas

- **«Abrir» repetido:** `Tab:Button` usaba `"Abrir"` como etiqueta predeterminada. En V8, las acciones normales usan una fila compacta con título/explicación y una flecha táctil a la derecha. CTA explícitos conservan su propio texto y apariencia.
- **Outfits demasiado pequeño:** altura anterior máxima de 280 px y preview del 36 % de ancho. V8 aumenta a 385–560 px en horizontal, usa preview 42–45 %, amplía la imagen y pagina 48 resultados por página; se mantiene la búsqueda, miniatura, previsualización y aplicación originales.
- **Cabecera saturada:** V8 no muestra badge ni botones cloud/bell sin configuración y callbacks. Mantiene lupa, minimizar y cerrar. El hub pasa `SafeTopInset=62` para intentar evitar la franja de controles de Roblox.
- **Textos suavizados:** V8 cambia el contenedor raíz `CanvasGroup` por un `Frame` que no compone toda la UI en textura. Mantiene entrada/salida por posición y escala; el resultado visual exacto depende del cliente Android.
- **Logo de color fijo:** la R usa el PNG `logo_mono` oficial y se tiñe mediante `ImageColor3 = Accent`. No altera la estructura del símbolo.

## Pruebas manuales en Android

1. Comparar las letras de V7 y V8 con escala 100 %, incluyendo descripciones y encabezados, con la misma configuración gráfica del juego.
2. Cambiar temas Menta, Ámbar, Violeta, Perla y colores RGB. Comprobar la R en cabecera y hero con caché vacío y caché existente.
3. Arrastrar y ampliar la ventana. Verificar que la cabecera no tape el título ni quede bajo los iconos del juego.
4. Revisar Inicio, Skybox, Fondo y Configuración: botones normales de una sola fila sin «Abrir» genérico. Confirmar que conservan callbacks.
5. Mover sliders por touch, abrir dropdowns y color pickers, cerrar y reabrir sin eventos duplicados.
6. En Outfits, consultar más de 120 resultados; cambiar páginas, filtrar, verificar preview y aplicar skin.
7. Comprobar que el scroll en Outfits se pueda usar sin desplazar el juego y que el botón Aplicar esté visible.
8. Verificar que TP Slash, Auto Shoot, Hitbox, ESP, skybox, animaciones R15 y sistema de configs mantienen su lógica original.
9. Ejecutar smoke en Roblox Studio o cliente Android y tests Luau CLI. No se afirman ejecutadas hasta verificarlas.

## Estado

Las rutas RAW y la igualdad exacta de Lua/TXT se verifican en GitHub. La biblioteca tiene pruebas de estado añadidas, pero no se ejecutaron en Luau CLI dentro de este entorno. No fusionar la rama hasta completar las pruebas de UI en Android.
