# Movimiento

| Modo | Comportamiento |
| --- | --- |
| `full` | Primera apertura escalonada de unos 660 ms, con desplazamiento del contenedor, marca, encabezado, navegación y contenido. |
| `reduced` | Sin introducción escalonada. El panel se desplaza 3 px y el feedback de los controles se abrevia. |
| `off` | Apertura y cambios visuales inmediatos. |

```lua
local window = UI:CreateWindow({Title = "Editor", Motion = "reduced"})
window:SetMotion("off")
print(window:GetMotion())
```

En `full` y `reduced`, las reaperturas duran 200 ms y el cierre 170 ms. Los controles se pueden usar durante la apertura. La altura del dropdown participa en el layout y los efectos de entrada usan propiedades separadas de las posiciones persistentes. El cambio de modo afecta a las transiciones siguientes.
