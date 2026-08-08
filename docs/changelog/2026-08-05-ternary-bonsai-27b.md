# 2026-08-05 - Ternary Bonsai 27B Integration

**What**: Ternary Bonsai 27B was incorporated into the Windows environment with `text`, `vision`, and `agentic` profiles. It requires the PrismML fork due to its `Q2_0` quantization with 128-element groups.

**Where**: `models\ternary-bonsai-27b`, `config\models\ternary-bonsai-27b.psd1`, `config\catalog.psd1`, `scripts\models\ternary-bonsai-27b`, `README.md`, and `docs\overview\models`.

**Why**: Ternary Bonsai 27B is a dense 27B model derived from Qwen3.6 that supports text, reasoning, vision, and tool calling. The `Q2_0` quantization with 128-element groups requires the PrismML fork.

**Validation**: SHA-256 passed two independent checks. All three profiles generated valid argument plans. The `text` profile uses Q8 KV cache and 131,072-token context. The `vision` profile uses Q8 KV cache and 65,536-token context. The `agentic` profile uses Q4 KV cache and 262,144-token context. All profiles use eight threads, Flash Attention, and the recommended sampling: temperature 0.7, `top-p` 0.95, and `top-k` 20.
