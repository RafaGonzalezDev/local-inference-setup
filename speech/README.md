# Transcripción de voz (NeMo-Speech.cpp)

Subárbol propio para modelos de voz servidos por [NeMo-Speech.cpp](https://github.com/NVIDIA/NeMo-Speech.cpp),
separado del catálogo de chat de llama.cpp. No se registra en Pi, OpenCode ni DSH (decisión del usuario,
2026-11-16): lo consume el plugin `video-workbench` por HTTP.

| Pieza | Ruta |
| --- | --- |
| Catálogo y manifiesto | `speech/config/catalog.psd1`, `speech/config/models/nemotron-3.5-transcribe-30b-a4b.psd1` |
| Pesos | `models/nemotron-3.5-transcribe-30b-a4b/` (compartido con el resto de `models/`) |
| Runtime | `runtimes/nemo-speech/nightly-e790e46-cuda/` (paquete en `packages/nemo-speech/`) |
| Lanzador | `speech/scripts/models/nemotron-3.5-transcribe-30b-a4b/start-transcribe-hybrid-32k.cmd` |
| Ficha | [nemotron-3.5-transcribe-30b-a4b](../docs/overview/models/nemotron-3.5-transcribe-30b-a4b.md) |

## Instalación y validación

Los scripts comunes aceptan este subárbol con `-RootDirectory`:

```powershell
.\speech\scripts\setup\Install-NemoSpeechRuntime.ps1
.\scripts\setup\Download-Model.ps1 -Model nemotron-3.5-transcribe-30b-a4b -RootDirectory .\speech
.\scripts\common\Test-ModelIntegrity.ps1 -RootDirectory .\speech
```

`Test-Llm.ps1` no cubre este subárbol: valida lanzadores de `llama-server`.

## Uso

El plugin `video-workbench` arranca este lanzador en cada transcripción y cierra el árbol de procesos al
terminar (también al cancelar o fallar); si ya hay un servidor respondiendo en el puerto, lo usa y lo deja.
Se registra una vez con `node plugins/video-workbench/nemotron/setup.mjs <lanzador>` desde `dsh-extensions`,
que instala su propio Python con PyAV en `~/.dsh/video-workbench/nemotron/`, independiente de Whisper.

A mano:

```powershell
.\speech\scripts\models\nemotron-3.5-transcribe-30b-a4b\start-transcribe-hybrid-32k.cmd
```

Escucha en `127.0.0.1:8090`, sin autenticación y solo en local. Carga en unos 5 s con los pesos en la caché
de ficheros. Ocupa unos 14,9 GB de VRAM: no puede convivir con un perfil de chat cargado en la GPU; en ese
caso el arranque falla y el plugin muestra el motivo. Parada con `Ctrl+C`.

```powershell
Invoke-RestMethod http://127.0.0.1:8090/health
```

Transcripción con tiempos por palabra y hablantes: `POST /v1/chat/completions` con `input_audio` (WAV, FLAC o
MP3) y `timestamp_granularities: ["word"]`; detalle en la ficha.
