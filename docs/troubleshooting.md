# Solución de problemas

| Síntoma | Qué comprobar |
| --- | --- |
| No aparece el panel | Ejecuta **Play** en Studio y confirma que la llamada a `CreateWindow` viene de un LocalScript. Si creaste el panel cerrado, toca el launcher o presiona el atajo. |
| Una ventana reemplaza a otra | El mismo módulo administra una sola ventana. Crea pestañas adicionales dentro de esa ventana. |
| No aparece un icono de imagen | Comprueba la publicación, moderación y los permisos del asset. Prueba `Icon = "grid"` para verificar el layout. |
| Un campo ignora las teclas | Asegúrate de que el control no esté bloqueado y toca el TextBox para darle foco. |
| No hay resultados en el dropdown | Revisa `Values`, usa `Refresh` si el catálogo cambió y limpia el filtro. |
| Desaparece un control al achicar la ventana | Revisa la búsqueda, cambia la pestaña o desplázate al final de la lista. Comprueba también que el control esté visible. |
| El callback no se ejecuta | La inicialización y `Set(valor, true)` son silenciosos. Comprueba Output y verifica que el valor realmente cambió. |
