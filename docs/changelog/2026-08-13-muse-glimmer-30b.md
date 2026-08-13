# 2026-08-13 - Muse Glimmer 30B

**What**: Added the Muse Glimmer 30B model with independent UD-Q4_K_XL and
UD-Q3_K_XL agentic launchers.

**Where**: `config\catalog.psd1`, `config\models`, `scripts\models`, the
launcher validation count, `README.md`, and the Muse Glimmer model card.

**Why**: The two requested quantizations need reproducible Windows launchers
and integrity-pinned downloads while vision and DFlash remain deferred.

**Validation**: Both GGUF artifacts are pinned to the same Hugging Face
revision and SHA-256 values recorded in the manifest. The launchers use the
official CUDA 13.3 runtime, 131,072-token context, Q8 KV cache, and the shared
`muse-glimmer-30b` API alias.
