# Qwen3.6 35B A3B

- Publicador: `unsloth` (Hugging Face), cuantización Unsloth Dynamic de `Qwen/Qwen3.6-35B-A3B`
- Modelo: `Qwen3.6-35B-A3B-UD-Q4_K_XL.gguf`
- Proyector: `mmproj-F16.gguf`
- Repositorio del modelo: `unsloth/Qwen3.6-35B-A3B-MTP-GGUF`, revisión
  `5bc3e238d916f48a861bac2f8a1990a0e9b7e98d`
- Repositorio del proyector: `unsloth/Qwen3.6-35B-A3B-GGUF`, revisión
  `a483e9e6cbd595906af30beda3187c2663a1118c`
- Licencia: `apache-2.0`.
- Alias API: `qwen3.6-35b-a3b`
- Arquitectura: `qwen35moe` (MoE, 256 expertos y 8 activos por token, 40 capas, contexto nativo
  262.144) con la plantilla oficial de Qwen3.6, que abre `<think>` por defecto y admite
  `enable_thinking: false` por petición.

Vuelve al catálogo el 2026-11-11, retirado el 2026-10-28
([changelog](../../changelog/2026-11-11-qwen3.6-35b-a3b.md)). El GGUF es el de la publicación con capa
MTP (bloque `blk.40.nextn`), que se conservó tras la comparación con Strata del mismo día. Los perfiles no
usan la capa: llama-server la ignora sin `MTP_ARGS`.

## Artefactos

| Artefacto | Archivo | Tamaño | SHA-256 |
| --- | --- | ---: | --- |
| `UD-Q4_K_XL` (con capa MTP) | `Qwen3.6-35B-A3B-UD-Q4_K_XL.gguf` | 22.853.663.008 bytes | `55983c5a75a1ab969824077b3bb3de4146e82a9234072b48ad4e8f92ad3fe9f1` |
| Proyector F16 | `mmproj-F16.gguf` | 899.283.680 bytes | `8971ee4f331ff0a4c609374f32984b3d4e6dc086c0aa35f1d637fad1829e887f` |

SHA-256 LFS de la API de Hugging Face en las revisiones fijadas; ambos verificados en local. El proyector
es byte a byte el de Nail y se copió desde su instalación.

## Perfiles

| Lanzador | Contexto | Batch/UBatch | Visión | Alias de perfil |
| --- | ---: | ---: | :---: | --- |
| `start-agentic-auto-131k-1024.cmd` | 131.072 | 1024/1024 | no | `qwen3.6-35b-a3b-131k` |
| `start-agentic-auto-262k-1024.cmd` | 262.144 | 1024/1024 | no | `qwen3.6-35b-a3b-262k` |
| `start-agentic-auto-vision-131k-1024.cmd` | 131.072 | 1024/1024 | sí | `qwen3.6-35b-a3b-vision-131k` |
| `start-agentic-auto-vision-262k-1024.cmd` | 262.144 | 1024/1024 | sí | `qwen3.6-35b-a3b-vision-262k` |

Copias de los lanzadores de Nail sobre `b11981-cuda13.4`: batch 1024/1024, 6 hilos, `--fit-target 1024`
(2048 en visión), caché KV `q8_0`, `--cache-ram 8192`, `--reasoning auto`, `--reasoning-budget 8192` e
`--image-min-tokens 2048`.

- Muestreo: `--temp 0.6 --top-p 0.95 --top-k 20 --min-p 0 --presence-penalty 0 --repeat-penalty 1`,
  la recomendación de la tarjeta para razonamiento en tareas de programación precisas y el valor que
  usaban estos perfiles antes de su retirada. Para tareas generales la tarjeta recomienda
  `temperature 1.0` con `presence_penalty 1.5`.
- Contexto, presupuesto de razonamiento y tokens de imagen se heredan de Nail.

## Validación (2026-11-11)

No se repitió la calibración bajo carga, por decisión del usuario: los pesos y la colocación son los de
Nail, calibrado el 2026-10-28. Datos medidos hoy con este GGUF:

- Comparación con Strata a 131K, perfil de texto sin MTP: VRAM pico 15.360 MiB, +12,1 GiB de RAM, prefill
  de 24.494 tokens a 2.311 t/s y decode de 68–73 t/s (`logs/validation/strata-ab-20261111/RESULTS.md`).
- Prueba funcional de los cuatro perfiles (`logs/validation/smoke-qwen3.6-35b-a3b-20261111/`): `/props`
  confirma 131.072 y 262.144; `/v1/models` publica el alias canónico con el de perfil en `aliases`; la
  plantilla termina en `<|im_start|>assistant\n<think>\n`; `enable_thinking: false` deja
  `reasoning_content` vacío; tool calling `get_weather {"location":"Madrid"}` en los cuatro;
  `thinking_budget_tokens: 64` recorta el razonamiento de 4.169 a 262 caracteres y sigue respondiendo.
- Visión (`tests/assets/panels-1080p.png`, 2.103 tokens de prompt): a la pregunta de los colores de los
  paneles responde rojo, verde y azul, con razonamiento y sin él. Al pedir una descripción libre dice que es
  la bandera de Mali, a veces con los colores de esa bandera (verde, dorado y rojo).

## Límites y no verificado

- Sin calibración propia con prompts largos (~99K/230K) ni prueba del contexto completo.
- La descripción libre de imágenes puede confundir la imagen de prueba con una bandera; no se evaluó con
  otras imágenes.
- No se midió calidad frente a Nail ni frente a la `UD-Q4_K_M` anterior.
- Los perfiles escuchan en `0.0.0.0:8080` sin autenticación: solo red privada de confianza y un perfil a la
  vez.

## Dependencias

- `config/models/qwen3.6-35b-a3b.psd1`
- `scripts/models/qwen3.6-35b-a3b/*.cmd`
- `runtimes/llama.cpp/b11981-cuda13.4/`

## Related ADRs

- [ADR-0001: lanzadores autocontenidos](../../adr/ADR-0001-self-contained-model-launchers.md)
