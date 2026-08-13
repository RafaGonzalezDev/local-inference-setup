# Muse Glimmer 30B

Native Windows profiles for `unsloth/Muse-Glimmer-30B-GGUF`, served with the
official `llama.cpp b10361-cuda13.3` runtime. The initial deployment compares
the two requested Unsloth UD quantizations independently.

## Artifacts

| Quantization | File | Size | SHA-256 |
| --- | --- | ---: | --- |
| `UD-Q4_K_XL` | `Muse-Glimmer-30B-UD-Q4_K_XL.gguf` | 15,878,222,368 bytes | `82bece304887a313ece08400bc030f6066c7bff5b906b0cd40308ec8a409fd38` |
| `UD-Q3_K_XL` | `Muse-Glimmer-30B-UD-Q3_K_XL.gguf` | 13,360,983,072 bytes | `820d18e00c59376331eba62dd716a6bcdcaa305c2316f5da3a2fab36c7c37e15` |

Both artifacts are pinned to revision
`faa5b025c584459c13febfa5c59883516710ae39`.

## Profiles

| Launcher | Quantization | Context | KV cache | Vision | DFlash |
| --- | --- | ---: | --- | :---: | :---: |
| `start-agentic-ud-q4-k-xl.cmd` | `UD-Q4_K_XL` | 131,072 | Q8/Q8 | no | no |
| `start-agentic-ud-q3-k-xl.cmd` | `UD-Q3_K_XL` | 131,072 | Q8/Q8 | no | no |

Both profiles use `--gpu-layers auto`, `--fit on --fit-target 768`, Flash
Attention, eight CPU threads, and the sampling recommended by Meta/Unsloth:
temperature 1, `top-p` 0.95, and `top-k` 64. They expose the common API alias
`muse-glimmer-30b`; the active launcher selects the quantization.

Vision projectors and DFlash drafts are intentionally deferred so the initial
comparison measures only the two main GGUF artifacts.

## Dependencies

- `config/models/muse-glimmer-30b.psd1`
- `scripts/models/muse-glimmer-30b/`
- `scripts/common/Test-Llm.ps1`

## Source

- Repository: https://huggingface.co/unsloth/Muse-Glimmer-30B-GGUF
- License declared by the model: Apache 2.0.
