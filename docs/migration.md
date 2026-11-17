# Migrar a V14

1. Añade `RyouUI.lua` como `ModuleScript` y carga la biblioteca con `require` desde el cliente.
2. Reutiliza tus opciones de `CreateWindow`, `Tab` y los controles. Conserva los callbacks legítimos de tu experiencia.
3. Sustituye iconos históricos por nombres del catálogo nativo o registra tus propios IDs.
4. Comprueba los argumentos de [referencia](api-reference.md) y prueba el redimensionamiento y el ciclo de destrucción con tu experiencia.

| Uso anterior | V14 |
| --- | --- |
| Llamadas de ventana y controles | Se conservan los nombres principales de V12. |
| `Dropdown:Open()` | Ahora es idempotente. Para alternar, llama a `Dropdown:Toggle()`. |
| `Menu`, tarjetas de sesión y wrappers Concept C | La navegación y el contenido tienen estructura propia. Los nombres de instancias internas pueden cambiar. |
| Iconos PNG desde un entorno cliente particular | La ruta pública utiliza dibujos nativos o IDs de Roblox. |
| Persistencia global de tema o estados | Guarda preferencias en tu aplicación y vuelve a pasarlas al crear la ventana. |
| Grupo `Open` y `Close` | Alias de compatibilidad que devuelven el grupo. El encabezado se presenta sin colapsar. |

La V14 usa `PlayerGui` mediante un LocalScript. Las instalaciones previas conservan su punto de entrada histórico.
