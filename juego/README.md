# ¿Es seguro? — versión web

El juego de [AIDA-Juego-Revision](../../AIDA-Juego-Revision) rehecho en HTML, CSS y
JavaScript, sin librerías. Se juega igual; las reglas están en el README de allá.

## Cómo abrirlo

En línea: **https://aidaasistente.com/juego/** (se publica con cada push a `main`
de WebAIDA; `herramientas/` y este README no se suben). Para probarlo, abrir
`index.html`. No tiene scripts ni `onclick` dentro del HTML.

## Qué hay

| Archivo | Qué tiene |
| :--- | :--- |
| `index.html`, `estilos.css`, `fondo.svg` | La pantalla. Fluida: dos columnas en pantallas anchas, apilada en angostas. |
| `juego.js` | El juego (`juego/juego.gd`). |
| `aida.js` | AIDA corriendo (`juego/aida_corre.gd` y el rig). |
| `datos/` | Casos y animaciones, **generados**: no editar a mano. |
| `arte/`, `sonidos/` | Copias del juego de Godot. |

## Después de cambiar el juego de Godot

```
python herramientas/generar.py
```

Trae casos, consejos, animaciones, arte y sonidos. Un cambio en `juego.gd`
(comportamiento o textos de las tarjetas) hay que pasarlo a mano a `juego.js`.

## Diferencias con Godot

- La pantalla es fluida (se adapta al zoom) y con fondo claro, como la web.
- La app del banco se dibuja como app de banco, y solo queda marcado lo último que se miró.
- La portada tiene una sola AIDA (la de la marca) y, con menos de 70 % de aciertos,
  el final muestra a AIDA con la campana y con anteojos de sol.
- Sin QR al final; arriba hay un botón para volver a aidaasistente.com.
- AIDA corriendo aparece entre días y al final; no en celulares ni si el sistema
  pide menos movimiento.
- No están las opciones de desarrollo (`--demo`, `--capturas`, `--dia`).

Al cambiar un `.js` o `estilos.css`, subir el número `?v=` en `index.html`: el sitio
guarda esos archivos en caché varias horas.
