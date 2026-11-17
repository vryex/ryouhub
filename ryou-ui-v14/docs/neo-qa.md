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

## Capturas para comparar en Roblox

1. Ejecuta el showcase con Play y captura en 1672 × 941. Abre Inicio y compáralo con 01. Luego repite en 1536 × 709, 853 × 394, con un viewport por debajo de 560 px y en un dispositivo Android horizontal.
2. En frío, confirma que la R, la diagonal y el launcher aparecen al cargar. Abre y cierra la ventana, reinicia la biblioteca y confirma que reutiliza los PNG locales. Comprueba nitidez de cabecera y tamaño del hero al lado de 01.
3. Abre Ajustes y despliega el selector. Captura con 02. Selecciona dos valores en Controles y usa 07 para revisar el menú y el toast.
4. Abre Apariencia y selecciona una miniatura. Captura con 03. Desplaza la cuadrícula y comprueba que Aplicar sigue accesible en el panel de preview.
5. Abre Visuales desde Controles. Captura con 04. Arrastra en el cuadro SV y en la barra de tono, prueba HEX, confirma y repite con Cancelar.
6. Abre Skybox y captura la lista y la vista previa. Compara con 05–06. Prueba filtro vacío, retorno a la lista y confirmación.
7. Prueba Full, Reduced, Off y cierre durante la entrada. Arrastra el launcher y verifica que soltar conserva el estado de la ventana.

Coloca cada captura renderizada junto a su mockup. Distingue resolución, escala y plataforma. Las imágenes del concepto no cuentan como resultados de ejecución.

La galería y Skybox usan muestras ficticias. El texto, las miniaturas y el material del master corresponden al diseño de referencia. El render y la decodificación de PNG mayores de 1024 px quedan pendientes en el cliente real.
