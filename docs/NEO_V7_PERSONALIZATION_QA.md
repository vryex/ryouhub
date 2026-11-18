# RyouHub V14 · Neo Sidebar V7: plan de integración y QA

**Autor:** Ryou  
**Base del hub:** PR #23, rama `ryouhub-v14-neo-v6-integrated`  
**Biblioteca:** PR #24, código fijado al commit `45b530badadf8c8bdef4ab422f7600302e394492`  
**Versión de biblioteca:** `14.1.0`, variante `Neo Sidebar V7`

## Ajustes disponibles

- Ocho temas: Menta Ryou, Medianoche, Violeta, Carmesí, Azul hielo, Rosa, Ámbar, Perla.
- Colores RGB personalizables de acento y base de fondo mediante el picker interno.
- Tipografía de toda la UI (Gotham, SourceSans, Arial).
- Transparencia de paneles de 0 a 35 %.
- Animaciones: completas, reducidas o desactivadas; velocidad 50 a 200 %.
- Escala 85 a 120 %, intensidad decorativa 0 a 100 %, neón ON/OFF.
- Botón de modo ahorro y botón de restauración visual.

El guardado automático de apariencia espera 750 ms desde el último cambio y escribe `_ui_appearance.json` dentro de `Ryou_Configs_<PlaceId>` cuando `writefile` está disponible. También se exporta como `UIAppearance` dentro de las configuraciones normales (versión 3) y la carga sigue admitiendo configuraciones antiguas sin ese campo. Si `readfile`, `isfile` o `writefile` no están disponibles, los controles funcionan en la sesión sin persistencia.

La biblioteca es independiente y no necesita acceso a archivos para mostrar la UI. No se agregan operaciones de renderizado en bucle, desenfoque ni animaciones permanentes. Se omiten tweens cuyo destino ya coincide con el valor actual.

## Verificación estática

Se verificó que la sección central original de RyouHub anterior a Configuración (incluyendo motores de animaciones, skins, TP Slash y apariencia) es idéntica a la V6, salvo comentarios de versión. El Lua y el TXT deben mantener el mismo SHA de blob.

**No se ha ejecutado Roblox Android en este entorno**, así que no se puede asegurar todavía la nitidez, fluidez o funcionamiento real de cada control.

## Checklist en Roblox Android

1. Ejecutar V7 en una sesión limpia; confirmar carga de la biblioteca (sin errores de versión).
2. Abrir Configuración. Probar los ocho presets, especialmente contraste y visibilidad de texto en Perla.
3. Cambiar manualmente acento y fondo. Verificar que actualice botones, bordes, pestañas, galería y notificaciones sin perder el scroll ni la selección.
4. Probar fuentes Gotham, Arial y SourceSans en horizontal y en ventanas compactas. Verificar textos largos sin cortes.
5. Probar transparencia 0/15/35 % y escalas 85/100/120 %. Confirmar que no deje barras sin fondo.
6. Cambiar velocidad 50/100/200 %, movimiento completo/reducido/off y abrir/minimizar repetidamente.
7. Activar Modo ahorro, comprobar que se desactiva neón y bajan decoraciones; restablecer apariencia.
8. Guardar un preset de UI, reiniciar el script y comprobar restauración. Si el entorno no admite archivos, verificar que los controles funcionen durante la sesión y no aparezcan errores.
9. Crear, guardar y cargar config general. Confirmar que incluye y restaura `UIAppearance`; comprobar que configs V2 siguen cargando.
10. Repetir pruebas de Outfits, dropdowns, launcher, animaciones R15, selector corporal, ESP y TP Slash para detectar regresiones.

**No fusionar PR #24 o PR de integración sin validar Luau CLI y Roblox Android.**
