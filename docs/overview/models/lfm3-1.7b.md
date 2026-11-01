# LFM3 1.7B

- Modelo: `LFM3-1.7B-Q8_0.gguf`
- Repositorio: `LiquidAI/LFM3-1.7B-GGUF`
- Revisión: `bad5729bba61d076fff20d2548e62526665af215`
- Licencia: LFM Open License v1.0 (`lfm1.0`), sin acceso restringido
- Alias API: `lfm3-1.7b`
- Arquitectura GGUF: `lfm3`, contexto nativo 262.144. Solo texto.

Modelo de texto post-entrenado para arneses de agentes (Pi, Hermes): tool calling XML, salidas
estructuradas y búsqueda diferida de herramientas. La tarjeta no lo recomienda para programación
agentic ni para tareas que exijan mucho conocimiento. Estuvo en `experimental/lfm3` del 2026-10-29 al
2026-11-01, cuando pasó al catálogo principal sin cambiar de archivo ni de runtime
([changelog](../../changelog/2026-11-01-lfm3-main-catalog.md)).

## Artefactos

| Archivo | Tamaño | SHA-256 |
| --- | ---: | --- |
| `LFM3-1.7B-Q8_0.gguf` | 1.846.238.496 bytes | `8f6b24182258205e9e01e21f1f24a1f208c1e8115578825d202ce39976af20b6` |

SHA-256 LFS de la API de Hugging Face en la revisión fijada. El archivo se movió desde
`experimental/lfm3/models` sin volver a descargarlo; `Test-ModelIntegrity.ps1` lo verificó en su
nueva ruta.

## Perfil

| Lanzador | Contexto | Batch/UBatch | Alias de perfil |
| --- | ---: | ---: | --- |
| `start-agentic-auto-262k-1024.cmd` | 262.144 | 1024/1024 | `lfm3-1.7b-262k` |

- Base del catálogo: `--gpu-layers auto --fit on --fit-target 1024`, 6 hilos, `--cache-ram 8192`,
  caché KV `q8_0`, Flash Attention, Jinja y logs compactos.
- Muestreo de la tarjeta GGUF: `--temp 0.1 --top-k 50 --repeat-penalty 1.1` (en matemáticas y ciencia,
  temperatura 1,0, top_p 0,95 y top_k 20 por petición).
- Razonamiento: la plantilla termina en `<think>`. `--reasoning auto` con presupuesto 8192;
  `chat_template_kwargs.enable_thinking: false` lo desactiva y `thinking_budget_tokens` lo recorta.

## Clientes

Pi y OpenCode lo registran como `LFM3-262K` y DSH como `LFM3 1.7B Local · 262K`, con las variantes
`off`/`low`/`medium`/`high` de los modelos con `enable_thinking`. Salida máxima: 32.768 (Pi, DSH) y
32.000 (OpenCode, como el resto de claves de 262K).

## Validación (2026-11-01)

- Smoke con `Test-Llm.ps1`. `/props` confirma 262.144 tokens y `/v1/models` los dos alias.
- La respuesta de texto sale con su razonamiento separado; la herramienta `get_weather` devuelve
  `{"location":"Madrid"}`. VRAM pico 6.764 MiB (incluye ~2 GiB del escritorio).
- Sin probar: prompts cerca del límite de contexto y sesiones reales de Pi, OpenCode o DSH.
