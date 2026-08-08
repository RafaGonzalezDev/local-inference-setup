# Ternary Bonsai 27B

- Model: `Ternary-Bonsai-27B-Q2_0.gguf`
- Projector: `Ternary-Bonsai-27B-mmproj-Q8_0.gguf`
- GGUF repository: `prism-ml/Ternary-Bonsai-27B-gguf`
- Revision: `abbae723028d71be674e71e1a71201a6f43fab22`
- API alias: `ternary-bonsai-27b`
- Declared license: Apache-2.0

| Profile | Context | KV | UBatch | Vision | Usage |
| --- | ---: | --- | ---: | :---: | --- |
| `text` | 131,072 | Q8 | 512 | no | Conversation and reasoning |
| `vision` | 65,536 | Q8 | 1,024 | yes | Images and visual documents |
| `agentic` | 262,144 | Q4 | 512 | no | Jinja-based tools |

This is a dense 27B model derived from Qwen3.6 that supports text, reasoning, vision, and tool calling. The profiles use eight threads, Flash Attention, a single parallel request, and the recommended sampling: temperature 0.7, `top-p` 0.95, and `top-k` 20.

## Specialized Runtime

The `Q2_0` quantization uses 128-element groups and requires the PrismML fork. The manifest selects `prism-b9599`, commit `9ca265a`, installed at `runtimes\llama.cpp\prism-b9599-9ca265a-cuda12.4`. All other models use the official `b10273` runtime.

This fork version does not support `--load-mode`. The manifest defines `LoadMode = ''` so that the common launcher omits only that argument.

The DSpark drafter was not installed because it remains documented as experimental. The `agentic` profile reaches the declared maximum context of 262,144 through Q4 KV cache, reducing VRAM usage at the possible cost of lower quality compared with Q8. The `text` and `vision` profiles retain Q8 KV cache and contexts of 131,072 and 65,536 respectively.

## Download and Test

```powershell
& scripts\setup\Install-PrismRuntime.ps1
& scripts\setup\Download-Model.ps1 -Model ternary-bonsai-27b
& scripts\common\Test-ModelIntegrity.ps1 -Model ternary-bonsai-27b
& scripts\common\Test-Llm.ps1 -Model ternary-bonsai-27b -Profile agentic
```

The normal launchers are located in `scripts\models\ternary-bonsai-27b`. They keep the terminal linked to the server and display loading, prompt processing, and decoding speed in real time.
