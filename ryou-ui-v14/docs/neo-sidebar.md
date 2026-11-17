# Neo Sidebar

El [master 01](../assets/neo-master-mockup.jpg) es la referencia conceptual. El [mapa de componentes](neo-map.md) vincula las láminas con la implementación. El [showcase](../examples/NeoShowcase.lua) monta cinco páginas para recorrer los estados de las imágenes 01–07. El [ejemplo LocalScript](../examples/NeoShowcase.client.lua) lo monta en Play.

## Montaje

Copia `RyouUI.lua` y `examples/NeoShowcase.lua` a módulos hermanos llamados `RyouUI` y `NeoShowcase`. Copia también el LocalScript de ejemplo junto a ambos o llama a la función del showcase desde tu host Luau.

```lua
local UI = require(script.Parent.RyouUI)
local mount = require(script.Parent.NeoShowcase)
local window = mount(UI, { Motion = "Full" })
```

El cargador dinámico sigue aceptando la URL con el SHA completo del repositorio. Su API y la de ModuleScript reciben el mismo archivo. Guarda preferencias como el modo de movimiento en el almacenamiento de tu aplicación y pásalas a `CreateWindow`.

## Dimensiones y recursos

El marco parte de 1040 × 615 px. La cabecera mide 70 px o 55 px en una ventana baja. El rail parte del 18.5 % del ancho y mide la etiqueta más larga con Gotham. Utiliza un rail de 53 px con iconos si el texto completo y el ancho mínimo del contenido no caben juntos. Los componentes en columnas se apilan cuando su ancho disponible baja del mínimo. El launcher usa un disco de 70 px; aparece junto al marco cuando hay espacio y al cerrar. Arrastra el disco 9 px o más para moverlo sin alternar la ventana.

## Arte de GitHub y caché

El [manifiesto V3](../assets/neo/manifest.json) enlaza cada PNG a su URL RAW fijada, SHA-256, tamaño, ruta de caché y componente. Los detalles de la ventana usan la R vectorial de 512 px, el hero usa la R artística con su brillo integrado, y el launcher usa el disco de neón. La variante vectorial del disco queda disponible como respaldo. Las bandas de cabecera, órbitas y curva del rail son PNG independientes. El tema claro conserva la marca y oculta el arte ambiental oscuro.

`RyouUI.lua` solicita únicamente los archivos del manifiesto. Prueba `game:HttpGet` y, si hace falta, la API de solicitud del host. Valida tamaño y estructura básica del PNG antes de escribir. El identificador devuelto por `getcustomasset` o `getsynasset` se asigna al `ImageLabel`. La cabecera, el monograma y el launcher se programan primero. Al registrarse el identificador local, se oculta el placeholder antes de mostrar el PNG. El botón y su interacción siguen disponibles mientras se resuelve la imagen.

La caché de disco usa `RyouUI/Cache/be94fa3ecf37/`. Si el host impide crear carpetas, usa el prefijo `RyouUI-be94fa3ecf37-` en la raíz. Con `readfile` disponible, los archivos de caché se validan antes de registrarse. Con `isfile` como único método de consulta, se intenta reutilizar el archivo existente y se vuelve a descargar si falla el registro. Los identificadores se comparten entre las vistas del mismo módulo.

Si faltan `writefile` o las funciones de registro de imágenes locales, la librería avisa en la consola y conserva el monograma tipográfico, el launcher y los controles nativos. Si GitHub devuelve datos inesperados, realiza un segundo intento y conserva el respaldo cuando el recurso sigue indisponible. Los `SVG` editables están en [assets/neo/source](../assets/neo/source/). Las muestras del catálogo y los outfits del showcase son ilustraciones de demostración.

## Componentes nuevos

| Miembro | Contrato |
| --- | --- |
| `tab:Banner(options)` | `Title`, `Subtitle`, `Height` entre 74 y 200. Devuelve el Frame. Admite texto enriquecido en el título. |
| `tab:Columns(options)` | `Count` 2 o 3, `Split` 0.32–0.68 en dos columnas, `MinWidth`, `Cards` booleano. Devuelve dos o tres contenedores con los métodos de composición y controles de Tab. |
| `tab:Stats(items)` | Hasta tres entradas con `Icon`, `Value` y `Text`. Devuelve el Frame o `nil` si se pasa una lista vacía. |
| `tab:Gallery(options)` | Lista `Items`, `Value` opcional, `Callback(id)` al seleccionar, `OnApply(item)` al confirmar. Devuelve un control compatible con `Set`, `Get`, `Refresh`, `Lock` y `Destroy`. |
| `gallery:SetStatus(state, message?)` | `loading`, `error` o `ready`. El mensaje opcional reemplaza el texto de estado y se desactiva Aplicar mientras se carga o hay un error. |
| `tab:Catalog(options)` | `Items`, `Value`, `DialogTitle`, `DialogDesc`, `Callback(id)`, `OnPreview(item)` y `OnApply(item)`. Devuelve un control con `Open`, `Close`, `Refresh`, `Set` y `Get`. Seleccionar es provisional hasta Aplicar. |
| `tab:Colorpicker(options)` | Conserva `Value`/`Default` como Color3, `Set` y el callback. Abre una herramienta HSV con campo HEX, entrada numérica, muestras y confirmación. Cancelar o cerrar descarta el borrador. |

En galería y catálogo, cada entrada usa `Id` único numérico o de texto, `Title`, `Desc` opcional y `Thumbnail` opcional con URI de Roblox. En la galería, `Preview` permite usar una imagen de mayor tamaño en la vista previa. Si falta, se reutiliza `Thumbnail`. Se aceptan URIs `rbxassetid://`, `rbxthumb://` y `rbxasset://` que el cliente pueda resolver. `Tint` y `Art = "Avatar" | "Swatch"` son ilustraciones nativas opcionales. Los filtros comparan el título, identificador y descripción con el texto escrito. Se muestran hasta 120 resultados por filtro. `Refresh` conserva el ID seleccionado si sigue en la lista. El manejo de datos, red y efectos del juego pertenece al consumidor.

`CreateWindow` admite `Badge` (por defecto `V14 · Stable`) y `Utilities = { Cloud = fn, Notifications = fn }` opcional. Los callbacks reciben la ventana. `Tab({ ShowTitle = false })` oculta el título de página para usar un banner. `Button({ Primary = true, Compact = true })` ofrece CTA menta y accesos compactos. Las firmas previas siguen disponibles. Consulta la [referencia de API](api-reference.md) y la [migración](migration.md).

### Imágenes de avatar en Outfits

```lua
local userId = 123456 -- Sustituye por el ID que resuelva tu script.
local function avatar(size)
    return string.format("rbxthumb://type=Avatar&id=%d&w=%d&h=%d", userId, size, size)
end
outfits:Gallery({
    Title = "Outfits",
    Items = {{ Id = userId, Title = "Avatar", Thumbnail = avatar(150), Preview = avatar(420) }},
    Callback = function(id) print("Selección", id) end,
    OnApply = function(item) print("Aplicar", item.Id) end,
})
```

**Created by Ryou**


## V5 en Android

La cabecera usa `R_FACETADA_VECTOR_512.png`. A un umbral alfa de 35 sobre 255, el símbolo ocupa 391 × 289 de 512. La nueva caja con ajuste proporcional lo muestra a unos 44 px de ancho lógico frente a 54 px en V4. El arte del hero y el launcher conserva su encuadre propio.

La zona táctil transparente cubre la cabecera bajo los botones de ventana y utilidades. Título, logo y decoración permanecen debajo de la zona táctil. El arrastre mantiene el puntero que inició el gesto y aplica su delta a la posición inicial en el área segura, sin interpolar el movimiento.
