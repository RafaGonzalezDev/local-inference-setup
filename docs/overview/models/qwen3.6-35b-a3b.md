# Qwen3.6 35B A3B

- Model: `Qwen3.6-35B-A3B-UD-Q4_K_M.gguf`
- Base repository: `unsloth/Qwen3.6-35B-A3B-GGUF`
- Base revision: `a483e9e6cbd595906af30beda3187c2663a1118c`
- MTP repository: `unsloth/Qwen3.6-35B-A3B-MTP-GGUF`
- MTP revision: `5bc3e238d916f48a861bac2f8a1990a0e9b7e98d`
- API alias: `qwen3.6-35b-a3b`

| Profile | Context | CPU-MoE | Batch/UBatch | Vision | MTP |
| --- | ---: | ---: | ---: | :---: | :---: |
| `text` | 131,072 | 21 | 1,024/512 | no | no |
| `text-mtp` | 131,072 | 23 | 1,024/512 | no | yes, n-max 3 |
| `vision` | 65,536 | 23 | 1,024/1,024 | yes | no |
| `agentic-vision` | 262,144 | 28 | 1,024/1,024 | yes | no |
| `agentic` | 262,144 | 25 | 1,024/1,024 | no | no |
| `agentic-mtp` | 262,144 | 28 | 1,024/1,024 | no | yes, n-max 3 |
| `agentic-131k-4096` | 131,072 | 23 | 4,096/4,096 | no | no |
| `agentic-mtp-131k-4096` | 131,072 | 26 | 2,048/2,048 | no | yes, n-max 3 |

The `Batch/UBatch` column corresponds to `--batch-size/--ubatch-size`. All
profiles use eight threads, Q8 KV cache, Flash Attention, one slot,
`--gpu-layers 999`, `--parallel 1`, `--cache-ram 0`, `--split-mode none`,
`--fit off`, and `--jinja`. MTP is a complete model and is served with
`--spec-type draft-mtp`; it is not combined with vision.

Agentic profiles use temperature 0.6 and presence penalty 0.
`agentic-vision` inherits that sampling and the full `agentic` context, with
vision and `batch/ubatch 1,024/1,024`; it does not use MTP. Vision profiles
(`vision` and `agentic-vision`) also launch with `--image-min-tokens 1024`,
the minimum recommended by llama.cpp for Qwen-VL grounding tasks (issue
16842). The remaining profiles use temperature 1.0 and Qwen's
thinking-oriented sampling.

`agentic` and `agentic-mtp` are the full-context variants: they keep 262,144
tokens and `batch/ubatch 1,024/1,024`. `agentic-131k-4096` uses the base GGUF,
`CPU-MoE 23`, and `batch/ubatch 4,096/4,096` for agentic workloads with high
prefill. `agentic-mtp-131k-4096` uses the MTP GGUF, `CPU-MoE 26`, and
`batch/ubatch 2,048/2,048`, together with `--spec-draft-n-max 3`.

The two 131,072-token profiles are final validated configurations for agentic
coding. All agentic profiles share the `qwen3.6-35b-a3b` alias and port `8080`,
so they must be run as alternatives rather than simultaneously.
