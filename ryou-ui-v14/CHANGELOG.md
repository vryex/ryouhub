# Cambios

## 14.0.0 · Neo Sidebar V6

- Desplegables anclados en una capa interna con apertura hacia arriba cuando falta espacio debajo.
- Buscador de pestañas y controles en la cabecera, junto a Minimizar.
- Menos grupos de composición alrededor del texto, bordes de ventana redondeados a píxeles y fondo ajustado a su contenedor con recorte proporcional.
- Galería adaptable con selección menta, miniaturas de proporción conservada, carga, error y vista previa con Aplicar.
- Apertura inicial automática desde el launcher cuando se configura `Open = true`.

## 14.0.0 · Neo Sidebar V5

- Monograma de cabecera aproximadamente 19 % más pequeño. El PNG aprobado conserva su proporción y el placeholder se oculta al asignar el recurso.
- Tema claro con superficies perla, texto carbón, CTA menta con texto oscuro y gradientes más suaves. Las asociaciones de tema se conservan hasta destruir el elemento.
- La cabecera mueve la ventana usando el desplazamiento del primer puntero. Los controles tienen sus propias zonas de toque y el movimiento queda dentro del área segura.
- La apertura inicial desde el launcher relaciona posición, escala e identidad del panel. Minimizar anima el regreso al launcher y reabrir usa una transición de 210 ms en modo completo.
- Ajustes en vivo de tema, neón, animaciones, escala de 85–120 % e intensidad de decoración. El showcase inicia en el launcher.
- Las pruebas cubren la selección de arte, el cambio de tema y neón, el segundo dedo, redimensionamiento a escala y transiciones interrumpidas. La validación física sigue en la matriz de QA.

## 14.0.0 · Neo Sidebar V4, acabados

- Superficies con iluminación diferenciada, contornos de opacidad variable, sombras escalonadas y reflejo en el CTA. La selección usa una base carbón con luz localizada.
- Cabecera con placas de 28 × 26 px y zonas táctiles más amplias. Minimizar anima hacia el launcher. Cerrar mantiene el comportamiento de V14 y conserva el estado de la ventana.
- El rail cambia a iconos según la medida de sus etiquetas y el espacio que necesita el panel de contenido.
- Inicio ajusta hero, acción, indicadores y accesos. Ajustes, los dropdowns y el modal de Skybox comparten los acabados de la ventana y mantienen sus acciones.

## 14.0.0 · Neo Sidebar V4

- La cabecera, el hero y el launcher muestran una sola marca por ubicación. Al registrarse el PNG local se oculta el placeholder. El hero usa el brillo integrado en su PNG original.
- El rail mide las etiquetas, ajusta el ancho y baja el tamaño de texto cuando hace falta. En ventanas por debajo de 560 px, el rail muestra iconos.
- Menos altura de banners, tarjetas y acciones. Inicio conserva dos columnas a partir de 334 px de ancho disponible en el showcase. La cabecera y las órbitas conservan la proporción de los PNG.
- Ajusta el halo ambiental, el indicador menta y la profundidad del panel. Refina entrada, hover, toque y arrastre del launcher.
- Outfits admite miniaturas y previews del consumidor y conserva Aplicar en el pie de la vista previa. PNG, rutas RAW y versión de caché se mantienen en el commit de arte V3.

## 14.0.0 · Neo Sidebar

- Recompone la ventana con el marco horizontal y el rail de la referencia 01, R facetada, launcher circular y franjas de marca.
- Añade composición por columnas, banners, galería, catálogo con preview y modal HSV con borrador.
- Conserva las firmas visuales de V14 y añade recursos SVG, exportaciones transparentes, showcase y pruebas de estado.

## 14.0.0 · Framework base

- Nueva marca geométrica, launcher flotante, panel con dos densidades de navegación y glifos nativos.
- Secuencia inicial por fases, reaperturas cortas, cancelación de tweens y modos Full, Reduced y Off.
- Controles visuales rediseñados, búsqueda y selección múltiple en dropdowns, barras HSV y avisos apilados.
- Módulo visual autocontenido, carga dinámica genérica, registro de iconos e integración mediante callbacks.
- Documentación de las firmas V12 conservadas y de las diferencias de migración.
