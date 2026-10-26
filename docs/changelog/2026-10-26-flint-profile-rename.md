# 2026-10-26 - Alinear la documentación de Flint con `agentic-auto-131k-1024`

**Qué**: El README y la ficha de `flint` pasan a nombrar el lanzador
`scripts\models\flint\start-agentic-auto-131k-1024.cmd`, que sustituyó a
`start-agentic-auto-131k-2048.cmd` el 2026-10-25 con `--batch-size 1024 --ubatch-size 1024`.

**Dónde**: `README.md` y `docs\overview\models\flint.md`.

**Por qué**: El lanzador desplegado ya usaba batch `1024` y la documentación seguía nombrando el de
`2048`. El motivo del cambio de batch no quedó registrado.

- El alias no cambia: `flint-131k`.
- El `-Profile` pasa a ser `agentic-auto-131k-1024`.
- Las mediciones 131K de la ficha son del lanzador anterior (`2048/2048`) y se marcan como tales.

## Validación

- `Test-Llm.ps1 -ConfigurationOnly -RequireInstalledFiles` sin filtros: 42/42 perfiles pasan.
- `Test-Llm.ps1 -Model flint -Profile agentic-auto-131k-1024` pasa (smoke de 16 tokens, no
  calibración).
