# Nemotron 3.5 Lightning 30B A3B

Native Windows profile for `ggml-org/NVIDIA-Nemotron-3.5-Lightning-30B-A3B-GGUF`,
served with the official `llama.cpp b10361-cuda13.3` runtime. The model is a
hybrid Mamba-2 + MoE + Attention architecture (`nemotron_h_moe`) with 128
experts, 6 active experts, and 1 shared expert. NVIDIA publishes it under the
OpenMDW-1.1 license.

## Artifact

| Quantization | File | Size | SHA-256 |
| --- | --- | ---: | --- |
| `NVFP4` | `NVIDIA-Nemotron-3.5-Lightning-30B-A3B-NVFP4.gguf` | 22.46 GB | `7827805ae9f2d20cc71e46bf05d9cb045e222d3fa0429363c324bbf6d3cab959` |

The artifact is pinned to revision
`88d7ce0b0fa385c5108866ce5d33690927531a37`. The GGUF combines NVFP4 MLP
tensors with BF16 attention, Mamba, and embedding tensors; scales and
normalization tensors remain in F32. The native context declared by the GGUF
is 1,048,576 tokens.

This model requires `llama.cpp b10361` or later. Its NVFP4 scale tensors and
`nemotron_h_moe` architecture with the embedded NextN head are not compatible
with the older `b10273` runtime.

## Profile

| Launcher | Context | CPU-MoE | Batch/UBatch | Vision | MTP |
| --- | ---: | ---: | ---: | :---: | :---: |
| `start-agentic.cmd` | 131,072 | 23 | 2,048/2,048 | no | no |

The launcher uses `--gpu-layers 999`, Flash Attention, one slot, Q8 KV cache,
eight CPU threads, `--cache-ram 0`, `--split-mode none`, and `--fit off`. It
enables reasoning with an 8,192-token reasoning budget and exposes the
`nemotron-3.5-lightning-30b-a3b` API alias on port `8080`.

The current Windows model directory contains only this agentic launcher. The
previous text launcher is intentionally not mirrored in this repository after
being removed from the Windows source tree.

The embedded NextN head is not used for MTP in this profile. NVIDIA's DFlash
draft is a separate safetensors checkpoint and is not part of this launcher.

## Dependencies

- `config/models/nemotron-3.5-lightning-30b-a3b.psd1`
- `scripts/models/nemotron-3.5-lightning-30b-a3b/`
- `scripts/common/Test-Llm.ps1`

## Source

- [Hugging Face model repository](https://huggingface.co/ggml-org/NVIDIA-Nemotron-3.5-Lightning-30B-A3B-GGUF)
- License declared by the model: OpenMDW-1.1.
