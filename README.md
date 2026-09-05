# WebAIDA — Sitio web oficial de AIDA Bot

Sitio estático HTML/CSS/JS para [AIDA Bot](https://github.com/AIDA-org), el asistente de Telegram para adultos mayores.
Deployado automáticamente en GitHub Pages desde la rama `main`.

## Estructura

```
WebAIDA/
├── index.html              # Página principal (SPA de una sola página)
├── privacidad.html         # Política de privacidad y términos
├── pinguinoAIDA.jpg        # Logo mascota (PNG)
├── pinguinoAIDA.ico        # Favicon
├── styles/
│   └── main.css            # Design system completo + estilos
├── scripts/
│   └── main.js             # Interactividad (nav, animaciones, formulario)
└── .github/
    └── workflows/
        └── deploy.yml      # Auto-deploy a GitHub Pages
```

## Configuración del formulario de lista de espera

El formulario usa [Formspree](https://formspree.io/) como backend. Para activarlo:

1. Creá una cuenta en [formspree.io](https://formspree.io)
2. Creá un nuevo formulario y copiá tu ID (ej: `xabcdefg`)
3. En `scripts/main.js`, reemplazá `YOUR_FORMSPREE_ID` con tu ID real:
   ```js
   fetch('https://formspree.io/f/xabcdefg', { ... })
   ```

## Deploy manual

El workflow `.github/workflows/deploy.yml` se ejecuta automáticamente en cada push a `main`.

Para activar GitHub Pages por primera vez:
1. Ir a **Settings → Pages**
2. En **Source**, seleccionar **GitHub Actions**
3. Hacer un push a `main`

## Design system

Todos los valores de color, tipografía, espaciado, radio y animaciones están definidos como CSS custom properties en `styles/main.css` bajo `:root`. No hay valores mágicos sueltos.

| Token | Valor |
|---|---|
| `--c-primary` | `#196F77` — Turquesa oscuro |
| `--c-secondary` | `#3BB7B4` — Turquesa claro |
| `--c-accent` | `#F2B84D` — Mostaza (exclusivo CTAs) |
| `--c-dark` | `#2C3539` — Texto principal |
| `--font-head` | Poppins 700/800 |
| `--font-body` | Inter 400/500 |
| `--ease-std` | `cubic-bezier(0.4, 0, 0.2, 1)` |
