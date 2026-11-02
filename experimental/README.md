# experimental

Raíz aparte de `D:\LLM`, fuera del catálogo principal y sin registrar en Pi, OpenCode ni DSH. Sigue la
misma estructura (`config/`, `models/`, `scripts/models/`) para que los scripts del catálogo funcionen
con `-RootDirectory`, y reutiliza el runtime principal `..\runtimes\llama.cpp\b11981-cuda13.4` sin copiarlo.

## Asistente de terminal

Doble clic en `Start-Assistant.cmd` (o ejecutarlo desde una terminal). Abre la interfaz en esa misma
ventana; si falla, la deja abierta para leer el error. Acepta el nombre de las instrucciones como
argumento (`Start-Assistant.cmd qwen-image-2.1`).

1. Lee `instructions\<nombre>.md` (la extensión es opcional) como prompt de sistema. Solo acepta
   archivos de esa carpeta. Sin argumento usa el único `.md` que haya, o muestra un menú si hay varios.
2. Comprueba que el puerto 8081 está libre, arranca el lanzador del modelo en segundo plano (log en
   `logs\server-<fecha>.log`) y espera a `/health`.
3. Cada línea escrita es una petición independiente (sin historial): instrucciones + prompt. Muestra la
   respuesta, sin el razonamiento, y la copia al portapapeles.
4. `/exit` o `Ctrl+C` detienen el servidor y todo su árbol de procesos. Si se cierra la ventana, el
   servidor comparte la consola y termina con ella.

Requiere PowerShell 7 (`pwsh`). Para otra tarea, añade un `.md` en `instructions\`. Usa `/exit` para
salir: con `Ctrl+C`, `cmd` pregunta además si terminar el proceso por lotes.

`qwen-image-2.1.md` convierte una idea breve, en cualquier idioma, en un prompt en inglés siguiendo las
pautas de Qwen Image 2.1: describe la imagen región por región, con luz y composición, sin
potenciadores de calidad ni relación de aspecto. Trata todo mensaje como una idea de imagen.

## Modelo: `lfm3-1.7b-uncensored`

- Repositorio: `AtomicChat/LFM3-1.7B-Uncensored-GGUF`, revisión `3ad712542eb9de349dbd28f2739b69c925cdec7d`.
- Archivo: `LFM3-1.7B-Uncensored-AD-Q6_K.gguf`, 1.587.969.920 bytes, SHA-256
  `4a7d91c094b9a0f8ed094093f3a0eb3cfeeb46b9bd491e33115689fc5d658b22` (LFS de la API). Es la mayor de las
  dos cuantizaciones publicadas (`AD-Q6_K`, `AD-Q4_K_M`).
- Base: `LiquidAI/LFM3-1.7B` con la dirección de rechazo eliminada (LoRA de rango 1 integrada). Licencia
  LFM Open License v1.0. Arquitectura `lfm3`, contexto nativo 262.144, solo texto.

### Perfil `agentic-cpu-32k-1024`

Alias `lfm3-1.7b-uncensored,lfm3-1.7b-uncensored-cpu-32k`. Parte del lanzador de `lfm3-1.7b` con estos
cambios:

- Contexto 32.768 en vez del nativo 262.144: cada petición del asistente es independiente y necesita
  unos 10K tokens (instrucciones, prompt, hasta 8192 de razonamiento y la respuesta), así que el resto
  solo reservaría caché KV en RAM sin usarla.

- Solo CPU, a petición del usuario: `--device none --gpu-layers 0 --fit off` (sin `--fit-target` ni
  `--split-mode`). 8 hilos, uno por núcleo físico: los 6 del catálogo se midieron con la GPU haciendo el
  cómputo; aquí es una estimación sin medir.
- `127.0.0.1:8081`: solo lo usa el asistente local y puede convivir con un perfil del catálogo en 8080.
- Muestreo heredado de la tarjeta de LFM3 1.7B (`--temp 0.1 --top-k 50 --repeat-penalty 1.1`): la tarjeta
  de AtomicChat no publica ninguno. Razonamiento `auto` con presupuesto 8192, como el original.

## Validación (2026-11-02)

- Descarga verificada por tamaño y SHA-256; `Test-ModelIntegrity.ps1 -RootDirectory` 1/1.
- `Test-Llm.ps1 -ConfigurationOnly -RequireInstalledFiles -RootDirectory` 1/1.
- `Start-Assistant.ps1`: sin errores de sintaxis y rechazo de instrucciones inexistentes o fuera de su carpeta.
- Sin probar, por indicación del usuario: arranque del servidor en CPU, velocidad, uso de RAM, flujo
  completo del asistente y calidad de los prompts generados. `DeferredInference = $true` en el manifiesto.
