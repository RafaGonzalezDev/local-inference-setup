# LFM3 deployment

Self-contained deployment for LiquidAI LFM3-1.7B, kept apart from the main catalog in `D:\LLM` with
its own llama.cpp runtime, `b11981-cuda13.4` (build 11981, commit `da6c30ade`). That release contains
native LFM3 support (PR #31252); no source build is needed. The main catalog stays on `b11551`.

The VL, Audio and Omni models of the family were installed here on 2026-10-29 and removed the same day
because their results were poor for the user
([changelog](../../docs/changelog/2026-10-29-lfm3-multimodal-retirement.md)).

The directory follows the same layout and launcher contract as `D:\LLM`
([ADR-0001](../../docs/adr/ADR-0001-self-contained-model-launchers.md)): launchers compute
`LLM_ROOT` as this directory and resolve `models\` and `runtimes\` here.

| Path | Content |
| --- | --- |
| `config/catalog.psd1`, `config/models/*.psd1` | Catalog and pinned manifest (revision, size, SHA-256) |
| `scripts/models/<model-id>/start-*.cmd` | Self-contained launcher |
| `docs/` | Model notes |
| `models/`, `runtimes/`, `packages/`, `logs/` | Weights, runtime, packages and validation logs (not mirrored) |

## Model

| Model ID | Publication | Weights | Context | Launcher | Profile alias | Clients |
| --- | --- | --- | ---: | --- | --- | --- |
| `lfm3-1.7b` | [LFM3-1.7B-GGUF](https://huggingface.co/LiquidAI/LFM3-1.7B-GGUF) | `Q8_0` | 262,144 | `start-agentic-auto-262k-1024.cmd` | `lfm3-1.7b-262k` | Pi, OpenCode |

Details and test status: [docs/models.md](docs/models.md).

## Usage

Run from `D:\LLM`. The shared scripts take `-RootDirectory`:

```powershell
# Runtime and weights (pinned and verified)
& .\scripts\setup\Install-LlamaRuntime.ps1 -RootDirectory .\experimental\lfm3 -Version b11981
& .\scripts\setup\Download-Model.ps1 -Model lfm3-1.7b -RootDirectory .\experimental\lfm3
& .\scripts\common\Test-ModelIntegrity.ps1 -RootDirectory .\experimental\lfm3

# Static validation
& .\scripts\common\Test-Llm.ps1 -RootDirectory .\experimental\lfm3 -ConfigurationOnly -RequireInstalledFiles

# Start the profile (terminal-bound, Ctrl+C to stop); it uses port 8080 like the main profiles
& .\experimental\lfm3\scripts\models\lfm3-1.7b\start-agentic-auto-262k-1024.cmd
```

The profile listens on `0.0.0.0:8080` without authentication: trusted private network only, and only
one profile (main or LFM3) can run at a time.
