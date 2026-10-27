# 2026-10-27 - Despliegue experimental LFM3

> 2026-10-28: `lfm3-1.7b`, el runtime y el script de compilación se movieron al directorio
> principal ([changelog](../../../../docs/changelog/2026-10-28-lfm3-1.7b.md)).

**Qué**: nuevo directorio `experimental/lfm3` con `lfm3-1.7b`, `lfm3-audio-2b` y `lfm3-omni-2b`
(LiquidAI, `Q8_0` y proyectores `Q8_0`), un perfil por modelo y un runtime de llama.cpp compilado
desde el commit `19ff817` (fusión de la PR #31257).

**Por qué**: el usuario quiere probar todas las capacidades de la familia LFM3 (texto, audio, voz e
imagen) sin mezclarla con los modelos de codificación agentic. Ninguna release de llama.cpp las
soportaba; compilar desde código está permitido con notificación al usuario, que se le dio antes de
compilar. Ver [backend](../../../../docs/overview/inference-backend.md#source-built-runtime-19ff817).

**Dónde**: `experimental/lfm3/{README.md,config,docs,scripts}`; pesos, runtime, fuente y registros
en `experimental/lfm3/{models,runtimes,src,logs}` (no versionados). En `D:\LLM`: referencia en
`README.md`, `AGENTS.md` y `handoff.md`, y `Test-Llm.ps1 -RootDirectory`.

## Validación (2026-10-28)

- Integridad: los 5 artefactos coinciden en tamaño y SHA-256 LFS con las revisiones fijadas.
- `Test-Llm.ps1 -RootDirectory .\experimental\lfm3 -ConfigurationOnly -RequireInstalledFiles`:
  3 perfiles, 0 fallos.
- Prueba funcional, un arranque secuencial por perfil, `temperature 0`, registros en
  `experimental/lfm3/logs/validation/capabilities-20261028-*.json`:

| Prueba | `lfm3-1.7b` | `lfm3-audio-2b` | `lfm3-omni-2b` |
| --- | --- | --- | --- |
| `/props` contexto | 262.144 | 32.768 | 32.768 |
| Modalidades (`/props`) | texto | audio | imagen, vídeo, audio |
| Texto | correcto, con `reasoning_content` | correcto, con `reasoning_content` | correcto, sin razonamiento |
| `enable_thinking: false` | sin `reasoning_content` | - | - |
| Tool calling `get_weather` | `tool_calls`, `{"location":"Madrid"}` | igual | igual |
| ASR (voz SAPI) | - | errores en la segunda frase | errores en la segunda frase |
| Pregunta sobre el audio | - | parcial (hora sí, día no) | parcial (hora sí, día no) |
| `POST /tts` | - | WAV 24 kHz, ~5,0 s | WAV 24 kHz, ~5,6 s |
| ASR del audio TTS | - | transcripción exacta | transcripción exacta |
| Imagen `panels-1080p.png` | - | - | rojo, verde y azul correctos |
| Decode | ~270 t/s | ~250–280 t/s | ~265–280 t/s |
| VRAM pico (incluye ~1,4 GB de escritorio) | 6.179 MiB | 5.015 MiB | 5.539 MiB |

- La muestra de voz es sintética (Windows SAPI): «The quick brown fox jumps over the lazy dog.
  Please schedule the meeting for Tuesday at three o clock.». Ambos modelos transcriben la primera
  frase y fallan en «schedule» y «Tuesday»; una voz sintética no representa la precisión con voz
  real.
- `/v1/models` publica el alias de perfil en `aliases` y las peticiones con ese nombre se aceptan.

## No verificado

- Calidad general, contexto completo (262K / 32K), ASR en otros idiomas, LiveASR, traducción de voz,
  voz `male`, `llama-tts` y `llama-mtmd-cli` por línea de comandos, y `/v1/realtime`.
- Vídeo en Omni: `/props` lo anuncia, pero la tarjeta GGUF dice que llama.cpp aún no lo soporta.
- Respuestas intercaladas texto+voz y conversación de voz en tiempo real: no expuestas por este
  runtime.
- Calibración de memoria bajo carga con prompts largos; con estos tamaños el margen es amplio.
