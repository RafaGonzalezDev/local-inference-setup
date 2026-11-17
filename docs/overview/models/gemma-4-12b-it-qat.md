# Gemma 4 12B IT QAT

- Modelo: `gemma-4-12B-it-qat-UD-Q4_K_XL.gguf`, proyector `mmproj-BF16.gguf` y borrador MTP
  `mtp-gemma-4-12B-it.gguf`
- Repositorio: `unsloth/gemma-4-12B-it-qat-GGUF` (base `google/gemma-4-12B-it-qat-q4_0-unquantized`)
- Revisión: `980b060c40a8539ac159e0501a3e0f66a6365af3` (cabeza de `main` el 2026-11-16)
- Licencia: Apache 2.0, sin acceso restringido
- Alias API: `gemma-4-12b-it-qat`
- Arquitectura GGUF: `gemma4` (denso unificado de 12B sin codificadores, 48 capas, atención deslizante de
  1024 alternada con global, contexto nativo 262.144). Entrada de texto, imagen, vídeo y audio según la
  tarjeta; `/props` anuncia las tres modalidades con el proyector cargado.

Es la versión QAT (Q4_0 entrenado con cuantización): la tarjeta indica que conserva una calidad similar a
bfloat16. `UD-Q4_K_XL` es la única cuantización que publica el repositorio.

Pese al nombre, el archivo es **Q4_0 puro**, sin K-quants: la cabecera (leída el 2026-11-17) declara
`general.file_type = 2` (Q4_0) y `general.name` «Gemma-4 12B IT (smart Q4_0, QAT-lossless)». Tipos: Q4_0 en 329
tensores (todos los pesos, incluido `token_embd`) y F32 en 338 (normas y escalas). Es el formato en el que se
hizo el QAT, así que «UD-Q4_K_XL» solo identifica la publicación de Unsloth.

## Artefactos

| Archivo | Tamaño | SHA-256 |
| --- | ---: | --- |
| `gemma-4-12B-it-qat-UD-Q4_K_XL.gguf` | 6.716.356.800 bytes | `90fd44e29e0d7cffeb0fd00dc73cfdab9ed0b0e95306ecf7821ea634c940c370` |
| `mmproj-BF16.gguf` | 175.115.840 bytes | `dcb8103adad042b1bf99df767aaf34eb37c5a73a4a2f0417e4d7ba557e91664f` |
| `mtp-gemma-4-12B-it.gguf` | 253.708.800 bytes | `fcb35dea42c71333db904cee11baac525c9ef872818ee3753f6cb156f3c6f4f6` |

SHA-256 LFS de la API de Hugging Face en la revisión fijada; todas las descargas se verificaron por tamaño y
SHA-256. El proyector es BF16 (también hay F16 y F32), como el de Gemma 26B ya instalado. El borrador es el
`Q4_0` que la tarjeta recomienda ("smart Q4_0", prácticamente sin pérdida), idéntico al de `MTP/`; hay también
`Q8_0`, `F16` y `BF16` sin instalar.

## MTP

El borrador es un archivo aparte (arquitectura `gemma4-assistant`) que comparte la caché KV del modelo:
`--spec-draft-model ... --spec-type draft-mtp --spec-draft-n-max 4 --spec-draft-ngl auto`. Siguiendo la política
del catálogo, los perfiles de visión nunca lo llevan, y cada perfil con MTP tiene su equivalente sin MTP. El
arranque registra `failed to measure the memory of the extra model, fitting without it`: `--fit` no cuenta el
borrador, así que el margen se confirmó midiendo.

## Perfiles

| Lanzador | Contexto | Batch/UBatch | Visión | MTP | Alias de perfil |
| --- | ---: | ---: | :---: | :---: | --- |
| `start-agentic-auto-131k-1024.cmd` | 131.072 | 1024/1024 | no | no | `gemma-4-12b-it-qat-131k` |
| `start-agentic-auto-262k-1024.cmd` | 262.144 | 1024/1024 | no | no | `gemma-4-12b-it-qat-262k` |
| `start-agentic-auto-mtp-131k-1024.cmd` | 131.072 | 1024/1024 | no | sí | `gemma-4-12b-it-qat-mtp-131k` |
| `start-agentic-auto-mtp-262k-1024.cmd` | 262.144 | 1024/1024 | no | sí | `gemma-4-12b-it-qat-mtp-262k` |
| `start-agentic-auto-vision-131k-1024.cmd` | 131.072 | 1024/1024 | sí | no | `gemma-4-12b-it-qat-vision-131k` |
| `start-agentic-auto-vision-262k-1024.cmd` | 262.144 | 1024/1024 | sí | no | `gemma-4-12b-it-qat-vision-262k` |

Base común del catálogo, sin cambios: `b12359-cuda13.5`, `--gpu-layers auto --fit on`, `--fit-target 1024`
(texto y MTP) / `2048` (visión), 6 hilos, `--cache-ram 8192`, caché KV `q8_0`, Flash Attention,
`--parallel 1`, `--split-mode none`, Jinja, `--load-mode none`, logs compactos y `--reasoning-budget 8192`.

- Muestreo: `--temp 1.0 --top-p 0.95 --top-k 64`, la configuración estándar de la tarjeta para todos los usos.
- `--reasoning auto`: la plantilla lee `enable_thinking` (por defecto falso), pero `/apply-template` con
  `--reasoning auto` inserta `<|think|>` en el turno de sistema, así que razona por defecto.
- La visión no fija `--image-min-tokens`; la tarjeta ofrece presupuestos de 70 a 1120 tokens por imagen y no
  pide uno concreto.

## Validación (2026-11-16, `b12359-cuda13.5`)

Prompt de 56.941 tokens con una respuesta enterrada, sin razonamiento; VRAM total 16.303 MiB con unos
2.150 MiB ocupados por el escritorio antes de arrancar. Una repetición por perfil.

| Perfil | VRAM tras carga | VRAM pico | Prefill | Generación (código) | Generación (57K) | Reutilización |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| 131K | 10.779 MiB | 11.190 MiB | 3.147 tok/s | 84,0 tok/s | 64,5 tok/s | 56.940 de 56.941 |
| 262K | 12.501 MiB | 12.898 MiB | 3.196 tok/s | 85,6 tok/s | 65,4 tok/s | 56.940 de 56.941 |
| MTP 131K | 11.806 MiB | 11.872 MiB | 3.249 tok/s | 246,4 tok/s | 143,8 tok/s | 56.940 de 56.941 |
| MTP 262K | 13.913 MiB | 14.252 MiB | 3.181 tok/s | 228,9 tok/s | 143,7 tok/s | 56.940 de 56.941 |
| Visión 131K | 11.315 MiB | 11.679 MiB | 3.208 tok/s | 86,5 tok/s | 63,6 tok/s | 56.940 de 56.941 |
| Visión 262K | 12.801 MiB | 13.256 MiB | 3.197 tok/s | 86,9 tok/s | 67,4 tok/s | 56.940 de 56.941 |

- MTP: aceptación de borradores del 76–79 % en la petición de código (303/382 y 300/393) y del 67 % en el
  prompt largo (16/24). Frente al perfil sin MTP del mismo contexto, la generación sube unas 2,7 veces en
  código y 2,2 veces a 57K. El pico de 14.252 MiB (MTP 262K) deja unos 2 GiB libres en la GPU.
- `/props`: `n_ctx` 131.072 y 262.144; las modalidades `vision`, `video` y `audio` solo aparecen en los
  perfiles de visión. `/v1/models` publica el alias canónico.
- Contrato de razonamiento: por defecto razona (84–154 palabras ante `17 × 23`); `enable_thinking: false` deja
  `reasoning_content` vacío; `thinking_budget_tokens: 64` lo recorta a 26–31 palabras. En una ejecución
  (visión 131K) el recorte dejó el razonamiento restante volcado en `content` antes de la respuesta `391`:
  los clientes no deberían enviar presupuestos muy bajos sin comprobarlo.
- Tool calling: `get_weather` con `{"location":"Madrid"}` y `finish_reason tool_calls` en los seis perfiles.
- Visión: ambos perfiles describen la imagen de prueba (tres franjas verticales roja, verde y azul).
- La respuesta enterrada (638 unidades, estación 12) se recuperó en los seis perfiles; una sola muestra con
  `temp 0.2`, no una medida de calidad.
- Cierre limpio: el puerto 8080 quedó libre tras cada perfil.

Registros: `logs/validation/calibration-gemma-4-12b-it-qat-*-20261116-*.json`.

## Pendiente

- Contexto completo (262.144 tokens exactos), vídeo, audio, calidad y sesiones reales en Pi, OpenCode y DSH
  no evaluados. El MTP se midió con una petición de código y un prompt largo, no con tráfico real.
- El tokenizador de `google/gemma-4-12B-it` cambió tras la publicación de otras conversiones (corrección de
  tokens defectuosos); no se comprobó si el GGUF de Unsloth lo incluye.