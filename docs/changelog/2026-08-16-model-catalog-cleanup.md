# 2026-08-16 - Supported model catalog cleanup

**What**: The active Windows catalog now contains four supported model
families and 17 self-contained profiles: the two Gemma 4 variants,
Qwen3.6-35B-A3B, and Nemotron 3.5 Lightning 30B A3B.

**Where**: `config\catalog.psd1`, `config\models`, `scripts\models`,
`README.md`, the overview guides, and the model cards.

**Why**: Keep the deployment directory and the declarative repository aligned
with the supported local-inference set while removing obsolete operational
paths and specialized runtime support.

**Validation**: The catalog contains four manifests and the launcher inventory
contains 17 profiles. Configuration validation and integrity checks cover only
the supported set.
