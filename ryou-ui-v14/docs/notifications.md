# Notificaciones

```lua
local notice = window:Notify({
    Type = "warning", Title = "Archivo incompleto",
    Content = "Quedan dos campos por revisar.", Duration = 4,
})
-- Para retirar el aviso al resolver el estado:
-- notice:Dismiss()
```

Tipos disponibles: `info`, `success`, `warning` y `error`. Los valores desconocidos resuelven a `info`. `Desc` y `Description` son alias de `Content`. La duración se limita a 1–10 s y por defecto es de 3 s. Usa un título y una descripción breves porque hay espacio para un título de una línea y una descripción corta.

Los avisos se apilan en el extremo inferior izquierdo del área segura, con hasta dos tarjetas (una bajo 320 px de alto). Al alcanzar el límite, el más viejo sale de la pila. `UI:Notify(...)` envía a la ventana vigente y devuelve `nil` cuando todavía no existe.
