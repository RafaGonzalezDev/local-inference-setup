# BTL-4 Compact

- Model: `BTL-4-IQ2_XXS.gguf`
- Repository: `badtheorylabs/BTL-4-Compact`
- Revision: `2a29bc80b0ebc80d6409fbad89f85d910dbb4aee`
- API alias: `btl-4-compact`
- Declared license: Apache-2.0

BTL-4 Compact is the official IQ2_XXS quantization of BTL-4. It packages the complete text model in 9,967,966,240 bytes, with 2.30 effective bits per weight. The author reports 94.1% conditional behavior retention on a 118-case gate; this figure is not equivalent to local code or tool-calling validation.

| Profile | Context | CPU-MoE | Temperature | Usage |
| --- | ---: | ---: | ---: | --- |
| `text` | 131,072 | 0 | 1.0 | Maximum speed and smallest footprint |
| `agentic` | 262,144 | 0 | 0.6 | Full native context window |

The profiles retain Q8 KV cache, Flash Attention, eight threads, Jinja, `deepseek` reasoning separation, and a 32,768-token reasoning budget. Both profiles offload all layers, including the MoE weights, to the RTX 5080. The Q8 KV cache also remains on the GPU because K/Q/V offloading is not disabled.

The build does not contain a vision projector or the MTP block. Compared with Q4_K_M, it optimizes storage and memory at the cost of greater quantization error. The 120 expert tensors use IQ2_XXS with an importance matrix; routers and normalization layers remain in F32 according to the official model card.

## Local Validation

On 2026-08-06, both profiles passed SHA-256 integrity checks, argument generation, and real inference tests with runtime `b10273`: `text` in 5.15 seconds and `agentic` in 4.05 seconds for the brief functional test. An additional test returned the structured call `add_numbers(a=17,b=25)`, separated `reasoning_content`, and did not leave `<think>` tags inside `content`.

CPU-MoE 0 is validated with the full 262,144-token `agentic` context. The global NVIDIA measurement during loading was 14,771 of 16,303 MiB, with 1,532 MiB free. Under WDDM, this figure includes the rest of the desktop and is not an exclusive `llama-server` breakdown or a sustained benchmark.
