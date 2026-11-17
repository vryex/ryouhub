# Personalización

| Opción de ventana | Uso |
| --- | --- |
| `Accent` | Color3 para el acento. |
| `BackgroundImage` | ID numérico o URI de imagen Roblox. El fondo conserva una capa oscura o clara bajo la imagen atenuada. |
| `Font` | Un `Enum.Font` incorporado. Aplica a etiquetas, campos y pesos de texto de la interfaz. |
| `Radius` | Radio de los controles y la navegación, 4–18 px. |
| `Spacing` | Espaciado de los controles, 8–20 px. |
| `Motion` | `full`, `reduced` u `off`. |
| `UIScale` | Escala de interfaz entre 0.7 y 1.4. |
| `Size`, `Position`, `MinSize` | Tamaño y posición de arranque en el área segura. |
| `LauncherPosition`, `OpenButton` | Posición y visibilidad del launcher, con título opcional. |

La escala base usa Builder Sans normal, medio y negrita. La marca usa Jura y los valores técnicos pueden usar Code. En clientes sin el Enum correspondiente se usa Gotham como alternativa. Los tamaños más frecuentes son 12 px para descripciones, 13–14 px para etiquetas y acciones, y 18–22 px para título de ventana. Los ajustes secundarios compactos pueden ser menores.

```lua
window:EditOpenButton({Enabled = true, Title = "Editor"})
window:SetUIScale(1.1)
```

El launcher muestra el símbolo por defecto. El texto es útil cuando una experiencia tiene varios accesos visibles. Para volver al ancho compacto usa `Title = ""`.
