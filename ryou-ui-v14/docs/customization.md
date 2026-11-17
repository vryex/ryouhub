# Personalización

Usa opciones del constructor para fijar la composición inicial. Las propiedades que cambian durante el uso tienen métodos específicos en [la referencia](api-reference.md).

| Parámetro | Inicial | Uso |
| --- | --- | --- |
| `Radius` | 8 px | Radio de controles. Se limita a 4–16 px. |
| `Spacing` | 9 px | Separación vertical de la página. Se limita a 4–16 px. |
| `Font` | `Enum.Font.Gotham` | Texto y campos editables. |
| `BoldFont` | `Enum.Font.GothamBold` | Marca, títulos y acciones. |
| `Size` | 1040 × 615 px | `Vector2` o `UDim2` de offsets. |
| `Position` | centrada | Centro en píxeles dentro del área de cliente. |
| `Launcher` | `true` | Muestra el símbolo al cerrar. |
| `Theme` | `Dark` | Tema o configuración de tema. |
| `Motion` | `Full` | Intensidad de movimiento. |

La escala visual usa 21 px en la marca, 19 px en encabezados de página, 14 px en acciones y campos, 13 px para descripciones y valores y 12 px para rótulos de organización. Los controles de interacción primaria tienen áreas de 44 px; el launcher mide 70 × 70 px. Prueba fuentes nativas alternativas con textos largos y en el emulador de dispositivo.
