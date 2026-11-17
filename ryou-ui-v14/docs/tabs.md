# Pestañas y secciones

```lua
local group = w:Group({ Title = "WORKSPACE" })
local home = group:Tab({ Title = "Inicio", Id = "home-view", Icon = "home" })
home:Section({ Title = "Sesión" })
home:Paragraph({ Desc = "Listo." })
w:SelectTab("home-view")
```

`Window:Section({...})` es alias de `Group`. Crea un encabezado de navegación donde se invoca. Declara juntas las pestañas del grupo para conservar el orden. `Tab:Section` crea un separador dentro de la página, y devuelve la misma pestaña. `SelectTab` acepta la pestaña, título, ID o índice desde 1.

La lista lateral se desplaza de forma independiente. Bajo 530 px de ancho muestra iconos de 18 px en filas de 44 px, y el nombre de la pestaña permanece visible al inicio de la página. Usa iconos distintos para destinos que necesiten distinguirse en móvil.
