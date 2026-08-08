# Qwen3.6 35B A3B

- Model: `Qwen3.6-35B-A3B-UD-Q4_K_M.gguf`
- Base repository: `unsloth/Qwen3.6-35B-A3B-GGUF`
- Base revision: `a483e9e6cbd595906af30beda3187c2663a1118c`
- MTP repository: `unsloth/Qwen3.6-35B-A3B-MTP-GGUF`
- MTP revision: `5bc3e238d916f48a861bac2f8a1990a0e9b7e98d`
- API alias: `qwen3.6-35b-a3b`

| Profile | Context | CPU-MoE | Vision | MTP |
| --- | ---: | ---: | :---: | :---: |
| `text` | 131,072 | 21 | no | no |
| `text-mtp` | 131,072 | 23 | no | yes |
| `vision` | 65,536 | 23 | yes | no |
| `agentic-vision` | 262,144 | 28 | yes | no |
| `agentic` | 262,144 | 25 | no | no |
| `agentic-mtp` | 262,144 | 28 | no | yes |

All profiles use eight threads, Q8 KV cache, Flash Attention, one slot, and the previously validated batch sizes. MTP is a complete model and is served with `--spec-type draft-mtp`; it is not combined with vision.

Agentic profiles use temperature 0.6 and presence penalty 0. `agentic-vision` inherits that sampling and the full `agentic` context, with the vision settings and batch size from `vision` (`UBatchSize` 1,024); it does not use MTP. Vision profiles (`vision` and `agentic-vision`) also launch with `--image-min-tokens 1024`, the minimum recommended by llama.cpp for Qwen-VL grounding tasks (issue 16842). The remaining profiles use temperature 1.0 and Qwen's thinking-oriented sampling.
