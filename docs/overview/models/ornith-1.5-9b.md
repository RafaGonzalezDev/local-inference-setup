# Ornith 1.5 9B

- Model: `Ornith-1.5-9B-AD-IQ4_XS.gguf`
- Base repository: `ornith-ai/Ornith-1.5-9B-GGUF`
- Base revision: `main`
- API alias: `ornith-1.5-9b`

## Architecture

Ornith-1.5-9B is a dense model with approximately 9 billion parameters, designed for efficient single-GPU deployment. It has native 262,144-token context with Flash Attention.

## Profile

| Profile | Context | Batch/UBatch | Reasoning |
| --- | ---: | ---: | ---: |
| `agentic-262k-1024` | 262,144 | 1,024/1,024 | yes |

The launcher uses `--gpu-layers 999`, Flash Attention, one slot, Q8 KV cache, eight CPU threads, `--cache-ram 0`, `--split-mode none`, `--fit off`, and `--jinja`. It enables reasoning with an unbounded reasoning budget (`--reasoning-budget -1`) and exposes the `ornith-1.5-9b` API alias on port `8080`.

Agentic profiles use temperature 0.6 and presence penalty 0. No `--repeat-penalty` is set (defaults to 1.0). The `--no-cache-idle-slots` flag is enabled for this profile.

The model is a reasoning model: by default the assistant turn opens with a `<think>` block before the final answer.

No vision projector or MTP draft model is published for Ornith 1.5.

## Dependencies

- `config/models/ornith-1.5-9b.psd1`
- `scripts/models/ornith-1.5-9b/`
- `scripts/common/Test-Llm.ps1`

## Source

- [Hugging Face model repository](https://huggingface.co/ornith-ai/Ornith-1.5-9B-GGUF)
- License: MIT
