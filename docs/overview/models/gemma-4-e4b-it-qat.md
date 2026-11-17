# Gemma 4 E4B IT QAT

- Modelo: `gemma-4-E4B_q4_0-it.gguf` y proyector `gemma-4-E4B-it-mmproj.gguf`
- Repositorio: `google/gemma-4-E4B-it-qat-q4_0-gguf` (GGUF oficial de Google; base
  `google/gemma-4-E4B-it-qat-q4_0-unquantized`)
- Revisión: `4b4a2c1d584be7264f87aac328a1bc739ce81b6c` (cabeza de `main` el 2026-11-17)
- Licencia: Apache 2.0, sin acceso restringido
- Alias API: `gemma-4-e4b-it-qat`
- Arquitectura GGUF: `gemma4` denso con *Per-Layer Embeddings* (4,5B efectivos, 8B con embeddings;
  `size_label` 7.5B), 42 capas, `embedding_length` 2560, ventana deslizante de 512 alternada con atención
  global, 18 capas que comparten KV y contexto nativo 131.072.

## Multimodalidad

Sí. La tarjeta anuncia texto, imagen, vídeo (como secuencia de fotogramas, hasta 60 s) y audio (hasta 30 s,
reconocimiento y traducción de voz), con salida de texto. El proyector de la publicación (`general.type =
mmproj`, BF16, 478M) tiene los dos codificadores: visión (`clip.has_vision_encoder`, `gemma4v`, 16 bloques)
y audio (`clip.has_audio_encoder`, `gemma4a`, 12 bloques). Con el proyector cargado, `/props` publica
`vision`, `video` y `audio`, y las pruebas de imagen y audio funcionaron (ver «Validación»).

Como en `gemma-4-12b-it-qat`, el perfil que carga el proyector usa el sufijo `-vision` aunque también admite
audio: los sufijos `-audio` y `-omni` están reservados a LFM3.

## Cuantización

`general.file_type = 2` (Q4_0, QAT). Tipos: Q4_0 en 342 tensores, Q6_K en 2 (`token_embd` y
`per_layer_token_embd`), F16 en 1 (`per_layer_model_proj`) y F32 en 321. Es la única cuantización publicada.

## Artefactos

| Archivo | Tamaño | SHA-256 |
| --- | ---: | --- |
| `gemma-4-E4B_q4_0-it.gguf` | 5.154.941.280 bytes | `676c35070db6dbe52f93e9c864ee0fba4eddea94b9c875d9cb10daff453fbaee` |
| `gemma-4-E4B-it-mmproj.gguf` | 991.552.256 bytes | `7498a37cb619e55f2fcf87eb931f56e99389ed6d432e4c5c66110694c0d65578` |

SHA-256 LFS de la API de Hugging Face en la revisión fijada; las descargas se verificaron por tamaño y
SHA-256. La publicación no incluye borrador MTP.

## Perfiles

| Lanzador | Contexto | Batch/UBatch | Proyector | Alias de perfil |
| --- | ---: | ---: | :---: | --- |
| `start-agentic-auto-131k-1024.cmd` | 131.072 | 1024/1024 | no | `gemma-4-e4b-it-qat-131k` |
| `start-agentic-auto-vision-131k-1024.cmd` | 131.072 | 1024/1024 | sí | `gemma-4-e4b-it-qat-vision-131k` |

Solo 131K: es el contexto nativo, y la política del catálogo no crea 262K por encima de él. Copian los
perfiles sin MTP de `gemma-4-12b-it-qat` salvo modelo, proyector y alias: `b12359-cuda13.5`,
`--gpu-layers auto --fit on`, `--fit-target 1024` / `2048`, 6 hilos, `--cache-ram 8192`, caché KV `q8_0`,
Flash Attention, `--parallel 1`, `--split-mode none`, Jinja, `--load-mode none`, logs compactos y
`--reasoning-budget 8192`. El modelo entero cabe en la GPU.

- Muestreo: `--temp 1.0 --top-p 0.95 --top-k 64`, la configuración estándar de la tarjeta (también en los
  metadatos `general.sampling.*` del GGUF).
- `--reasoning auto`: `/apply-template` inserta `<|think|>` en el turno de sistema, así que el razonamiento
  está activado por defecto. Según la tarjeta, E2B/E4B, a diferencia del resto, no emiten el bloque de
  pensamiento vacío cuando está desactivado.

## Validación (2026-11-17, `b12359-cuda13.5`)

`Test-ModelIntegrity.ps1` (2/2), `Test-Llm.ps1 -ConfigurationOnly -RequireInstalledFiles` sin filtros (46/46)
y smoke de los dos perfiles pasan. Calibración bajo carga con
`logs/validation/calibration-gemma-4-e4b-it-qat-20261117/Invoke-Calibration.ps1`: prompt de 54.442 tokens con
un dato enterrado, sin razonamiento. VRAM total 16.303 MiB, con unos 1.600 MiB ocupados por el escritorio antes
de arrancar; RAM libre mínima de 44 GB. Una repetición por perfil.

| Perfil | VRAM tras carga | VRAM pico | Carga | Prefill (54K) | Generación (código) | Generación (54K) | Reutilización |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| 131K | 6.656 MiB | 6.774 MiB | 2 s | 11.839 tok/s | 158,1 tok/s | 81,5 tok/s | 54.442 de 54.442 |
| Visión 131K | 7.744 MiB | 8.234 MiB | 2 s | 11.860 tok/s | 155,0 tok/s | 81,6 tok/s | 54.442 de 54.442 |

- `/props`: `n_ctx` 131.072 en ambos; `vision`, `video` y `audio` solo con el proyector. `/v1/models`
  publica el alias canónico.
- Contrato de razonamiento: con `17 × 23` responde `391` sin razonar (el modelo decide no pensar en lo trivial).
  Con un problema de horarios razona 207 palabras y acierta (`244`); `enable_thinking: false` deja
  `reasoning_content` vacío; `thinking_budget_tokens: 64` lo corta en 43 palabras, pero el resto del
  razonamiento acaba en `content` antes de la respuesta, como en el 12B. Los clientes no deberían enviar
  presupuestos muy bajos.
- Tool calling: `get_weather` con `{"location":"Madrid"}` y `finish_reason tool_calls` en ambos perfiles.
- Visión: describe la imagen de prueba como tres franjas roja, verde y azul de izquierda a derecha
  (la llama «bandera horizontal», aunque el orden de las franjas es correcto).
- Audio: un WAV de 16 kHz sintetizado con la voz de Windows («The quick brown fox jumps over the lazy dog.
  Please deliver seventeen boxes to the main office on Tuesday.») se transcribió bien en la primera frase y
  con errores en la segunda («seven timba exist to me in office»). Es una sola muestra con voz sintética, no una
  medida de calidad.
- La respuesta enterrada (638 unidades, estación 12) se recuperó en los dos perfiles.
- Cierre limpio: el puerto 8080 quedó libre tras cada perfil.

Registros: `logs/validation/calibration-gemma-4-e4b-it-qat-*-20261117-*.json` (la primera ejecución del perfil de
texto, a las 19:16:40, no incluía la pregunta de razonamiento difícil) y
`logs/validation/smoke-tests-20261117-191637-127-a4b09953.json`.

## Pendiente

- Contexto completo (131.072 tokens exactos), vídeo, calidad de audio con voz real, calidad general y sesiones
  reales en Pi, OpenCode y DSH, no evaluados. Ningún cliente envía audio hoy.
