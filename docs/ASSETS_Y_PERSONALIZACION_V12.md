# RyouHub V12 · Personalización de fondos y logos

**Creador:** Ryou. Este repositorio puede clonarse y personalizarse sin modificar el motor del juego.

## Desde la interfaz

Abre **Personalización**. Ahí puedes cambiar el tema, el acento, la tipografía, la intensidad de Liquid Glass y los efectos (Suave, Destellos, Desactivados). Liquid Glass está activo al cargar por primera vez.

En **Fondo del menú** elige uno de los nuevos fondos anime o pega un enlace HTTPS de una imagen pública en Pinterest, GitHub, Discord o una web que permita obtener su imagen. En **Logo personalizado**, pega una URL directa PNG o JPG y pulsa **Aplicar logo**. El logo personalizado sustituye la R del banner de Inicio, no el texto de cabecera. Usa **Restaurar logo R** para volver al original.

El control de escala fue retirado. La ventana cambia de tamaño únicamente con el tirador de la esquina inferior derecha.

## Cómo agregar imágenes a tu propio fork

1. Crea un fork de `vryex/ryouhub` en tu cuenta GitHub.
2. En tu fork y rama de trabajo sube fondos PNG/JPG a `assets/backgrounds/user/` y logos PNG/JPG a `assets/logos/user/`. Puedes poner imágenes de anime originales, logos propios, diseños para Discord, etc., siempre que tengas derecho a usarlos.
3. Abre el archivo subido en GitHub, pulsa **Raw** y copia la dirección HTTPS. Por ejemplo:
   - Fondo: `https://raw.githubusercontent.com/TU_USUARIO/ryouhub/TU_RAMA/assets/backgrounds/user/mi_fondo.jpg`
   - Logo: `https://raw.githubusercontent.com/TU_USUARIO/ryouhub/TU_RAMA/assets/logos/user/mi_logo.png`
4. Pega esa URL en la sección correspondiente y pulsa **Aplicar**.
5. Si quieres que el fondo figure en el desplegable predeterminado, edita el arreglo `RYOU_BG_PRESETS` en el script completo. Añade `{Name="Mi fondo",File="user/mi_fondo.jpg"}` y cambia `RYOU_BG_REPO` para que apunte a `https://raw.githubusercontent.com/TU_USUARIO/ryouhub/TU_RAMA/assets/backgrounds/`.
6. Para ejecutar tu propia versión, adapta el loadstring a tu usuario y rama:
   ```lua
   loadstring(game:HttpGet("https://raw.githubusercontent.com/TU_USUARIO/ryouhub/TU_RAMA/scripts/RyouHub_V14_NeoSidebar_V12.lua"))()
   ```

Se aceptan imágenes PNG/JPG públicas, con tamaño de descarga hasta 8 MB. Para fondos se recomienda 1200 × 650 o superior, y para logos PNG cuadrado con transparencia. Las URLs temporales de adjuntos de Discord pueden caducar; subir el archivo al fork evita ese problema. Roblox necesita `writefile` y `getcustomasset` o `getsynasset` para registrar recursos externos; si faltan, el selector no podrá mostrar imágenes descargadas.

Los ajustes de apariencia se guardan en `UIAppearance`; el fondo y la URL del logo están en `Fondo`. En entornos con archivos se conserva caché de URL.

## Colección original V12

- `Estación nocturna`: lluvia y estación teal oscura.
- `Santuario violeta`: jardín japonés nocturno.
- `Estación bajo lluvia`: tren, paraguas y reflejos.
- `Jardín lunar`: linternas y flores violetas.

Los cuatro JPEG optimizados residen en `assets/backgrounds/anime/`. La versión de mayor definición está incluida en el ZIP entregado en el chat. Las referencias de Pinterest se usaron como inspiración visual, no se incorporaron imágenes de terceros al repo.

## Marca Pinterest

El icono de Pinterest se usa para **identificar esa fuente**, no como logo de RyouHub ni para sugerir afiliación. Su forma corresponde al emblema vectorial de Pinterest; consultar [las guías de marca](https://business.pinterest.com/es/brand-guidelines/) antes de reutilizarlo en otro contexto.

## Validaciones pendientes

Los cambios necesitan pruebas físicas en Roblox Android (scroll, rotación, descarga, cacheado y miniatura del juego) y Luau CLI antes de fusionar los PR.
