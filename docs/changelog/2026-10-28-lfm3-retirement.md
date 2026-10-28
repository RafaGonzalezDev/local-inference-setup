# 2026-10-28 - Retirada de los modelos LFM3 y del runtime compilado

**Qué**: se eliminan `lfm3-1.7b`, `lfm3-audio-2b` y `lfm3-omni-2b` (LiquidAI, `Q8_0` y proyectores
`Q8_0`) y el runtime `19ff817-cuda13.4`, compilado desde el código fuente de llama.cpp para
ejecutarlos. El catálogo vuelve a 7 modelos y 18 perfiles sobre `b11669-cuda13.4`.

**Por qué**: decisión del usuario tras probarlos todos: los considera demasiado flojos para su uso.

## Eliminado

- Pesos: `models/lfm3-1.7b` y, con `experimental/lfm3`, los de Audio y Omni (unos 5,6 GB).
- Runtime `runtimes/llama.cpp/19ff817-cuda13.4`, su archivo de hashes y la copia del código fuente y del
  registro de compilación en `packages/llama.cpp/19ff817` (unos 1,4 GB).
- `experimental/lfm3` completo (catálogo, manifiestos, lanzadores, documentación y registros).
- `config/models/lfm3-1.7b.psd1`, `scripts/models/lfm3-1.7b/`, `scripts/setup/Build-LlamaRuntime.cmd`,
  `docs/overview/models/lfm3-1.7b.md` y la entrada de `config/catalog.psd1`.
- Clientes: la entrada `lfm3-1.7b-262k` de DSH (repositorio y configuración global), los cinco
  `opencode.json`, el catálogo de Pi y los clientes activos de WSL.

## Se conserva

- `scripts/common/Test-Llm.ps1 -RootDirectory`, añadido durante este trabajo; no tiene otro uso ahora.
- La regla de AGENTS.md que permite compilar llama.cpp desde un commit o PR avisando al usuario y
  registrando commit, toolchain y SHA-256.
- El historial: los manifiestos con revisión y SHA-256, los lanzadores, la ficha, el script de
  compilación y el registro de runtime siguen en el historial git de `local-inference-setup`. Los
  registros de `logs/validation/` de las pruebas no se han tocado.
- Datos de referencia: runtime compilado desde el commit `19ff817fb25e9a1b838b1d7f9f4325f7bf9779c4`
  (fusión de la PR #31257 de llama.cpp; la arquitectura `lfm3` llegó con la PR #31252) con MSVC
  19.44.35222.0 y CUDA 13.4.59.

## Verificación

Ver el cierre de la sesión: validación estática sin filtros y paridad de alias en todos los catálogos.
