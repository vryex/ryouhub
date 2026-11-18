# Neo Sidebar V8 · Matriz de QA visual

**Autor:** Ryou. Este PR modifica la biblioteca compartida sin integrar lógica de juego.

## Cambios
- Ventana principal con `Frame` y animación de posición/escala, sin `GroupTransparency` de toda la UI; debería mejorar nitidez, pero el resultado real depende de Roblox/Android.
- Logo R basado en `logo_mono` oficial, teñido con el acento actual.
- Acciones compactas de una fila sin botones gigantes «Abrir».
- Sliders con lectura de valor separada y pista más usable.
- Galería Outfits con altura 385–560 px en panel horizontal, preview más ancho y paginación de 48 elementos.
- Cabecera sin badge ni cloud/bell por defecto. `SafeTopInset` configurable; el hub usa 62 px.

## Pruebas requeridas
1. Comparar nitidez de tipografía 100% entre V7 y V8 en Roblox Android.
2. Probar R color de tema en oscuro, Perla, Carmesí y color RGB personalizado.
3. Verificar que logo monocromático conserve alpha y silueta al cargar assets sin caché.
4. Buscar outfits de usuario con más de 120 resultados: comprobar 1 / 3, 2 / 3, búsqueda, preview y aplicación.
5. Redimensionar ventana, scroll y botones del juego, especialmente la parte superior segura.
6. Probar botón normal / CTA / compacto, cambios de tema, deshabilitar, idioma y textos largos.
7. Slider por toque y arrastre, cambio de pestaña, min/reabrir y efecto de modo ahorro.
8. Ejecutar `tests/run-cli.py` con binarios oficiales `luau` y `luau-compile`; documentar errores y corregir antes de fusionar.

**Esta nota no certifica pruebas físicas que aún no se realizaron.**