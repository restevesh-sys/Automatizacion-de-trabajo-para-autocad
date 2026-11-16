
`[README.md](https://github.com/user-attachments/files/34911001/README.md)
<p align="center"><img src="assets/img/og-image.png" alt="Herramientas de fibra y metrados" width="100%"></p>

<h1 align="center">Herramientas de fibra y metrados</h1>
<p align="center"><b>CAD & GIS</b> · Recursos gratuitos — 20 rutinas AutoLISP para AutoCAD / Civil 3D que te ahorran horas de clics, calculadora y sufrimiento.</p>
<p align="center">
  <a href="https://restevesh-sys.github.io/herramientas-fibra-metrados/"><b>🌐 Ver la página</b></a> ·
  <a href="#cómo-cargarlas-en-autocad">⚙️ Instalar</a> ·
  <a href="#lista-de-comandos">📋 Comandos</a>
</p>

## Galería
<img width="943" height="636" alt="msedge_HqmS0bxCB0" src="https://github.com/user-attachments/assets/dd7c17d5-f1fc-41d7-a1eb-458bc88ef015" />
<img width="862" height="630" alt="msedge_toko6uHtA2" src="https://github.com/user-attachments/assets/87460c6e-dd51-49b0-b5bf-338e21bf8717" />
<img width="922" height="643" alt="lrAOM6KQKS" src="https://github.com/user-attachments/assets/8ef6d4cf-a2c8-4d39-a59e-74c86c6b481f" />
<img width="850" height="641" alt="msedge_onp5OfBM7c" src="https://github.com/user-attachments/assets/151bafd0-e555-474a-a190-d6392b541bd2" />
<img width="1003" height="631" alt="msedge_sLsMZNyf3G" src="https://github.com/user-attachments/assets/18d7b738-988b-45af-9acd-d48b171ee6c8" />

<table>
<tr><td align="center" width="50%"><img src="assets/img/metrafibra.svg" width="100%" alt="METRAFIBRA"><br><b>01 · <code>METRAFIBRA</code></b><br><sub>Metrado de fibra por capa</sub></td><td align="center" width="50%"><img src="assets/img/metrapol.svg" width="100%" alt="METRAPOL"><br><b>02 · <code>METRAPOL</code></b><br><sub>Metrado dentro de un polígono</sub></td></tr>
<tr><td align="center" width="50%"><img src="assets/img/metrado_radial.svg" width="100%" alt="METRADO_GENERAL_RADIAL"><br><b>03 · <code>METRADO_GENERAL_RADIAL</code></b><br><sub>Metrado general de radiales</sub></td><td align="center" width="50%"><img src="assets/img/tabla_blocks.svg" width="100%" alt="TABLA_BLOCKS"><br><b>04 · <code>TABLA_BLOCKS</code></b><br><sub>Conteo de bloques con vista</sub></td></tr>
<tr><td align="center" width="50%"><img src="assets/img/cortapol.svg" width="100%" alt="CORTAPOL"><br><b>05 · <code>CORTAPOL</code></b><br><sub>Cortar en el límite del polígono</sub></td><td align="center" width="50%"><img src="assets/img/selpol.svg" width="100%" alt="SELPOL"><br><b>06 · <code>SELPOL</code></b><br><sub>Seleccionar todo lo de adentro</sub></td></tr>
<tr><td align="center" width="50%"><img src="assets/img/recortapol.svg" width="100%" alt="RECORTAPOL"><br><b>07 · <code>RECORTAPOL</code></b><br><sub>Recortar fuera del límite</sub></td><td align="center" width="50%"><img src="assets/img/nomfibra.svg" width="100%" alt="NOMFIBRA"><br><b>08 · <code>NOMFIBRA</code></b><br><sub>Nomenclatura F1 / F2 / F3</sub></td></tr>
<tr><td align="center" width="50%"><img src="assets/img/radiografia.svg" width="100%" alt="RADIOGRAFIA"><br><b>09 · <code>RADIOGRAFIA</code></b><br><sub>Radiografía de la caja de 8 salidas</sub></td><td align="center" width="50%"><img src="assets/img/renombra.svg" width="100%" alt="RENOMBRA_NOMENCLATURA"><br><b>10 · <code>RENOMBRA_NOMENCLATURA</code></b><br><sub>Renombrar nomenclaturas en serie</sub></td></tr>
<tr><td align="center" width="50%"><img src="assets/img/acom_registro.svg" width="100%" alt="ACOM_REGISTRO"><br><b>11 · <code>ACOM_REGISTRO</code></b><br><sub>Acometidas en abanico desde el registro</sub></td><td align="center" width="50%"><img src="assets/img/acom_curva.svg" width="100%" alt="ACOM_REGISTRO_CURVA"><br><b>12 · <code>ACOM_REGISTRO_CURVA</code></b><br><sub>Acometidas sobre calle curva</sub></td></tr>
<tr><td align="center" width="50%"><img src="assets/img/acom_manzana.svg" width="100%" alt="ACOM_MANZANA"><br><b>13 · <code>ACOM_MANZANA</code></b><br><sub>Acometidas por manzana completa</sub></td><td align="center" width="50%"><img src="assets/img/radial_flex.svg" width="100%" alt="RADIAL_FLEX"><br><b>14 · <code>RADIAL_FLEX</code></b><br><sub>Radiales con curva flexible</sub></td></tr>
<tr><td align="center" width="50%"><img src="assets/img/unigap.svg" width="100%" alt="UNIGAP"><br><b>15 · <code>UNIGAP</code></b><br><sub>Unir tramos y marcar separaciones</sub></td><td align="center" width="50%"><img src="assets/img/uniarco.svg" width="100%" alt="UNIARCO"><br><b>16 · <code>UNIARCO</code></b><br><sub>Muchos cuadritos → un solo arco</sub></td></tr>
<tr><td align="center" width="50%"><img src="assets/img/unipol.svg" width="100%" alt="UNIPOL"><br><b>17 · <code>UNIPOL</code></b><br><sub>Unir en una sola polilínea</sub></td><td align="center" width="50%"><img src="assets/img/numera.svg" width="100%" alt="NUMERA"><br><b>18 · <code>NUMERA</code></b><br><sub>Numerar edificios, lotes y dptos.</sub></td></tr>
<tr><td align="center" width="50%"><img src="assets/img/txtxy.svg" width="100%" alt="TXTXY"><br><b>19 · <code>TXTXY</code></b><br><sub>Lista de textos con coordenadas</sub></td><td align="center" width="50%"><img src="assets/img/registro.svg" width="100%" alt="REGISTRO_2D / 3D"><br><b>20 · <code>REGISTRO_2D / 3D</code></b><br><sub>Registro prefabricado 60×40×60</sub></td></tr>
</table>

## Lista de comandos

| # | Comando | Categoría | Qué hace | Archivo |
|---|---|---|---|---|
| 01 | `METRAFIBRA` | Metrado | Suma longitudes de líneas, polilíneas y arcos agrupadas por capa y arma la tabla de metrado con su total. Adiós calculadora. | [`METRAFIBRA.lsp`](lisp/METRAFIBRA.lsp) |
| 02 | `METRAPOL` | Metrado | Mide solo lo que cae dentro del polígono límite (zona, área de servicio, frente de trabajo). Lo de afuera ni lo pela. | [`METRAPOL.lsp`](lisp/METRAPOL.lsp) |
| 03 | `METRADO_GENERAL_RADIAL` | Metrado | Cuenta y suma todos los radiales que salen de cada registro y te da el resumen general en una sola corrida. | [`METRADO_GENERAL_RADIAL.lsp`](lisp/METRADO_GENERAL_RADIAL.lsp) |
| 04 | `TABLA_BLOCKS` | Metrado | Tabla de conteo con la vista del bloque, agrupada por CAPA (que sí se entiende) en lugar del nombre críptico del bloque. | [`TABLA_BLOCKS.lsp`](lisp/TABLA_BLOCKS.lsp) |
| 05 | `CORTAPOL` | Polígonos | Parte líneas, polilíneas y círculos exactamente donde cruzan el polígono, para metrar cada zona por separado. | [`POLIGONO_HERRAMIENTAS.lsp`](lisp/POLIGONO_HERRAMIENTAS.lsp) |
| 06 | `SELPOL` | Polígonos | Selecciona todo lo que está dentro de un polígono existente. Sin ventanas a mano ni clics de más. | [`POLIGONO_HERRAMIENTAS.lsp`](lisp/POLIGONO_HERRAMIENTAS.lsp) |
| 07 | `RECORTAPOL` | Polígonos | Recorta lo que sobresale del polígono y deja solo tu zona. Incluye SELECPOL y SELECPOLTODO. | [`RECORTA_POL.lsp`](lisp/RECORTA_POL.lsp) |
| 08 | `NOMFIBRA` | Fibra | Nombra la continuidad F1 y las derivadas F2, F3… de la fibra de 24 hilos siguiendo la ruta y los cierres. | [`NOMFIBRA.lsp`](lisp/NOMFIBRA.lsp) |
| 09 | `RADIOGRAFIA` | Fibra | Vuelca a un TXT lo que hay dentro y alrededor de la caja (salidas F1/F2, acometidas, capas) en coordenadas locales del bloque. | [`RADIOGRAFIA.lsp`](lisp/RADIOGRAFIA.lsp) |
| 10 | `RENOMBRA_NOMENCLATURA` | Fibra | Busca un patrón (BUSCAPAT) y cambia segmentos en serie (RENSEQ), p. ej. A01 → R13, sin romper la estructura del nombre. | [`RENOMBRA_NOMENCLATURA.lsp`](lisp/RENOMBRA_NOMENCLATURA.lsp) |
| 11 | `ACOM_REGISTRO` | Acometidas | Traza las acometidas del registro a cada lote, con flecha en bloque y número consecutivo para contabilizarlas. | [`ACOM_REGISTRO.lsp`](lisp/ACOM_REGISTRO.lsp) |
| 12 | `ACOM_REGISTRO_CURVA` | Acometidas | La misma idea del abanico, pero respetando calles curvas y lotes girados. Las glorietas ya no dan miedo. | [`ACOM_REGISTRO_CURVA.lsp`](lisp/ACOM_REGISTRO_CURVA.lsp) |
| 13 | `ACOM_MANZANA` | Acometidas | Coloca y numera las acometidas de toda una manzana de un jalón, por ambos frentes. | [`ACOM_MANZANA.lsp`](lisp/ACOM_MANZANA.lsp) |
| 14 | `RADIAL_FLEX` | Acometidas | Dibuja radiales curvos (tipo flexoducto) desde un registro hacia sus destinos, sin cruzarse a lo loco. | [`RADIAL_FLEX.lsp`](lisp/RADIAL_FLEX.lsp) |
| 15 | `UNIGAP` | Dibujo | Une tramos por cercanía de extremos, simplifica, rotula la longitud en metros y pone un bloque en cada hueco y extremo libre. | [`UNIGAP.lsp`](lisp/UNIGAP.lsp) |
| 16 | `UNIARCO` | Dibujo | Reemplaza piezas sueltas a lo largo de una curva por un solo arco que sí se puede acotar. | [`UNIARCO.lsp`](lisp/UNIARCO.lsp) |
| 17 | `UNIPOL` | Dibujo | Junta recta + tramo ondulado (o lo que esté pegado) en una sola polilínea para anotar una sola distancia. | [`UNIPOL.lsp`](lisp/UNIPOL.lsp) |
| 18 | `NUMERA` | Dibujo | Numeración consecutiva o nota fija (CN-20) con bloques; NUMTABLA arma el resumen de conteo. No crea capas nuevas. | [`NUMERA.lsp`](lisp/NUMERA.lsp) |
| 19 | `TXTXY` | Datos | Saca X, Y y el contenido de los textos seleccionados en columnas, listo para Excel, CSV o Google Earth. | [`TXTXY.lsp`](lisp/TXTXY.lsp) |
| 20 | `REGISTRO_2D / 3D` | Datos | Dibuja el registro de concreto en planta 2D o en sólido 3D con medidas reales, para planos y fichas técnicas. | [`REGISTRO.lsp`](lisp/REGISTRO.lsp) |

## Cómo cargarlas en AutoCAD

1. Descarga los `.lsp` y guárdalos en una carpeta (ej. `%USERPROFILE%\Documents\LISP`).
2. `OPTIONS` → **Files** → **Trusted Locations** → agrega la carpeta.
3. `APPLOAD` → **Startup Suite → Contents** → agrega los archivos.
4. Escribe el comando (ej. `METRAFIBRA`). `U` deshace todo de un jalón.

Probado en AutoCAD / Civil 3D 2022, dibujo en metros (escala 1:1).

```

Para cambiar textos: edita `herramientas.json` y corre `python scripts/construir.py`.

---
<sub>Hecho por <b>RestevesH</b>. Úsalas bajo tu propio riesgo y revisa el resultado antes de entregar el plano.</sub>
