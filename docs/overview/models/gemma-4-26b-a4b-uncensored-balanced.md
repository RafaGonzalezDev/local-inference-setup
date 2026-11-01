# Gemma 4 26B A4B Uncensored Balanced

- Modelo: `Gemma4-26B-A4B-QAT-Uncensored-HauhauCS-Balanced-Q4_K_M.gguf` y proyector
  `mmproj-Gemma4-26B-A4B-QAT-Uncensored-HauhauCS-Balanced-BF16.gguf`
- Repositorio: `HauhauCS/Gemma4-26B-A4B-QAT-Uncensored-HauhauCS-Balanced-MTP` (variante sin rechazos de
  `google/gemma-4-26B-A4B-it`, construida desde los pesos QAT oficiales)
- Revisión: `f9093662a2e7ae0503f637088bc96f77a1a70c83` (cabeza de `main` el 2026-11-01)
- Licencia: `gemma`, sin acceso restringido
- Alias API: `gemma-4-26b-a4b-uncensored-balanced`
- Arquitectura GGUF: `gemma4` (MoE, 128 expertos con 8 activos, 30 capas, `embedding_length` 2816,
  `feed_forward_length` 2112, `expert_feed_forward_length` 704; atención deslizante de 1024 alternada con
  global; contexto nativo 262.144). Entrada de texto e imagen (el proyector anuncia también vídeo).

La variante **Balanced** es la que el autor recomienda: elimina los rechazos sin cambiar datos ni
capacidades y razona antes de responder. El usuario pidió primero `UD-Q4_K_L` de
`unsloth/gemma-4-26B-A4B-it-qat-GGUF`, que no existe (solo hay `UD-Q4_K_XL`), y eligió después esta
publicación, que solo ofrece `Q4_K_M`.

## Cuantización y MTP

Tipos reales leídos de la cabecera (`general.file_type = 15`, Q4_K_M): Q4_K 192, Q5_0 32, Q8_0 28, Q6_K 14
y F32 392 tensores. `feed_forward_length` (2112) y `expert_feed_forward_length` (704) no son múltiplos de
256, así que llama.cpp guarda los `ffn_down` (densos y expertos) en tipos de bloque 32 (Q5_0/Q8_0) en
lugar de K-quants.

El GGUF principal **no** lleva cabezal MTP: 30 bloques (`blk.0`–`blk.29`) y ninguna clave
`nextn_predict_layers`. El borrador es un archivo aparte, `mtp-gemma-4-26B-A4B-it.gguf` (arquitectura
`gemma4-assistant`, de Unsloth), que la tarjeta carga con `-md ... --spec-type draft-mtp`. Por la política
del catálogo y la petición del usuario no se descarga ni se declara en el manifiesto.

## Artefactos

| Archivo | Tamaño | SHA-256 |
| --- | ---: | --- |
| `Gemma4-26B-A4B-QAT-Uncensored-HauhauCS-Balanced-Q4_K_M.gguf` | 16.796.015.520 bytes | `3c13133469e431312fffb8b1d9c85ae42199e6bb5746ea1da84e8ddf2097d73c` |
| `mmproj-Gemma4-26B-A4B-QAT-Uncensored-HauhauCS-Balanced-BF16.gguf` | 1.194.827.776 bytes | `b5346e5bfd906f5e16878c2d0b8243e948ca7410fa28ea35be9b0c54a0ac10b7` |

SHA-256 LFS de la API de Hugging Face en la revisión fijada; la descarga se verificó por tamaño y SHA-256.

## Perfiles

| Lanzador | Contexto | Batch/UBatch | Visión | Alias de perfil |
| --- | ---: | ---: | :---: | --- |
| `start-agentic-auto-131k-1024.cmd` | 131.072 | 1024/1024 | no | `gemma-4-26b-a4b-uncensored-balanced-131k` |
| `start-agentic-auto-262k-1024.cmd` | 262.144 | 1024/1024 | no | `gemma-4-26b-a4b-uncensored-balanced-262k` |
| `start-agentic-auto-vision-131k-1024.cmd` | 131.072 | 1024/1024 | sí | `gemma-4-26b-a4b-uncensored-balanced-vision-131k` |
| `start-agentic-auto-vision-262k-1024.cmd` | 262.144 | 1024/1024 | sí | `gemma-4-26b-a4b-uncensored-balanced-vision-262k` |

Copian la base del catálogo (Occult Nail) salvo modelo, alias, proyector y muestreo: `b11981-cuda13.4`,
`--gpu-layers auto --fit on`, `--fit-target 1024` (texto) / `2048` (visión), 6 hilos, `--cache-ram 8192`,
caché KV `q8_0`, Flash Attention, `--parallel 1`, `--split-mode none`, Jinja, `--load-mode none`, logs
compactos y `--reasoning-budget 8192`. `MTP_ARGS` vacío. La visión no fija `--image-min-tokens`: la tarjeta
no lo pide y los perfiles Gemma 4 anteriores tampoco lo usaban. Batch/ubatch no son óptimos medidos.

Muestreo y razonamiento:

- `--temp 0.6 --top-p 0.9 --top-k 64 --min-p 0.05 --repeat-penalty 1.1`: los valores que la tarjeta
  recomienda para esta compilación (no los de Gemma 4 de serie, `1.0/0.95/64`).
- `--reasoning auto`. La plantilla embebida activa el razonamiento por defecto: `/apply-template`
  inserta `<|think|>` en el turno de sistema. Lee `enable_thinking`; no tiene niveles de esfuerzo.

## Validación (2026-11-02, `b11981`)

- `Test-ModelIntegrity.ps1` (2/2) y `Test-Llm.ps1 -ConfigurationOnly -RequireInstalledFiles` sin
  filtros (30/30) pasan; smoke en los cuatro perfiles.
- `/props` informa `n_ctx` 131.072 y 262.144; modalidades `vision` y `video` solo en los perfiles de
  visión. `/v1/models` publica el alias canónico y el de perfil.
- Calibración con un prompt de 56.147 tokens (sin razonamiento). VRAM total 16.303 MiB, con
  1,3–1,5 GB ocupados por otros procesos antes de arrancar:

| Perfil | Prefill | Generación (prompt corto) | Generación (56K) | VRAM tras carga | VRAM pico |
| --- | ---: | ---: | ---: | ---: | ---: |
| 131K | 2.141 tok/s | 66–72 tok/s | 58,1 tok/s | 15.438 MiB | 15.523 MiB |
| 262K | 2.609 tok/s | 63–65 tok/s | 48,6 tok/s | 15.457 MiB | 15.527 MiB |
| Visión 131K | 2.702 tok/s | 60–67 tok/s | 50,6 tok/s | 14.476 MiB | 15.180 MiB |
| Visión 262K | 2.338 tok/s | 52–54 tok/s | 43,3 tok/s | 14.234 MiB | 15.082 MiB |

  Una sola repetición por perfil: el prefill varía entre ejecuciones y no prueba que 131K sea más lento.
- Tool calling en los cuatro perfiles: `get_weather` con `{"location":"Madrid"}` y `finish_reason
  tool_calls`.
- Contrato de razonamiento: por defecto razona (164–429 palabras ante una pregunta trivial; en visión
  262K agotó los 600 tokens de la prueba sin responder). `enable_thinking: false` deja
  `reasoning_content` vacío y `thinking_budget_tokens: 64` lo corta en 33–38 palabras antes de responder.
- Visión: describe bien la imagen de prueba (tres franjas verticales roja, verde y azul).
- Recuperación en el prompt de 56K: la pregunta tenía respuesta «638 unidades, estación 12». Tres
  perfiles dieron el valor correcto, uno dio 708; dos acertaron la estación. Es una sola muestra con
  temperatura 0,6, no una medida de calidad.

Registros: `logs/validation/functional-gemma-4-26b-a4b-uncensored-balanced-*-20261102-*.json` y los
smoke `smoke-tests-2026110{1,2}-*.json`.

## Pendiente

- Contexto completo (262.144 tokens exactos), vídeo, calidad y sesiones reales en Pi, OpenCode y DSH no
  evaluados.
- Rendimiento con el borrador MTP no medido (no instalado).
