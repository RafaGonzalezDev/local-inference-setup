# LFM3 VL 2B

- Modelo: `LFM3-VL-2B-Q8_0.gguf` y proyector `mmproj-LFM3-VL-2B-Q8_0.gguf`
- Repositorio: `LiquidAI/LFM3-VL-2B-GGUF`
- Revisión: `b36554cfd35854b06429900131730cd80f092cdb` (la misma del 2026-10-29, que sigue siendo la
  cabeza de `main`)
- Licencia: LFM Open License v1.0, sin acceso restringido
- Alias API: `lfm3-vl-2b`
- Entrada de texto, imagen y vídeo; salida de texto. Contexto nativo 128.000.

Se instaló en `experimental/lfm3` el 2026-10-29, se retiró ese mismo día y vuelve el 2026-11-01 al
catálogo principal ([changelog](../../changelog/2026-11-01-lfm3-main-catalog.md)). El soporte está en
`b11981` (PR #31252; vídeo, PR #31283).

## Artefactos

| Archivo | Tamaño | SHA-256 |
| --- | ---: | --- |
| `LFM3-VL-2B-Q8_0.gguf` | 1.846.238.496 bytes | `e138e54189a751d90ea8c0b236360490613ecd465d28d68fa6094d3db7fa6727` |
| `mmproj-LFM3-VL-2B-Q8_0.gguf` | 203.031.872 bytes | `c5c5b58d544a18da919172d2d0368090ea1a4a351b6feb7f8a326a264a5918ab` |

SHA-256 LFS de la API de Hugging Face; descarga verificada por tamaño y SHA-256.

## Perfil

| Lanzador | Contexto | Batch/UBatch | Alias de perfil |
| --- | ---: | ---: | --- |
| `start-agentic-auto-vision-128k-1024.cmd` | 128.000 | 1024/1024 | `lfm3-vl-2b-vision-128k` |

- La etiqueta `128k` es el entero nativo exacto: 131.072 lo supera, así que no hay perfiles de 131K
  ni de 262K. `--fit-target 2048`, como el resto de perfiles con proyector.
- Muestreo de la tarjeta: `--temp 0.1 --top-p 1 --top-k 50 --repeat-penalty 1.1`.
- Razonamiento: la plantilla termina en `<think>`. `--reasoning auto` con presupuesto 8192 y
  `--no-reasoning-preserve` (la tarjeta descarta el razonamiento anterior del historial). El vídeo
  necesita `ffmpeg` en el `PATH`.

## Clientes

Pi y OpenCode lo registran como `LFM3-VL-V-128K` y DSH como `LFM3 VL 2B Local · Vision 128K`, con
entrada de texto e imagen, salida máxima de 24.576 y las variantes de `enable_thinking`. Ningún cliente
envía vídeo.

## Validación (2026-11-01)

- Smoke con `Test-Llm.ps1` y la imagen de paneles. `/props` confirma 128.000 tokens y las modalidades
  `vision` y `video`.
- Describe correctamente la imagen de prueba (tres bandas verticales: roja, verde y azul).
- `/apply-template` termina en `<think>`. `enable_thinking: false` deja el razonamiento vacío y
  `thinking_budget_tokens: 64` lo recorta a 54 palabras con la respuesta completa; sin presupuesto,
  313 palabras.
- VRAM pico 6.107 MiB. El 2026-10-29 se validó también una petición de 127.965 tokens con imagen.
- Sin probar ahora: vídeo y prompts largos.
