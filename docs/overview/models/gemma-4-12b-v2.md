# Gemma 4 12B v2

- Model: `gemma-4-12B-it-qat-UD-Q4_K_XL.gguf`
- Repository: `unsloth/gemma-4-12B-it-qat-GGUF`
- Revision: `980b060c40a8539ac159e0501a3e0f66a6365af3`
- API alias: `gemma-4-12b-v2`
- Profiles: `text`, `vision`

Both profiles retain a 262,144-token context, enabled reasoning, temperature 1.0, `top_p=0.95`, and `top_k=64`. The vision profile only adds `mmproj-F16.gguf`.

The model is dense and does not configure CPU-MoE. The KV cache remains in F16 because the WSL launcher did not enable quantization by default. No MTP artifact is installed.

This is the revision refreshed by Unsloth in July 2026, with tool-calling changes compared with the previous load.
