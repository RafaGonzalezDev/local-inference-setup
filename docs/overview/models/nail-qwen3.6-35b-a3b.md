# Nail Qwen3.6 35B A3B

- Publicador: `peculiar-ragdoll` (Hugging Face), que también publica Occult Nail, Tiel Coder y Cyber Tiel
- Modelo: `Nail-Qwen3.6-35B-A3B-UD-Q4_K_XL.gguf`
- Proyector: `mmproj-F16.gguf`
- Repositorio: `peculiar-ragdoll/Nail-Qwen3.6-35B-A3B-GGUF`, revisión
  `ac66b0fad4bc2b68d29eff967c06d55de09429c1`
- Licencia: `apache-2.0`, heredada de `Qwen/Qwen3.6-35B-A3B`.
- Alias API: `nail-qwen3.6-35b-a3b`
- Arquitectura: la de `qwen3.6-35b-a3b` (`qwen35moe`, contexto nativo 262.144), sin cabezal MTP.
  Según la tarjeta, son las cuantizaciones Unsloth Dynamic de Qwen3.6-35B-A3B con la plantilla de
  chat de froggeric modificada y un mensaje de sistema de concisión añadido siempre tras el del
  cliente. Los pesos no son un ajuste fino.

El mensaje de sistema vive en la plantilla embebida y no se puede desactivar desde la API. La
plantilla abre `<think>` por defecto y admite `enable_thinking: false` por petición.

El 2026-10-28 el modelo pasó de `UD-Q4_K_S` a `UD-Q4_K_XL` y se retiraron los perfiles MTP con su GGUF
(`Nail-Qwen3.6-35B-A3B-GGUF-MTP`), a petición del usuario
([changelog](../../changelog/2026-10-28-q4-k-xl-without-mtp.md)).

## Artefactos

| Artefacto | Archivo | Tamaño | SHA-256 |
| --- | --- | ---: | --- |
| `UD-Q4_K_XL` | `Nail-Qwen3.6-35B-A3B-UD-Q4_K_XL.gguf` | 22.360.465.312 bytes | `a9db25750e5b253922a6f780b5e6e7852013d2f85fad589270fbc8c314d2c9b1` |
| Proyector F16 | `mmproj-F16.gguf` | 899.283.680 bytes | `8971ee4f331ff0a4c609374f32984b3d4e6dc086c0aa35f1d637fad1829e887f` |

SHA-256 LFS de la API de Hugging Face en la revisión fijada; ambos verificados tras la descarga. El
proyector es byte a byte el de `unsloth/Qwen3.6-35B-A3B-GGUF` y el de Occult Nail. La cuantización la
eligió el usuario, la misma que Occult Nail.

## Perfiles

| Lanzador | Contexto | Batch/UBatch | Visión | Alias de perfil |
| --- | ---: | ---: | :---: | --- |
| `start-agentic-auto-131k-1024.cmd` | 131.072 | 1024/1024 | no | `nail-qwen3.6-35b-a3b-131k` |
| `start-agentic-auto-262k-1024.cmd` | 262.144 | 1024/1024 | no | `nail-qwen3.6-35b-a3b-262k` |
| `start-agentic-auto-vision-131k-1024.cmd` | 131.072 | 1024/1024 | sí | `nail-qwen3.6-35b-a3b-vision-131k` |
| `start-agentic-auto-vision-262k-1024.cmd` | 262.144 | 1024/1024 | sí | `nail-qwen3.6-35b-a3b-vision-262k` |

Copias de los lanzadores de `qwen3.6-35b-a3b` (retirado el 2026-10-28) sobre `b11551-cuda13.4` (`b11981-cuda13.4` desde el 2026-10-30): batch
1024/1024, 6 hilos, `--fit-target 1024` (2048 en visión), caché KV `q8_0`, `--reasoning auto`,
`--reasoning-budget 8192` e `--image-min-tokens 2048`.

- Único cambio respecto a Qwen3.6: el muestreo que recomienda la tarjeta, `--temp 1.0 --top-p 0.95
  --top-k 20 --min-p 0` sin penalizaciones (`--presence-penalty 0 --repeat-penalty 1`). Qwen3.6
  usa `--temp 0.6`.
- La tarjeta no fija presupuesto de razonamiento, contexto de perfil ni tokens de imagen: se heredan
  de Qwen3.6.

## Validación medida (2026-10-28, `UD-Q4_K_XL`)

Una ejecución por perfil, en serie, con el mismo script para todo el catálogo. `/props` confirma el
contexto, `/v1/models` publica el alias canónico y el de perfil con `ftype Q4_K - Medium`, e
`input_modalities` es `text` o `text,image,video` en visión. La plantilla termina en
`<|im_start|>assistant\n<think>\n`.

| Perfil | Prompt largo | Prefill | Decode largo | Decode corto (1.024) | VRAM pico | RAM libre mínima |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 131K | 99.143 | 1.955,06 t/s (50,7 s) | 58,81 t/s | 75,85 t/s | 15.332 MiB | 40.410 MiB |
| 262K | 229.884 | 1.469,50 t/s (156,4 s) | 39,46 t/s | 68,84 t/s | 15.404 MiB | 38.001 MiB |
| Visión 131K | 99.143 | 1.733,68 t/s (57,2 s) | 51,66 t/s | 67,51 t/s | 14.544 MiB | 38.274 MiB |
| Visión 262K | 229.884 | 1.335,59 t/s (172,1 s) | 36,98 t/s | 60,96 t/s | 14.551 MiB | 36.152 MiB |

- `nvidia-smi` y RAM libre muestreados cada ~0,8 s; el escritorio ocupaba 1,1–1,2 GB de la tarjeta
  antes de cada arranque. Decode largo: hasta 128 tokens tras el prompt largo. Decode corto: prompt
  breve. Ambos con `enable_thinking: false`, `temperature 0` y sin caché de prompt.
- Tool calling en los cuatro perfiles: `get_weather` con `arguments {"location":"Madrid"}` y
  razonamiento separado.
- Visión: `tests/assets/panels-1080p.png` (2.275 tokens) se describe correctamente como tres franjas
  verticales roja, verde y azul; en 262K añade que es la bandera de Mali, que no lo es.
- El prefill no es comparable con la calibración del 2026-10-26 (`UD-Q4_K_S`, 2.302 t/s a 131K): aquel
  script no se conservó, el prompt era otro y el decode largo generaba hasta 512 tokens en vez de 128.
- Registros: `logs/validation/calibration-nail-qwen3.6-35b-a3b-*`.

## Límites y no verificado

- No se ejercitó el contexto completo: los prompts más largos fueron 99.143 (131K) y 229.884 (262K)
  tokens. El prompt largo con imagen no se probó.
- No se volvió a comprobar `reasoning_effort: "none"` ni `thinking_budget_tokens` con este GGUF; la
  plantilla es la misma que en `UD-Q4_K_S`.
- No se midió calidad frente a `UD-Q4_K_S`.
- Los perfiles escuchan en `0.0.0.0:8080` sin autenticación: solo red privada de confianza y un
  perfil a la vez.

## Dependencias

- `config/models/nail-qwen3.6-35b-a3b.psd1`
- `scripts/models/nail-qwen3.6-35b-a3b/*.cmd`
- `runtimes/llama.cpp/b11981-cuda13.4/`

## Related ADRs

- [ADR-0001: lanzadores autocontenidos](../../adr/ADR-0001-self-contained-model-launchers.md)
