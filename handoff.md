# Handoff

Sesión del 2026-10-13 sobre el despliegue de modelos locales en `D:\LLM` (Windows, RTX 5080 16 GB,
64 GB de RAM, dos runtimes `llama.cpp` instalados). Este documento no repite lo que ya está en las
tarjetas, changelogs y README: los referencia por ruta.

## Next session focus

- Si se quiere cerrar la validación del cambio de runtime: ejecutar el barrido funcional completo
  (`Test-Llm.ps1` sin filtros) y, solo si se necesita, recalibrar los perfiles con margen documentado.
- Vigilar la próxima release estable de `llama.cpp`: si incluye el soporte de MiniCPM-V 4.7
  (PR #29416), promoverla como runtime único del catálogo y retirar la excepción del nightly.
- Opcional, fuera de alcance hasta ahora: proyector 4x de MiniCPM-V 4.7, tool calling con imagen y
  DSpark bajo el fork `tc-mb/llama.cpp-omni`.

## Current status

Hecho y verificado en esta sesión:

- **Modelo nuevo** `minicpm-v-4.7-35b-a3b` (Q4_K_M + proyector 16x) descargado, íntegro y con dos
  perfiles publicados: `agentic-auto-131k-2048`, `agentic-auto-262k-1024` y
  `agentic-auto-vision-131k-2048`. Detalles en
  [docs/overview/models/minicpm-v-4.7-35b-a3b.md](docs/overview/models/minicpm-v-4.7-35b-a3b.md).
- **Runtime del catálogo a `b11551`**: los 30 lanzadores apuntan a
  `runtimes\llama.cpp\b11551-cuda13.4`; `b11269-cuda13.4` sigue instalado para revertir y el
  instalador (`-Version b11269|b11551`, por defecto `b11551`) puede reinstalar cualquiera. Detalles y
  evidencia A/B en
  [docs/changelog/2026-10-13-llama-runtime-b11551-catalog.md](docs/changelog/2026-10-13-llama-runtime-b11551-catalog.md).
- **Validación estática global**: `Test-Llm.ps1 -ConfigurationOnly -RequireInstalledFiles` sin
  filtros → 30 lanzadores, 0 fallos, todos resolviendo el ejecutable de `b11551`.
- **Lista de modelos locales de DSH**: `~/.dsh/profiles/desktop/cordis.patch.yml` incluye ya los
  tres alias de perfil de MiniCPM-V 4.7 en la ruta `llama-cpp`; validado con un parse YAML y un diff
  contra el backup (34 líneas añadidas, 0 eliminadas).

Pendiente o no verificado (declarado, no asumido):

- **No** se ha repetido el barrido funcional de los 30 perfiles con `b11551`: el usuario detuvo ese
  barrido a propósito. Antes de detenerlo pasaron con el runtime nuevo
  `gemma-4-12b-v2/text-auto`, `gemma-4-12b-v2/vision-auto`, `gemma-4-26b-a4b/agentic-auto` y
  `gemma-4-26b-a4b/agentic-auto-vision`. El resto no se ha re-ejecutado.
- Las tablas de calibración de las tarjetas siguen siendo mediciones de `b11269`.
- El cambio en `cordis.patch.yml` requiere reiniciar el harness para que la GUI liste los modelos
  nuevos; no se ha reiniciado desde esta sesión.

## Key context

- Un solo perfil puede escuchar en `0.0.0.0:8080` (sin autenticación); comprobar el listener antes de
  arrancar y liberar el puerto y la GPU al terminar. `Ctrl+C` en la terminal del lanzador es el
  procedimiento normal; `Test-Llm.ps1` solo mata el árbol que inicia.
- `--fit` decide la colocación en cada arranque: depende de la memoria libre del escritorio, así que
  las tablas de VRAM son fotos de un momento, no cuotas.
- Hechos medidos con `b11551` en la misma carga (perfil `qwen3.6-35b-a3b/agentic-auto-131k-2048`,
  prompt de 728 tokens, 200 de salida): prefill 1.361,46 t/s (antes 1.060,75), decode 68,91 t/s
  (antes 70,04), carga hasta la caché KV 6,6 s (antes 16,1 s), búfer de cómputo +26/+32 MiB,
  colocación y KV idénticas.
- MiniCPM-V 4.7 a 131K y a 262K medido: decode 75,32 y 66,33 t/s; el perfil de 262K reserva
  2.720,00 MiB de caché KV a contexto completo (10 capas de atención completa, 10,88 KB por token).
- DSpark se probó y se retiró por regresión medida (aceptación 0,059; 3,29 t/s frente a 75,32 t/s).
  No reintroducir sin medir y sin resolver la colocación del borrador.
- `~/.dsh/profiles/desktop/cordis.patch.yml` está gestionado por `dotfiles-dsh`: una instalación de
  ese componente reemplaza el archivo entero y descarta filas no declaradas en el propio archivo. El
  backup de esta edición es
  `cordis.patch.yml.bak-20261013-212818-local-models` en el mismo directorio.
- Rutas de trabajo temporales de esta sesión (`$env:TEMP\dsh-calib.ps1`, `dsh-ab.ps1`,
  `dsh-tools.ps1`, `dsh-validate-models.js`) son instrumentos de medición, no entregables.

## Artifacts to reference

- [AGENTS.md](AGENTS.md): convenciones del directorio, contrato de lanzadores y estado de referencia.
- [README.md](README.md): tabla de modelos, perfiles, alias e instalación.
- [docs/overview/inference-backend.md](docs/overview/inference-backend.md): los dos runtimes
  instalados, paquetes, SHA-256 y qué perfiles usan cuál.
- [docs/overview/models/minicpm-v-4.7-35b-a3b.md](docs/overview/models/minicpm-v-4.7-35b-a3b.md):
  artefactos, perfiles, calibración, DSpark retirado y límites.
- [docs/changelog/2026-10-13-minicpm-v-4.7-35b-a3b.md](docs/changelog/2026-10-13-minicpm-v-4.7-35b-a3b.md),
  [docs/changelog/2026-10-13-minicpm-v-4.7-35b-a3b-262k.md](docs/changelog/2026-10-13-minicpm-v-4.7-35b-a3b-262k.md)
  y [docs/changelog/2026-10-13-llama-runtime-b11551-catalog.md](docs/changelog/2026-10-13-llama-runtime-b11551-catalog.md).
- [config/models/minicpm-v-4.7-35b-a3b.psd1](config/models/minicpm-v-4.7-35b-a3b.psd1) y
  [config/catalog.psd1](config/catalog.psd1).
- [scripts/setup/Install-LlamaRuntime.ps1](scripts/setup/Install-LlamaRuntime.ps1): versiones fijadas.
- Evidencia en `logs\validation\`: `ab-qwen-b11269-20261013-211946.*`, `ab-qwen-b11551-20261013-212010.*`,
  `calib-agentic-auto-*-20261013-*`, `tools-agentic-auto-131k-2048-20261013-210351.*` y los smokes
  `smoke-tests-20261013-*`.

## Suggested skills

- `ponytail` para cualquier cambio en este repositorio: el usuario trabaja con el diff más pequeño que
  resuelve el problema.
- `docs-structure` antes de añadir documentación, para colocar el contenido en el tipo de documento
  correcto.
- `handoff` si hay que reescribir este archivo al cerrar otra sesión.

## Open questions

- ¿Se completa el barrido funcional de los 27 perfiles restantes con `b11551`, o basta la validación
  estática más los cuatro smokes que pasaron?
- ¿Se promueve una release estable como runtime único cuando incluya MiniCPM-V 4.7, en lugar de
  mantener un nightly?
- ¿Se añade el proyector 4x (`mmproj-model-f16-4x.gguf`) como perfil de detalle, y un perfil de visión
  a 262K?
- ¿Se reintenta DSpark con contexto menor para darle sitio en VRAM al borrador, o se descarta hasta
  que exista soporte en el fork del autor?

## Verification steps

```powershell
# Estado de los runtimes y de los lanzadores
& .\runtimes\llama.cpp\b11551-cuda13.4\llama-server.exe --version
Select-String -Path .\scripts\models\*\*.cmd -Pattern 'b11269|b11551' | Group-Object { $_.Line -match 'b11551' }

# Validación estática global (no carga pesos)
powershell -NoProfile -ExecutionPolicy RemoteSigned -File scripts\common\Test-Llm.ps1 -ConfigurationOnly -RequireInstalledFiles

# Integridad del modelo nuevo
powershell -NoProfile -ExecutionPolicy RemoteSigned -File scripts\common\Test-ModelIntegrity.ps1 -Model minicpm-v-4.7-35b-a3b

# Prueba funcional de un perfil (secuencial, un solo perfil a la vez en el puerto 8080)
powershell -NoProfile -ExecutionPolicy RemoteSigned -File scripts\common\Test-Llm.ps1 -Model minicpm-v-4.7-35b-a3b -Profile agentic-auto-vision-131k-2048
```

```powershell
# Lista de modelos locales de DSH (debe listar 14 modelos en la ruta llama-cpp)
& 'C:\Program Files\nodejs\node.exe' -e "const YAML=require('C:/Users/rafat/.dsh/audit-dsh/extracted/dsh/node_modules/yaml');const fs=require('fs');const d=YAML.parse(fs.readFileSync('C:/Users/rafat/.dsh/profiles/desktop/cordis.patch.yml','utf8').replace(/!!js/g,''));const m=d.find(e=>e.id==='llm-pi-ai').config.providers['llama-cpp'].models;console.log(m.length, m.map(x=>x.id).join('\n'))"
```
