# Cyber Tiel Coder 35B A3B

- Publicador: `peculiar-ragdoll` (Hugging Face), que también publica Tiel Coder, Nail y Occult Nail
- Modelo: `Cyber-Tiel-Coder-35B-A3B-UD-Q4_K_XL.gguf`
- Proyector: `mmproj-BF16.gguf`
- Repositorio: `peculiar-ragdoll/Cyber-Tiel-Coder-35B-A3B-GGUF`
- Revisión: `e59f05c5bda27883c2846bd6163acba3f5e00a8e`
- Licencia: `mit`, según la tarjeta (el modelo base es `huihui-ai/Huihui-Ornith-1.5-35B-A3B-abliterated`).
- Alias API: `cyber-tiel-coder-35b-a3b`
- Arquitectura GGUF: `qwen35moe` (la misma que Tiel Coder), contexto nativo 262.144, sin cabezal MTP

CyberTiel es la variante abliterada de Tiel Coder, afinada para código y ciberseguridad: la tarjeta
la presenta con una imatrix ponderada hacia código y seguridad y la plantilla Sharp de Tiel. Según la
publicación no rechaza peticiones en HarmBench (0 rechazos de 84), resuelve 13,7 de 25 problemas de
SWE-bench-Live (media de tres ejecuciones) y sacrifica conocimiento general a cambio de código; todo
eso son afirmaciones del autor, no mediciones propias. La tarjeta insiste en usarlo con aislamiento a
nivel de sistema operativo (ejecución de código y acceso a internet controlados) y recomienda Tiel
Coder si no es posible.

El 2026-10-28 este modelo pasó del ID `cyber-tiel-coder-35b-a3b-mtp` (`UD-Q4_K_S` con cabezal MTP) a
este ID con `UD-Q4_K_XL` sin cabezal, a petición del usuario, y se retiraron sus perfiles MTP
([changelog](../../changelog/2026-10-28-q4-k-xl-without-mtp.md)). Los alias de perfil no cambiaron.

## Artefactos

| Cuantización | Archivo | Tamaño | SHA-256 |
| --- | --- | ---: | --- |
| `UD-Q4_K_XL` | `Cyber-Tiel-Coder-35B-A3B-UD-Q4_K_XL.gguf` | 22.360.478.720 bytes | `21bff5a96fa051809f4a8260befe977771c9927cae9c32eadfcb0718bae960cd` |
| `BF16` (mmproj) | `mmproj-BF16.gguf` | 902.822.016 bytes | `d9ce31026d1cb1f3f8d5152e2e2a014d9d2b302b6c93a7dc07bb0a0487f52837` |

SHA-256 LFS de la API de Hugging Face en la revisión fijada; ambos verificados en disco. La tarjeta
llama a `UD-Q4_K_XL` «the best 4-bit tier» (sus benchmarks usan `UD-Q4_K_M`, que considera casi
idéntico). El proyector es el de Ornith sin cambios, byte a byte el mismo que el de Tiel Coder.

## Perfiles

| Lanzador | Contexto | Batch/UBatch | Visión | Alias de perfil |
| --- | ---: | ---: | :---: | --- |
| `start-agentic-auto-131k-1024.cmd` | 131.072 | 1.024/1.024 | no | `cyber-tiel-coder-35b-a3b-131k` |
| `start-agentic-auto-262k-1024.cmd` | 262.144 | 1.024/1.024 | no | `cyber-tiel-coder-35b-a3b-262k` |
| `start-agentic-auto-vision-131k-1024.cmd` | 131.072 | 1.024/1.024 | sí | `cyber-tiel-coder-35b-a3b-vision-131k` |
| `start-agentic-auto-vision-262k-1024.cmd` | 262.144 | 1.024/1.024 | sí | `cyber-tiel-coder-35b-a3b-vision-262k` |

Son los de Tiel Coder cambiando solo el modelo, el proyector y los alias: `b11981-cuda13.4` (desde el 2026-10-30; calibrados con `b11551`), 6 hilos,
`--fit-target 1024` (2048 en visión), caché KV `q8_0`, `--reasoning auto`, presupuesto 8.192 y
batch/ubatch 1.024/1.024.

- Muestreo `--temp 0.6 --top-p 0.95 --top-k 20 --min-p 0`, sin penalizaciones: es el de coding agentic
  de la tarjeta. Para ciberseguridad/CTF la tarjeta propone `--top-k 40 --min-p 0.05`, probado por el
  autor en Q4; no se ha aplicado.
- Presupuesto de razonamiento: la tarjeta dice que el modelo rinde mejor sin límite
  (`--reasoning-budget -1 --predict -1`) y que, si se limita, usa 16.384 con `--predict 32768`. Los
  lanzadores heredan los 8.192 de Tiel; se puede cambiar editando `RUNTIME_ARGS`.
- Visión: `--mmproj mmproj-BF16.gguf --image-min-tokens 1024`, como en Tiel.
- La tarjeta propone `--n-cpu-moe` para descargar expertos; los lanzadores no lo usan y dejan que
  `--fit` coloque los expertos.

## Validación medida (2026-10-28, `UD-Q4_K_XL`)

Una ejecución por perfil, en serie, con el mismo script para todo el catálogo. `/props` confirma el
contexto, `/v1/models` publica el alias canónico y el de perfil con `ftype Q4_K - Medium`, e
`input_modalities` es `text` o `text,image,video` en visión. La plantilla termina en
`<|im_start|>assistant\n<think>\n`.

| Perfil | Prompt largo | Prefill | Decode largo | Decode corto (1.024) | VRAM pico | RAM libre mínima |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 131K | 99.140 | 1.978,04 t/s (50,1 s) | 61,54 t/s | 82,44 t/s | 15.263 MiB | 40.503 MiB |
| 262K | 229.881 | 1.503,47 t/s (152,9 s) | 43,63 t/s | 73,19 t/s | 15.271 MiB | 38.318 MiB |
| Visión 131K | 99.140 | 1.736,94 t/s (57,1 s) | 55,37 t/s | 69,84 t/s | 14.549 MiB | 37.696 MiB |
| Visión 262K | 229.881 | 1.359,71 t/s (169,1 s) | 39,13 t/s | 65,21 t/s | 14.747 MiB | 35.554 MiB |

- `nvidia-smi` y RAM libre muestreados cada ~0,8 s; el escritorio ocupaba ~1,1 GB de la tarjeta antes
  de cada arranque. Decode largo: hasta 128 tokens tras el prompt largo. Decode corto: prompt breve.
  Ambos con `enable_thinking: false`, `temperature 0` y sin caché de prompt.
- Tool calling en los cuatro perfiles: `get_weather` con `arguments {"location":"Madrid"}` y
  razonamiento separado.
- Visión: `tests/assets/panels-1080p.png` (2.238 tokens) se describe como bandera tricolor vertical
  roja, verde y azul.
- Primera calibración de este modelo: el GGUF MTP anterior nunca se probó.
- Registros: `logs/validation/calibration-cyber-tiel-coder-35b-a3b-*`.

## Límites y no verificado

- No se ejercitó el contexto completo (prompts de hasta 99.140 y 229.881 tokens) ni un prompt largo
  con imagen.
- No se comprobó `reasoning_effort: "none"` ni `thinking_budget_tokens`; se supone el contrato de Tiel
  Coder porque usa la misma plantilla.
- No se midió calidad ni la ausencia de rechazos.
- Los perfiles escuchan en `0.0.0.0:8080` sin autenticación: solo red privada de confianza y un
  perfil a la vez.

## Dependencias

- `config/models/cyber-tiel-coder-35b-a3b.psd1`
- `scripts/models/cyber-tiel-coder-35b-a3b/*.cmd`
- `runtimes/llama.cpp/b11981-cuda13.4/`

## Related ADRs

- [ADR-0001: lanzadores autocontenidos](../../adr/ADR-0001-self-contained-model-launchers.md)
