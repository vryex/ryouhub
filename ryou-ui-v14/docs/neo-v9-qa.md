# Neo Sidebar V9 · Validación visual de Android

**Creador:** Ryou. **Origen:** V8, PR #26.

## Correcciones incluidas

- Acciones estándar reducidas a filas fijas de título + descripción (hasta dos líneas) y botón táctil de 35 px. No necesitan calcular altura mediante `AbsoluteSize`.
- La cabecera deja únicamente «RyouHub», con `Hub` ligado a `Accent`; no se dibuja la R duplicada a la izquierda del título. El hero y el launcher conservan el logo oficial.
- Las esquinas utilizan el `UICorner` de la raíz, encabezado y rail; no se aplica un recorte rectangular a la raíz. El arte de fondo redondea sus propios bordes.
- La imagen del fondo se atenúa al acercarse a la sidebar, evitando una línea abrupta en el margen.
- Reabrir no reconstruye ni anima las pestañas: conserva `Selected` y `CanvasPosition`; la primera apertura sigue animada.
- `SafeTopInset` permanece opcional para clientes que sí necesiten margen; el hub integrado lo establece a 0 para permitir subir la ventana.

## Pruebas

1. En Roblox Android, ampliar y reducir la ventana varias veces. Examinar las cuatro esquinas en diferentes escalas.
2. Mover el hub hacia arriba hasta el borde permitido por `DeviceSafeInsets`; comprobar que no se atasca 62 px antes.
3. Navegar a Auto Shoot y comprobar que la imagen ambiental se desvanece antes de la separación con el rail.
4. Comprobar `RyouHub` en cabecera tras cambiar color de tema; el logo debe seguir visible en Inicio y launcher, no junto al título.
5. Navegar a Configuración y TP Slash; los botones normales deben ser compactos y las explicaciones no deben solaparse.
6. Minimizar y reabrir repetidas veces en la misma pestaña y posición de scroll; comprobar que las imágenes no se recargan.
7. Probar los menús internos y modales cerca de los bordes redondeados, incluyendo el color picker y dropdown.
8. Ejecutar `tests/run-cli.py` con Luau CLI/luau-compile, luego realizar QA físico en Android.

Los tests de estado se ampliaron pero **no se han ejecutado desde este entorno**. No afirmar que el dispositivo ha pasado pruebas.
