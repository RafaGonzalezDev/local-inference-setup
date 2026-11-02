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
   modelo no puede llamar a ninguna. Límite de 1.024 tokens de salida (el párrafo esperado ronda 400);
   avisa si la respuesta se corta.
4. `/exit` o `Ctrl+C` detienen el servidor y todo su árbol de procesos. Si se cierra la ventana, el
   servidor comparte la consola y termina con ella.

Requiere PowerShell 7 (`pwsh`). Para otra tarea, añade un `.md` en `instructions\` y un `.cmd` que lo pase. Usa `/exit` para
salir: con `Ctrl+C`, `cmd` pregunta además si terminar el proceso por lotes.

`qwen-image-2.1.md` convierte una idea breve, en cualquier idioma, en un prompt en inglés siguiendo las
pautas de Qwen Image 2.1: describe la imagen región por región, con luz y composición, sin
potenciadores de calidad ni relación de aspecto. Trata todo mensaje como una idea de imagen.

## Modelo: `occult-nail-1.0-35b-a3b`

El mismo GGUF del catálogo principal (`..\models\occult-nail-1.0-35b-a3b\Occult-Nail-1.0-35B-A3B-UD-Q4_K_XL.gguf`,
22.360.465.312 bytes, revisión `3fdd9b72fc54083a6c8959b259011366a0b1571b`); su ficha es
[occult-nail-1.0-35b-a3b.md](../docs/overview/models/occult-nail-1.0-35b-a3b.md). El manifiesto de esta
raíz declara solo ese archivo (sin proyector) con `RelativeDirectory = '..\models\...'`. Es una variante
de Qwen3.6-35B-A3B (MoE, ~3B parámetros activos) sin rechazos.

### Perfil `agentic-cpu-8k-1024`

Alias `occult-nail-1.0-35b-a3b,occult-nail-1.0-35b-a3b-cpu-8k`.

- Solo CPU, para convivir con el modelo de imagen en la GPU: `--device none --gpu-layers 0 --fit off`
  (sin `--fit-target` ni `--split-mode`). 8 hilos, uno por núcleo físico; sin medir frente a 6.
- Contexto 8.192: cada petición es independiente y ocupa menos de 2K tokens (instrucciones ~800, la idea
  y hasta 1.024 de respuesta). Menos caché KV reservada en RAM.
- `--reasoning off`, sin presupuesto: reescribir un prompt no necesita razonar, y con razonamiento LFM3
  generó ~4.800 tokens para un párrafo de ~400.
- `127.0.0.1:8081`: solo lo usa el asistente local y puede convivir con un perfil del catálogo en 8080.
- Muestreo de los perfiles principales de Occult Nail (`--temp 0.6 --top-p 0.95 --top-k 20 --min-p 0`, sin
  penalizaciones; valores de Qwen3.6, la tarjeta no publica ninguno).

Estimación sin medir: ~23–24 GB de RAM (con 37,4 GB libres el 2026-11-02 y el modelo de imagen cargado),
15–25 t/s de generación (ancho de banda de memoria: LFM3 1.7B Q6 midió 33 t/s en esta CPU) y prefill
lento la primera vez; el prefijo de instrucciones se reutiliza en las siguientes peticiones.

## Historial

- 2026-11-02: primero se usó `lfm3-1.7b-uncensored` (`AtomicChat/LFM3-1.7B-Uncensored-GGUF`, `AD-Q6_K`).
  Generaba prompts incoherentes (un hipopótamo con pelaje, sentado en el aro mientras jugaba) y se
  sustituyó el mismo día por Occult Nail; sus pesos se borraron. Ver el
  [changelog](../docs/changelog/2026-11-02-experimental-lfm3-1.7b-uncensored.md).

## Validación (2026-11-02)

- `Test-ModelIntegrity.ps1 -RootDirectory` 1/1 y `Test-Llm.ps1 -ConfigurationOnly -RequireInstalledFiles
  -RootDirectory` 1/1.
- `Start-Assistant.ps1`: sin errores de sintaxis; resolución de instrucciones probada sin arrancar el modelo.
- Sin probar con Occult Nail: arranque en CPU, RAM, velocidad, que la plantilla respete el prompt de
  sistema propio y calidad. `DeferredInference = $true` en el manifiesto.
