# Ornith 1.0 35B

- Model: `Ornith-1.0-35B-UD-Q4_K_M.gguf`
- GGUF repository: `unsloth/Ornith-1.0-35B-GGUF`
- Revision: `78e1321ef86b69126dc991f481bb0cdc37614ed0`
- Inspected base checkpoint: `5df2ed3f675c7beaa490328cc70bb573b65fb660`
- API alias: `ornith-1.0-35b`

| Profile | Context | CPU-MoE | UBatch | Vision | Sampling |
| --- | ---: | ---: | ---: | :---: | --- |
| `text` | 131,072 | 21 | 512 | no | thinking |
| `vision` | 65,536 | 23 | 1,024 | yes | thinking |
| `agentic` | 262,144 | 25 | 512 | no | code |

Ornith uses a Qwen3.5 MoE architecture with 40 layers, 256 experts, and eight active experts per token. Its operational parameters were inherited from Qwen rather than from a dedicated performance test suite. No MTP was installed.

Inference is deferred for a later manual test. The catalog still immediately validates paths, profiles, sizes, and hashes.
