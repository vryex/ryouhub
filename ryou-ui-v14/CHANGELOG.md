# Cambios

## 14.5.0 · Neo Sidebar V11 · Wallpaper completo y Liquid Glass

- Los fondos personalizados se dibujan bajo **toda** la ventana, incluyendo cabecera y sidebar, en una única capa. Se ocultan las decoraciones de Ryou mientras exista un wallpaper activo.
- Añade `Window:SetWallpaper(assetId,transparency)` y `Window:HasWallpaper()`, sin reconstruir controles ni descargar de nuevo el tema.
- Estilo Liquid Glass opcional mediante `SetGlassMode` y `SetGlassIntensity`: transparencias moderadas y reflejos sobre tarjetas, botones, barra lateral y cabecera. No usa un `BlurEffect` global sobre Roblox.
- Las preferencias Glass se guardan en `ExportAppearance` e importan desde `ImportAppearance`.
- Launcher circular sustituido por una **pastilla de 152 × 44 px** situada arriba y centrada por defecto, todavía táctil y arrastrable. El menú conserva animaciones de abrir/cerrar y el icono circular deja de descargarse.
- El encabezado sigue mostrando RyouHub con Hub en el color del tema; el hero conserva la R ilustrada oficial.
- No se modifica la API de Outfits, color pickers, dropdowns ni callbacks.


## 14.4.0 · Neo Sidebar V10 · Personalización y fondos estables

- Recupera la imagen ilustrada original del monograma R en el banner de Inicio. La cabecera sigue sin la R duplicada.
- Los adornos del sidebar y del contenido usan coordenadas locales fijas, sin estirarse ni trasladarse al redimensionar la ventana.
- Añade una capa de wallpaper detrás de páginas y tarjetas, expuesta como `Window:GetWallpaperLayer()` y `UIElements.Wallpaper`; su colocación evita tapar los controles.
- Incluye un glifo Pinterest rojo con P blanca, sin requerir descargar imágenes adicionales.
- Evita cabeceras repetidas cuando un `Paragraph` o `Section` inicial repite exactamente el nombre de la pestaña.
- Conserva búsqueda, modales, outfits y la API del motor de temas.


## 14.3.0 · Neo Sidebar V9 · Bordes y limpieza

- Botones normales de altura estable (37/53 px de contenido, 35 px de acción), sin expansión basada en AbsoluteSize.
- Título de cabecera `RyouHub` con `Hub` coloreado por el acento; se elimina la R duplicada junto al título, pero se conserva el logo original en Inicio y el launcher.
- Esquinas coherentes: se elimina el recorte rectangular de la raíz y se redondean el encabezado, la barra lateral y la imagen decorativa.
- El fondo de contenido se atenúa gradualmente al llegar al límite con la barra lateral para evitar cortes visuales.
- Las reaperturas reutilizan la ventana y sus estados, sin animaciones ni reconstrucción de controles.
- Sigue existiendo `SafeTopInset` como opción de biblioteca. El hub V9 usa valor 0 para permitir arrastrar hacia arriba en el área segura.


## 14.2.0 · Neo Sidebar V8 · Rediseño responsive

- La ventana raíz usa `Frame` en lugar de un `CanvasGroup` de pantalla completa; elimina esa pasada de composición que podía suavizar el texto. La apertura mantiene movimiento y escala, sin opacidad global.
- El logo usa la máscara PNG monocromática oficial y `ImageColor3` ligado al acento de tema.
- Las acciones normales muestran título, explicación y botón con flecha en una sola fila, sin el texto genérico «Abrir». Las llamadas `Primary`, `Compact` y `Action` conservan el estilo CTA.
- Sliders con pista de 5 px, agarradera de 15 px y valor separado.
- Outfits con panel mayor, preview de 42–45 % del ancho, zoom de miniatura y paginación interna de 48 por página.
- La cabecera oculta por defecto estado y acciones sin callback; admite `ShowStatus`, `ShowUtilities` y `SafeTopInset` para evitar solaparse con controles del juego.
- Se conservan dropdowns, fuentes, temas, buscador, APIs y callbacks V7.


## 14.1.0 · Neo Sidebar V7 · Personalización

- Ocho temas de acento listos para usar y colores de acento/fondo editables en vivo.
- Fuentes Gotham, SourceSans y Arial sin reconstruir las pestañas.
- Transparencia de superficies de 0 a 35 %, velocidad de animación de 0.5× a 2× y modos de movimiento conservados.
- `Window:ExportAppearance()` / `Window:ImportAppearance()` devuelven/restauran una tabla JSON segura.
- Evita generar tweens cuando el objetivo coincide con el valor actual.
- Mantiene la API V6 de búsqueda, Outfits, dropdowns, modal y launcher.
- El hub integrador puede guardar las preferencias en su propio fichero, sin imponer dependencias de sistema de archivos a la biblioteca.


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
