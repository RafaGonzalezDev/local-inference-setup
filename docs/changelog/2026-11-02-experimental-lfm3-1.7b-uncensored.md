# 2026-11-02 - `experimental/` con LFM3 1.7B Uncensored y asistente de terminal

**Qué**: vuelve `experimental/` como raíz aparte con `lfm3-1.7b-uncensored`
(`AtomicChat/LFM3-1.7B-Uncensored-GGUF`, `AD-Q6_K`, revisión `3ad712542eb9de349dbd28f2739b69c925cdec7d`),
un perfil solo CPU de 32K (`agentic-cpu-32k-1024`, `127.0.0.1:8081`) y `Start-Assistant.cmd` (con su
`Start-Assistant.ps1`), que arranca el
modelo al abrirse, responde cada prompt con un fichero de instrucciones, copia la respuesta al
portapapeles y detiene el modelo al salir. Incluye `instructions/qwen-image-2.1.md` para escribir prompts
de Qwen Image 2.1.

**Por qué**: lo pidió el usuario. El modelo no entra en el catálogo principal ni en Pi, OpenCode o DSH, y
debe ejecutarse entero en CPU.

**Dónde**: `experimental/` (README, `config/`, `scripts/models/lfm3-1.7b-uncensored/`, `instructions/`,
`Start-Assistant.ps1`; sin espejar `models/` ni `logs/`) y `README.md`.

## Decisiones

- Reutiliza `runtimes/llama.cpp/b11981-cuda13.4` del catálogo principal mediante `%LLM_ROOT%\..`, en vez
  de copiarlo como en 2026-10-29. `Test-Llm.ps1` normaliza la ruta, así que el validador la acepta.
- `instructions/qwen-image-2.1.md` resume la skill de prompts de Qwen Image 2.1 de WSL (`~/SKILL.md`) para
  un modelo de 1,7B: solo texto a imagen, reglas numeradas y cortas, 200–300 palabras en vez de 400–500 y
  salida en un único párrafo sin JSON ni `wh_ratio`, para copiarlo directamente.
- Contexto 32K y no el nativo 262K: una petición del asistente ocupa unos 10K tokens y el resto solo
  reservaría caché KV. El primer perfil de este mismo día usaba 262K.
- Detalle del perfil y del asistente en [experimental/README.md](../../experimental/README.md).

## Validación

- Descarga verificada por tamaño y SHA-256; integridad 1/1 y estática con `-RequireInstalledFiles` 1/1 en
  `experimental`; estática sin filtros del catálogo principal sin cambios.
- No se lanzó el modelo, por indicación del usuario: ni smoke, ni RAM, ni velocidad, ni el flujo completo
  del asistente.

## Ajustes tras el primer uso

- La primera petición real generó unos 4.800 tokens (5.663 en total, ~33 t/s en CPU) para un párrafo de
  ~400. El perfil pasa a `--reasoning off` sin presupuesto y el asistente limita la salida a 1.024 tokens
  y avisa si se corta. Solo texto: el asistente no declara herramientas.

## Sustitución por Occult Nail (mismo día)

- Los prompts de LFM3 1.7B eran incoherentes: un hipopótamo con pelaje, de pie y sentado en el aro a la
  vez, materiales forzados y la regla de edad de personas aplicada a un animal.
- Se sustituye por `occult-nail-1.0-35b-a3b` con un perfil solo CPU de 8K (`agentic-cpu-8k-1024`, alias
  `occult-nail-1.0-35b-a3b-cpu-8k`) que reutiliza el GGUF del catálogo principal: el manifiesto de
  `experimental` usa `RelativeDirectory = '..\models\occult-nail-1.0-35b-a3b'` y solo declara el modelo.
  Muestreo de los perfiles principales y `--reasoning off`.
- Se borran de `experimental` el manifiesto, el lanzador y los pesos de LFM3 (1,6 GB; reinstalables con la
  revisión y el SHA-256 fijados arriba).
- Validación: integridad 1/1 y estática con `-RequireInstalledFiles` 1/1. Sin lanzar el modelo: RAM
  (~23–24 GB estimados), velocidad y calidad pendientes.

## Instrucciones detalladas, NSFW y medición

- `qwen-image-2.1.md` pasa a la especificación completa de la skill de WSL (8 pasos y reglas estrictas,
  400–500 palabras), con coherencia física, contenido adulto explícito permitido (también anime) y un
  límite fijo: menores, rasgos infantiles o personas reales responden `Request not allowed.`
  Termina con una sección de precedencia frente al mensaje de concisión de Nail que añade la plantilla.
- El asistente sube el límite de salida a 1.536 tokens.
- Medido con el modelo de imagen cargado en la GPU: carga en 11 s, 22,6 GB de RAM, 16,8 t/s de generación,
  21–26 s por respuesta con el prefijo en caché (43 s la primera). Detalle en
  [experimental/README.md](../../experimental/README.md#validación-2026-11-02). `DeferredInference` pasa a
  `$false`.

## Sustitución por Gemma 4 26B A4B (mismo día)

- Prueba de una petición en CPU a 8K: 15,7 t/s frente a 16,8 de Occult Nail, 18,0 GB de RAM frente a 22,6
  y un prompt coherente de 305 palabras. El usuario la elige por redactar mejor.
- `experimental` pasa a `gemma-4-26b-a4b-uncensored-balanced` (perfil `agentic-cpu-8k-1024`, alias
  `gemma-4-26b-a4b-uncensored-balanced-cpu-8k`), con el GGUF del catálogo principal y el muestreo de sus
  perfiles. Se quitan el manifiesto y el lanzador de Occult Nail (sus pesos siguen en el catálogo).
- Se elimina de las instrucciones la sección de precedencia: la plantilla de Gemma no añade mensaje propio.
- Validación: integridad 1/1 y estática 1/1. El lanzador nuevo no se ha arrancado; la medición se hizo con
  los mismos argumentos invocando el servidor directamente.
