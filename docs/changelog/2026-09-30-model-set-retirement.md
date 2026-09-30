# 2026-09-30 - Retire three models and both secondary runtimes

**What**: Retire `mimo-v2.6-distill-qwen-9b`, `ternary-bonsai-2-27b` and
`qwen3.8-27b`, together with the two secondary runtimes that only they used:
official `b10964-cuda13.3` and the PrismML fork `prism-b10685-7dffb15-cuda13.3`.
The official `b10502-cuda13.3` is now the only installed runtime.

- The catalog drops from ten models to seven and from 26 launchers (Windows) to
  17. The WSL repository carried 24 before this change and also lands on 17,
  because its launcher set was already two MiMo vision profiles smaller.
- The three model cards are removed; the per-model changelog entries are kept as
  history, following the practice already applied to the retired Qwen3.6 35B A3B
  NVFP4 Fast entry.
- `Install-BonsaiRuntime.ps1` is deleted and `Install-LlamaRuntime.ps1` no longer
  offers `-Version b10964`: its `ValidateSet` and pinned `$releases` table now
  contain only `b10502`.
- `inference-backend.md` documents a single runtime instead of three.

**Where**: `config/catalog.psd1`, `config/models`, `scripts/models`,
`scripts/setup/Install-LlamaRuntime.ps1`,
`scripts/setup/Install-BonsaiRuntime.ps1`, `docs/overview/inference-backend.md`,
`docs/overview/model-management.md`, `docs/overview/models`, `README.md`,
`tests/Test-Mimo.ps1` and `docs/changelog`.

**Why**: Keep the declarative repository aligned with the deployment set that is
actually retained, and remove the last consumers of two runtimes whose only
purpose was to serve models that are no longer part of the catalog. With both
consumers gone, keeping a second official runtime and a third-party fork
installed had no remaining function.

## Deployment reconciliation

This change also reconciles pre-existing drift between the Windows deployment at
`D:\LLM` and this repository. The drift was bidirectional, so the newer side was
taken per file rather than by direction:

- **Taken from this repository, where it was newer:** `README.md`,
  `docs/overview/models/ling-3.0-tiny.md`, `docs/overview/inference-backend.md`,
  `scripts/common/Test-ModelIntegrity.ps1`, `scripts/setup/Download-Model.ps1` and
  `scripts/setup/Install-LlamaRuntime.ps1`. These carry the portable
  `$RootDirectory` derivation from `$PSScriptRoot` instead of a hardcoded
  `D:\LLM` default.
- **Taken from Windows, where it was newer:** `docs/overview/model-management.md`,
  whose launcher count the 2026-09-23 Ornith 1.5 9B entry already identified as
  the correct value, and `docs/changelog/2026-09-23-ornith-1.5-9b-q4-k-m.md`,
  which had not been mirrored yet.
- **Line-ending-only differences** (CRLF in Windows, LF here) in
  `config/catalog.psd1`, `config/models/ornith-1.5-9b.psd1`,
  `docs/overview/models/ornith-1.5-9b.md` and
  `docs/changelog/2026-08-27-reconcile-active-model-set.md` needed no content
  action. Every `.cmd` launcher was already byte-identical in both trees.
- The validation count in `model-management.md` is corrected from 26 (Windows) and
  21 (this repository, stale) to **17**, the value both trees now share.

## Data retirement

Weight removal is a separate operation from this declarative change, as
`model-management.md` states. The GGUF directories for the three models, the two
retired runtime directories and their packages in `packages\llama.cpp` were
deleted from the Windows deployment only; none of them is versioned here, so this
commit does not reference them.

**Validation**: Pending. The declarative catalog must report seven models and 17
launchers, and every remaining launcher must resolve its runtime and artifacts
under `-RequireInstalledFiles`.
