# qwen3.8-flash-next-gsq-rco (Strata)

Qwen3.8 Flash Next (MoE de 512 expertos por capa en 48 capas, 10 activos por token; contexto nativo 262.144) en la
cuantización GSQ-RCO IQ3_XXS de ISTA-DASLab. Servido por Strata, no por llama.cpp. Solo texto. Instalación y uso en
[strata/README.md](../../../strata/README.md).

## Procedencia

| Artefacto | Dato |
| --- | --- |
| Repositorio | [ISTA-DASLab/Qwen3.8-Flash-Next-GSQ-RCO-GGUF](https://huggingface.co/ISTA-DASLab/Qwen3.8-Flash-Next-GSQ-RCO-GGUF), revisión `ed59f92082b1e93c0e96d60a8b11aab089b52f09` (la misma que fija Strata 0.2.18) |
| Shard 1 | `IQ3_XXS/Qwen3.8-Flash-Next-GSQ-RCO-IQ3_XXS-00001-of-00002.gguf`, 47.039.860.096 bytes, SHA-256 `219ea929900dfa9ef091f3aa473fdba6874b65fcb36526d7d851ac9e95856d15` |
| Shard 2 (tabla n-gram) | `IQ3_XXS/Qwen3.8-Flash-Next-GSQ-RCO-IQ3_XXS-00002-of-00002.gguf`, 28.800.138.432 bytes, SHA-256 `316b46f3a2dbd68c900f43136ab9449f9dcc3725dfd8c794847c204bc161e113` |
| Licencia | La tarjeta declara Apache 2.0 y dice que los pesos heredan la del modelo base (Qwen3.8 Flash Next) |
| Motor | Strata 0.2.19 (Terminal y motor 0.1.65, `windows-x86_64-cuda-cuda13`), feed firmado (secuencia 131), desde el 2026-11-22; antes 0.2.18 (0.1.64, secuencia 130), que se conserva en `runtimes/strata/0.2.18/` |

SHA-256 del LFS de Hugging Face, comprobados por `Download-Model.ps1` y por `Test-ModelIntegrity.ps1`.

## Preparación de Strata

- `tools/iq_pack.py` creó `strata-data/packs/iq3_xxs` (índice de 1.079 tensores, 302 nativos, arena de 1,43 GiB y el
  tokenizador); los expertos se leen de los GGUF.
- Borrador DFlash2 (`strata-data/dflash2/qwen3.8-flash-next-dflash2.q4_0.pack`, 1,21 GB del release 0.2.16): el que
  Strata elige por defecto para este modelo con una petición a la vez. No se descargó la capa MTP (~5 GB); el
  `--mtp` de los JSON apunta a una carpeta inexistente y el servidor lo retira al usar DFlash2.

## Perfiles

| Lanzador | Contexto | Modelo en la API (`model_name`) | Puerto |
| --- | ---: | --- | --- |
| `start-text-131k.cmd` | 131.072 | `qwen3.8-flash-next-gsq-rco-131k` | `0.0.0.0:8080` |
| `start-text-200k.cmd` | 204.800 | `qwen3.8-flash-next-gsq-rco-200k` | `0.0.0.0:8080` |
| `start-text-262k.cmd` | 262.144 | `qwen3.8-flash-next-gsq-rco-262k` | `0.0.0.0:8080` |

El perfil de 262K se retiró el 2026-11-22, a petición del usuario: a 131K el modelo ya llena la RAM y la VRAM. El
mismo día se añadió el de 200K (204.800 tokens, el paso de 200K del menú de Strata), con los mismos argumentos que el
de 131K salvo `--max-context`: 2,42 GiB de KV en RAM fija según el log (+0,9 GiB sobre 131K) y la misma VRAM (misma
ventana de 32.768 tokens y misma reserva). Strata recomienda 128K como máximo con 64 GB.

El 2026-11-23 el usuario volvió a añadir el de 262K (nativo), copiado del de 200K. Ver «Perfil de 262K».

Argumentos del motor: los que escribe el instalador de Strata para este equipo (`--expert-cache auto`,
`--prefill auto`, `--kv int8`, `--kv-resident 32768` con KV en RAM, perfil de expertos incluido), sin visión ni
`--parallel`, más `--vram-reserve-mib 1536` (desde el 2026-11-22, ver «Velocidad observada»). Está solo en `args`,
no en `args_written`: Strata trata las diferencias entre ambos como opciones propias y no las pisa al reinstalar. `serve --plan` muestra que el servidor añade `--draft dflash2 --spec 6 --draft-conf 0.7` y el
vocabulario de borrador `latin` (por el idioma del equipo). Muestreo y razonamiento: los predeterminados del
servidor; en Pi, `reasoning_effort` `none`, `low`, `medium` o `high`, sin presupuesto.

## Limitaciones conocidas

- Sin calibración propia (decisión del usuario, 2026-11-22); solo `strata serve --plan`. El usuario lo probó desde
  Pi, lo comparó con el Coder (retirado: resultados claramente peores) y lo adoptó el mismo día; se registró en Pi,
  OpenCode y DSH.
- Memoria a 131K (log del primer arranque): los 43 GB de expertos en RAM fija, 1,55 GiB de KV y 1,28 GiB de caché de
  conversaciones; quedaron unos 7 GiB de RAM disponibles y 0,4 GiB de memoria comprometida libre. La caché de
  expertos (5.200 ranuras, 8,43 GiB) toma toda la VRAM libre: 83–343 MiB libres, y Strata sugiere
  `--vram-reserve-mib` de 1.059 a 1.664 (aplicado 1.536 después). Aciertos de la caché en generación: 83–88 %.
- El instalador avisó de que el archivo de paginación es de 3,9 GB y crece a demanda, y recomienda uno fijo de
  64 GB si el modelo no arranca o usa menos VRAM (Strata issue #60). No se cambió.
- PCIe 4.0 x16 (la placa no admite 5.0).
- Las rutas de los JSON son absolutas bajo `D:\LLM`. shortcut: Strata no documenta rutas relativas en su
  configuración; revisar si el despliegue cambia de unidad.
- La primera comparación con Strata (2026-11-11, Qwen3.6 35B-A3B) lo descartó; aquella ruta de Qwen3.6 no es la de
  este modelo.

## Strata 0.2.19 (2026-11-22)

Los dos lanzadores pasaron a `runtimes/strata/0.2.19/`. El instalador de 0.2.19 escribió para este equipo los
mismos argumentos que 0.2.18; solo cambian las rutas del Terminal y del perfil de expertos, que es idéntico (mismo
SHA-256), como `tools/iq_pack.py` y el vocabulario de borrador. Se reutilizan el paquete y el borrador DFlash2 sin
cambios. `serve --plan` da el mismo plan (DFlash2, `--spec 6`, `--draft-conf 0.7`, reserva de 1.536 MiB).

Según las notas de la versión, el motor 0.1.65 activa por defecto en Blackwell (`sm_120`) kernels FP4 e INT8
sobre Tensor Cores y un cabezal LM en dos etapas. Las mejoras publicadas son de una RTX 5090, sobre todo con
`IQ3_S`, `UD-Q4_K_XL` y `NVFP4`; para `IQ3_XXS` no hay cifras. Los argumentos y la reserva de VRAM no cambian, así
que no se espera más memoria, pero no se ha medido. Sin arrancar: el usuario lo prueba desde Pi.

## Velocidad observada (log del servidor)

`logs/strata/qwen3.8-flash-next-gsq-rco-131k.log`, dos sesiones del 2026-11-22 (134 peticiones desde Pi, DFlash2).
Cifras del propio motor (generación por petición); no es un benchmark controlado.

| Contexto de la petición | Sesión 1 (07:57) | Sesión 2 (08:45) |
| --- | --- | --- |
| 11–47K | 100–169 tok/s | 103–168 tok/s |
| 50–72K | 72–99 tok/s (una de 44) | 59–71 tok/s |
| 80–115K | — | 53–68 tok/s |
| Conversación nueva tras la anterior | 63–119 tok/s (recupera) | 50–66 tok/s a 16–54K (no recupera) |

- La caída con el contexto es la esperada: pasado el KV que cabe en VRAM (32.768 tokens), los aciertos de KV en VRAM
  bajan del 99,9 al 98,8 % y el motor llega a leer de RAM 20–100 MiB de KV por token generado. Es la variable que más
  se corresponde con la velocidad (r = 0,68); la longitud del contexto, −0,62; los aciertos de la caché de
  expertos, 0,46; la aceptación de borradores (65–89 %), 0,19.
- En la sesión 2 hay además un escalón: la generación bajó de ~105–168 a ~60–70 tok/s en la petición de 56K y siguió
  así en una conversación nueva de 16–22K. El contexto no lo explica. El log registró 0 MiB de VRAM libre al
  empezar una petición y Strata avisa de que, por debajo de 1 GiB, Windows puede pasar memoria de la GPU a la RAM;
  es la hipótesis más probable, sin confirmar (no se registraron relojes ni temperatura durante la sesión; después,
  41 °C y sin límites activos).

### Reserva de VRAM (2026-11-22)

Se añadió `--vram-reserve-mib 1536` (el motor deja 1.536 MiB libres en vez de 700), el valor que sugiere Strata en el
log. Estimación, sin medir: unas 550 ranuras menos en la caché de expertos (−11 % sobre ~5.200) y un 3–4 % menos de
generación en los picos, por analogía con la cifra que Strata documenta para el lector de imágenes en la GPU (~850
ranuras, "about 5% of decode"). A cambio, debería evitar el escalón si la causa era la VRAM agotada. No cambia la
caída gradual con el contexto (KV leído de RAM).

Resultado, tercera sesión (09:30, 67 peticiones hasta 103K): caché de 4.690 ranuras (7,61 GiB), VRAM libre de
862–1.052 MiB al empezar cada petición (antes, hasta 0) y aciertos de expertos del 77–81 %. Medianas de generación
por contexto: 106 tok/s a 0–20K, 104 a 20–40K, 123 a 40–60K, 119 a 60–80K, 129 a 80–100K y 115 a 100–103K
(mínimo 92, máximo 143). El escalón no apareció, lo que confirma en la práctica la hipótesis de la VRAM agotada. La
pérdida en los picos no se puede aislar: la aceptación de borradores fue mayor (71–86 %) que en las sesiones
anteriores.

## Perfil de 262K (2026-11-23)

El usuario creó `start-text-262k.cmd` y `text-262k.json` copiando los de 200K, pero el JSON solo cambió
`--max-context` en `args_written`: `args`, que es lo que lee el servidor, seguía en 204.800, y `model_name` y `log`,
en `-200k`. El arranque de las 10:26 (el JSON se guardó a las 10:25) sirvió por tanto 204.800 tokens con el alias
`-200k` y escribió en `qwen3.8-flash-next-gsq-rco-200k.log`. Se corrigieron `args`, `model_name` y `log`;
`serve --plan` confirma `--max-context 262144` y el alias `-262k`.

Sesión de esa mañana (10:26–14:19, 538 peticiones desde Pi, hasta 161.863 tokens de prompt), **a 204.800 tokens**:
caché de expertos de 4.454 ranuras (7,24 GiB), KV en RAM fija de 2,42 GiB y ningún aviso de VRAM por debajo de
1 GiB. Según el usuario, con el equipo dedicado a la inferencia, la RAM en uso se mantuvo en unos 54 de 61,9 GB
durante toda la mañana. Medianas de generación por contexto: 135 tok/s a 0–20K, 130 a 20–40K, 125 a 40–60K, 120 a 60–80K, 116 a
80–100K, 120 a 100–130K y 115 a 130–162K (mínimo 86). La caché de conversaciones (2.304 MiB, calculada con la RAM
libre) dejó de aparcar 14 conversaciones de 1,2–3 GiB por falta de presupuesto.

A 262K, sin arrancar todavía:

- Estimación: unos 3,1 GiB de KV en RAM fija (+0,7 GiB sobre 200K), es decir, unos 55 de 61,9 GB de RAM en uso
  con la carga de esta mañana; la misma VRAM y menos RAM libre para la caché de conversaciones.
- `serve --plan` elige `--draft-conf 0.8` (0,7 a 131K y 200K); el resto del borrador es igual. El plan nombra
  `qwen3.8-flash-next-dflash2.q4_0.pack`, pero todos los arranques registrados en los logs (131K y
  200K) cargaron la variante `q4_0-selq4.pack`.
- Pendiente: arrancarlo y comprobar la RAM disponible con prompts por encima de 205K.
