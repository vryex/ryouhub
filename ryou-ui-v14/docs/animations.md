# Movimiento

| Modo | Primera apertura | Reapertura | Interacción |
| --- | --- | --- | --- |
| `Full` | Hasta 740 ms, con fases superpuestas | 210 ms | Hasta 230 ms en la mayoría de los controles |
| `Reduced` | Aproximadamente 150 ms | Aproximadamente 70 ms | 34 % del tiempo normal |
| `Off` | Instantánea | Instantánea | Instantánea |

La ventana entra con desplazamiento vertical, el símbolo y el texto se revelan en fases distintas, un trazo breve cruza el encabezado, la navegación aparece escalonada y entra la página seleccionada. Las primeras diez pestañas reciben escalonamiento individual. Cerrar durante la entrada cancela sus fases y conserva la capacidad de reabrir. La secuencia completa corre una vez por ventana.

```lua
local w = UI:CreateWindow({ Motion = "Reduced" })
w:Tab({ Title = "Inicio" })
w:SetMotion("Off")
```

El estado de apertura se aplica al inicio de cada transición. `OnOpen` y `OnClose` se disparan al cambiar el estado. Las transiciones usan [CanvasGroup](https://create.roblox.com/docs/reference/engine/classes/CanvasGroup) y tweens cancelables. La memoria gráfica y el resultado visual dependen del dispositivo.
