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

## Cambio posterior del mismo día

- `transcribe-audio.cmd` arranca `lfm3-audio-2b` en su misma ventana si no hay servidor en el puerto
  8080 y lo para al cancelar el selector. Al cerrar la ventana, Windows termina también el servidor,
  porque comparte la consola. Reutiliza sin pararlo un servidor ya arrancado que admita audio.
- Pide archivos en bucle y guarda cada transcripción junto al audio como `<nombre>.transcript.txt`
  (sin sobrescribir), en párrafos con su marca de tiempo, y la abre en el editor predeterminado.
- Los tramos se cortan en la pausa más larga de su segunda mitad. Si un tramo empieza a mitad de
  frase, el resto de esa frase se añade al párrafo anterior.
- Probado: arranque, transcripción y parada con `-Path` (135 s de audio, 6 s en total, puerto y GPU
  libres al terminar), reutilización de un servidor existente y cancelación del selector. El cierre de
  la ventana coincidió con una cancelación y el log no permite saber cuál de los dos paró el servidor.
