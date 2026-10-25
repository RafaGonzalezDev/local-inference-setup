# 2026-10-22 - Desinstalar el runtime b11269

**Qué**: Se elimina `runtimes\llama.cpp\b11269-cuda13.4` (745,6 MB). Se envió a
la Papelera de reciclaje, no se borró de forma permanente.

**Dónde**: `runtimes\llama.cpp\`, `README.md`, `AGENTS.md` y
`docs\overview\inference-backend.md`.

**Por qué**: Los 31 lanzadores fijan `b11551-cuda13.4` en su `SERVER`; ninguna
ruta de `scripts\` ni `config\` resolvía a `b11269-cuda13.4`, que se conservaba
solo como opción de rollback.

## Estado

- Único runtime instalado: `runtimes\llama.cpp\b11551-cuda13.4`.
- `Install-LlamaRuntime.ps1` mantiene `-Version b11269` con sus SHA-256, y la
  caché verificada `packages\llama.cpp\b11269` (577,1 MB) se conserva, así que el
  rollback sigue siendo posible sin volver a descargar.

## Validación

- Antes de eliminar se comprobó que la ruta estaba dentro de
  `D:\LLM\runtimes\llama.cpp\`, que no era un punto de reanálisis y que ningún
  proceso en ejecución usaba esa carpeta.
- `Test-Llm.ps1 -ConfigurationOnly -RequireInstalledFiles` tras la eliminación.

## Nota posterior

Tras el alta de `flint` el mismo día (commit `b556c82`), quedaron instalados `b11551-cuda13.4` y
`b11827-cuda13.4`. Ver `docs/changelog/2026-10-22-flint.md`.
