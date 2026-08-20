# Ornith 1.5 35B A3B

- Model: `Ornith-1.5-35B-A3B-AD-Q4_K-IQ4_XS.gguf`
- Base repository: `ornith-ai/Ornith-1.5-35B-A3B-GGUF`
- Base revision: `main`
- API alias: `ornith-1.5-35b-a3b`

## Architecture

Ornith-1.5-35B-A3B is a mixture-of-experts model with 35 billion total parameters and approximately 3 billion active parameters per token. It uses the `nemotron_h_moe` architecture with Flash Attention and native 262,144-token context.

## Profile

| Profile | Context | CPU-MoE | Batch/UBatch | Reasoning |
| --- | ---: | ---: | ---: | ---: |
| `agentic-131k-2048` | 131,072 | 20 | 2,048/2,048 | yes |

The launcher uses `--gpu-layers 999`, Flash Attention, one slot, Q8 KV cache, eight CPU threads, `--cache-ram 0`, `--split-mode none`, `--fit off`, and `--jinja`. It enables reasoning with an 8,192-token reasoning budget and exposes the `ornith-1.5-35b-a3b` API alias on port `8080`.

Agentic profiles use temperature 0.6 and presence penalty 0.

The model is a reasoning model: by default the assistant turn opens with a `<think>` block before the final answer. The serving recipes enable a reasoning parser so the chain-of-thought is returned in a separate `reasoning_content` field.

## Dependencies

- `config/models/ornith-1.5-35b-a3b.psd1`
- `scripts/models/ornith-1.5-35b-a3b/`
- `scripts/common/Test-Llm.ps1`

## Source

- [Hugging Face model repository](https://huggingface.co/ornith-ai/Ornith-1.5-35B-A3B-GGUF)
- License: MIT
