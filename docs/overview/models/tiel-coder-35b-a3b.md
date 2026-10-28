# Tiel Coder 35B A3B

- Publicador: `peculiar-ragdoll` (Hugging Face), que también publica Cyber Tiel, Nail y Occult Nail
- Modelo: `Tiel-Coder-35B-A3B-UD-Q4_K_XL.gguf`
- Proyector: `mmproj-BF16.gguf`
- Repositorio: `peculiar-ragdoll/Tiel-Coder-35B-A3B-GGUF`
- Revisión: `dd9b8f8be29bd939afe0fb5c712f09ed1ff87bb6`
- Licencia: `mit`, heredada del modelo base.
- Alias API: `tiel-coder-35b-a3b`
- Arquitectura GGUF: `qwen35moe` (MoE de 256 expertos con 8 activos por token, familia Ornith 1.5
  35B A3B), contexto nativo 262.144, sin cabezal MTP

Tiel Coder es una recuantización dinámica de `ornith-ai/Ornith-1.5-35B-A3B` hecha por
`peculiar-ragdoll` (imatrix propia, receta estilo Unsloth Dynamic), con la plantilla de chat Sharp
incorporada en el GGUF.

El 2026-10-28 este modelo pasó del ID `tiel-coder-35b-a3b-mtp` (`UD-IQ4_XS` con cabezal MTP) a este ID
con `UD-Q4_K_XL` sin cabezal, a petición del usuario, y se retiraron sus perfiles MTP
([changelog](../../changelog/2026-10-28-q4-k-xl-without-mtp.md)). Los alias de perfil no cambiaron.

## Artefactos

| Cuantización | Archivo | Tamaño | SHA-256 |
| --- | --- | ---: | --- |
| `UD-Q4_K_XL` | `Tiel-Coder-35B-A3B-UD-Q4_K_XL.gguf` | 22.360.478.080 bytes | `9779b32f998371c66ae5e1aa9a0bc7ad946b1a36c61ea6a8eb39d523b4b19033` |
| `BF16` (mmproj) | `mmproj-BF16.gguf` | 902.822.016 bytes | `d9ce31026d1cb1f3f8d5152e2e2a014d9d2b302b6c93a7dc07bb0a0487f52837` |

SHA-256 LFS de la API de Hugging Face en la revisión fijada; ambos verificados en disco. La tarjeta
presenta `UD-Q4_K_XL` (22,4 GB) como el nivel recomendado y el usado en sus benchmarks. El proyector
es el de Ornith, sin cambios, compartido por todas las cuantizaciones y byte a byte el mismo que el de
Cyber Tiel.

## Perfiles

| Lanzador | Contexto | Batch/UBatch | Visión | Alias de perfil |
| --- | ---: | ---: | :---: | --- |
| `start-agentic-auto-131k-1024.cmd` | 131.072 | 1.024/1.024 | no | `tiel-coder-35b-a3b-131k` |
| `start-agentic-auto-262k-1024.cmd` | 262.144 | 1.024/1.024 | no | `tiel-coder-35b-a3b-262k` |
| `start-agentic-auto-vision-131k-1024.cmd` | 131.072 | 1.024/1.024 | sí | `tiel-coder-35b-a3b-vision-131k` |
| `start-agentic-auto-vision-262k-1024.cmd` | 262.144 | 1.024/1.024 | sí | `tiel-coder-35b-a3b-vision-262k` |

Los lanzadores son los sin MTP del ID anterior, cambiando solo el GGUF, el proyector y el alias
canónico: `b11551`, 6 hilos, `--fit-target 1024` (2048 en visión), caché KV `q8_0`, `--reasoning
auto` y presupuesto 8.192.

- Muestreo `temp 0.6 --top-p 0.95 --top-k 20 --min-p 0`, sin penalizaciones: la tarjeta recomienda
  `1.0/0.95/20` para uso general y `0.6` para coding agentic.
- Visión: `--mmproj mmproj-BF16.gguf --image-min-tokens 1024`, el mínimo que la tarjeta de Ornith
  exige.
- La plantilla lee `reasoning_effort` y además acepta `enable_thinking: false`.

## Validación medida (2026-10-28, `UD-Q4_K_XL`)

Una ejecución por perfil, en serie, con el mismo script para todo el catálogo. `/props` confirma el
contexto, `/v1/models` publica el alias canónico y el de perfil con `ftype Q4_K - Medium`, e
`input_modalities` es `text` o `text,image,video` en visión. La plantilla termina en
`<|im_start|>assistant\n<think>\n`.

| Perfil | Prompt largo | Prefill | Decode largo | Decode corto (1.024) | VRAM pico | RAM libre mínima |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 131K | 99.139 | 1.900,35 t/s (52,2 s) | 56,29 t/s | 76,27 t/s | 15.356 MiB | 40.202 MiB |
| 262K | 229.880 | 1.460,09 t/s (157,4 s) | 44,22 t/s | 74,18 t/s | 15.268 MiB | 38.299 MiB |
| Visión 131K | 99.139 | 1.736,41 t/s (57,1 s) | 55,09 t/s | 71,78 t/s | 14.535 MiB | 38.255 MiB |
| Visión 262K | 229.880 | 1.358,76 t/s (169,2 s) | 40,78 t/s | 65,73 t/s | 14.552 MiB | 36.155 MiB |

- `nvidia-smi` y RAM libre muestreados cada ~0,8 s; el escritorio ocupaba 1,0–1,2 GB de la tarjeta
  antes de cada arranque. Decode largo: hasta 128 tokens tras el prompt largo. Decode corto: prompt
  breve. Ambos con `enable_thinking: false`, `temperature 0` y sin caché de prompt.
- Tool calling en los cuatro perfiles: `get_weather` con `arguments {"location":"Madrid"}` y
  razonamiento separado.
- Visión: `tests/assets/panels-1080p.png` (2.237 tokens) se describe como bandera tricolor vertical
  roja, verde y azul.
- El prefill no es comparable con la calibración del 2026-10-26 (`IQ4_XS` con MTP, 2.238 t/s a 131K):
  aquel script no se conservó y el prompt era otro. En la misma serie, Occult Nail 131K dio 1.957 t/s
  con 6 hilos y 1.957 t/s con 8.
- Registros: `logs/validation/calibration-tiel-coder-35b-a3b-*`.

## Límites y no verificado

- No se ejercitó el contexto completo (prompts de hasta 99.139 y 229.880 tokens) ni un prompt largo
  con imagen.
- No se volvió a comprobar `reasoning_effort: "none"` ni `thinking_budget_tokens` con este GGUF; la
  plantilla es la misma Sharp de la publicación MTP.
- No se midió calidad frente a `IQ4_XS`.
- Los perfiles escuchan en `0.0.0.0:8080` sin autenticación: solo red privada de confianza y un
  perfil a la vez.

## Dependencias

- `config/models/tiel-coder-35b-a3b.psd1`
- `scripts/models/tiel-coder-35b-a3b/*.cmd`
- `runtimes/llama.cpp/b11551-cuda13.4/`

## Related ADRs

- [ADR-0001: lanzadores autocontenidos](../../adr/ADR-0001-self-contained-model-launchers.md)
