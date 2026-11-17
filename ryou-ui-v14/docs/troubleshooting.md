# Resolución de problemas

| Problema | Verificación |
| --- | --- |
| No aparece el panel | Inicia **Play**, ejecuta desde el cliente, confirma `PlayerGui` y llama `Open()` si configuraste `Open = false`. |
| El módulo no se encuentra | Usa un `ModuleScript` llamado `RyouUI` como hermano del `LocalScript`, o ajusta la ruta de `require`. |
| El cargador no instala la UI | Verifica que la respuesta sea el cuerpo Luau oficial, que el host incluya compilador y que el chunk ejecute con servicios de cliente. |
| Icono vacío | Verifica permisos y moderación del recurso. Prueba primero `Icon = "home"`. |
| Dropdown sin coincidencias | Quita el filtro, revisa `Values` y desplaza la página para alcanzar la lista. `Refresh` mantiene la selección previa. |
| El panel parece demasiado angosto | Revisa el tamaño solicitado y el área segura del cliente. Bajo 560 px cambia a navegación por iconos. |
| Un callback no se ejecuta | Comprueba que el valor haya cambiado, que no usaste `silent = true` y que el control no esté bloqueado si lo activas mediante la UI. Revisa Output para advertencias `[Ryou UI]`. |
| Ves superficies vacías o recortadas | Prueba una ventana más pequeña, revisa la calidad gráfica y registra el modelo de dispositivo y resolución. CanvasGroup usa memoria de texturas. |

Para reproducir una regresión usa [Smoke.client.lua](../tests/Smoke.client.lua) como LocalScript junto al módulo. Registra también una captura de Roblox cuando el fallo sea visual.
