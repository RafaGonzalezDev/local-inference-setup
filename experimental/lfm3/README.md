# LFM3 experimental deployment

Self-contained deployment for LiquidAI LFM3-Audio and LFM3-Omni, kept apart from the main catalog
in `D:\LLM`: they are for evaluating audio, speech and vision capabilities, not for agentic
coding, and they are not registered in any client catalog (DSH, OpenCode, Pi). The text model
`lfm3-1.7b` started here and moved to the main catalog on 2026-10-28
([model card](../../docs/overview/models/lfm3-1.7b.md)).

The directory follows the same layout and launcher contract as `D:\LLM`
([ADR-0001](../../docs/adr/ADR-0001-self-contained-model-launchers.md)): launchers compute
`LLM_ROOT` as this directory, so they resolve `models\` here, and they run the main tree's
`runtimes\llama.cpp\19ff817-cuda13.4`, built from source because no official release supports
LFM3 yet ([build record](../../docs/overview/inference-backend.md#source-built-runtime-19ff817)).

| Path | Content |
| --- | --- |
| `config/catalog.psd1`, `config/models/*.psd1` | Catalog and pinned manifests (revision, size, SHA-256) |
| `scripts/models/<model-id>/start-*.cmd` | Self-contained launchers |
| `docs/` | Model notes and changelog |
| `models/`, `logs/` | Weights and validation logs (not mirrored) |

## Models

| Model ID | Publication | Weights | Projector | Context | Launcher | Profile alias |
| --- | --- | --- | --- | ---: | --- | --- |
| `lfm3-audio-2b` | [LiquidAI/LFM3-Audio-2B-GGUF](https://huggingface.co/LiquidAI/LFM3-Audio-2B-GGUF) | `Q8_0` | `Q8_0` | 32,768 | `start-agentic-auto-audio-32k-1024.cmd` | `lfm3-audio-2b-audio-32k` |
| `lfm3-omni-2b` | [LiquidAI/LFM3-Omni-2B-GGUF](https://huggingface.co/LiquidAI/LFM3-Omni-2B-GGUF) | `Q8_0` | `Q8_0` | 32,768 | `start-agentic-auto-omni-32k-1024.cmd` | `lfm3-omni-2b-omni-32k` |

Details, capabilities and test status: [docs/models.md](docs/models.md).

## Usage

Run from `D:\LLM`. The shared scripts take `-RootDirectory`:

```powershell
# Build the runtime (Visual Studio 2022 Build Tools + CUDA 13.4)
& .\scripts\setup\Build-LlamaRuntime.cmd

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

When an official llama.cpp release contains LFM3 support (PR #31252 and PR #31257), install it with
`Install-LlamaRuntime.ps1` and point `SERVER` at it here and in `lfm3-1.7b`. To move a model to the
main catalog, move its manifest, weights and launcher to `D:\LLM` and propagate its alias to the
clients as `AGENTS.md` describes.
