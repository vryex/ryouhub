# Procedencia y licencia

El alcance de esta rama añade una biblioteca visual, glifos de segmentos diseñados para V14, SVG editables, una exportación PNG, documentación y ejemplos. La ejecución usa servicios nativos de Roblox y no importa módulos externos ni descarga recursos por su cuenta. El único mecanismo de imagen externa acepta IDs que registra el consumidor de la biblioteca.

Se revisaron las firmas de `ui/compat.lua` en `ryou-ui-v12-crafted` y los nombres de los PNG en `icons/`. Los PNG históricos permanecen en su ubicación original y no se empacan con V14. La revisión no confirma los derechos ni la procedencia de esos recursos, tampoco los de otros directorios históricos. La ruta visual nueva usa geometría propia y conserva alias por nombre.

La [licencia MIT](../LICENSE) cubre `RyouUI.lua` y el código original de los ejemplos y pruebas de V14. El módulo de un solo archivo incluye el aviso completo de licencia para su distribución independiente. Los SVG y PNG independientes, los textos de las guías y los archivos históricos quedan fuera de su alcance.

Neo Sidebar reconstruye el monograma y el lenguaje visual a partir del paquete de referencia suministrado por Ryou. El JPG del master es un mockup de documentación. El runtime usa geometría propia y no carga esa imagen. Los recursos gráficos se entregan como fuentes de diseño y permanecen fuera del alcance de la licencia del código.
