# Local Language Model Inference Setup

Declarative configuration for self-contained launchers of local language models. Includes download manifests, validation scripts, documentation, and `.cmd` launchers with all inference parameters materialized.

This repository does not contain binary artifacts (GGUF weights, runtimes, downloaded packages). These are obtained by running the included installation scripts.

## Hardware Configuration

The following specifications are relevant for language model inference:

| Component | Specification |
|-----------|---------------|
| **CPU** | AMD Ryzen 7 9800X3D |
| **GPU** | RTX 5080 16 GB GDDR7 |
| **RAM** | 64 GB DDR5-6000 (2 x 32 GB) |
| **Storage** | 2 TB NVMe (primary) + 2 TB NVMe PCIe 4.0 (secondary) |

## Available Models

| Identifier | Profiles |
| --- | --- |
| `btl-4` | `text`, `agentic` |
| `btl-4-compact` | `text`, `agentic` |
| `qwen3.6-35b-a3b` | `text`, `text-mtp`, `vision`, `agentic`, `agentic-mtp`, `agentic-vision` |
| `qwen3.6-27b-mtp` | `text`, `agentic`, `text-iq4-xs`, `agentic-iq4-xs` |
| `gemma-4-26b-a4b` | `text`, `text-mtp`, `vision`, `agentic`, `agentic-vision`, `vision-mtp` |
| `gemma-4-12b-v2` | `text`, `vision` |
| `qwen3.6-35b-a3b-uncensored` | `text`, `agentic-vision` |
| `ornith-1.0-35b` | `text`, `vision`, `agentic` |
| `ternary-bonsai-27b` | `text`, `vision`, `agentic` |
| `lfm2.5-2.6b` | `text`, `agentic` |
| `lfm2.5-8b-a1b` | `text`, `agentic` |

## Repository Structure

```
├── config/
│   ├── catalog.psd1              # Model catalog
│   └── models/                   # Per-model manifests
├── scripts/
│   ├── common/                   # Launcher and integrity validation
│   ├── models/<model-id>/        # start-<profile>.cmd launchers
│   └── setup/                    # Model download and runtime installation
├── docs/
│   ├── adr/                      # Architecture decision records
│   ├── overview/                 # General documentation and model cards
│   └── changelog/                # Change history
```

## Installation

1. Install the required runtime:

```powershell
powershell -NoProfile -ExecutionPolicy RemoteSigned -File scripts/setup/Install-LlamaRuntime.ps1
```

For Ternary Bonsai 27B (requires PrismML fork):

```powershell
powershell -NoProfile -ExecutionPolicy RemoteSigned -File scripts/setup/Install-PrismRuntime.ps1
```

2. Download a model:

```powershell
powershell -NoProfile -ExecutionPolicy RemoteSigned -File scripts/setup/Download-Model.ps1 -Model qwen3.6-35b-a3b
```

3. Validate integrity:

```powershell
powershell -NoProfile -ExecutionPolicy RemoteSigned -File scripts/common/Test-ModelIntegrity.ps1 -Model qwen3.6-35b-a3b
```

## Launchers

The 34 launchers are grouped by model:

```bat
scripts\models\qwen3.6-35b-a3b\start-text.cmd
scripts\models\gemma-4-26b-a4b\start-vision-mtp.cmd
scripts\models\ternary-bonsai-27b\start-agentic.cmd
scripts\models\lfm2.5-2.6b\start-text.cmd
scripts\models\lfm2.5-8b-a1b\start-agentic.cmd
```

Each `.cmd` contains the runtime path, model path, and all effective parameters for its profile. To customize context, port, sampling, or other values, edit the corresponding launcher directly. The scripts do not accept hidden additional arguments.

The terminal remains linked to `llama-server` and displays loading, prompt processing, speed, and errors in real time. Stop the server with `Ctrl+C` in that same terminal.

## API

- Web interface: `http://localhost:8080`
- OpenAI API: `http://localhost:8080/v1`
- Health: `http://localhost:8080/health`
- Models: `http://localhost:8080/v1/models`

Profiles listen on `0.0.0.0:8080` without authentication. They should only be used on a private trusted network.

## Validation

Validate all 34 launchers and their artifacts without loading weights:

```powershell
powershell -NoProfile -ExecutionPolicy RemoteSigned -File scripts/common/Test-Llm.ps1 -ConfigurationOnly
```

Verify model hashes:

```powershell
powershell -NoProfile -ExecutionPolicy RemoteSigned -File scripts/common/Test-ModelIntegrity.ps1 -Model gemma-4-12b-v2
```

Run a brief functional test:

```powershell
powershell -NoProfile -ExecutionPolicy RemoteSigned -File scripts/common/Test-Llm.ps1 -Model lfm2.5-2.6b -Profile text
```

Functional tests control and close only the process tree they initiate. Ornith remains marked as deferred inference when testing the entire catalog, but can be run explicitly by name.

## Documentation

- [Backend and architecture](docs/overview/inference-backend.md)
- [Management, download, and testing](docs/overview/model-management.md)
- [How to add a model](docs/overview/adding-a-model.md)
- [Model cards](docs/overview/models)
- [Self-contained launcher ADR](docs/adr/ADR-0001-self-contained-model-launchers.md)
- [Architecture change](docs/changelog/2026-08-07-self-contained-launchers.md)
