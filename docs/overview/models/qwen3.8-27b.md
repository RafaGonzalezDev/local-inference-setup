# Qwen3.8 27B

- Model: `Qwen3.8-27B-UD-IQ3_XXS.gguf`
- Base repository: `unsloth/Qwen3.8-27B-GGUF`
- Base revision: `main`
- MTP repository: `unsloth/Qwen3.8-27B-GGUF`
- MTP revision: `main`
- API alias: `qwen3.8-27b`

## Architecture

Qwen3.8-27B is a dense vision-language model built on the Qwen3.5 architectural foundation. It uses Gated DeltaNet combined with Gated Attention, with native 262,144-token context (extensible to 1,000,000 tokens). The model supports MTP (Multi-Token Prediction) for speculative decoding.

## Profiles

| Profile | Context | CPU-MoE | Batch/UBatch | Vision | MTP |
| --- | ---: | ---: | ---: | :---: | :---: |
| `text` | 65,536 | — | 1,024/512 | no | no |
| `text-mtp` | 32,768 | — | 1,024/512 | no | yes, n-max 6 |
| `vision` | 32,768 | — | 1,024/512 | yes | no |

All profiles use eight threads, Q8 KV cache, Flash Attention, one slot, `--gpu-layers 999`, `--parallel 1`, `--cache-ram 0`, `--split-mode none`, `--fit off`, and `--jinja`. Text profiles use temperature 1.0 and presence penalty 0. MTP uses `--spec-type draft-mtp` with a complete draft model.

The `text` profile uses a 65,536-token context with `batch/ubatch 1,024/512`. The `text-mtp` profile reduces context to 32,768 tokens for MTP speculative decoding. The `vision` profile also uses 32,768 tokens with `batch/ubatch 1,024/512` and includes the `mmproj-F16.gguf` vision projector.

## Dependencies

- `config/models/qwen3.8-27b.psd1`
- `scripts/models/qwen3.8-27b/`
- `scripts/common/Test-Llm.ps1`

## Source

- [Hugging Face model repository](https://huggingface.co/unsloth/Qwen3.8-27B-GGUF)
- License: Apache-2.0
