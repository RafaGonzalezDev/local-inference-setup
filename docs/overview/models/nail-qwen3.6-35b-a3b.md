# Nail Qwen3.6 35B A3B

- Publicador: `peculiar-ragdoll` (Hugging Face), que también publica Occult Nail y Tiel Coder
- Modelo: `Nail-Qwen3.6-35B-A3B-UD-Q4_K_S.gguf`
- Modelo MTP: `mtp/Nail-Qwen3.6-35B-A3B-MTP-UD-IQ4_XS.gguf`
- Proyector: `mmproj-F16.gguf`
- Repositorio base: `peculiar-ragdoll/Nail-Qwen3.6-35B-A3B-GGUF`, revisión
  `ac66b0fad4bc2b68d29eff967c06d55de09429c1`
- Repositorio MTP: `peculiar-ragdoll/Nail-Qwen3.6-35B-A3B-GGUF-MTP`, revisión
  `dc3f6b9bdc5ee6d617499e4be5d05d81f2a1db03`
- Licencia: `apache-2.0`, heredada de `Qwen/Qwen3.6-35B-A3B`.
- Alias API: `nail-qwen3.6-35b-a3b`
- Arquitectura: la de `qwen3.6-35b-a3b` (`qwen35moe`, contexto nativo 262.144). Según la tarjeta,
  son las cuantizaciones Unsloth Dynamic de Qwen3.6-35B-A3B (la MTP conserva los tensores `nextn`)
  con la plantilla de chat de froggeric modificada y un mensaje de sistema de concisión añadido
  siempre tras el del cliente. Los pesos no son un ajuste fino.

El mensaje de sistema vive en la plantilla embebida y no se puede desactivar desde la API. La
plantilla abre `<think>` por defecto y admite `enable_thinking: false` por petición.

## Artefactos

| Artefacto | Archivo | Tamaño | SHA-256 |
| --- | --- | ---: | --- |
| `UD-Q4_K_S` | `Nail-Qwen3.6-35B-A3B-UD-Q4_K_S.gguf` | 20.893.024.160 bytes | `cafba2e3320dcd0a5e3a101372c04e1b023afa85e82bc0ea5852542452d4d98d` |
| `UD-IQ4_XS` (MTP integrado) | `mtp/Nail-Qwen3.6-35B-A3B-MTP-UD-IQ4_XS.gguf` | 18.209.045.728 bytes | `09023c680dab746311a674cff30af5d4150f80c1e79134323f554216bfa6254a` |
| Proyector F16 | `mmproj-F16.gguf` | 899.283.680 bytes | `8971ee4f331ff0a4c609374f32984b3d4e6dc086c0aa35f1d637fad1829e887f` |

SHA-256 LFS de la API de Hugging Face en las revisiones fijadas; los tres se verificaron tras la
descarga. El proyector procede del repositorio base y es byte a byte el de
`unsloth/Qwen3.6-35B-A3B-GGUF` que usa `qwen3.6-35b-a3b`. El repositorio MTP publica otro
`mmproj-F16.gguf` (SHA-256 distinto); no se descarga porque ningún perfil MTP usa visión.

Las cuantizaciones las eligió el usuario: `UD-Q4_K_S` es la que la tarjeta base presenta como opción
de 4 bits con más margen, y `UD-IQ4_XS` la recomendada para 24 GB en la tarjeta MTP.

## Perfiles

| Lanzador | Contexto | Batch/UBatch | Visión | MTP | Alias de perfil |
| --- | ---: | ---: | :---: | :---: | --- |
| `start-agentic-auto-131k-1024.cmd` | 131.072 | 1024/1024 | no | no | `nail-qwen3.6-35b-a3b-131k` |
| `start-agentic-auto-262k-1024.cmd` | 262.144 | 1024/1024 | no | no | `nail-qwen3.6-35b-a3b-262k` |
| `start-agentic-auto-mtp-131k-1024.cmd` | 131.072 | 1024/1024 | no | sí, n-max 3 | `nail-qwen3.6-35b-a3b-mtp-131k` |
| `start-agentic-auto-vision-131k-1024.cmd` | 131.072 | 1024/1024 | sí | no | `nail-qwen3.6-35b-a3b-vision-131k` |

Los cuatro son copias de los lanzadores de `qwen3.6-35b-a3b` sobre el runtime `b11669-cuda13.4`:
mismo contexto y estructura, batch fijo 1024/1024 para todos los perfiles,
`--fit-target 1024` (2048 en visión), caché KV `q8_0`, `--reasoning auto`,
`--reasoning-budget 8192`, `--image-min-tokens 2048` y `--spec-type draft-mtp --spec-draft-n-max 3`.
El perfil MTP usa el GGUF de `mtp\` y los otros tres el `UD-Q4_K_S`.

- Único cambio respecto a Qwen3.6: el muestreo que recomienda la tarjeta, `--temp 1.0 --top-p 0.95
  --top-k 20 --min-p 0` sin penalizaciones (`--presence-penalty 0 --repeat-penalty 1`). Qwen3.6
  usa `--temp 0.6`.
- La tarjeta MTP midió en un M2 Ultra ~1,35× con `--spec-draft-n-max 5 --spec-draft-p-min 0.6`
  frente a ~1,25× con los valores por defecto. Es un ajuste opcional, no un requisito; se conserva
  `n-max 3` de Qwen3.6 y no se ha comparado.
- La tarjeta no fija presupuesto de razonamiento, contexto de perfil ni tokens de imagen: se heredan
  de Qwen3.6.

## Validación medida (2026-10-26)

Una ejecución por perfil, sin cambiar parámetros entre ellas. `/props` confirma el contexto
declarado y `/v1/models` publica el alias canónico y el de perfil; `input_modalities` es `["text"]`,
o `["text", "image", "video"]` en visión. La plantilla aplicada termina en
`<|im_start|>assistant\n<think>\n`.

| Perfil | Prompt largo | Prefill | Decode largo | Decode corto (1.024 tokens) | VRAM pico | RAM libre mínima |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 131K | 99.547 | 2.301,72 t/s (43,2 s) | 53,39 t/s | 68,88 t/s | 15.644 MiB | 38.891 MiB |
| 262K | 229.936 | 1.625,71 t/s (141,4 s) | 43,15 t/s | 72,51 t/s | 15.684 MiB | 37.499 MiB |
| MTP 131K | 99.547 | 2.186,04 t/s (45,5 s) | 76,71 t/s | 89,71 t/s | 15.678 MiB | 40.407 MiB |
| Visión 131K | 99.547 | 2.676,48 t/s (37,2 s) | 55,05 t/s | 71,31 t/s | 15.013 MiB | 36.839 MiB |

- `nvidia-smi` y RAM libre muestreados cada ~0,8 s; el escritorio ocupaba 1,5–2,0 GB de la tarjeta
  antes de cada arranque. Decode largo: respuesta de hasta 512 tokens tras el prompt largo
  (`temperature 0`). Decode corto: prompt breve, `enable_thinking: false`, `temperature 0`.
- MTP: el log muestra «creating MTP draft context»; se aceptaron 683 de 1.016 borradores (67 %) en
  decode corto y 334 de 444 en el largo. El perfil MTP usa otra cuantización (`IQ4_XS`), así que su
  diferencia de velocidad frente al 131K no aísla el efecto de MTP.
- Visión: `tests/assets/panels-1080p.png` (2.280 tokens de prompt) se describe correctamente como
  tres paneles verticales rojo, verde y azul.
- Tool calling en los cuatro perfiles: `get_weather` responde `finish_reason = tool_calls` con
  `arguments {"location":"Madrid"}` y razonamiento en `reasoning_content`.
- Contrato de razonamiento (perfil 131K): `enable_thinking: false` y `reasoning_effort: "none"` dejan
  `reasoning_content` vacío; `thinking_budget_tokens: 64` corta el razonamiento en ~35 palabras.
- `Test-Llm.ps1 -Model nail-qwen3.6-35b-a3b` pasa en los cuatro perfiles; el puerto y la GPU se
  liberan tras cada prueba.
- Registros: `logs/validation/calibration-nail-qwen3.6-35b-a3b-*` y
  `logs/validation/smoke-tests-20261026-164720-188-fb895341.json`.

## Límites y no verificado

- No se ejercitó el contexto completo: los prompts más largos fueron 99.547 (131K) y 229.936 (262K)
  tokens. El prompt largo con imagen no se probó.
- No se registró la colocación de `--fit` por capa (requiere `--log-verbosity 4`); el margen se
  comprobó con la VRAM pico, que deja ~600–1.300 MiB libres de 16.303.
- No se midió calidad. Los resultados de la tarjeta son de la versión MLX en un M2 Ultra, no de
  estos GGUF.
- Los perfiles escuchan en `0.0.0.0:8080` sin autenticación: solo red privada de confianza y un
  perfil a la vez.

## Dependencias

- `config/models/nail-qwen3.6-35b-a3b.psd1`
- `scripts/models/nail-qwen3.6-35b-a3b/*.cmd`
- `runtimes/llama.cpp/b11669-cuda13.4/`

## Related ADRs

- [ADR-0001: lanzadores autocontenidos](../../adr/ADR-0001-self-contained-model-launchers.md)
