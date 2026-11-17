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

El marco parte de 1040 × 615 px. La cabecera mide 74 px o 58 px en un viewport bajo. El rail usa aproximadamente el 18.5 % del ancho y pasa a 56 px bajo 560 px. Los componentes en columnas se apilan cuando su ancho disponible baja del mínimo. El launcher usa un disco de 70 px; aparece junto al marco cuando hay espacio y al cerrar. Arrastra el disco 9 px o más para moverlo sin alternar la ventana.

- [Símbolo editable](../assets/neo-mark.svg) y PNG transparentes de [512 px](../assets/neo-mark.png), [96 px](../assets/neo-mark-96.png) y [48 px](../assets/neo-mark-48.png). [Monocromo SVG](../assets/neo-mark-mono.svg) y [PNG](../assets/neo-mark-mono.png).
- [Launcher editable](../assets/neo-launcher.svg) y [PNG](../assets/neo-launcher.png).
- Recursos decorativos separados para [cabecera](../assets/neo-header-ribbon.svg), [hero](../assets/neo-hero-ribbon.svg) y [rail](../assets/neo-rail-ribbon.svg).

Usa el símbolo sin disco en cabecera y hero, y centrado dentro del círculo en el launcher. Conserva el espacio del corte interno y la inclinación de las facetas al escalar. El SVG es editable y el PNG sirve para importar en Studio. Si se usa como `ImageLabel` en otra integración, publica el PNG en la cuenta o grupo propietario y usa su ID real con los permisos correspondientes.

La biblioteca dibuja la R desde ocho polígonos facetados en Luau y usa Frames, UIStroke y UIGradient para las curvas y destellos. Los SVG y PNG se incluyen como archivos de diseño e importación opcional. El runtime no descarga el master ni utiliza IDs para esta identidad. Las ilustraciones de personajes y cielos del showcase son formas y muestras generadas por la biblioteca. Los detalles fotográficos, efectos de mapa y material 3D de las láminas se traducen a superficies de UI.

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

En galería y catálogo, cada entrada usa `Id` único numérico o de texto, `Title`, `Desc` opcional y `Thumbnail` opcional con URI de Roblox. `Tint` y `Art = "Avatar" | "Swatch"` son ilustraciones nativas opcionales. Los filtros comparan el título, identificador y descripción con el texto escrito. Se muestran hasta 120 resultados por filtro. `Refresh` conserva el ID seleccionado si sigue en la lista. El manejo de datos, red y efectos del juego pertenece al consumidor.

`CreateWindow` admite `Badge` (por defecto `V14 · Stable`) y `Utilities = { Cloud = fn, Notifications = fn }` opcional. Los callbacks reciben la ventana. `Tab({ ShowTitle = false })` oculta el título de página para usar un banner. `Button({ Primary = true, Compact = true })` ofrece CTA menta y accesos compactos. Las firmas previas siguen disponibles. Consulta la [referencia de API](api-reference.md) y la [migración](migration.md).

**Created by Ryou**
