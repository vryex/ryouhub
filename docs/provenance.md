# Alcance y atribución

El punto de partida de `ui/RyouUI.lua` es `ui/compat.lua` de `ryou-ui-v12-crafted` en `aeb1de076fa2e7bf8c0f82ad7889569c4923daa2`. Ese archivo deriva de la biblioteca visual anterior del proyecto. V14 usa servicios del motor Roblox y no importa módulos de terceros durante la ejecución. Los ejemplos no enlazan lógica específica de otros juegos.

Los SVG de `branding/` y los dibujos nativos de V14 se crearon para esta versión. Los PNG de `icons/` ya estaban en el historial. Sus nombres coinciden en varios casos con convenciones de Lucide, pero el nombre no acredita procedencia ni licencia. V14 no los empaqueta ni los descarga. Fondos opcionales y nuevos iconos de imagen se suministran mediante IDs de Roblox elegidos por quien integra la biblioteca.

**Propuesta de licencia.** MIT para código original de la biblioteca y ejemplos, con atribución a Ryou, una vez confirmados los derechos sobre las partes heredadas y la autorización para licenciar. La propuesta no se extiende a imágenes históricas ni a otros componentes del repositorio. No se ha añadido un archivo de licencia.
