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
| Motor | Strata 0.2.18 (Terminal y motor 0.1.64, `windows-x86_64-cuda-cuda13`), feed firmado (secuencia 130) |

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

El perfil de 262K se retiró el 2026-11-22, a petición del usuario: a 131K el modelo ya llena la RAM y la VRAM.

Argumentos del motor: los que escribe el instalador de Strata para este equipo (`--expert-cache auto`,
`--prefill auto`, `--kv int8`, `--kv-resident 32768` con KV en RAM, perfil de expertos incluido), sin visión ni
`--parallel`. `serve --plan` muestra que el servidor añade `--draft dflash2 --spec 6 --draft-conf 0.7` y el
vocabulario de borrador `latin` (por el idioma del equipo). Muestreo y razonamiento: los predeterminados del
servidor; en Pi, `reasoning_effort` `none`, `low`, `medium` o `high`, sin presupuesto.

## Limitaciones conocidas

- Sin calibración propia (decisión del usuario, 2026-11-22); solo `strata serve --plan`. El usuario lo probó desde
  Pi, lo comparó con el Coder (retirado: resultados claramente peores) y lo adoptó el mismo día; se registró en Pi,
  OpenCode y DSH.
- Memoria a 131K (log del primer arranque): los 43 GB de expertos en RAM fija, 1,55 GiB de KV y 1,28 GiB de caché de
  conversaciones; quedaron unos 7 GiB de RAM disponibles y 0,4 GiB de memoria comprometida libre. La caché de
  expertos (5.200 ranuras, 8,43 GiB) toma toda la VRAM libre: 83–343 MiB libres, y Strata sugiere
  `--vram-reserve-mib` de 1.059 a 1.664. Aciertos de la caché en generación: 83–88 %.
- El instalador avisó de que el archivo de paginación es de 3,9 GB y crece a demanda, y recomienda uno fijo de
  64 GB si el modelo no arranca o usa menos VRAM (Strata issue #60). No se cambió.
- PCIe 4.0 x16 (la placa no admite 5.0).
- Las rutas de los JSON son absolutas bajo `D:\LLM`. shortcut: Strata no documenta rutas relativas en su
  configuración; revisar si el despliegue cambia de unidad.
- La primera comparación con Strata (2026-11-11, Qwen3.6 35B-A3B) lo descartó; aquella ruta de Qwen3.6 no es la de
  este modelo.

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
  41 °C y sin límites activos). `--vram-reserve-mib 1536` es la mitigación que sugiere Strata; no aplicada.
