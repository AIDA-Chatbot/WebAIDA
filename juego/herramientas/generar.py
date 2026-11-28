"""Trae al juego web los textos, la animación y el arte del juego de Godot.

    python herramientas/generar.py

Lee de AIDA-Juego-Revision, AidaImagenesPingus y el logo del sitio (carpetas hermanas
de WebAIDA). Escribe datos/, arte/ y sonidos/ de acá.
"""
import ast
import json
import re
import shutil
from pathlib import Path

from PIL import Image

WEB = Path(__file__).resolve().parents[1]
AIDA = WEB.parents[1]
GODOT = AIDA / "AIDA-Juego-Revision"


def escribir(nombre, variable, valor):
    ruta = WEB / "datos" / nombre
    ruta.parent.mkdir(exist_ok=True)
    ruta.write_text(
        "/* Generado por herramientas/generar.py: no editar a mano. */\n"
        f"window.{variable} = {json.dumps(valor, ensure_ascii=False, indent=1)};\n",
        encoding="utf-8")


# ── Los casos: la lista DIAS de casos.gd, tal cual ──
gd = (GODOT / "juego/casos.gd").read_text(encoding="utf-8")
lista = gd[gd.index("const DIAS :=") + len("const DIAS :="):].strip()
lista = re.sub(r"\b(true|false)\b(?=\s*[,}])", lambda m: m[1].title(), lista)
dias = ast.literal_eval(lista)
escribir("casos.js", "DIAS", dias)

# ── Las animaciones de AIDA ──
tscn = (GODOT / "personaje/exacta/aida.tscn").read_text(encoding="utf-8")
bloques = dict(re.findall(
    r'\[sub_resource type="Animation" id="(\w+)"\]\n(.*?)(?=\n\[)', tscn, re.S))


def numeros(texto):
    return [float(n) for n in re.findall(r"-?\d+(?:\.\d+)?(?:e-?\d+)?", texto)]


def animacion(cuerpo):
    largo = float(re.search(r"^length = (.+)$", cuerpo, re.M)[1])
    a = {"largo": largo, "repite": "loop_mode = 1" in cuerpo, "pistas": {}, "eventos": []}
    for n, tipo in re.findall(r'tracks/(\d+)/type = "(\w+)"', cuerpo):
        ruta = re.search(rf'tracks/{n}/path = NodePath\("([^"]+)"\)', cuerpo)[1]
        claves = re.search(rf"tracks/{n}/keys = \{{(.*?)\n\}}", cuerpo, re.S)[1]
        tiempos = numeros(re.search(r'"times": PackedFloat32Array\(([^)]*)\)', claves)[1])
        if tipo == "method":
            nombres = re.findall(r'"method": &"(\w+)"', claves)
            a["eventos"] += [[t, m] for t, m in zip(tiempos, nombres)]
            continue
        valores = re.search(r'"values": \[(.*)\]', claves)[1]
        if "Vector2" in valores:
            v = [numeros(x) for x in re.findall(r"Vector2\(([^)]*)\)", valores)]
        else:
            v = [[x] for x in numeros(valores)]
        nodo, prop = ruta.split(":")
        a["pistas"][f"{nodo.split('/')[-1]}.{prop}"] = {"t": tiempos, "v": v}
    return a


ids = dict(re.findall(r'&"(\w+)": SubResource\("(\w+)"\)', tscn))
escribir("animaciones.js", "ANIMACIONES", {
    nombre: animacion(bloques[ids[nombre]])
    for nombre in ["quieto", "correr", "saltar", "caer", "aterrizar"]})

# ── Arte y sonidos ──
CARAS = ["normal", "pensando", "seria", "trofeo", "confundida", "festeja", "pulgar", "corazon", "saluda"]
imagenes = [f"aida_{c}" for c in CARAS] + ["escua"]
poses = [m for m in ["portada", "amenaza", "rie", "enojada"] if (GODOT / f"arte/escua_{m}.png").exists()]
imagenes += [f"escua_{m}" for m in poses]
escribir("arte.js", "POSES_ESCUA", poses)

copias = [f"arte/{n}.png" for n in imagenes]
copias += [f"arte/fotos/{p.name}" for p in (GODOT / "arte/fotos").glob("*.png")]
copias += [f"sonidos/{n}.wav" for n in ["llega", "lupa", "sello", "bien", "mal", "escua"]]
copias += [f"personaje/exacta/arte/{n}.png" for n in
           ["sombra", "pie", "aleta", "cuerpo", "ojo", "boca", "pico_abajo", "pico", "polvo"]]
for origen in copias:
    destino = WEB / origen.replace("personaje/exacta/arte", "arte/rig")
    destino.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(GODOT / origen, destino)
shutil.copyfile(GODOT / "icon.png", WEB / "arte/icono.png")
shutil.copyfile(WEB.parent / "assets/aida-mark.png", WEB / "arte/aida-mark.png")  # logo del header

# Las dos AIDAs del final que solo tiene la versión web.
for nombre, original in [("aida_campana", "campana-pose.png"),
                         ("aida_anteojos", "pinguino-anteojos-de-sol-brillos-sin-fondo.png")]:
    im = Image.open(AIDA / "AidaImagenesPingus" / original).convert("RGBA")
    im = im.crop(im.getchannel("A").getbbox())
    im.thumbnail((420, 420), Image.LANCZOS)
    im.save(WEB / f"arte/{nombre}.png")

print(f"listo: {len(dias)} días, {sum(len(d['casos']) for d in dias)} casos, {len(copias)} archivos")
