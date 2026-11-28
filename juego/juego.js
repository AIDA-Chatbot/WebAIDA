/* «¿Es seguro?», el juego de AIDA. Versión web de juego/juego.gd.
   Los mensajes están en datos/casos.js (se generan desde casos.gd). */
"use strict";

const PUNTOS_ACIERTO = 100;
const PUNTOS_RAPIDEZ = 100;
const SEGUNDOS_RAPIDO = 5;
const SEGUNDOS_LENTO = 30;
const AMBAR = "#f2b84d", TURQ = "#3bb7b4", CORAL = "#b94a30", VERDE = "#2c7a53";

const TIPOS = {
  chat: { cab: "#196f77", txt: "#fff", fondo: "#e6efe9", burbuja: "#fff", letra: "#2c3539", icono: "" },
  sms: { cab: "#dde4e8", txt: "#2c3539", fondo: "#f4f6f8", burbuja: "#e3e9ee", letra: "#2c3539", icono: "💬" },
  mail: { cab: "#fff", txt: "#2c3539", fondo: "#fff", burbuja: "#fff", letra: "#2c3539", icono: "✉" },
  llamada: { cab: "#22303a", txt: "#fff", fondo: "#2b3b45", burbuja: "#3d505c", letra: "#fff", icono: "📞" },
  app: { cab: "#f4f6f8", txt: "#2c3539", fondo: "#fff", burbuja: "#f4f6f8", letra: "#2c3539", icono: "📲" },
};

const $ = (id) => document.getElementById(id);
const mesa = $("mesa"), capa = $("capa");

// Estado del juego
let dia = 0, casos = [], indice = 0, caso = null, respondido = false;
let aciertos = 0, jugados = 0, aciertosDia = 0, puntos = 0, puntosDia = 0;
let segundos = 0, ayudas = [], ayudaN = 0;
let escalaPista = 1, anchoPista = 1280, destinoPista = 0.5;
let corredora = null, lienzo = null;
let animaciones = [];

// ── Sonidos ──
const sonidos = {};
for (const n of ["llega", "lupa", "sello", "bien", "mal", "escua"]) {
  sonidos[n] = new Audio(`sonidos/${n}.wav`);
  sonidos[n].preload = "auto";
}
function sonar(nombre, db = 0) {
  const a = sonidos[nombre].cloneNode();
  a.volume = Math.min(1, 10 ** (db / 20));
  a.play().catch(() => {}); // antes del primer toque el navegador no deja
}

// ── Ayudantes ──
function crear(etiqueta, clase, texto) {
  const e = document.createElement(etiqueta);
  if (clase) e.className = clase;
  if (texto !== undefined) e.textContent = texto;
  return e;
}
function imagen(nombre, clase) {
  const i = crear("img", clase);
  i.src = `arte/${nombre}.png`;
  i.alt = "";
  return i;
}
function boton(texto, accion) {
  const b = crear("button", "boton turquesa", texto);
  b.type = "button";
  b.addEventListener("click", accion);
  return b;
}
const escua = (momento) => (POSES_ESCUA.includes(momento) ? `escua_${momento}` : "escua");

function animar(nodo, cuadros, opciones) {
  const a = nodo.animate(cuadros, opciones);
  animaciones.push(a);
  return a;
}
function cortarAnimaciones() {
  animaciones.forEach((a) => a.cancel());
  animaciones = [];
}

// ── AIDA corriendo ──
const ALTO_PISTA = 460, SUELO = 404; // unidades del dibujo

/* En el celular no va. Se decide por el aparato y no por el tamaño de la
   ventana, para que el zoom del navegador no la haga desaparecer. */
const hayLugarParaCorrer = !(window.matchMedia("(pointer: coarse)").matches
    && Math.min(screen.width, screen.height) < 600)
  && !window.matchMedia("(prefers-reduced-motion: reduce)").matches;
document.body.classList.toggle("con-pista", hayLugarParaCorrer);

function ajustarLienzo() {
  if (!lienzo) return;
  escalaPista = Math.max(0.5, Math.min(1.1, window.innerHeight / 720));
  anchoPista = capa.clientWidth / escalaPista;
  const k = escalaPista * Math.min(2, window.devicePixelRatio || 1);
  lienzo.width = Math.round(anchoPista * k);
  lienzo.height = Math.round(ALTO_PISTA * k);
  lienzo.style.height = `${ALTO_PISTA * escalaPista}px`;
  lienzo.getContext("2d").setTransform(k, 0, 0, k, 0, 0);
  capa.style.setProperty("--k", escalaPista);
}

// ── Tarjetas grandes ──
function tarjeta(clase, ...hijos) {
  cortarAnimaciones();
  corredora = lienzo = null;
  const caja = crear("div", `tarjeta ${clase}`);
  caja.append(...hijos);
  capa.replaceChildren(caja);
  capa.hidden = false;
  mesa.hidden = true;
  $("marcador").hidden = true;
  window.scrollTo(0, 0);
}
const linea = (clase, texto) => crear("div", `linea ${clase}`, texto);
function grupo(clase, ...hijos) {
  const f = crear("div", clase);
  f.append(...hijos);
  return f;
}

/* La marca, como en el encabezado de aidaasistente.com. */
function marca() {
  return grupo("marca", imagen("aida-mark"), grupo("marca-textos",
    crear("span", "marca-nombre", "AIDA"),
    crear("span", "marca-lema", "Tu asistente digital")));
}

/* destino: en qué parte del ancho se frena (0 a 1). */
function pisoConAida(destino, pasear = false) {
  if (!hayLugarParaCorrer) return;
  lienzo = crear("canvas");
  capa.append(grupo("pista", crear("div", "piso"), lienzo));
  ajustarLienzo();
  destinoPista = destino;
  corredora = new AidaCorre(-80, SUELO, 1.25);
  corredora.destino = anchoPista * destino;
  corredora.pasear = pasear;
  corredora.limites = [100, Math.max(110, anchoPista - 100)];
}

function mostrarPortada() {
  tarjeta("portada",
    linea("t-titulo", "¿Es seguro?"),
    linea("t-de", "Un juego de"),
    marca(),
    linea("t-ayuda", "Ayudá a Don Tito a descubrir los engaños."),
    imagen(escua("portada"), "figura escua escua-hamaca"),
    boton("Jugar  ▸", empezarPartida));
}

function empezarPartida() {
  aciertos = jugados = puntos = 0;
  mostrarInicioDia();
}

function mostrarInicioDia() {
  const d = DIAS[dia];
  tarjeta("inicio",
    linea("d-numero ambar", `Día ${dia + 1} de ${DIAS.length}`),
    linea("d-titulo", d.titulo),
    crear("div", "consejo", d.consejo),
    imagen(escua("amenaza"), "figura escua"),
    boton("Empezar  ▸", empezarDia));
  sonar("escua", -8);
  pisoConAida(0.16);
}

function empezarDia() {
  capa.hidden = true;
  capa.replaceChildren();
  corredora = lienzo = null;
  mesa.hidden = false;
  $("marcador").hidden = false;
  casos = DIAS[dia].casos;
  aciertosDia = puntosDia = indice = 0;
  mostrarCaso();
}

// ── Un caso ──
function mostrarCaso() {
  cortarAnimaciones();
  caso = casos[indice];
  respondido = false;
  segundos = 0;
  $("lbl-dia").textContent = `Día ${dia + 1} · ${DIAS[dia].titulo}`;
  $("lbl-mensaje").textContent = `Mensaje ${indice + 1} de ${casos.length}`;
  $("sello").hidden = true;
  $("escua-asoma").hidden = true;
  mesa.classList.remove("respondido");
  $("btn-seguro").hidden = $("btn-trampa").hidden = $("btn-ayuda").hidden = false;
  $("btn-siguiente").hidden = true;
  prepararAyudas();
  window.scrollTo(0, 0);

  const e = TIPOS[caso.tipo] || TIPOS.app;
  const pantalla = $("pantalla");
  for (const [k, v] of Object.entries({
    "--pantalla": e.fondo, "--cab": e.cab, "--cab-letra": e.txt, "--burbuja": e.burbuja, "--letra": e.letra,
  })) pantalla.style.setProperty(k, v);
  $("cabecera").classList.remove("mirada");
  const banco = caso.tipo === "app" && caso.foto === "logo_banco";
  pantalla.classList.toggle("banco", banco);
  $("avatar").src = `arte/fotos/${caso.foto}.png`;
  $("icono").textContent = banco ? "" : e.icono;
  $("nombre").textContent = caso.de;
  $("numero").textContent = caso.numero;
  $("cuerpo").replaceChildren(...caso.partes.map(armarParte));
  $("cuerpo").scrollTop = 0;

  // El teléfono entra desde abajo.
  animar($("telefono"), [{ transform: "translateY(60vh)" }, { transform: "none" }],
    { duration: 450, easing: "cubic-bezier(.25,.46,.45,.94)" });
  sonar("llega");

  // El globo aparece solo si hay algo importante para saber.
  if (caso.contexto) {
    aidaDice("aida_normal", [crear("b", "", "Ojo:"), ` ${caso.contexto}`]);
  } else {
    cara("aida_normal");
    $("globo").hidden = true;
  }
}

function armarParte(p, i) {
  const b = crear("button", `parte ${p.k || ""}`);
  b.type = "button";
  if (p.k === "foto") {
    b.append(crear("span", "rotulo", p.t), imagen(`fotos/${p.img}`, p.img));
  } else {
    b.textContent = p.k === "permiso" ? `☐  ${p.t}` : p.t;
  }
  b.addEventListener("click", () => mirar(i));
  return b;
}

/* Lo que conviene mirar primero: las partes sospechosas; si no hay, todo. */
function prepararAyudas() {
  ayudaN = 0;
  ayudas = caso.partes.map((p, i) => (p.p ? i : null)).filter((i) => i !== null);
  if (caso.pista_de) ayudas.push(-1);
  if (!ayudas.length) ayudas = [-1, ...caso.partes.keys()];
}

/* Cada vez que se pide ayuda, AIDA señala otra cosa. */
function pedirAyuda() {
  if (respondido || !capa.hidden) return;
  const i = ayudas[ayudaN++ % ayudas.length];
  mirar(i);
  if (i >= 0) $("cuerpo").children[i].scrollIntoViewIfNeeded?.(false);
}

/* Tocar una parte (-1 es el remitente): AIDA dice qué ve. */
function mirar(i) {
  if (respondido) return;
  const nota = i < 0 ? caso.nota_de : caso.partes[i].n;
  const esPista = i < 0 ? caso.pista_de : caso.partes[i].p;
  sonar("lupa", -6);
  const nodo = i < 0 ? $("cabecera") : $("cuerpo").children[i];
  // Solo queda marcado lo último que se miró.
  mesa.querySelectorAll(".mirada").forEach((n) => n.classList.remove("mirada"));
  nodo.style.setProperty("--borde", esPista ? AMBAR : TURQ);
  nodo.classList.add("mirada");
  aidaDice(esPista ? "aida_seria" : "aida_pensando", [nota]);
  // En vertical el globo achica el teléfono: se acerca la parte señalada.
  if (i >= 0) {
    const c = $("cuerpo");
    const abajo = nodo.offsetTop - c.offsetTop + nodo.offsetHeight + 16;
    if (abajo > c.scrollTop + c.clientHeight) c.scrollTop = abajo - c.clientHeight;
  }
}

function cara(nombre) {
  const a = $("aida"), ruta = `arte/${nombre}.png`;
  if (a.getAttribute("src") === ruta) return;
  a.src = ruta;
  animar(a, [{ transform: "scale(.92,1.08)" }, { transform: "scale(1.03,.97)" }, { transform: "none" }],
    { duration: 300, easing: "ease-out" });
}

function aidaDice(nombre, contenido) {
  cara(nombre);
  $("globo").hidden = false;
  $("globo-texto").replaceChildren(...contenido);
  $("globo-texto").scrollTop = 0;
}

// ── Decidir ──
function puntosPor(tardo) {
  const rapidez = Math.max(0, Math.min(1, (SEGUNDOS_LENTO - tardo) / (SEGUNDOS_LENTO - SEGUNDOS_RAPIDO)));
  return PUNTOS_ACIERTO + Math.round((PUNTOS_RAPIDEZ * rapidez) / 10) * 10;
}

function decidir(diceTrampa) {
  if (respondido || !capa.hidden) return;
  respondido = true;
  mesa.classList.add("respondido");
  $("btn-seguro").hidden = $("btn-trampa").hidden = $("btn-ayuda").hidden = true;

  const estafa = caso.estafa;
  const acerto = diceTrampa === estafa;
  jugados++;
  if (acerto) {
    aciertos++;
    aciertosDia++;
    const ganados = puntosPor(segundos);
    puntos += ganados;
    puntosDia += ganados;
  }

  // El sello muestra lo que el mensaje era de verdad.
  ponerSello(estafa ? "TRAMPA" : "SEGURO", estafa ? CORAL : VERDE);
  const titulo = crear("b");
  titulo.append(
    crear("span", acerto ? "bien" : "casi", acerto ? "¡Muy bien!" : "¡Casi!"),
    `\n${estafa ? "Era una trampa." : "Era de verdad."}`);
  const expresion = acerto ? (estafa ? "aida_festeja" : "aida_pulgar") : "aida_confundida";
  aidaDice(expresion, [titulo, `\n\n${caso.leccion}`]);

  if (acerto) {
    sonar("bien");
  } else {
    sonar("mal", -6);
    if (estafa) asomaEscua();
  }
  $("btn-siguiente").hidden = false;
  $("btn-siguiente").focus({ preventScroll: true });
}

function ponerSello(texto, color) {
  const s = $("sello");
  const giro = -(6 + Math.random() * 8);
  s.textContent = texto;
  s.style.color = color;
  s.style.transform = `rotate(${giro}deg)`;
  s.hidden = false;
  animar(s, [
    { transform: `rotate(${giro}deg) scale(2.6)`, opacity: 0 },
    { transform: `rotate(${giro}deg)`, opacity: 0.95 },
  ], { duration: 180, easing: "ease-in" }).finished.then(() => {
    sonar("sello");
    animar($("telefono"), [0, 1.5, -1, 0].map((g) => ({ transform: `rotate(${g}deg)` })), { duration: 160 });
  }).catch(() => {}); // se canceló porque ya se pasó al siguiente
}

function asomaEscua() {
  const e = $("escua-asoma");
  e.src = `arte/${escua("rie")}.png`;
  e.hidden = false;
  const total = 2000;
  const paso = (ms, y, giro) => ({ offset: ms / total, transform: `translateY(${y}px) rotate(${giro}deg)` });
  animar(e, [
    { ...paso(0, 260, 0), opacity: 0, easing: "cubic-bezier(.34,1.56,.64,1)" },
    { ...paso(300, 0, 0), opacity: 1 },
    paso(450, 0, 8), paso(600, 0, -8), paso(750, 0, 0),
    { ...paso(1550, 0, 0), opacity: 1, easing: "ease-in" },
    { ...paso(1900, 240, 0), opacity: 0 },
    { ...paso(2000, 240, 0), opacity: 0 },
  ], { duration: total, fill: "forwards" });
  const caso_ = caso;
  setTimeout(() => { if (caso === caso_ && capa.hidden) sonar("escua", -3); }, 300);
}

function siguiente() {
  if (!respondido || !capa.hidden) return;
  $("btn-siguiente").hidden = true;
  indice++;
  if (indice >= casos.length) mostrarFinDia();
  else mostrarCaso();
}

// ── Fin del día y final ──
function mostrarFinDia() {
  const bien = aciertosDia * 2 >= casos.length;
  const todo = aciertosDia === casos.length;
  const ultimo = dia >= DIAS.length - 1;
  tarjeta("fin-dia",
    linea("f-titulo", `¡Terminaste el día ${dia + 1}!`),
    linea("f-puntos ambar", `${puntosDia} puntos`),
    linea("f-aciertos", `Acertaste ${aciertosDia} de ${casos.length}`),
    linea("f-nota turq", "Suman los aciertos y la rapidez."),
    grupo("figuras",
      imagen(bien ? "aida_pulgar" : "aida_corazon", "figura aida"),
      imagen(todo ? escua("enojada") : escua("rie"), "figura escua")),
    boton(ultimo ? "Ver el final  ▸" : "Seguir  ▸", () => {
      if (ultimo) {
        mostrarFinal();
      } else {
        dia++;
        mostrarInicioDia();
      }
    }));
  sonar("bien", -4);
  pisoConAida(0.23);
}

function mostrarFinal() {
  const parte = aciertos / Math.max(jugados, 1);
  const figuras = parte >= 0.9 ? ["aida_trofeo"]
    : parte >= 0.7 ? ["aida_pulgar"]
    : ["aida_campana", "aida_anteojos"];
  // Lo que hace AIDA de verdad.
  const promo = grupo("promo",
    crear("strong", "", "AIDA te cuida en el celular"),
    crear("span", "", "Detecta engaños y amenazas, y te avisa a tiempo."),
    crear("span", "", "¿Una duda con el celular? Te guía paso a paso."));
  tarjeta("final",
    grupo("figuras", ...figuras.map((n, i) => imagen(n, `figura ${i ? "otra" : "aida"}`))),
    linea("z-titulo", parte >= 0.7 ? "¡Muy bien!" : "¡Seguí practicando!"),
    linea("z-puntos ambar", `Total: ${puntos} puntos`),
    linea("z-aciertos", `Acertaste ${aciertos} de ${jugados}`),
    promo,
    boton("Jugar de nuevo", () => {
      dia = 0;
      mostrarPortada();
    }));
  pisoConAida(0.12);
  sonar("bien");
}

// ── Controles ──
$("btn-ayuda").addEventListener("click", pedirAyuda);
$("btn-seguro").addEventListener("click", () => decidir(false));
$("btn-trampa").addEventListener("click", () => decidir(true));
$("btn-siguiente").addEventListener("click", siguiente);
$("cabecera").addEventListener("click", () => mirar(-1));

// Tocar a AIDA en cualquier tarjeta la hace saltar.
capa.addEventListener("pointerdown", (ev) => {
  if (!corredora || ev.target.closest("button, a")) return;
  const r = lienzo.getBoundingClientRect();
  if (corredora.toca((ev.clientX - r.left) / escalaPista, (ev.clientY - r.top) / escalaPista)) {
    corredora.saltar();
    sonar("lupa");
  }
});

document.addEventListener("keydown", (ev) => {
  if (ev.repeat || ev.ctrlKey || ev.metaKey || ev.altKey || !capa.hidden) return;
  const tecla = ev.key.toLowerCase();
  if (tecla === "s") decidir(false);
  else if (tecla === "t") decidir(true);
  else if (tecla === "a") pedirAyuda();
  else if ((tecla === "enter" || tecla === " ") && respondido) {
    ev.preventDefault(); // que el botón enfocado no avance dos veces
    siguiente();
  }
});

// Cuenta cuánto se tarda en decidir (para el puntaje) y mueve a AIDA.
let antes = performance.now();
requestAnimationFrame(function cuadro(ahora) {
  const dt = Math.min(0.05, Math.max(0, (ahora - antes) / 1000));
  antes = ahora;
  if (!respondido && caso && capa.hidden) segundos += dt;
  if (corredora) {
    corredora.avanzar(dt);
    const ctx = lienzo.getContext("2d");
    ctx.clearRect(0, 0, anchoPista, ALTO_PISTA);
    corredora.dibujar(ctx);
  }
  requestAnimationFrame(cuadro);
});

window.addEventListener("resize", () => {
  if (!corredora) return;
  ajustarLienzo();
  corredora.limites = [100, Math.max(110, anchoPista - 100)];
  corredora.destino = anchoPista * destinoPista;
});
mostrarPortada();
