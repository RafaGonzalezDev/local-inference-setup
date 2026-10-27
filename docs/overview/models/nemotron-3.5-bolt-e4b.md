# NVIDIA Nemotron 3.5 Bolt E4B 4GB

- Modelo: `Nemotron-3.5-Bolt-E4B-Q4_K_M.gguf`
- Repositorio: `nvidia/NVIDIA-Nemotron-3.5-Bolt-E4B-4GB`
- Revisión: `1db54d5b12533ff1bcaa8e42cf4c667988a1f1be`
- Alias API: `nemotron-3.5-bolt-e4b`
- Arquitectura: Gemma 4 E4B (densa, 42 capas, 8B parámetros totales / 4B efectivos)

## Arquitectura

Post-entrenamiento de NVIDIA (GRPO) sobre `google/gemma-4-E4B-it`, orientado a
asistentes locales, tool calling multi-turno y seguimiento de instrucciones.
Según `config.json` del repositorio BF16 base
(`nvidia/NVIDIA-Nemotron-3.5-Bolt-E4B-BF16`, revisión
`49843eed8db1f1c616c47af75cfd36e07aec0667`), `max_position_embeddings` es
65.536 y la atención alterna capas de ventana deslizante (512) y globales. La
tarjeta declara entrada y salida solo de texto: aunque la arquitectura Gemma 4
incluye codificadores de visión y audio, la publicación no ofrece proyector y
no se instala ninguno.

## Artefacto

| Cuantización | Archivo | Tamaño | SHA-256 |
| --- | --- | ---: | --- |
| `Q4_K_M` | `Nemotron-3.5-Bolt-E4B-Q4_K_M.gguf` | 6.180.446.208 bytes | `c8af2b8aea10a690a1d9491db744a9446660173cb38fc489612b556615a69612` |

Es el único GGUF de la revisión fijada. El SHA-256 procede de los metadatos LFS
de la API de Hugging Face y coincide con el archivo instalado.

## Perfil

| Lanzador | Contexto | Batch/UBatch | Visión | MTP |
| --- | ---: | ---: | :---: | :---: |
| `start-agentic-auto-65k-1024.cmd` | 65.536 | 1.024/1.024 | no | no |

- Contexto: el máximo nativo (65.536); no se crean perfiles mayores.
- Base agentic habitual: `--gpu-layers auto --fit on --fit-target 1024`,
  Flash Attention, un slot, `--cache-ram 0`, `--split-mode none`, ocho hilos,
  KV `q8_0`, Jinja y `--load-mode none`.
- Batch/ubatch 1024/1024: valor heredado de los perfiles densos, no un óptimo
  medido.
- Muestreo: `temp 1` y `top-p 0.95` de la tarjeta; `top-k 64` del
  `generation_config.json` del repositorio BF16.
- Razonamiento: `--reasoning auto` con `--reasoning-budget 8192` (valor local
  heredado de los perfiles Gemma). La plantilla inserta `<|think|>` por
  defecto; `reasoning_effort: "none"` lo desactiva. La tarjeta documenta
  además `chat_template_kwargs` `enable_thinking` y `conversational_mode`.

## Validación (2026-10-25, runtime `b11551-cuda13.4`)

- Integridad: `Test-ModelIntegrity.ps1` pasa.
- `Test-Llm.ps1 -ConfigurationOnly -RequireInstalledFiles` pasa sin filtros.
- `/v1/models` expone `nemotron-3.5-bolt-e4b,nemotron-3.5-bolt-e4b-65k`;
  `/props` informa `n_ctx` 65.536.
- `/apply-template` abre el bloque de razonamiento; la salida separa
  `reasoning_content` y `content`. Con `reasoning_effort: "none"`,
  `reasoning_content` queda vacío.
- Tool calling: la petición `get_weather` de la tarjeta devuelve
  `finish_reason: tool_calls` con argumentos JSON válidos.
- Calibración bajo carga: GPU con 3.142 MiB ocupados por otros procesos antes
  de arrancar; 7.546 MiB tras la carga y pico de 7.705 MiB (de 16.303) durante
  un prefill de 52.005 tokens con generación de 137. La RAM libre bajó unos
  4,3 GB al cargar; parte del modelo reside en host según la colocación de
  `--fit` (no se desglosó por tensor). Medición puntual: prefill ~5.989
  tokens/s y generación ~71 tokens/s con ese contexto; ~119 tokens/s con
  prompt corto. No es un benchmark.
- Smoke `Test-Llm.ps1 -Model nemotron-3.5-bolt-e4b -Profile
  agentic-auto-65k-1024`: superado; puerto 8080 y GPU liberados.

## Limitaciones y pendientes

- El log advierte que los tokens `<|tool_response>` y `</s>` no son de tipo
  control en el GGUF; llama.cpp los corrige al cargar. Tool calling básico
  funciona, pero no se probaron conversaciones multi-turno con respuestas de
  herramienta.
- No se instaló el borrador DFlash
  (`nvidia/NVIDIA-Nemotron-3.5-Bolt-E4B-4GB-DFlash`). El runtime `b11551`
  anuncia `--spec-type draft-dflash`, pero no se ha verificado ni medido.
- No se evaluó calidad ni el contexto completo de 65.536 tokens.

## Dependencias

- `config/models/nemotron-3.5-bolt-e4b.psd1`
- `scripts/models/nemotron-3.5-bolt-e4b/start-agentic-auto-65k-1024.cmd`
- `runtimes/llama.cpp/b11669-cuda13.4/`

## Source

- [Hugging Face model repository](https://huggingface.co/nvidia/NVIDIA-Nemotron-3.5-Bolt-E4B-4GB)
- License: OpenMDW-1.1 (modelo base Gemma 4 bajo Apache 2.0)
