# 2026-10-29 - Resumen de audios con LFM3-Omni

**Qué**: `experimental/lfm3/scripts/Summarize-Audio.ps1`, con `summarize-audio.cmd` para abrirlo con
doble clic, resume en español en uno o dos párrafos un audio o vídeo elegido en un selector y escribe el
resultado en `scripts/SUMMARY.md`, que se reemplaza en cada uso. Si no hay servidor en el puerto 8080,
arranca `lfm3-omni-2b` en la misma ventana y lo para al cancelar el selector; al cerrar la ventana,
el servidor termina con ella.

**Por qué**: el usuario consideró pobre la calidad de la transcripción literal y prefiere un resumen. Se
retiró el transcriptor del mismo día (`Transcribe-Audio.ps1`; commits revertidos en el espejo).

## Decisiones

- El resumen se pide sobre el texto, no sobre el audio: con un prompt de resumen, Audio y Omni
  devolvían la transcripción de cada tramo. El script transcribe tramos de 30 s (una sola petición con
  135 s perdió un tercio del texto) y luego pide el resumen.
- Omni en lugar de Audio: Audio dejó un resumen cortado a media frase; Omni completó los dos casos.
- Sin marcas de tiempo, cortes en pausas ni reparación de frases: el resumen final hace innecesario
  cuidar los límites de los tramos.

## Validación

Con `lfm3-omni-2b` sobre `b11981`, arrancado y parado por el script en cada prueba (puerto y GPU libres
después):

- Reunión sintética de 135 s en MP3 (tres repeticiones del mismo texto): 117 palabras en un párrafo,
  sin repetir y con todos los datos, en 7 s.
- La misma reunión de 45 s dentro de un MP4: 116 palabras, en 3 s.
- Nota de voz real del usuario (OGG de WhatsApp, 5 tramos): un párrafo de 269 palabras, en 5 s. Su
  contenido no se revisó; en la prueba previa de la misma nota, el resumen arrastraba errores de
  reconocimiento y atribuía frases a hablantes inexistentes («la audiencia», «la mujer»).
- Sin probar: el cierre de la ventana como única causa de parada del servidor, y audios de más de unos
  minutos.
