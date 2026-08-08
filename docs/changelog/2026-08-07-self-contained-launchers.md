# 2026-08-07 - Self-Contained Launchers and LFM Context

**What**: The 28 profiles now invoke `llama-server.exe` directly with all visible parameters. The `text` and `agentic` profiles of LFM2.5-2.6B changed from 128,000 to 131,072 tokens.

**Where**: `scripts\models`, `scripts\common\Test-Llm.ps1`, `config\models`, the `docs\overview` guides, and the LFM card.

**Why**: The inheritance between runtime, model, and profile made it difficult to know with what parameters a model was started. Inspection and local editing are prioritized over configuration deduplication. The official LFM checkpoint declares `max_position_embeddings = 131072`, though the installed GGUF retains `lfm2.context_length = 128000`. The two profiles apply an explicit override of that key so the runtime does not reduce the slot.

**Validation**: The 28 materialized commands were compared in order and value with the previous plans. There were no differences except the intentional LFM correction and its metadata override. Static validation checked paths, unique flags, and absence of delegation or hidden arguments. The LFM `text` and `agentic` profiles responded with `n_ctx_slot = 131072`. Qwen `vision`, Qwen `text-mtp`, Gemma `text-mtp` with separate drafter, and Ternary Bonsai `text` via Prism also passed; all released port 8080.
