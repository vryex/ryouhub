# Verificación

La compilación con Luau verifica sintaxis y generación de bytecode. La prueba [Smoke.client.lua](../tests/Smoke.client.lua) recorre el ciclo de creación, cambios de estado, selección, notificaciones y reutilización. Para ejecutarla, monta el módulo en ReplicatedStorage e instala la prueba como único LocalScript en StarterPlayerScripts.

## Pruebas manuales en Studio

1. Abre el ejemplo completo en escritorio, arrastra el encabezado, redimensiona desde un borde y cambia de pestaña mientras el panel entra.
2. Minimiza durante la primera entrada, arrastra el launcher sin abrirlo, toca para reabrir y cambia de modo de movimiento.
3. Prueba el emulador a 360 × 800, 740 × 360 y 1280 × 720. Comprueba área segura, scroll independiente, botón de cierre, foco y teclado nativo.
4. En el ejemplo responsive, llega a la última pestaña con scroll y vuelve a Inicio. Comprueba los botones que cambian de tamaño.
5. Expande un dropdown al final de una lista, escribe un filtro, abre otro control, cambia de pestaña y verifica que el anterior se cierre.
6. Arrastra el slider con mouse y touch, escribe manualmente un valor y abre el selector de color. Prueba el scroll del selector en horizontal.
7. Prueba tema claro y oscuro, vuelve al tema inicial y abre cada tipo de aviso. Cierra y recrea el módulo desde la prueba de humo.
8. Captura el modo escritorio y el perfil móvil. Graba la entrada desde una sesión nueva para mostrar la secuencia original.

La ejecución real en cliente, las capturas y el teclado físico de Android requieren una sesión de Roblox Studio o un dispositivo.
