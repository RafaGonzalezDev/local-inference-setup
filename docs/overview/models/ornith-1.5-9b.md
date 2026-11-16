# Ornith 1.5 9B

- Modelo: `Ornith-1.5-9B-Q4_K_M.gguf` y proyector `mmproj-Ornith-1.5-9B-BF16.gguf`
- Repositorio: `ornith-ai/Ornith-1.5-9B-GGUF` (publicación oficial del autor)
- Revisión: `abdd624b12ebf020b767fff532ff44fe552b28c3` (cabeza de `main` el 2026-11-16)
- Licencia: MIT, sin acceso restringido
- Alias API: `ornith-1.5-9b`
- Arquitectura GGUF: `qwen35` (denso de 9B, sin expertos; contexto nativo 262.144). Razonador: la plantilla
  embebida abre `<think>` por defecto y soporta llamadas a herramientas en formato XML.

Este alta repite el modelo retirado el 2026-10-26, pero con el `Q4_K_M` oficial en lugar del `AD-IQ4_XS` de
`AtomicChat` que se usó entonces (la evaluación de septiembre se revirtió sin comparar calidad; ver el
[changelog](../../changelog/2026-09-23-ornith-1.5-9b-q4-k-m.md)). No se compararon ambas
cuantizaciones. Los tipos de tensor reales no se leyeron de la cabecera.

## Artefactos

| Archivo | Tamaño | SHA-256 |
| --- | ---: | --- |
| `Ornith-1.5-9B-Q4_K_M.gguf` | 5.780.090.816 bytes | `70c112196e0b7023803c9762752e46d29e612a92c83f995bc3ba1ceb07e8fab6` |
| `mmproj-Ornith-1.5-9B-BF16.gguf` | 921.704.672 bytes | `626f9f90627402a6bf4a999111d0fbd69b5fcca7aa8ba089d69e5f10e8858e1d` |

SHA-256 LFS de la API de Hugging Face en la revisión fijada; las descargas se verificaron por tamaño y SHA-256.
El proyector se añadió el 2026-11-16, después del alta, a petición del usuario. Es el único que publica el
repositorio. La tarjeta no anuncia visión (`pipeline_tag: text-generation`, sin benchmarks de imagen), pero la
plantilla embebida acepta imágenes y vídeo con los tokens de Qwen3.5.

## Perfiles

| Lanzador | Contexto | Batch/UBatch | Alias de perfil |
| --- | ---: | ---: | --- |
| `start-agentic-auto-131k-1024.cmd` | 131.072 | 1024/1024 | `ornith-1.5-9b-131k` |
| `start-agentic-auto-262k-1024.cmd` | 262.144 | 1024/1024 | `ornith-1.5-9b-262k` |
| `start-agentic-auto-vision-131k-1024.cmd` | 131.072 | 1024/1024 | `ornith-1.5-9b-vision-131k` |
| `start-agentic-auto-vision-262k-1024.cmd` | 262.144 | 1024/1024 | `ornith-1.5-9b-vision-262k` |

Los perfiles de visión son copias de los de texto con `--mmproj` y `--fit-target 2048`, porque `--fit` no
cuenta el proyector. No fijan `--image-min-tokens`: la tarjeta no lo pide y no se ha probado.

Base común del catálogo, sin cambios: `b12359-cuda13.5`, `--gpu-layers auto --fit on --fit-target 1024`,
6 hilos, `--cache-ram 8192` (reutiliza el prompt de la conversación), caché KV `q8_0`, Flash Attention,
`--parallel 1`, `--split-mode none`, Jinja, `--load-mode none`, logs compactos y `--reasoning-budget 8192`.

- Muestreo: `--temp 0.6 --top-p 0.95 --top-k 20 --min-p 0 --presence-penalty 0 --repeat-penalty 1`, la
  receta de la tarjeta para programación precisa (la general usa `temp 1.0` y `presence_penalty 1.5`).
- `--reasoning auto`: `/apply-template` termina en `<think>\n`, es decir, razona por defecto.

## Validación (2026-11-16, `b12359-cuda13.5`)

Prompt de 55.844 tokens con una respuesta enterrada, sin razonamiento; VRAM total 16.303 MiB con unos
2.150 MiB ocupados por el escritorio antes de arrancar. Una repetición por perfil.

| Perfil | `n_ctx` | VRAM tras carga | VRAM pico | Prefill | Generación (código) | Generación (56K) | Reutilización |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| 131K | 131.072 | 10.253 MiB | 10.260 MiB | 5.487 tok/s | 117 tok/s | 92 tok/s | 55.840 de 55.844 tokens en caché |
| 262K | 262.144 | 13.214 MiB | 13.218 MiB | 5.454 tok/s | 116 tok/s | 92 tok/s | 55.840 de 55.844 tokens en caché |

- `/props`: `n_ctx` 131.072 y 262.144, sin modalidades de visión; `/v1/models` publica `ornith-1.5-9b`.
- Contrato de razonamiento: por defecto razona (25–37 palabras ante `17 × 23`), `enable_thinking: false`
  deja `reasoning_content` vacío y `thinking_budget_tokens: 64` lo recorta; la respuesta fue siempre `391`.
- Tool calling: `get_weather` con `{"location":"Madrid"}` y `finish_reason tool_calls` en ambos perfiles.
- La respuesta enterrada (638 unidades, estación 12) se recuperó correctamente en los dos perfiles; es una
  sola muestra con `temp 0.2`, no una medida de calidad.
- Cierre limpio: el puerto 8080 quedó libre y la VRAM volvió a ~2.000 MiB.

Registros: `logs/validation/calibration-ornith-1.5-9b-*-20261116-*.json`.

## Pendiente

- **Perfiles de visión sin ejecutar** (la GPU estaba ocupada): no se ha comprobado que `b12359` cargue el
  proyector ni medido VRAM, contexto efectivo, descripción de la imagen de prueba ni tool calling. Antes de
  darlos por viables, aplicar la calibración bajo carga con `tests/assets/panels-1080p.png`. El pico estimado
  a 262K (unos 14–14,5 GB) es una estimación, no una medida.

- Contexto completo (262.144 tokens exactos), sesiones reales en Pi, OpenCode y DSH, y comparación con el
  `AD-IQ4_XS` anterior no evaluados.