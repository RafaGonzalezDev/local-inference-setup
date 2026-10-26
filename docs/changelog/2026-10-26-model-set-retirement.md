# 2026-10-26 - Tiel Coder pasa a IQ4_XS y se retiran diez modelos

**Qué**:

- `tiel-coder-35b-a3b-mtp` sustituye `UD-Q4_K_XL` por `UD-IQ4_XS` de
  `peculiar-ragdoll/Tiel-Coder-35B-A3B-GGUF-MTP` (revisión `bb5f3f441849fc24c2d9037c310bc995404bfa0c`).
  Conserva el ID, los alias y el proyector, que no cambió entre revisiones.
- Se retiran `tiel-coder-35b-a3b` (sin MTP), `gemma-4-12b-v2`, `gemma-4-26b-a4b`, `ornith-1.5-9b`,
  `nemotron-3.5-lightning-30b-a3b`, `ling-3.0-tiny`, `swift-1.5-qwen3.8-27b-gsq-rco-mtp`,
  `minicpm-v-4.7-35b-a3b`, `flint` y `sage-a1.5-35b-a3b`: catálogo, manifiestos, lanzadores, fichas y
  pesos.
- Se desinstala `runtimes/llama.cpp/b11827-cuda13.4` y su paquete, que solo usaba `flint`.
  `Install-LlamaRuntime.ps1 -Version b11827` puede reinstalarlo.

**Dónde**: `config/`, `scripts/models/`, `models/`, `runtimes/`, `packages/`, `README.md`, `AGENTS.md`,
`docs/overview/inference-backend.md`, `docs/overview/model-management.md` y
`docs/overview/models/tiel-coder-35b-a3b-mtp.md`.

**Por qué**: El usuario eligió qué modelos ya no usa. Las referencias de `AGENTS.md` a lanzadores
retirados (Gemma MTP con borrador externo y Swift denso) se sustituyen por perfiles activos. Los
lanzadores y fichas retirados siguen en el historial git de `local-inference-setup`.

## Validación

- `Test-ModelIntegrity.ps1 -Model tiel-coder-35b-a3b-mtp` pasa con `UD-IQ4_XS`.
- `Test-Llm.ps1 -ConfigurationOnly -RequireInstalledFiles` pasa sin filtros con los 7 modelos y 18 perfiles.
- Calibración de los tres perfiles de Tiel IQ4_XS; detalle en su ficha.
- Quedan en `models/` solo los artefactos que referencian los manifiestos activos.
