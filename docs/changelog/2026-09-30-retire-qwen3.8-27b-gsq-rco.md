# 2026-09-30 - Retire Qwen3.8 27B GSQ-RCO

## 2026-09-30 - Remove `qwen3.8-27b-gsq-rco` from the catalog

**What**: Retire `qwen3.8-27b-gsq-rco` completely: its three launchers, its
manifest, its catalog entry and its model card. The catalog drops from eight
models to seven, and the launcher count from 37 to 34. The 24,82 GB of installed
weights are removed as a separate data-retirement operation, following the
procedure in `model-management.md`.

The removal covers:

- `scripts/models/qwen3.8-27b-gsq-rco/`, with `start-agentic-262k-1024.cmd`,
  `start-agentic-mtp-32k-1024.cmd` and `start-agentic-vision-32k-1024.cmd`.
- `config/models/qwen3.8-27b-gsq-rco.psd1`.
- The identifier in `config/catalog.psd1`.
- `docs/overview/models/qwen3.8-27b-gsq-rco.md`.
- Their artifacts under `models/qwen3.8-27b-gsq-rco/`:
  `Qwen3.8-27B-GSQ-RCO-IQ3_S.gguf` (11.771.546.784 bytes),
  `mtp/Qwen3.8-27B-GSQ-RCO-IQ3_S-mtp.gguf` (12.120.016.960 bytes) and
  `mmproj-Qwen3.8-27B-BF16.gguf` (931.146.528 bytes), 24.822.710.272 bytes in
  total.

**Where**: `config/catalog.psd1`, `config/models`,
`docs/overview/models/qwen3.8-27b-gsq-rco.md`, `README.md`,
`docs/overview/inference-backend.md`, `docs/overview/model-management.md`,
`scripts/models/qwen3.8-27b-gsq-rco` and `models/qwen3.8-27b-gsq-rco`.

**Why**: The model's output did not meet the bar, so it stops being part of the
retained set. Keeping a profile set whose only purpose was to serve a rejected
model would leave the catalog aligned with a deployment set that no longer
exists.

## Consequences

- `inference-backend.md` no longer names this model as the delegated-placement
  exception. That role now belongs to the `*-auto*` profiles across the catalog,
  which were added in the same session.
- The `--n-cpu-ffn` lever was the original justification for updating the runtime
  to `b11269`, because it was aimed at this dense model. With the model gone, no
  catalog profile uses it. `b11269-cuda13.4` is retained because the `*-auto*`
  profiles depend on its `--fit` and `-ot` semantics, on `--gpu-layers auto` and
  on `--spec-draft-ngl auto`, none of which exist in `b10502-cuda13.3`.
- The two changelog entries that reference the retired model are kept as history
  and were not rewritten, following the practice already applied to the retired
  Qwen3.6 35B A3B NVFP4 Fast and MiMo entries: `2026-08-20-qwen3.8-27b.md` and
  `2026-09-30-qwen3.8-auto-placement.md`. The latter describes launchers that no
  longer exist and is superseded by this entry.

## Validation

- `Test-Llm.ps1 -ConfigurationOnly` and `Test-Llm.ps1 -ConfigurationOnly
  -RequireInstalledFiles` both report 34 of 34 launchers passing, with the
  catalog reporting seven models.
- `config/catalog.psd1` keeps its CRLF line endings and no BOM.
- The remaining 17 manual launchers of the other seven models keep their previous
  modification time and content.
- Data retirement moved the four paths to the Recycle Bin rather than deleting
  them permanently. Functional validation is not applicable to a removal; no
  server was started.
