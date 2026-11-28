/* AIDA animada: el rig de personaje/exacta y el paseo de juego/aida_corre.gd,
   dibujados en un canvas. Las animaciones salen de datos/animaciones.js. */
"use strict";

window.AidaCorre = (() => {
  const VELOCIDAD = 300, GRAVEDAD = 2200, IMPULSO = -820;
  const PIVOTES = {
    sombra: [-83, -27], pie: [-47, -26], aleta: [-57, -20], cuerpo: [-104, -311],
    ojo: [-25, -29], boca: [-17, -17], pico_abajo: [-20, -21], pico: [-21, -41], polvo: [-23, -23],
  };
  const img = {};
  for (const n in PIVOTES) {
    img[n] = new Image();
    img[n].src = `arte/rig/${n}.png`;
  }

  // Las piezas de atrás van más oscuras.
  const oscuras = {};
  function oscura(nombre, k) {
    const clave = nombre + k;
    if (oscuras[clave]) return oscuras[clave];
    const o = img[nombre];
    if (!o.complete || !o.naturalWidth) return o;
    const c = document.createElement("canvas");
    c.width = o.naturalWidth;
    c.height = o.naturalHeight;
    const x = c.getContext("2d");
    x.drawImage(o, 0, 0);
    x.globalCompositeOperation = "source-atop";
    x.fillStyle = `rgba(0,0,0,${1 - k})`;
    x.fillRect(0, 0, c.width, c.height);
    return (oscuras[clave] = c);
  }

  // Interpolación cúbica entre claves, como la de Godot.
  function muestra(pista, t, largo, repite) {
    const { t: ts, v } = pista;
    const n = ts.length;
    if (n === 1) return v[0];
    let i = 0;
    while (i < n - 2 && t >= ts[i + 1]) i++;
    const k = Math.min(1, Math.max(0, (t - ts[i]) / (ts[i + 1] - ts[i])));
    // Si repite, la primera y la última clave son la misma: se da la vuelta.
    const antes = i > 0 ? v[i - 1] : v[repite ? n - 2 : 0];
    const despues = i + 2 < n ? v[i + 2] : v[repite ? 1 : n - 1];
    return v[i].map((p1, c) => {
      const p0 = antes[c], p2 = v[i + 1][c], p3 = despues[c];
      return 0.5 * (2 * p1 + (p2 - p0) * k + (2 * p0 - 5 * p1 + 4 * p2 - p3) * k * k
        + (3 * p1 - p0 - 3 * p2 + p3) * k * k * k);
    });
  }

  function pieza(ctx, nombre, x, y, giro = 0, sx = 1, sy = 1, imagen = img[nombre]) {
    if (!img[nombre].complete) return;
    ctx.save();
    ctx.translate(x, y);
    ctx.rotate(giro);
    ctx.scale(sx, sy);
    ctx.drawImage(imagen, PIVOTES[nombre][0], PIVOTES[nombre][1]);
    ctx.restore();
  }

  function pierna(ctx, a, b, color, contorno) {
    const doblez = Math.max(0, 34 - Math.hypot(b[0] - a[0], b[1] - a[1])) * 0.35 + 4;
    const medio = [(a[0] + b[0]) / 2 + doblez, (a[1] + b[1]) / 2];
    ctx.lineCap = "round";
    for (const [ancho, c] of [[34, contorno], [18, color]]) {
      ctx.beginPath();
      ctx.moveTo(a[0], a[1]);
      ctx.quadraticCurveTo(medio[0], medio[1], b[0], b[1]);
      ctx.lineWidth = ancho;
      ctx.strokeStyle = c;
      ctx.stroke();
    }
  }

  return class {
    constructor(x, piso, escala) {
      Object.assign(this, {
        x, piso, escala, destino: x, pasear: false, limites: [80, 1200],
        vy: 0, alto: 0, aterrizando: 0, pausa: 0, dir: 1,
        nombre: "quieto", t: 0, velocidad: 1, pose: null, previa: null, mezcla: 0, mezclaTotal: 0,
        polvo: [],
      });
    }

    saltar() {
      if (this.alto === 0) this.vy = IMPULSO;
    }

    toca(px, py) {
      const x = (px - this.x) / this.escala;
      const y = (py - this.piso) / this.escala - this.alto;
      return x >= -55 && x <= 55 && y >= -150 && y <= 10;
    }

    animar(nombre, velocidad = 1) {
      this.velocidad = velocidad;
      if (this.nombre === nombre) return;
      this.previa = this.pose;
      this.mezclaTotal = this.mezcla = this.nombre === "saltar" && nombre === "caer" ? 0.12 : 0.06;
      this.nombre = nombre;
      this.t = 0;
    }

    levantarPolvo(golpe) {
      const entre = (a, b) => a + Math.random() * (b - a);
      for (let i = 0; i < (golpe ? 16 : 4); i++) {
        const angulo = golpe
          ? -Math.PI / 2 + entre(-1.4, 1.4)
          : Math.atan2(-0.6, -this.dir) + entre(-0.6, 0.6);
        const v = golpe ? entre(80, 200) : entre(50, 110);
        this.polvo.push({
          x: golpe ? entre(-26, 26) : 0, y: -2,
          vx: Math.cos(angulo) * v, vy: Math.sin(angulo) * v,
          tam: golpe ? entre(0.84, 1.4) : entre(0.54, 0.9),
          edad: 0, vida: golpe ? 0.5 : 0.35,
        });
      }
    }

    avanzar(dt) {
      // Paseo: elige otro lugar cada tanto.
      if (this.pasear && Math.abs(this.destino - this.x) < 4) {
        this.pausa -= dt;
        if (this.pausa <= 0) {
          this.destino = this.limites[0] + Math.random() * (this.limites[1] - this.limites[0]);
          this.pausa = 1.2 + Math.random() * 1.8;
          if (Math.random() < 0.35) this.saltar();
        }
      }
      const dx = this.destino - this.x;
      let vx = 0;
      if (Math.abs(dx) > 4) {
        vx = Math.sign(dx) * VELOCIDAD;
        this.x += Math.max(-Math.abs(dx), Math.min(Math.abs(dx), vx * dt));
        this.dir = Math.sign(vx);
      }
      // Salto.
      if (this.alto < 0 || this.vy < 0) {
        this.vy += GRAVEDAD * dt;
        this.alto += this.vy * dt;
        if (this.alto >= 0) {
          this.alto = 0;
          this.vy = 0;
          this.aterrizando = 0.25;
          this.animar("aterrizar");
        }
      }
      if (this.alto < 0) this.animar(this.vy < 0 ? "saltar" : "caer");
      else if (this.aterrizando > 0) this.aterrizando -= dt;
      else if (vx !== 0) this.animar("correr", 1.15);
      else this.animar("quieto");

      const a = ANIMACIONES[this.nombre];
      const antes = this.t;
      this.t += dt * this.velocidad;
      for (const [cuando, que] of a.eventos) {
        const paso = a.repite
          ? Math.floor((this.t - cuando) / a.largo) > Math.floor((antes - cuando) / a.largo)
          : antes <= cuando && this.t > cuando;
        if (paso) this.levantarPolvo(que === "_golpe");
      }
      const t = a.repite ? this.t % a.largo : Math.min(this.t, a.largo);
      const pose = {};
      for (const k in a.pistas) pose[k] = muestra(a.pistas[k], t, a.largo, a.repite);
      if (this.mezcla > 0 && this.previa) {
        this.mezcla -= dt;
        const p = Math.max(0, this.mezcla / this.mezclaTotal);
        for (const k in pose) {
          if (this.previa[k]) pose[k] = pose[k].map((v, i) => v + (this.previa[k][i] - v) * p);
        }
      }
      this.pose = pose;

      for (const m of this.polvo) {
        const v = Math.hypot(m.vx, m.vy) || 1;
        const frenada = Math.max(0, v - 170 * dt) / v;
        m.vx *= frenada;
        m.vy = m.vy * frenada - 30 * dt;
        m.x += m.vx * dt;
        m.y += m.vy * dt;
        m.edad += dt;
      }
      this.polvo = this.polvo.filter((m) => m.edad < m.vida);
    }

    dibujar(ctx) {
      const p = this.pose;
      if (!p) return;
      const v = (k, porDefecto) => p[k] || porDefecto;
      ctx.save();
      ctx.translate(this.x, this.piso);
      ctx.scale(this.escala, this.escala);

      // La sombra queda en el piso y se achica cuanto más alto está.
      const k = Math.max(0.35, Math.min(1, 1 + this.alto / 260));
      ctx.globalAlpha = k;
      pieza(ctx, "sombra", 0, 2, 0, 0.33 * k, 0.33 * k);
      ctx.globalAlpha = 1;

      ctx.save();
      ctx.translate(0, this.alto);
      ctx.scale(0.33 * this.dir, 0.33);
      const cuerpo = v("Cuerpo.position", [0, -28]);
      const escala = v("Cuerpo.scale", [1, 1]);
      const giro = v("Giro.rotation", [0])[0];
      // Un punto de «Giro» visto desde «Arte» (para colgar las caderas).
      const cadera = (x, y) => {
        const gx = x * Math.cos(giro) - y * Math.sin(giro);
        const gy = x * Math.sin(giro) + y * Math.cos(giro) - 121.8;
        return [cuerpo[0] + gx * escala[0], cuerpo[1] + gy * escala[1]];
      };
      for (const lado of ["Atras", "Frente"]) {
        const atras = lado === "Atras";
        const pie = v(`Pie${lado}.position`, [atras ? 3.8 : 10.8, -22]);
        pierna(ctx, cadera(atras ? -14 : 12, 97.8), pie,
          atras ? "#104156" : "#165a78", atras ? "#112831" : "#183844");
        pieza(ctx, "pie", pie[0], pie[1], v(`Pie${lado}.rotation`, [0])[0], 1, 1,
          atras ? oscura("pie", 0.72) : img.pie);
      }

      ctx.translate(cuerpo[0], cuerpo[1]);
      ctx.scale(escala[0], escala[1]);
      ctx.translate(0, -121.8);
      ctx.rotate(giro);
      pieza(ctx, "aleta", -10.4, -17, v("AletaAtras.rotation", [0])[0], 1, 1, oscura("aleta", 0.7));
      pieza(ctx, "cuerpo", 0, 121.8);
      const ojo = v("Ojo.scale", [1, 1]);
      pieza(ctx, "ojo", 51.4, -92.9, 0, ojo[0], ojo[1]);
      ctx.save();
      ctx.translate(70.4, -66.8);
      ctx.rotate(v("Pico.rotation", [0])[0]);
      const boca = v("Boca.scale", [1, 0.02]);
      pieza(ctx, "boca", 0, 0, 0, boca[0], boca[1]);
      pieza(ctx, "pico_abajo", 0, 0, v("Abajo.rotation", [0])[0]);
      pieza(ctx, "pico", 0, 0);
      ctx.restore();
      pieza(ctx, "aleta", 9.6, -14, v("AletaFrente.rotation", [0])[0]);
      ctx.restore();

      for (const m of this.polvo) {
        const e = m.edad / m.vida;
        const tam = m.tam * (e < 0.25 ? 0.5 + 2 * e : 1 - (e - 0.25) / 0.75);
        ctx.globalAlpha = 0.9 * (1 - e);
        pieza(ctx, "polvo", m.x, m.y, 0, tam, tam);
      }
      ctx.restore();
    }
  };
})();
