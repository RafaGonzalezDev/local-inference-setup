# LFM 2.5 8B A1B

- Model: `LFM2.5-8B-A1B-Q8_0.gguf`
- Base repository: `LiquidAI/LFM2.5-8B-A1B-GGUF`
- Base revision: `dfd5fdcad7a1c0d31473fb4ca443b8befbacddf0`
- SHA-256: `33ab3b8ce6a964fb8ebac89360c9b3cf72c4fa418d5e4c0a94d46883124d5c02`
- API alias: `lfm2.5-8b-a1b`

| Profile | Context | Vision | MTP |
| --- | ---: | :---: | :---: |
| `text` | 128,000 | no | no |
| `agentic` | 128,000 | no | no |

The official model declares 8.3 billion total parameters, 1.5 billion active parameters, and a 128,000-token context window. It is a reasoning checkpoint without vision. Both launchers are intentionally identical: they enable reasoning and use Liquid AI's published recipe with temperature 0.2, `top-k` 80, and repetition penalty 1.05. `top-p` 0.95, `min-p` 0, and presence penalty 0 remain explicit operational values.

The official Q8_0 quantization was installed, with a size of 9,010,195,680 bytes. Q4_K_M would reduce the file to 5,155,564,768 bytes and remains a useful alternative if approximately 3.85 GB needs to be freed, but Q8_0 was chosen to minimize quantization loss in reasoning and tool use because it fits in the RTX 5080's 16 GB. The full-context test left 4,561 MiB free according to `nvidia-smi`; this figure includes other graphical processes and is not an isolated benchmark.

The launchers offload all layers to the GPU (`--gpu-layers 999`), use a single slot, Q8 KV cache, Flash Attention, and 1024/512 batches. The functional test confirmed `n_ctx_slot = 128000` for both profiles.
