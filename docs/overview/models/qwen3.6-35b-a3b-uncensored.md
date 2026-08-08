# Qwen3.6 35B A3B Uncensored

- File: `Qwen3.6-35B-A3B-Uncensored-HauhauCS-Aggressive-Q4_K_M.gguf`
- Vision projector: `mmproj-Qwen3.6-35B-A3B-Uncensored-HauhauCS-Aggressive-f16.gguf` (899 MB, SHA-256 `c8e70234…`)
- Repository: `HauhauCS/Qwen3.6-35B-A3B-Uncensored-HauhauCS-Aggressive`
- Revision: `f12a584fecbeb5f20001130d8ecd66c9327ae685`
- API alias: `qwen3.6-35b-a3b-uncensored`
- Profiles: `text`, `agentic-vision`

## text

The profile inherits the base Qwen text configuration because it shares the same architecture and size class: 131,072-token context, CPU-MoE 21, Q8 KV cache, eight threads, and 1024/512 batch and ubatch sizes.

These values are inherited and are not the result of a model-specific benchmark.

## agentic-vision

Full context window (262,144) with vision, replicating the validated parameters of the equivalent profile from the base Qwen model (the GGUF is approximately 1 GB smaller, so the VRAM impact is equal or lower): CPU-MoE 28, ubatch 1,024, `ImageMinTokens` 1,024 (Qwen-VL grounding fix), temperature 0.6, and presence penalty 0.0. No MTP is used (the `D:\LLM` rule is not to combine vision and MTP).

The projector is the one published by the fine-tune's own repository; the model is natively multimodal (text, image, and video) according to the official README, which states that the uncensoring does not alter these capabilities.

The name "uncensored" describes the adjustment published by the repository and does not alter the safety restrictions of software clients consuming the API.
