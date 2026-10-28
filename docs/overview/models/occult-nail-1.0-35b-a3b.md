# Occult Nail 1.0 35B A3B

- Publicador: `peculiar-ragdoll` (Hugging Face), que también publica Nail y Tiel Coder
- Modelo: `Occult-Nail-1.0-35B-A3B-UD-Q4_K_XL.gguf`
- Proyector: `mmproj-F16.gguf`
- Repositorio: `peculiar-ragdoll/Occult-Nail-1.0-35B-A3B-GGUF`, revisión
  `3fdd9b72fc54083a6c8959b259011366a0b1571b`
- Licencia: `apache-2.0`, heredada de `Qwen/Qwen3.6-35B-A3B`.
- Alias API: `occult-nail-1.0-35b-a3b`
- Arquitectura: `qwen35moe`, la de `qwen3.6-35b-a3b`. Sin cabezal MTP.

Según la tarjeta, es `llmfan46/Qwen3.6-35B-A3B-uncensored-heretic` (Qwen3.6-35B-A3B con las
direcciones de rechazo eliminadas por abliteración Heretic, sin entrenamiento) con la plantilla y el
mensaje de sistema de concisión de [Nail](nail-qwen3.6-35b-a3b.md). La cuantización la hizo
`peculiar-ragdoll` reproduciendo la receta Unsloth Dynamic, con imatrix de mradermacher. La tarjeta
advierte que el modelo no rechaza peticiones dañinas y que pierde algo de capacidad frente a Nail.

## Artefactos

| Artefacto | Archivo | Tamaño | SHA-256 |
| --- | --- | ---: | --- |
| `UD-Q4_K_XL` | `Occult-Nail-1.0-35B-A3B-UD-Q4_K_XL.gguf` | 22.360.465.312 bytes | `1fa938085d7c5472767e75c987a595b7bf439258f63f3fdd55ca3bc7a3eaf733` |
| Proyector F16 | `mmproj-F16.gguf` | 899.283.680 bytes | `8971ee4f331ff0a4c609374f32984b3d4e6dc086c0aa35f1d637fad1829e887f` |

SHA-256 LFS de la API de Hugging Face en la revisión fijada; ambos verificados tras la descarga. La
cuantización la eligió el usuario. El proyector es byte a byte el de `unsloth/Qwen3.6-35B-A3B-GGUF`.
`/v1/models` informa `ftype Q4_K - Medium`, el tipo base de la receta dinámica.

## Perfiles

| Lanzador | Contexto | Batch/UBatch | Visión | Alias de perfil |
| --- | ---: | ---: | :---: | --- |
| `start-agentic-auto-131k-1024.cmd` | 131.072 | 1024/1024 | no | `occult-nail-1.0-35b-a3b-131k` |
| `start-agentic-auto-262k-1024.cmd` | 262.144 | 1024/1024 | no | `occult-nail-1.0-35b-a3b-262k` |
| `start-agentic-auto-vision-131k-1024.cmd` | 131.072 | 1024/1024 | sí | `occult-nail-1.0-35b-a3b-vision-131k` |
| `start-agentic-auto-vision-262k-1024.cmd` | 262.144 | 1024/1024 | sí | `occult-nail-1.0-35b-a3b-vision-262k` |

Son copias de los tres perfiles sin MTP de `qwen3.6-35b-a3b` (retirado el 2026-10-28), con batch/ubatch `1024/1024` en los
tres perfiles (el 131K y el de visión bajaron de `2048/2048` el 2026-10-27 para igualar a Nail):
`b11551`, `--fit-target 1024` (2048 en visión), caché KV `q8_0`, `--reasoning auto`, presupuesto
8.192, `--image-min-tokens 2048` y muestreo `--temp 0.6 --top-p 0.95 --top-k 20 --min-p 0` sin
penalizaciones. La tarjeta no recomienda muestreo, así que se hereda el de Qwen3.6; Nail, con la
misma plantilla, recomienda `temp 1.0`.

El perfil `vision-262k` se añadió el 2026-10-28 copiando el de visión 131K con contexto 262K; no se
ha probado. No hay perfiles MTP: la publicación `peculiar-ragdoll/Occult-Nail-1.0-35B-A3B-GGUF` no
trae cabezal MTP y no existe una publicación `-MTP` de este modelo (comprobado el 2026-10-28).

## Validación medida (2026-10-26, batch/ubatch 2048)

Una ejecución por perfil, sin cambiar parámetros. `/props` confirma el contexto y `/v1/models`
publica el alias canónico y el de perfil. La plantilla termina en `<|im_start|>assistant\n<think>\n`.

| Perfil | Prompt largo | Prefill | Decode largo | Decode corto (1.024 tokens) | VRAM pico | RAM libre mínima |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 131K | 99.547 | 2.579,28 t/s (38,6 s) | 53,94 t/s | 70,44 t/s | 15.740 MiB | 36.712 MiB |
| 262K | 229.936 | 1.438,91 t/s (159,8 s) | 40,50 t/s | 65,48 t/s | 15.778 MiB | 33.122 MiB |
| Visión 131K | 99.547 | 2.586,67 t/s (38,5 s) | 51,54 t/s | 63,73 t/s | 15.595 MiB | 34.583 MiB |

- Mismo método que en Nail: muestreo de `nvidia-smi` y RAM cada ~0,8 s, con 1,5–1,9 GB de escritorio
  en la tarjeta antes de arrancar.
- Tool calling en los tres perfiles: `get_weather` con `arguments {"location":"Madrid"}` y razonamiento
  en `reasoning_content`.
- Contrato de razonamiento (131K): `enable_thinking: false` y `reasoning_effort: "none"` dejan
  `reasoning_content` vacío; `thinking_budget_tokens: 64` lo corta en ~39 palabras.
- Visión: `tests/assets/panels-1080p.png` (2.280 tokens) se describe como tres paneles rojo, verde y azul.
- Referencia del 2026-10-28 con el script de la serie `UD-Q4_K_XL` (prompt de 99.143 tokens, 128 de
  decode largo), perfil 131K: 1.957,48 t/s de prefill, 53,01 y 74,86 t/s de decode largo y corto y
  15.306 MiB de VRAM pico con 6 hilos; con 8 hilos, 1.956,75, 57,33 y 76,58 t/s. El prefill de la
  tabla superior no es comparable porque el prompt era otro.

## Límites y no verificado

- No se ejercitó el contexto completo ni un prompt largo con imagen. No se midió la calidad.
- El batch/ubatch `1024/1024` de los perfiles 131K y visión 131K no se ha recalibrado ni medido: la
tabla anterior corresponde a `2048/2048`.
- Modelo sin salvaguardas de rechazo: úsalo solo en esta red privada y con criterio propio.
- Los perfiles escuchan en `0.0.0.0:8080` sin autenticación: un perfil a la vez.

## Dependencias

- `config/models/occult-nail-1.0-35b-a3b.psd1`
- `scripts/models/occult-nail-1.0-35b-a3b/*.cmd`
- `runtimes/llama.cpp/b11551-cuda13.4/`

## Related ADRs

- [ADR-0001: lanzadores autocontenidos](../../adr/ADR-0001-self-contained-model-launchers.md)
