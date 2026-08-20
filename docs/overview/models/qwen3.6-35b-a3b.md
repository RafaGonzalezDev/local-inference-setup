# Qwen3.6 35B A3B

- Model: `Qwen3.6-35B-A3B-UD-Q4_K_M.gguf`
- Base repository: `unsloth/Qwen3.6-35B-A3B-GGUF`
- Base revision: `a483e9e6cbd595906af30beda3187c2663a1118c`
- MTP repository: `unsloth/Qwen3.6-35B-A3B-MTP-GGUF`
- MTP revision: `5bc3e238d916f48a861bac2f8a1990a0e9b7e98d`
- API alias: `qwen3.6-35b-a3b`

| Profile | Context | CPU-MoE | Batch/UBatch | Vision | MTP |
| --- | ---: | ---: | ---: | :---: | :---: |
| `agentic-131k-2048` | 131,072 | 20 | 2,048/2,048 | no | no |
| `agentic-mtp-131k-2048` | 131,072 | 25 | 2,048/2,048 | no | yes, n-max 3 |
| `agentic-vision-131k-2048` | 131,072 | 24 | 2,048/2,048 | yes | no |

The `Batch/UBatch` column corresponds to `--batch-size/--ubatch-size`. All
profiles use eight threads, Q8 KV cache, Flash Attention, one slot,
`--gpu-layers 999`, `--parallel 1`, `--cache-ram 0`, `--split-mode none`,
`--fit off`, and `--jinja`. MTP is a complete model and is served with
`--spec-type draft-mtp`; it is not combined with vision.

Agentic profiles use temperature 0.6 and presence penalty 0 (no presence-based repetition penalty). This setting allows the model to repeat tokens naturally when the context requires it, which is important for agentic coding workloads that may reference the same code snippets or identifiers multiple times.

`agentic-vision-131k-2048` uses `--image-min-tokens 2048` (higher than the default 1024) for improved grounding accuracy on vision tasks.

All three profiles share the `qwen3.6-35b-a3b` alias and port `8080`, so they must be run as alternatives rather than simultaneously.
