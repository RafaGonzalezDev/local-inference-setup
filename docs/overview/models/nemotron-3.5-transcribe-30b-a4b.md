# Nemotron 3.5 Transcribe 30B A4B

Modelo de transcripción de voz (SALM: codificador de audio + Nemotron 3.5 Lightning 30B-A3B), servido por
NeMo-Speech.cpp desde el subárbol [`speech/`](../../../speech/README.md). Fuera del catálogo de chat y de sus
clientes; lo usa el plugin `video-workbench` (motor «Nemotron» de la pestaña Captions, desde 1.35.0), que
arranca el lanzador para cada transcripción y lo cierra al terminar. El plugin decodifica el audio con su
propio entorno (Python 3.12.14, PyAV 18.1.0 con FFmpeg 8.1.2), independiente del de Whisper.

## Procedencia

| Dato | Valor |
| --- | --- |
| Modelo base | [nvidia/NVIDIA-Nemotron-3.5-Transcribe-30B-A4B](https://huggingface.co/nvidia/NVIDIA-Nemotron-3.5-Transcribe-30B-A4B) |
| Licencia | OpenMDW-1.1 |
| Publicación GGUF | [AtomicChat/NVIDIA-Nemotron-3.5-Transcribe-30B-A4B-GGUF](https://huggingface.co/AtomicChat/NVIDIA-Nemotron-3.5-Transcribe-30B-A4B-GGUF), revisión `dbd06c5cad7a2f33c8e06be2fb3ef814dbd9aa59` (tercero) |
| Decodificador | `NVIDIA-Nemotron-3.5-Transcribe-30B-A4B-AD-IQ4_NL.gguf`, 19.678.656.672 bytes, SHA-256 `0c47d4ab6c783e7606ec03714b354fab0b2052027a7ea1991e7e2d3009c345ad` |
| Encoder (audio, hablantes, cabeza CTC de tiempos) | `NVIDIA-Nemotron-3.5-Transcribe-30B-A4B-Encoder-F16.gguf`, 1.670.410.080 bytes, SHA-256 `4221029c8a565c4a80c507ffa760c716e595acf663f9f4273ce69910050e7ba2` |

Los SHA-256 son los LFS de la API de Hugging Face en esa revisión; la descarga los comprobó. El decodificador nombra
al encoder: no renombres este último.

## Runtime

NeMo-Speech.cpp build nightly del 2026-11-13, commit `e790e463b2913cff9f989a3df224c587f14b4c5c`
(`nemo-speech 0.3.0+nightly.e790e46`), paquete `nemo-speech-nightly-windows-x86_64-cuda.zip`, SHA-256
`17a54013679473eb6bdafe23217ff3ed253cb4e6475812e056a688e65892d8dc`, en `runtimes/nemo-speech/nightly-e790e46-cuda/`.
La versión estable 0.3.0 (commit `20999cc`, SHA-256 `d0d32ae1…f6ed42`) también está instalada en
`runtimes/nemo-speech/0.3.0-cuda/`, pero rechaza `--asr.salm.n_cpu_moe`, sin el que el modelo no cabe en 16 GB.
La etiqueta `nightly` se mueve: el zip guardado en `packages/nemo-speech/nightly-e790e46/` es la copia reinstalable.

## Perfil

`start-transcribe-hybrid-32k.cmd`, fila de 16 GB de la
[guía de configuración](https://github.com/NVIDIA/NeMo-Speech.cpp/blob/main/docs/salm/configuration.md):

| Ajuste | Valor | Motivo |
| --- | --- | --- |
| `asr.salm.n_cpu_moe` | 28 | Expertos de los 28 primeros bloques en RAM (ruta llama.cpp, sin MTP) |
| `max_sequences` / `n_ctx_per_sequence` / `max_context` | 1 / 32768 / 32768 | Una petición; unos 29 min de audio por petición |
| `n_batch` / `encoder_max_batch` / `encoder_ahead_seconds` | 512 / 1 / 600 | Recomendación para 16 GB |
| `asr.backend.threads` | 6 | Igual que los perfiles de chat; no medido aquí |
| Red | `127.0.0.1:8090`, `--no-ui` | Solo local, sin autenticación; 8080 queda para el chat |

## Mediciones (RTX 5080, 2026-11-16)

Muestra: 300 s de una entrevista en español con dos personas (export del proyecto de video-workbench).

| Prueba | Resultado |
| --- | --- |
| VRAM en reposo / pico | 14,4 GB / 14,9 GB (incluye ~2 GB ocupados antes de arrancar) |
| Instrucción por defecto | 20,1 s; 901 palabras; todo `spk:0`; empieza en 7,6 s y del tramo 150–180 s solo da 16 palabras |
| Instrucción con etiquetas de hablante (la que usa el plugin) | 27,9 s; 1036 palabras desde 0 s; 2 hablantes (416/620); muletillas incluidas |
| Whisper large-v3 (faster-whisper, mismo audio) | 32,2 s con la carga; 873 palabras, texto limpio sin muletillas |
| Tiempos frente a Whisper | 51 palabras comparables: diferencia mediana 0,13 s, p90 0,37 s; Nemotron ~0,1–0,2 s más tarde |
| Carga del servidor (pesos en caché de ficheros) | 4,7–4,9 s hasta `/ready`; al cerrar, VRAM liberada |
| Plugin 1.35.0 (`runNemotron`), 2 tramos de 60 s del MP4, con arranque y cierre del servidor | 16,6 s; tiempos en segundos de la fuente |

No hay referencia humana del audio: no se ha medido la tasa de error de ninguno de los dos.

## Limitaciones

- Offline: sin streaming de audio. Más de unos 29 min por petición falla; el plugin trocea a 25 min.
- La numeración de hablantes solo es estable dentro de una petición.
- El modelo no informa del idioma detectado; solo devuelve el pedido.
- Con la instrucción por defecto omitió tramos completos de habla en la muestra; usar la instrucción con
  `<spk:N>` del prompt guide.
- La API ordena `words` por inicio y mezcla hablantes en los solapamientos; `word_index` conserva el orden de
  la transcripción.
- No convive en la GPU con un perfil de chat cargado.
