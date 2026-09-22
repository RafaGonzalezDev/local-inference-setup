## 2026-09-23 — MiMo vision removal

**What**: Remove the vision projector (`mmproj`) from the MiMo config manifest and delete the two vision launcher scripts (`start-agentic-vision-131k-1024.cmd`, `start-agentic-vision-262k-1024.cmd`). Update the model card, README, and `docs/overview/local-models.md` to reflect that MiMo is now text-only in the Pi client catalog.

**Where**: `config/models/mimo-v2.6-distill-qwen-9b.psd1`, `scripts/models/mimo-v2.6-distill-qwen-9b/`, `README.md`, `docs/overview/models/mimo-v2.6-distill-qwen-9b.md`. Also `../../../../dotfiles-pi/agent/models.json` and `../../../../dotfiles-pi/docs/overview/local-models.md` in the `dotfiles-pi` repo.

**Why**: The Pi client no longer declares MiMo as a multimodal model. Both selection aliases (`mimo-v2.6-distill-qwen-9b-131k`, `mimo-v2.6-distill-qwen-9b-262k`) now have `"input": ["text"]` only. The vision launcher scripts and projector artifact are therefore unnecessary.

**Validation**: The remaining text-only launchers (`start-agentic-131k-1024.cmd`, `start-agentic-262k-1024.cmd`) are unchanged and continue to work as before. The config manifest now lists only the GGUF model file.
