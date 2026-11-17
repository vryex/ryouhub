# Pruebas

**CLI.** Ejecuta `python3 tests/run-cli.py /ruta/a/luau /ruta/a/luau-compile` desde el paquete. Compila el módulo y los ejemplos, y ejecuta las aserciones de estado con dobles de los servicios de Roblox. Los dobles no implementan renderizado, animación en tiempo real, teclado, desplazamiento, permisos de assets o límites de memoria.

**Cliente.** Crea un módulo hermano de `Smoke.client.lua` llamado `RyouUI` y ejecuta Play. Espera el texto `Ryou UI V14: smoke OK` en Output. Para ver y probar la UI manualmente, usa `Complete.client.lua` o `Responsive.client.lua` en lugar de la prueba.

En el emulador y en un teléfono real, redimensiona a 320 px, recorre más de 12 pestañas, arrastra el launcher al borde y confirma que un arrastre no abre la ventana. En Complete prueba búsqueda, selección múltiple, teclado nativo y HSV. En Motion comprueba la primera apertura, cerrar mientras entra, reabrir y alternar Reduced y Off. Captura resultados directamente del cliente.

La suite Neo Sidebar prueba galería, catálogo y HSV en memoria, cambio de tamaño y gestos de launcher simulados. Consulta la [matriz de QA](../docs/neo-qa.md) para reproducir las comparaciones en el cliente.
