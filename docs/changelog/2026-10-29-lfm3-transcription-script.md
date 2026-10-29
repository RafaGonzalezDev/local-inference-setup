# 2026-10-29 - Script de transcripción para LFM3

**Qué**: `experimental/lfm3/scripts/Transcribe-Audio.ps1` (con `transcribe-audio.cmd` para abrirlo con
doble clic y un selector de archivo) transcribe un audio o vídeo con `lfm3-audio-2b` o `lfm3-omni-2b`
ya arrancados. Convierte la entrada a WAV de 16 kHz mono con ffmpeg y la envía en tramos de unos 30 s
cortados en la pausa más cercana.

**Por qué**: en la Web UI de llama.cpp el audio llegaba al modelo, pero la interfaz le ofrece sus
herramientas integradas y LFM3-Audio llamaba a `get_datetime` en vez de responder. Además, descarta sin
avisar los audios con un tipo MIME que no reconoce (`.m4a`, `.flac`). El usuario prefiere no depender de
la Web UI. Los tramos son necesarios porque una sola petición con 135 s de audio perdió un tercio del
texto, con `finish_reason: stop`.

**Validación** (con `lfm3-audio-2b` sobre `b11981` y audio en español generado con su propio TTS):

- 135 s en MP3: 369 palabras frente a 375 de referencia (la diferencia son números escritos en cifras),
  en 3 s. Los cortes en pausas internas añaden a veces un punto («12%. Respecto»).
- 45 s dentro de un MP4 con vídeo y en M4A: 123 de 125 palabras.
- Sin probar: el selector de archivo (necesita interacción), audio real con ruido o varias voces, y
  Omni.
