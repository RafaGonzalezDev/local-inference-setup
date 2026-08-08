# BTL-4 35B

- Served model: `BTL-4-Q4_K_M.gguf`
- BF16 checkpoint: `badtheorylabs/BTL-4`
- Inspected BF16 revision: `07efbdadfb12af983d66b3df19308405649c685f`
- GGUF repository: `DogukanUrker/BTL-4-GGUF`
- GGUF revision: `28921f57a52cb1a3bdd9b801162faa074c677118`
- API alias: `btl-4`

BTL-4 is an agentic reasoning, tools, and software development fine-tune of Ornith 1.0 35B. The original checkpoint contains 35.1B BF16 parameters and occupies approximately 70.2 GB. For the Windows environment, a Q4_K_M conversion of 21,544,204,064 bytes is used, with embeddings and output in Q8.

| Profile | Context | CPU-MoE | Temperature | Usage |
| --- | ---: | ---: | ---: | --- |
| `text` | 131,072 | 21 | 1.0 | Published configuration and general service |
| `agentic` | 262,144 | 25 | 0.6 | Agents and long tasks |

Both profiles use Q8 KV cache, Flash Attention, eight threads, Jinja, and `--reasoning-format deepseek`. Reasoning separation is necessary so that previous traces do not accumulate within `content` during tool conversations. The reasoning budget is increased to 32,768 tokens because the author documents frequent truncations with lower limits on difficult problems.

The quantization was converted from BF16 with `--no-mtp`. It does not include vision or MTP: the inspected checkpoint does not contain the NextN block tensors and the available conversion is text-only. The CPU-MoE values are inherited from the equivalent Ornith profile and should be distinguished from a quality or performance measurement.

Temperature 1.0 and `top_p=0.95` are the values published with the model's results. The `agentic` profile offers 0.6 as a more deterministic operational option; it is not intended to reproduce those benchmarks.

## Local Validation

On 2026-08-06, both profiles passed SHA-256 integrity checks, argument generation, and real inference tests with runtime `b10273`: `text` in 9.14 seconds and `agentic` in 8.34 seconds for the brief functional test. An additional test returned the structured call `add_numbers(a=17,b=25)`, separated `reasoning_content`, and did not leave `<think>` tags inside `content`.

CPU-MoE values 21 and 25 are validated for loading and brief inference on the RTX 5080. They do not constitute a sustained benchmark of speed or quality.
