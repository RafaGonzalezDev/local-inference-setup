# LFM3 Omni 2B

- Modelo: `LFM3-Omni-2B-Q8_0.gguf` y proyector `mmproj-LFM3-Omni-2B-Q8_0.gguf`
- Repositorio: `LiquidAI/LFM3-Omni-2B-GGUF`
- Revisión: `3d29af2ad166f8299c2d820937e47dc0add20ffc` (cabeza de `main` el 2026-11-01)
- Licencia: LFM Open License v1.0, sin acceso restringido
- Alias API: `lfm3-omni-2b`
- Entrada de texto, imagen, vídeo y audio; salida de texto o voz. Contexto 32K. Sin razonamiento.

Se instaló en `experimental/lfm3` el 2026-10-29 (revisión `2918dd47`), se retiró ese mismo día y vuelve
el 2026-11-01 al catálogo principal ([changelog](../../changelog/2026-11-01-lfm3-main-catalog.md)).

## Artefactos

| Archivo | Tamaño | SHA-256 |
| --- | ---: | --- |
| `LFM3-Omni-2B-Q8_0.gguf` | 1.846.240.768 bytes | `59118f661eaacb93d204723d76355b53347f0940b508c11412f6290fd49158d4` |
| `mmproj-LFM3-Omni-2B-Q8_0.gguf` | 506.842.528 bytes | `8a25f9d1931244429de404fccacfb7fb933970a36aa5688d2f5069f29c6b27b1` |

SHA-256 LFS de la API de Hugging Face; descarga verificada por tamaño y SHA-256. Como en Audio, los pesos
no cambian y el proyector de la revisión más reciente cuantiza el decodificador del códec (540.892.768
bytes antes); `b11981` lo carga.

## Perfil

| Lanzador | Contexto | Batch/UBatch | Alias de perfil |
| --- | ---: | ---: | --- |
| `start-agentic-auto-omni-32k-1024.cmd` | 32.768 | 1024/1024 | `lfm3-omni-2b-omni-32k` |

- `--fit-target 2048` por el proyector. Decodificación voraz de texto (`--temp 0 --top-k 1`), como pide
  la tarjeta; el muestreo de audio está guardado en el GGUF.
- `--reasoning off`: la tarjeta lo pide expresamente para este modelo sin razonamiento. Es la excepción
  a `--reasoning auto`.
- El vídeo necesita `ffmpeg` en el `PATH`.

## Clientes

Pi y OpenCode lo registran como `LFM3-Omni-V-32K` y DSH como `LFM3 Omni 2B Local · Vision 32K`: texto e
imagen, sin razonamiento (DSH `reasoningEfforts: false`) y salida máxima de 8192. Sus 32K se quedan
cortos para el prompt de sistema de un arnés agentic.

## Validación (2026-11-01)

- Smoke con `Test-Llm.ps1`. `/props` confirma 32.768 tokens y las modalidades `vision`, `video` y
  `audio`.
- Describe correctamente la imagen de prueba; la herramienta `get_weather` devuelve
  `{"location":"Madrid"}`.
- `POST /tts` en español devuelve un WAV válido en 0,35 s; transcribirlo de vuelta da la frase exacta y
  la muestra `omni-question-es.wav` se transcribe correctamente.
- VRAM pico 6.183 MiB.
- Sin probar ahora: vídeo y `/v1/realtime` (validados el 2026-10-29 con el proyector anterior).
