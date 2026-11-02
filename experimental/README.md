# experimental

Raíz aparte de `D:\LLM`, fuera del catálogo principal y sin registrar en Pi, OpenCode ni DSH. Sigue la
misma estructura (`config/`, `scripts/models/`) para que los scripts del catálogo funcionen
con `-RootDirectory`, y reutiliza el runtime y los pesos del catálogo principal (`..\runtimes\`,
`..\models\`) sin copiarlos.

## Asistente de terminal

Doble clic en `Start-Assistant.cmd` (o ejecutarlo desde una terminal). Abre la interfaz en esa misma
ventana; si falla, la deja abierta para leer el error.

1. El fichero de instrucciones es el prompt de sistema y es obligatorio: `Start-Assistant.cmd` pasa
   `qwen-image-2.1` y `Start-Assistant.ps1 -Instructions <nombre>` lee `instructions\<nombre>.md` (la
   extensión es opcional). Solo acepta archivos de esa carpeta.
2. Comprueba que el puerto 8081 está libre, arranca el lanzador del modelo en segundo plano (log en
   `logs\server-<fecha>.log`) y espera a `/health`.
3. Cada línea escrita es una petición independiente (sin historial): instrucciones + prompt. Muestra la
   respuesta y la copia al portapapeles. Solo texto: la petición no declara herramientas, así que el
   modelo no puede llamar a ninguna. Límite de 1.536 tokens de salida (la descripción pedida ronda 700);
   avisa si la respuesta se corta.
4. `/exit` o `Ctrl+C` detienen el servidor y todo su árbol de procesos. Si se cierra la ventana, el
   servidor comparte la consola y termina con ella.

Requiere PowerShell 7 (`pwsh`). Para otra tarea, añade un `.md` en `instructions\` y un `.cmd` que lo pase. Usa `/exit` para
salir: con `Ctrl+C`, `cmd` pregunta además si terminar el proceso por lotes.

`qwen-image-2.1.md` convierte una idea breve, en cualquier idioma, en un prompt en inglés siguiendo las
pautas de Qwen Image 2.1: describe la imagen región por región, con luz y composición, sin
potenciadores de calidad ni relación de aspecto. Sigue los 8 pasos y las reglas de la skill de WSL
(`~/SKILL.md`), sin las partes de edición ni de parámetros de generación, y añade reglas de coherencia
física. Trata todo mensaje como una idea de imagen. Admite desnudos y contenido sexual explícito entre
adultos, también en estilo anime; con menores, rasgos infantiles o personas reales responde solo
`Request not allowed.`

## Modelo: `gemma-4-26b-a4b-uncensored-balanced`

El mismo GGUF del catálogo principal
(`..\models\gemma-4-26b-a4b-uncensored-balanced\Gemma4-26B-A4B-QAT-Uncensored-HauhauCS-Balanced-Q4_K_M.gguf`,
16.796.015.520 bytes, revisión `f9093662a2e7ae0503f637088bc96f77a1a70c83`); su ficha es
[gemma-4-26b-a4b-uncensored-balanced.md](../docs/overview/models/gemma-4-26b-a4b-uncensored-balanced.md).
El manifiesto de esta raíz declara solo ese archivo (sin proyector) con `RelativeDirectory = '..\models\...'`.
Es la variante sin rechazos de HauhauCS de Gemma 4 26B A4B (MoE, ~4B parámetros activos).

### Perfil `agentic-cpu-8k-1024`

Alias `gemma-4-26b-a4b-uncensored-balanced,gemma-4-26b-a4b-uncensored-balanced-cpu-8k`.

- Solo CPU, para convivir con el modelo de imagen en la GPU: `--device none --gpu-layers 0 --fit off`
  (sin `--fit-target` ni `--split-mode`). 8 hilos, uno por núcleo físico; sin medir frente a 6.
- Contexto 8.192: cada petición es independiente y ocupa unos 2.900–4.100 tokens (instrucciones ~2.500 con
  la plantilla, la idea y hasta 1.536 de respuesta). Menos caché KV reservada en RAM.
- `--reasoning off`, sin presupuesto: reescribir un prompt no necesita razonar, y con razonamiento LFM3
  generó ~4.800 tokens para un párrafo de ~400.
- `127.0.0.1:8081`: solo lo usa el asistente local y puede convivir con un perfil del catálogo en 8080.
- Muestreo de los perfiles principales de este modelo (`--temp 0.6 --top-p 0.9 --top-k 64 --min-p 0.05
  --repeat-penalty 1.1`, de la tarjeta).
- La plantilla no añade ningún mensaje de sistema propio: el fichero de instrucciones llega tal cual.

## Historial (2026-11-02)

- Primero `lfm3-1.7b-uncensored` (`AtomicChat/LFM3-1.7B-Uncensored-GGUF`, `AD-Q6_K`): prompts incoherentes
  (un hipopótamo con pelaje, sentado en el aro mientras jugaba); se borraron sus pesos.
- Después `occult-nail-1.0-35b-a3b` en CPU a 8K: coherente, 16,8 t/s y 22,6 GB de RAM, pero su plantilla
  añade el mensaje de concisión de Nail tras el prompt de sistema
  (`logs/validation/functional-occult-nail-cpu-8k-20261102-012604.json`).
- Gemma 4 26B A4B lo sustituye a elección del usuario, que la prefiere redactando. Detalle en el
  [changelog](../docs/changelog/2026-11-02-experimental-lfm3-1.7b-uncensored.md).

## Validación (2026-11-02)

- `Test-ModelIntegrity.ps1 -RootDirectory` 1/1 y `Test-Llm.ps1 -ConfigurationOnly -RequireInstalledFiles
  -RootDirectory` 1/1.
- `Start-Assistant.ps1`: sin errores de sintaxis; resolución de instrucciones probada sin arrancar el modelo.
- Una petición con los mismos argumentos que el perfil, antes de crear el lanzador, con el modelo de imagen
  cargado en la GPU (`logs/validation/functional-gemma-4-26b-cpu-8k-20261102-013223.json`):
  - Carga en 11,6 s; RAM del proceso 18,0 GB (privada); el puerto quedó libre al cerrar.
  - 2.538 tokens de prompt a 86,8 t/s; 363 tokens generados a 15,7 t/s, sin razonamiento; 52 s en total.
    Con el prefijo en caché, las siguientes deberían rondar 23–25 s (estimación).
  - Idea "un hipopótamo jugando al baloncesto": 305 palabras, coherente (piel gris rosada sin pelo, una
    sola acción, posiciones únicas, luz y sombras consistentes).
- Sin probar con el lanzador ni el asistente reales: varias peticiones, contenido adulto, anime, el caso
  `Request not allowed.`, longitud de 400–500 palabras (305 en la prueba) y generación simultánea con el
  modelo de imagen.
