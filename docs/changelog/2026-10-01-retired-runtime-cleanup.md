# 2026-10-01 - Retirar el runtime antiguo y la copia de lanzadores

**Qué**: Se eliminan del repositorio el runtime `b10502-cuda13.3`, la copia de
referencia `logs\reference\retired-launchers-20260930\` con los 17 lanzadores
manuales retirados el 2026-09-30, y los paquetes de instalación obsoletos
`packages\llama.cpp\b10502\` y `packages\llama.cpp\b10273\`.

| Elemento eliminado | Tamaño |
| --- | ---: |
| `runtimes\llama.cpp\b10502-cuda13.3` | 669,4 MB |
| `logs\reference\retired-launchers-20260930` (17 `.cmd`) | 22,2 KB |
| `packages\llama.cpp\b10502` | 512,9 MB |
| `packages\llama.cpp\b10273` | 512,5 MB |

**Dónde**: `runtimes\llama.cpp\`, `logs\reference\`, `packages\llama.cpp\`,
`README.md`, `docs\overview\inference-backend.md`, las siete model cards que
citaban la copia de referencia y
`docs\changelog\2026-09-30-retire-manual-launchers.md`.

**Por qué**: Los 20 lanzadores del catálogo fijan `b11269-cuda13.4` en su
`SERVER`, así que ninguna ruta resolvía ya a `b10502-cuda13.3`, que se conservaba
solo como opción de rollback. `Install-LlamaRuntime.ps1` declara
`ValidateSet('b11269')`, de modo que los paquetes `b10273` y `b10502` no eran
consumibles por el instalador y no podían reinstalar nada. El usuario renuncia
explícitamente al rollback porque tanto los lanzadores como el runtime actual
funcionan.

## Estado

- Único runtime instalado: `runtimes\llama.cpp\b11269-cuda13.4`.
- Único paquete de instalador: `packages\llama.cpp\b11269`, que
  `Install-LlamaRuntime.ps1` sigue reutilizando como caché verificada.
- `logs\reference\` conserva `gemma-4-26b-a4b`, `qwen3.6-35b-a3b` y
  `windows-initial-validation`, que son mediciones y no lanzadores retirados.

## Validación

- Antes de borrar se resolvió cada ruta absoluta y se comprobó que existiera,
  que estuviera dentro de `D:\LLM` y que no fuera un punto de reanálisis.
- `Test-Llm.ps1 -ConfigurationOnly -RequireInstalledFiles` pasa los 20
  lanzadores con el runtime y los artefactos presentes.
- No se eliminó ninguna entrada de changelog ni ningún ADR: la entrada del
  2026-09-30 registra ahora que su copia de referencia fue borrada.
