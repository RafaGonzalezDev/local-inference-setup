# Nemotron 3.5 Lightning 30B A3B

- Publicador: `AtomicChat` (Hugging Face), cuantización GGUF del modelo de NVIDIA
- Modelo: `NVIDIA-Nemotron-3.5-Lightning-30B-A3B-AD-IQ4_NL.gguf`
- Repositorio: `AtomicChat/NVIDIA-Nemotron-3.5-Lightning-30B-A3B-GGUF`, revisión
  `14571e1092ca67401685a3a4f7de455845a384f3`
- Modelo base: `nvidia/NVIDIA-Nemotron-3.5-Lightning-30B-A3B-BF16`
- Licencia: OpenMDW-1.1, la de NVIDIA, que también declara el GGUF. La tarjeta de AtomicChat indica
  `nvidia-open-model-license` en sus metadatos; prevalece la del modelo base.
- Alias API: `nemotron-3.5-lightning-30b-a3b`
- Arquitectura GGUF: `nemotron_h_moe`, híbrido Mamba-2 + MoE + atención: 52 capas (23 Mamba-2, 23 MoE y
  6 de atención con 2 cabezas KV), 128 expertos con 6 activos más uno compartido, ~3B parámetros activos.
  Contexto nativo 1.048.576 según el GGUF y la tarjeta (`max_position_embeddings` 262.144 en `config.json`).
  Solo texto.

El modelo estuvo en el catálogo con el NVFP4 de `ggml-org` (2026-08-11) y se retiró el 2026-10-26 a
elección del usuario. Se reintegra con otra cuantización
([changelog](../../changelog/2026-10-29-nemotron-3.5-lightning-30b-a3b.md)).

## Artefacto

| Artefacto | Archivo | Tamaño | SHA-256 |
| --- | --- | ---: | --- |
| `AD-IQ4_NL` | `NVIDIA-Nemotron-3.5-Lightning-30B-A3B-AD-IQ4_NL.gguf` | 19.649.755.008 bytes | `b09afe4f1a1688edea3988e443e2173f4d0992a00f6552ff7ab04cad7da1e121` |

SHA-256 LFS de la API de Hugging Face en la revisión fijada, verificado tras la descarga.

Reparto leído de la cabecera: expertos (`ffn_up_exps`, `ffn_down_exps`) en `IQ4_NL` con imatrix; atención,
Mamba (`ssm_in`, `ssm_out`), experto compartido, embeddings y salida en `Q8_0`. La capa MTP (`blk.52`) va en
`Q4_0` y se ignora al cargar sin `--spec-type`; no existe versión de esta publicación sin ella. La plantilla de
chat es idéntica a la oficial (la misma que en `ggml-org`).

## Elección de la cuantización

`hidden_size` 2688 y `moe_intermediate_size` 1856 no son múltiplos de 256, así que llama.cpp sustituye en los
expertos (el ~93 % del peso) las K-quants e IQ-quants de superbloque 256 por tipos de bloque 32. Los nombres
publicados engañan: `UD-Q4_K_XL` (unsloth) y `Q4_K_M` (bartowski) son en realidad expertos `Q5_0`/`Q5_1`/`Q8_0`
de 25,5 GB, y los `IQ2`/`IQ3` son `IQ4_NL` de unos 19 GB. La convención `UD-Q4_K_XL` de los otros MoE no se
traslada a este modelo.

Divergencia KL frente a `Q8_0` publicada por AtomicChat (texto neutro, con sus registros); no es una medición
propia:

| Archivo | Tamaño | KLD media | Top-1 |
| --- | ---: | ---: | ---: |
| `AD-IQ4_NL` (instalado) | 19,65 GB | 0,0173 | 93,5 % |
| `AD-IQ4_NL_L` | 22,40 GB | 0,0134 | 94,2 % |
| `Q5_K_M` (real `Q5_1`/`Q5_0`) | 26,59 GB | 0,0178 | 93,2 % |
| `Q4_K_M` (real `Q8_0`/`Q5_0`) | 25,02 GB | 0,0254 | 91,9 % |
| NVFP4 de `ggml-org` (el instalado antes) | 22,46 GB | 0,0623 | 86,8 % |

El NVFP4 anterior era un repack del checkpoint NVFP4 de NVIDIA con atención y Mamba en BF16. NVIDIA publica para
su NVFP4 resultados casi a la par con BF16, con caídas en HLE, SWE-bench Multilingual y AA-LCR. `ggml-org`
retiró ese archivo de su repositorio el 2026-08-14. Alternativas no elegidas: `AD-IQ4_NL_L` (menos divergencia,
~2,75 GB más de expertos en CPU) y el NVFP4 de `tngtech` (18,5 GB, más rápido en prefill según AtomicChat, KLD
no publicada).

## Perfiles

| Lanzador | Contexto | Batch/UBatch | Alias de perfil |
| --- | ---: | ---: | --- |
| `start-agentic-auto-131k-1024.cmd` | 131.072 | 1024/1024 | `nemotron-3.5-lightning-30b-a3b-131k` |
| `start-agentic-auto-262k-1024.cmd` | 262.144 | 1024/1024 | `nemotron-3.5-lightning-30b-a3b-262k` |

Copias de los lanzadores de Nail sobre `b11551-cuda13.4`: `--fit-target 1024`, 6 hilos, `--cache-ram 8192`,
caché KV `q8_0`, `--reasoning auto`, `--reasoning-budget 8192` y logs compactos. Sin MTP, por la política
actual; con el NVFP4 ya se midió más lento.

- Muestreo de NVIDIA: `--temp 1.0 --top-p 0.95`. `--top-k 0 --min-p 0` es una decisión propia, que reproduce
  los valores por defecto de vLLM, la referencia de la tarjeta. Sin penalizaciones.
- La caché KV es pequeña: solo 6 capas de atención con 2 cabezas KV. 262K cabe con el mismo margen que 131K.

## Validación medida (2026-10-29)

Script de calibración del 2026-10-28, una ejecución por perfil, en serie. `/props` confirma el contexto,
`/v1/models` publica ambos alias con `ftype IQ4_NL - 4.5 bpw` e `input_modalities` `text`. La plantilla termina
en `<|im_start|>assistant\n<think>\n`.

| Perfil | Prompt largo | Prefill | Decode largo | Decode corto (1.024) | VRAM pico | RAM libre mínima |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 131K | 98.727 | 2.737,36 t/s (36,1 s) | 70,30 t/s | 91,58 t/s | 15.457 MiB | 42.189 MiB |
| 262K | 228.928 | 2.299,16 t/s (99,6 s) | 56,76 t/s | 87,22 t/s | 15.476 MiB | 41.439 MiB |

- El escritorio ocupaba 1,4–1,7 GB de la tarjeta antes de cada arranque. En el pico quedan unos 830-850 MiB
  libres, por debajo del objetivo de `--fit` (1.024 MiB) y del mismo orden que el resto del catálogo.
- Tool calling en ambos perfiles: `get_weather` con `arguments {"location":"Madrid"}` y razonamiento separado.
- Contrato de razonamiento (131K): por defecto razona en `reasoning_content`; `chat_template_kwargs.enable_thinking:
  false` y `reasoning_effort: "none"` lo desactivan (4 tokens de salida); `thinking_budget_tokens: 64` lo corta y
  responde bien.
- Caché de prompts en RAM (131K): conversación A en frío, 28.224 tokens (9,42 s); una B distinta ocupa el slot; al
  volver a A con un mensaje más se procesan 19 tokens y se recuperan 28.239 de la caché (0,12 s).
- `Test-Llm.ps1` de ambos perfiles pasa.
- Registros: `logs/validation/calibration-nemotron-3.5-lightning-30b-a3b-*`,
  `reasoning-contract-nemotron-3.5-lightning-30b-a3b-131k-20261029.json` y
  `ram-prompt-cache-nemotron-3.5-lightning-30b-a3b-131k-20261029.json`.

## Límites y no verificado

- No se ejercitó el contexto completo: los prompts más largos fueron 98.727 (131K) y 228.928 (262K) tokens.
- No se midió calidad propia; las cifras de divergencia son de AtomicChat.
- No se midió el rendimiento a través de Pi ni con la caché en RAM llena.
- Los perfiles escuchan en `0.0.0.0:8080` sin autenticación: solo red privada de confianza y un perfil a la vez.

## Dependencias

- `config/models/nemotron-3.5-lightning-30b-a3b.psd1`
- `scripts/models/nemotron-3.5-lightning-30b-a3b/*.cmd`
- `runtimes/llama.cpp/b11551-cuda13.4/`

## Related ADRs

- [ADR-0001: lanzadores autocontenidos](../../adr/ADR-0001-self-contained-model-launchers.md)
