# 2026-08-21 - Model catalog expansion and launcher synchronization

**What**: The active Windows catalog now contains seven supported model
families and 17 self-contained profiles: the two Gemma 4 variants,
Qwen3.6-35B-A3B (3 profiles), Qwen3.8-27B (3 profiles), Ornith 1.5-35B-A3B
(1 profile), Ornith 1.5-9B (1 profile), and Nemotron 3.5 Lightning 30B A3B
(1 profile).

**Where**: `config\catalog.psd1`, `config\models`, `scripts\models`,
`README.md`, the overview guides, and the model cards.

**Why**: Align the declarative repository with the current Windows source
tree. Three new models (Ornith 1.5-35B-A3B, Ornith 1.5-9B, Qwen3.8-27B) are
added with their launchers, manifests, and documentation. Qwen3.6-35B-A3B
launchers are replaced with the three Windows variants
(`agentic-131k-2048`, `agentic-mtp-131k-2048`, `agentic-vision-131k-2048`),
removing the eight legacy repo-only scripts. All llama.cpp runtime references
are updated to `b10502-cuda13.3`. Presence penalty is set to 0 across all
agentic profiles to allow natural token repetition in coding workloads.

**Validation**: The catalog contains seven manifests and the launcher inventory
contains 17 profiles. Configuration validation and integrity checks cover only
the supported set.
