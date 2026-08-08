# LFM 2.5 2.6B

- Model: `LFM2.5-2.6B-Q8_0.gguf`
- Base repository: `LiquidAI/LFM2.5-2.6B-GGUF`
- Base revision: `b22e29ebf6249a8c9fcdda36914743e9980595c4`
- API alias: `lfm2.5-2.6b`

| Profile | Context | Vision | MTP |
| --- | ---: | :---: | :---: |
| `text` | 131,072 | no | no |
| `agentic` | 131,072 | no | no |

Both launchers set `--ctx-size 131072`, according to the
`max_position_embeddings` value in the [official checkpoint](https://huggingface.co/LiquidAI/LFM2.5-2.6B/blob/main/config.json). The GGUF from the installed revision still contains `lfm2.context_length = 128000`; therefore, the launchers add `--override-kv lfm2.context_length=int:131072` to prevent `llama-server` from reducing the slot to 128,000.

They use eight threads, Q8 KV cache, Flash Attention, one slot, and 1024/512 batches. The model is dense and does not configure `--n-cpu-moe`, MTP, or vision.

Both profiles use the parameters published by Liquid AI: temperature 0.1, `top-k` 50, and repetition penalty 1.1. `top-p` 0.95, `min-p` 0, and presence penalty 0 remain explicit operational values. The batches and Q8 KV cache were adapted to the local environment and do not represent a performance measurement.
