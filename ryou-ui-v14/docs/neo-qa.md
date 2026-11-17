# Verificación Neo Sidebar

| Área | Evidencia |
| --- | --- |
| Sintaxis y API | Luau CLI compila la biblioteca, ejemplos y pruebas. Pasa la batería de V14 previa y la de Neo Sidebar. |
| Arte publicado | Las 10 URLs de PNG y 6 de SVG respondieron por HTTPS. Sus bytes y SHA-256 coinciden con el ZIP V3, en el [commit del manifiesto](../assets/neo/manifest.json). |
| Descarga y caché | Simulación de cliente con carga diferida, solicitudes compartidas, reutilización al reabrir, reemplazo de caché corrupta, ruta plana y launcher alterno. |
| Geometría de diálogos | Prueba de límites de Skybox y ubicación del pie Aplicar en 1672 × 941, 1536 × 709 y 853 × 394. Aplicación de insets reales y teclado móvil pendientes en Roblox. |
| Navegación y dropdown | La prueba comprueba selección, apertura y cierre expandido, cambios y persistencia de la selección en Refresh. Scroll y búsqueda al tacto requieren Play. |
| HSV y catálogo | La prueba emite eventos de preview, cancelación, entrada HEX y Aplicar. Comprueba callback y valor confirmado. Los gradientes y el arrastre táctil se verifican en Play. |
| Galería | La prueba cubre selección, Refresh y estados de carga/error. El scroll independiente y el pie de preview se verifican en Play. |
| Launcher y viewport | Eventos simulados separan arrastre de toque. La geometría cambia de rail con etiquetas a solo iconos al cruzar el umbral. |
| Limpieza y motion | Se verifica cerrar con modal activo, destruir y volver a crear sin tweens activos. El ritmo y las curvas de animación requieren Roblox. |
| Carga dinámica | El ejemplo utiliza la fuente RAW fijada a un commit. Se prueba la compilación con el fragmento descargado en Luau CLI con servicios simulados. |
| Capturas | Pendiente de prueba visual. El repositorio etiqueta el master adjunto como mockup conceptual. |

```bash
python3 ryou-ui-v14/tests/run-cli.py /ruta/a/luau /ruta/a/luau-compile
```

## Capturas Android de V3 y revisión V4

Las tres capturas de Roblox Android adjuntas al encargo son de 1536 × 709. Son evidencia anterior al cambio. Contrastar V4 con el master 01 y las pantallas 02 a 07 al tomar las siguientes capturas.

| Captura V3 | Defecto observado | Ajuste V4 | Prueba pendiente en Roblox |
| --- | --- | --- | --- |
| Inicio, ventana centrada | «Contro…» y «Aparie…». R tipográfica sobre el PNG en cabecera y hero. Diagonal sobre el subtítulo. | Ancho según texto, visibilidad exclusiva del logo y franja desplazada con proporción fija. | Con caché fría y caliente, comprobar que cada logo muestra una R limpia y que ambas etiquetas se leen completas. |
| Apariencia | La vista previa de muestra aplasta el avatar. El panel llega al borde inferior de la ventana. | Preview y miniaturas con proporción fija, altura calculada a partir del espacio disponible y Aplicar fijo. | Deslizar dentro de la cuadrícula y sobre la página. Probar miniatura y preview reales enviados por el consumidor, y pulsar Aplicar. |
| Inicio, ventana desplazada | Botón y tarjeta altos. Estado queda cortado. Launcher visible junto a la ventana. | Cards y CTA más bajos, columnas de Inicio desde 334 px de contenido y launcher con feedback de toque y arrastre. | Comparar densidad con 01. Arrastrar el launcher, soltarlo sin cambiar el estado de la ventana, y abrir y cerrar con toques consecutivos. |

En Luau CLI se verificó la exclusión entre fallback e imagen en los tres lugares incluso con `IsLoaded = false`, el registro alterno, la caché fría y caliente, títulos completos a 596 × 394, iconos solos a 525 × 394 y el pie de Skybox a 1672 × 941, 1536 × 709 y 853 × 394. La prueba de Outfits valida que la miniatura y la vista previa pueden ser distintas y que el callback recibe la entrada del consumidor. Las métricas del texto se verifican con un servicio simulado.

## Sesión de validación en Android

1. Abre el showcase con el bloque del README. Captura Inicio y Apariencia en horizontal a 1536 × 709 y en un viewport lógico cercano a 853 × 394. Captura también 1672 × 941 en escritorio para comparar con el master.
2. Abre el dropdown de Ajustes, Skybox y HSV. Usa touch para el scroll, el campo HEX y Aplicar. Verifica el pie de cada modal con el teclado Android abierto y cerrado.
3. Reduce el ancho hasta que el rail pase a iconos. Aumenta el ancho y confirma que vuelven las etiquetas. Verifica los estados Full, Reduced y Off y el cierre durante la entrada.
4. Repite con caché caliente. Comprueba que la diagonal no invade el texto y que las órbitas y los avatares conservan su forma.

Pendientes el render de V4, la medición con Gotham real, las zonas seguras del dispositivo y las capturas posteriores al cambio.
