# Gemma 4 26B A4B

- Model: `gemma-4-26B-A4B-it-qat-UD-Q4_K_XL.gguf`
- Repository: `unsloth/gemma-4-26B-A4B-it-qat-GGUF`
- Revision: `7b92b5b28818151e8669af2e501a3e0f66a6365af3`
- API alias: `gemma-4-26b-a4b`

| Profile | Context | CPU-MoE | UBatch | Vision | MTP |
| --- | ---: | ---: | ---: | :---: | :---: |
| `text` | 131,072 | 5 | 256 | no | no |
| `text-mtp` | 131,072 | 7 | 256 | no | yes |
| `vision` | 65,536 | 8 | 1,024 | yes | no |
| `agentic` | 262,144 | 12 | 1,024 | no | no |
| `agentic-vision` | 262,144 | 16 | 1,024 | yes | no |
| `vision-mtp` | 65,536 | 10 | 1,024 | yes | yes |

MTP uses the separate drafter `mtp-gemma-4-26B-A4B-it.gguf`. The profiles keep eight threads, Q8 KV cache, temperature 1.0, `top_p=0.95`, and `top_k=64`.

`agentic-vision` combines the model's full window (262,144, the same as Qwen3.6-35B-A3B) with vision and the `vision` batch size (`UBatchSize` 1,024), using agentic sampling (temperature 0.6 and presence penalty 0); it does not use MTP.

`agentic` without vision uses the same window and agentic sampling with 12 MoE layers on the CPU (2026-08-06): without the mmproj, 16 layers left approximately 2.3 GiB free; with 12, approximately 950 MiB remained free according to `nvidia-smi` (approximately 1.3 GB in Task Manager).
