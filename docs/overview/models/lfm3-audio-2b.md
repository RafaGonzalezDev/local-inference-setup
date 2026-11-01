# LFM3 Audio 2B

- Modelo: `LFM3-Audio-2B-Q8_0.gguf` y proyector `mmproj-LFM3-Audio-2B-Q8_0.gguf`
- Repositorio: `LiquidAI/LFM3-Audio-2B-GGUF`
- Revisión: `02355c1a141e464a064f2ab2c276638dbcb7f38a` (cabeza de `main` el 2026-11-01)
- Licencia: LFM Open License v1.0, sin acceso restringido
- Alias API: `lfm3-audio-2b`
- Entrada de texto y audio; salida de texto o voz (`POST /tts`, WebSocket `/v1/realtime`). Contexto 32K.

Se instaló en `experimental/lfm3` el 2026-10-29 (revisión `642697a5`), se retiró ese mismo día y vuelve
el 2026-11-01 al catálogo principal ([changelog](../../changelog/2026-11-01-lfm3-main-catalog.md)).

## Artefactos

| Archivo | Tamaño | SHA-256 |
| --- | ---: | --- |
| `LFM3-Audio-2B-Q8_0.gguf` | 1.846.236.704 bytes | `d4e36902ba8f0ee7b333596030a59d650f88ac76660b4d9ba5ff77c3c2258fc0` |
| `mmproj-LFM3-Audio-2B-Q8_0.gguf` | 303.811.840 bytes | `2b6648b1fd48af16aa0877b0592b144d15070783673e038a379fdbc51d40e365` |

SHA-256 LFS de la API de Hugging Face; descarga verificada por tamaño y SHA-256. Por elección del
usuario se fija la revisión más reciente: los pesos son los mismos que el 2026-10-29 (mismo SHA-256),
pero el proyector cuantiza el decodificador del códec (337.862.080 bytes antes). La PR que permite esa
cuantización (#31386) es posterior a `b11981`, pero `b11981` carga el proyector nuevo y sintetiza voz
con él (ver validación).

## Perfil

| Lanzador | Contexto | Batch/UBatch | Alias de perfil |
| --- | ---: | ---: | --- |
| `start-agentic-auto-audio-32k-1024.cmd` | 32.768 | 1024/1024 | `lfm3-audio-2b-audio-32k` |

- `--fit-target 2048` por el proyector. Decodificación voraz de texto (`--temp 0 --top-k 1`), como pide
  la tarjeta; el muestreo de audio está guardado en el GGUF.
- `--reasoning auto` con presupuesto 8192: el modelo solo razona si la plantilla abre `<think>`.
- Transcripción: prompt de sistema `Perform ASR in <language>.`.

## Clientes

No se registra en ningún cliente (decisión del usuario, 2026-11-01): Pi, OpenCode y DSH no envían ni
reproducen audio.

## Validación (2026-11-01)

- Smoke con `Test-Llm.ps1`. `/props` confirma 32.768 tokens y solo la modalidad `audio`.
- `POST /tts` en español devuelve un WAV válido en 0,39 s. Transcribirlo de vuelta da la frase exacta
  y la muestra `omni-question-es.wav` se transcribe correctamente.
- VRAM pico 5.363 MiB.
- Sin probar ahora: `/v1/realtime` (validado el 2026-10-29 con el proyector anterior).
