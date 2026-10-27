# LFM3 experimental deployment

Self-contained deployment for the LiquidAI LFM3 family, kept apart from the main catalog in
`D:\LLM` because it needs a llama.cpp runtime built from source: no official release contained
LFM3 support when it was set up (2026-10-27). These models are for evaluating capabilities
(audio, speech, vision, small-model agents), not for agentic coding, and they are not registered
in any client catalog (DSH, OpenCode, Pi).

The directory follows the same layout and launcher contract as `D:\LLM`
([ADR-0001](../../docs/adr/ADR-0001-self-contained-model-launchers.md)): launchers compute
`LLM_ROOT` as this directory, so they resolve `runtimes\` and `models\` here.

| Path | Content |
| --- | --- |
| `config/catalog.psd1`, `config/models/*.psd1` | Catalog and pinned manifests (revision, size, SHA-256) |
| `scripts/models/<model-id>/start-*.cmd` | Self-contained launchers |
| `scripts/setup/Build-LlamaRuntime.cmd` | Reproducible source build of the runtime |
| `docs/` | Runtime build record, model notes and changelog |
| `src/`, `runtimes/`, `models/`, `logs/` | Source checkout, build output, weights and logs (not mirrored) |

## Models

| Model ID | Publication | Weights | Projector | Context | Launcher | Profile alias |
| --- | --- | --- | --- | ---: | --- | --- |
| `lfm3-1.7b` | [LiquidAI/LFM3-1.7B-GGUF](https://huggingface.co/LiquidAI/LFM3-1.7B-GGUF) | `Q8_0` | - | 262,144 | `start-agentic-auto-262k-1024.cmd` | `lfm3-1.7b-262k` |
| `lfm3-audio-2b` | [LiquidAI/LFM3-Audio-2B-GGUF](https://huggingface.co/LiquidAI/LFM3-Audio-2B-GGUF) | `Q8_0` | `Q8_0` | 32,768 | `start-agentic-auto-audio-32k-1024.cmd` | `lfm3-audio-2b-audio-32k` |
| `lfm3-omni-2b` | [LiquidAI/LFM3-Omni-2B-GGUF](https://huggingface.co/LiquidAI/LFM3-Omni-2B-GGUF) | `Q8_0` | `Q8_0` | 32,768 | `start-agentic-auto-omni-32k-1024.cmd` | `lfm3-omni-2b-omni-32k` |

Details, capabilities and test status: [docs/models.md](docs/models.md). Runtime build record:
[docs/runtime.md](docs/runtime.md).

## Usage

Run from `D:\LLM`. The shared scripts take `-RootDirectory`:

```powershell
# Build the runtime (Visual Studio 2022 Build Tools + CUDA 13.4)
& .\experimental\lfm3\scripts\setup\Build-LlamaRuntime.cmd

# Download and verify the pinned weights
& .\scripts\setup\Download-Model.ps1 -Model lfm3-omni-2b -RootDirectory .\experimental\lfm3
& .\scripts\common\Test-ModelIntegrity.ps1 -RootDirectory .\experimental\lfm3

# Static validation of the experimental launchers
& .\scripts\common\Test-Llm.ps1 -RootDirectory .\experimental\lfm3 -ConfigurationOnly -RequireInstalledFiles

# Start a profile (terminal-bound, Ctrl+C to stop); it uses port 8080 like the main profiles
& .\experimental\lfm3\scripts\models\lfm3-omni-2b\start-agentic-auto-omni-32k-1024.cmd
```

Profiles listen on `0.0.0.0:8080` without authentication: trusted private network only, and only
one profile (main or experimental) can run at a time.

## Leaving the experiment

When an official llama.cpp release contains LFM3 support (PR #31252 and PR #31257), the models can
move to the main catalog: install that release with `Install-LlamaRuntime.ps1`, move manifests,
weights and launchers to `D:\LLM`, point `SERVER` at the official runtime and propagate the aliases
to the clients as `AGENTS.md` describes.
