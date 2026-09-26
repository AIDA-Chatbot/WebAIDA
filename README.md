# WebAIDA — Sitio oficial de AIDA

Sitio estático (HTML + CSS + JS, sin frameworks ni build) de **AIDA**, el asistente digital
que acompaña a personas mayores en el uso de la tecnología.

> 🏆 AIDA fue el **proyecto campeón del Capstone Project del Samsung Innovation Campus
> Argentina 2025**, en la edición especializada en Inteligencia Artificial.

En línea: **https://aida-chatbot.github.io/WebAIDA/**
Se publica automáticamente en GitHub Pages con cada push a `main`.

## Estructura

```
WebAIDA/
├── index.html                  # Página principal (una sola página, con anclas)
├── tecnologia.html             # Detalle técnico (arquitectura, stack, decisiones)
├── privacidad.html             # Política de privacidad y términos
├── 404.html                    # Página de error
├── robots.txt · sitemap.xml    # Para buscadores (ver «SEO y visibilidad en IA»)
├── llms.txt                    # Resumen de AIDA para asistentes de IA
├── assets/
│   ├── aida-mark.png           # Isotipo recortado (fondo transparente) — nav, footer, avatar
│   ├── aida-wave.png           # Pingüino saludando — hero y CTA
│   ├── aida-penguin.png        # Pingüino parado, alta resolución
│   ├── aida-ganadores.jpg      # Banner del premio
│   ├── equipo-*.png            # Los tres integrantes en versión pingüino
│   ├── aida-logo.jpg           # Logotipo horizontal original
│   ├── og-image.jpg            # Imagen para compartir en redes (1200×630)
│   └── favicon.ico · favicon-32.png · favicon-256.png
├── styles/main.css             # Sistema de diseño completo + componentes
├── scripts/main.js             # Interactividad, sin dependencias
└── .github/workflows/static.yml
```

Los `assets/*.png` se generaron a partir del arte original de la carpeta del proyecto
recortando el fondo, para que el pingüino se vea bien sobre fondos oscuros.

## Secciones de la página

| Ancla | Contenido |
|---|---|
| `#inicio` | Hero con demo animada de una conversación real y métricas. En escritorio entra entero en la primera pantalla, incluso en una notebook con escala al 150 % (~1280×600) |
| `#que-es` | Qué es AIDA y sus cuatro principios |
| `#funciones` | Las 9 capacidades del asistente |
| `#como-funciona` | Los 4 pasos para empezar |
| `#android` | Adelanto de la app para Android (todavía sin publicar): la burbuja, con un teléfono de ejemplo animado |
| `#para-quien` | Personas mayores / familias y cuidadores |
| `#video` | Video de presentación (se carga recién al hacer clic) |
| `#premio` | La historia del 1.º puesto en el SIC 2025 |
| `#tecnologia` | Invitación a la página técnica (el detalle vive en `tecnologia.html`) |
| `#estado` | Qué está listo, qué está en curso y qué viene |
| `#equipo` | Integrantes y agradecimientos |
| `#preguntas` | Preguntas frecuentes |
| `#lista-de-espera` | Formulario de la lista de espera |

La página principal está escrita para cualquier persona: no nombra modelos ni tecnologías.
Todo el detalle técnico (arquitectura, stack, decisiones de diseño y limitaciones conocidas)
vive en [`tecnologia.html`](tecnologia.html), para quien lo busque.

## Accesibilidad

Es el punto central del proyecto, así que el sitio también lo cuida:

- **Botón "Texto grande"** en la barra superior: sube la base tipográfica de 16 a 19 px y escala
  todo el sitio de forma pareja. La preferencia queda guardada en `localStorage`.
- Enlace de salto al contenido, foco visible en todos los elementos interactivos y jerarquía de
  encabezados correcta.
- Se respetan `prefers-reduced-motion` (se apagan las animaciones) y `prefers-contrast: more`.
- Contraste alto, cuerpo de texto de 17 px y alineación a la izquierda, según el manual de identidad.

## Configuración del formulario de lista de espera

El formulario usa [Formspree](https://formspree.io/). Mientras no esté configurado, en lugar de
fingir que guardó el correo, invita a escribir a la casilla del proyecto.

1. Creá una cuenta en [formspree.io](https://formspree.io) y un formulario nuevo.
2. Copiá el ID (por ejemplo `xabcdefg`).
3. En [`scripts/main.js`](scripts/main.js), reemplazá el valor de `FORMSPREE_ID`:

```js
var FORMSPREE_ID = 'xabcdefg';
```

## Deploy

`.github/workflows/static.yml` publica el sitio en cada push a `main`.
Para activarlo por primera vez: **Settings → Pages → Source: GitHub Actions**.

Se publican **solo los archivos del sitio**, que el workflow copia a `_site/`. Los `.md`
de esta carpeta quedan en el repo pero no en la web. **Un archivo nuevo del sitio hay que
sumarlo a la lista del paso «Preparar el sitio»**, o no se publica.

Para verlo en local, desde esta carpeta:

```bash
python -m http.server 8765
```

## SEO y visibilidad en IA

Hecho en el código:

- **Título, descripción y encabezado con las palabras que se buscan.** En Argentina se
  busca «adultos mayores» mucho más que «personas mayores»: va en el `<title>`, en la
  descripción y en la línea chica que abre el `<h1>`. El resto del texto sigue diciendo
  «personas mayores».
- **Datos estructurados (JSON-LD).** En `index.html`: `Organization` (con el equipo, el
  premio, YouTube y GitHub), `WebSite`, `WebPage`, `SoftwareApplication`, `VideoObject` y
  `FAQPage`. En las otras dos páginas: `TechArticle` o `WebPage`, más `BreadcrumbList`.
- **Las preguntas frecuentes tienen que decir lo mismo en el HTML y en el `FAQPage`.** Si
  se cambia una, se cambia en los dos lados (hay un aviso en el HTML).
- **`llms.txt`**: los datos de AIDA en texto plano, para que un asistente de IA la describa
  sin inventar. Si cambia algo del proyecto (estado, precio, canales), va también ahí.
- **Tres preguntas pensadas para asistentes de IA**: «¿Qué es AIDA?», «¿En qué se
  diferencia de ChatGPT…?» y «¿Quién hizo AIDA?». Son lo que la gente les pregunta, con
  una respuesta directa que se puede citar.
- `lang="es-AR"`, `canonical`, Open Graph y tarjeta de X en las tres páginas, imágenes en
  el sitemap y la página 404 con `noindex`.

Queda a mano, porque pide una cuenta:

1. **Google Search Console**: agregar la propiedad `https://aida-chatbot.github.io/WebAIDA/`
   (la verificación por etiqueta HTML va en el `<head>` de `index.html`) y enviar
   `sitemap.xml`.
2. **Bing Webmaster Tools**: importar la propiedad desde Search Console. El índice de Bing
   alimenta la búsqueda de Copilot y es una de las fuentes de ChatGPT.
3. **Probar los datos estructurados** en la
   [prueba de resultados enriquecidos](https://search.google.com/test/rich-results) de Google.

Limitaciones de publicar en `github.io/WebAIDA`:

- **Los buscadores solo leen el `robots.txt` de la raíz del dominio**, y esa raíz
  (`aida-chatbot.github.io`) no es de este repo. Por eso el sitemap se da de alta a mano.
  Hoy la raíz da 404, así que nada está bloqueado.
- **Un dominio propio** (por ejemplo `aida.com.ar`) resolvería lo anterior y suma
  autoridad de marca. Para mudarse: poner el dominio en Settings → Pages y reemplazar
  `https://aida-chatbot.github.io/WebAIDA/` en los `.html`, `sitemap.xml`, `robots.txt` y
  `llms.txt`.

## Sistema de diseño

Todos los colores, tamaños, radios, sombras y tiempos son *custom properties* declaradas en
`:root` dentro de [`styles/main.css`](styles/main.css). No hay valores sueltos.
La paleta se muestreó del arte original del isotipo y respeta el
[manual de identidad visual](manual-de-identidad-visual.md).

| Token | Valor | Uso |
|---|---|---|
| `--c-primary` | `#196F77` | Color principal de marca |
| `--c-teal-500` | `#1FA6A0` | Turquesa de la cabeza del pingüino |
| `--c-teal-400` | `#3BB7B4` | Secundario, detalles y acentos fríos |
| `--c-blue` | `#1E6E96` | Base del degradado del cuerpo |
| `--c-ink` | `#14343E` | Contorno del isotipo, títulos |
| `--c-gold` | `#F2B84D` | Pico y patas — reservado para CTA y el premio |
| `--font-head` | Poppins 600/700/800 | Títulos y elementos de interfaz |
| `--font-body` | Inter 400/500/600 | Texto corrido |

## Equipo

- [Santiago Oroz](https://www.linkedin.com/in/santiago-oroz/)
- [Renata Berho](https://www.linkedin.com/in/renata-ana-emilia-berho-02264230a/)
- [Milagros Argañin](https://www.linkedin.com/in/milagros-arga%C3%B1in-13641a376/)

Los tres trabajamos en todo el proyecto, sin roles separados.

Contacto: **aidaassistantbot@gmail.com** · [Video de presentación](https://youtu.be/Sl-CFzgz-u0)

> El repositorio del bot es privado, así que el sitio no enlaza a código fuente.
