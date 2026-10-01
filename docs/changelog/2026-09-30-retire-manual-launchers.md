# 2026-09-30 - Retire the hand-tuned launchers and keep only automatic placement

## 2026-09-30 - Remove the seventeen manual launchers

**What**: Retire every launcher that pinned its device placement by hand, so the
catalog keeps only the automatic profiles that delegate to the runtime through
`--fit`:

- `gemma-4-12b-v2`: `start-text.cmd`, `start-vision.cmd`.
- `gemma-4-26b-a4b`: `start-text.cmd`, `start-text-mtp.cmd`, `start-vision.cmd`,
  `start-vision-mtp.cmd`, `start-agentic.cmd`, `start-agentic-vision.cmd`.
- `qwen3.6-35b-a3b`: `start-agentic-131k-2048.cmd`,
  `start-agentic-262k-1024.cmd`, `start-agentic-mtp-131k-2048.cmd`,
  `start-agentic-vision-131k-2048.cmd`.
- `ornith-1.5-35b-a3b`: `start-agentic-131k-2048.cmd`,
  `start-agentic-262k-1024.cmd`.
- `nemotron-3.5-lightning-30b-a3b`: `start-agentic-131k-2048.cmd`.
- `ling-3.0-tiny`: `start-agentic-262k-1024.cmd`.
- `ornith-1.5-9b`: `start-agentic-262k-1024.cmd`.

The launcher count drops from 34 to 17 (17 manual + 17 automatic → 17 automatic).
No model, manifest, artifact or profile of the automatic set is otherwise
modified: context, batch, ubatch, sampling, alias, port, `--fit-target` and the
MTP and vision settings of the surviving launchers keep their values.

The retired files were preserved as a reference copy under
`logs\reference\retired-launchers-20260930\<model-id>\`, following the existing
practice of keeping historical material in `logs\reference`. That copy was
deleted on 2026-10-01; see
[the retired-runtime cleanup](2026-10-01-retired-runtime-cleanup.md).

**Where**: `scripts/models/` for the seven models, `README.md`, the seven model
cards under `docs/overview/models`, `docs/overview/inference-backend.md`,
`docs/overview/model-management.md`, `docs/overview/adding-a-model.md` and
`docs/changelog`.

**Why**: With both placements available, the automatic set was the one used in
practice, and the manual profiles kept a second configuration per model that had
to be updated in parallel on every change of runtime, model or context. Removing
them leaves a single placement policy per profile and one lever — `--fit` — to
reason about, without deleting the measurements recorded in the model cards and
the changelog.

## Consequences

- `--n-cpu-moe` disappears from the catalog. `--fit` places the weights with a
  per-layer `-ot` override and offloads a trailing span of layers, so the exact
  distribution of the retired profiles is no longer reproducible from the
  launchers alone; the recorded `llama-fit-params.exe` estimates and the WDDM
  measurements stay in the model cards as history.
- The context must stay declared in every launcher. `--fit` only adjusts unset
  arguments, and an omitted `--ctx-size` resolves to `--fit-ctx`, 4096 tokens.
- Nothing else changes in `config/`: all seven models remain in the catalog and
  every artifact declared in a manifest is still referenced by at least one
  surviving launcher, so the `Test-Llm.ps1` reference check keeps passing.

## Validation

- `Test-Llm.ps1 -ConfigurationOnly` reports 17 of 17 launchers passing.
- No artifact of any manifest is left unreferenced, and no model directory is
  left without launchers.
- The seventeen retired files were byte-identical to the copies under
  `logs\reference\retired-launchers-20260930\`, which were deleted on 2026-10-01.
- Functional validation of the surviving automatic profiles is still pending and
  belongs to a later session: no server was started and no inference was run for
  this change.
