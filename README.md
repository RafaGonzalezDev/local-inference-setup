# Local Language Model Inference Setup

Declarative configuration for self-contained launchers of local language models. Includes download manifests, validation scripts, documentation, and `.cmd` launchers with all inference parameters materialized.

This repository does not contain binary artifacts (GGUF weights, runtimes, downloaded packages). These are obtained by running the included installation scripts.

The installed artifacts in `D:\LLM\models` and the effective arguments in
`D:\LLM\scripts\models` are the deployment source of truth. This repository
mirrors their manifests and launchers; client catalogs do not select server
profiles. See the [Windows sync record](docs/changelog/2026-09-22-windows-profile-sync.md).

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
| `gemma-4-12b-v2` | `text`, `vision` |
| `gemma-4-26b-a4b` | `text`, `text-mtp`, `vision`, `agentic`, `agentic-vision`, `vision-mtp` |
| `qwen3.6-35b-a3b` | `agentic-131k-2048`, `agentic-262k-1024`, `agentic-mtp-131k-2048`, `agentic-vision-131k-2048` |
| `qwen3.8-27b` | `text`, `vision`, `text-mtp` |
| `nemotron-3.5-lightning-30b-a3b` | `agentic-131k-2048` |
| `ornith-1.5-35b-a3b` | `agentic-131k-2048`, `agentic-262k-1024` |
| `ling-3.0-tiny` | `agentic-262k-1024` |
| `ornith-1.5-9b` | `agentic-262k-1024` |
| `mimo-v2.6-distill-qwen-9b` | `agentic-131k-1024`, `agentic-262k-1024` |
| `ternary-bonsai-2-27b` | `text-131k-1024`, `vision-131k-1024` |

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

   Ternary-Bonsai 2 27B profiles additionally require the PrismML fork runtime:

```powershell
powershell -NoProfile -ExecutionPolicy RemoteSigned -File scripts/setup/Install-BonsaiRuntime.ps1
```

   MiMo requires official `b10964`, installed alongside the unchanged default `b10502`:

```powershell
powershell -NoProfile -ExecutionPolicy RemoteSigned -File scripts/setup/Install-LlamaRuntime.ps1 -Version b10964
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

The launchers are grouped by model (representative commands below):

```bat
scripts\models\gemma-4-12b-v2\start-text.cmd
scripts\models\gemma-4-26b-a4b\start-vision-mtp.cmd
scripts\models\qwen3.6-35b-a3b\start-agentic-mtp-131k-2048.cmd
scripts\models\qwen3.8-27b\start-text.cmd
scripts\models\ornith-1.5-35b-a3b\start-agentic-262k-1024.cmd
scripts\models\nemotron-3.5-lightning-30b-a3b\start-agentic-131k-2048.cmd
scripts\models\ling-3.0-tiny\start-agentic-262k-1024.cmd
scripts\models\ornith-1.5-9b\start-agentic-262k-1024.cmd
scripts\models\mimo-v2.6-distill-qwen-9b\start-agentic-262k-1024.cmd
scripts\models\ternary-bonsai-2-27b\start-text-131k-1024.cmd
scripts\models\ternary-bonsai-2-27b\start-vision-131k-1024.cmd
```

Each `.cmd` contains the runtime path, model path, and all effective parameters for its profile. To customize context, port, sampling, or other values, edit the corresponding launcher directly. The scripts do not accept hidden additional arguments.

The terminal remains linked to `llama-server` and displays loading, prompt processing, speed, and errors in real time. Stop the server with `Ctrl+C` in that same terminal.

## API

- Web interface: `http://localhost:8080`
- OpenAI API: `http://localhost:8080/v1`
- Health: `http://localhost:8080/health`
- Models: `http://localhost:8080/v1/models`

Profiles, including MiMo and Ornith 1.5 9B, listen on `0.0.0.0:8080`
without authentication. Use a private trusted network only. The Pi/OpenCode
WSL clients use `http://192.168.1.100:8080/v1`; Windows-only loopback did not
work from this WSL setup. Restart an existing server after changing a
launcher. No firewall rules are changed. Only one profile can use port 8080
at a time; check `/health` and `/v1/models` from WSL after startup.

## Validation

Validate all launchers declaratively without loading weights:

```powershell
powershell -NoProfile -ExecutionPolicy RemoteSigned -File scripts/common/Test-Llm.ps1 -ConfigurationOnly
```

Verify model hashes:

```powershell
powershell -NoProfile -ExecutionPolicy RemoteSigned -File scripts/common/Test-ModelIntegrity.ps1 -Model gemma-4-12b-v2
```

Run a brief functional test:

```powershell
powershell -NoProfile -ExecutionPolicy RemoteSigned -File scripts/common/Test-Llm.ps1 -Model qwen3.6-35b-a3b -Profile agentic-vision-131k-2048
```

Functional tests control and close only the process tree they initiate.

## Documentation

- [Backend and architecture](docs/overview/inference-backend.md)
- [Management, download, and testing](docs/overview/model-management.md)
- [How to add a model](docs/overview/adding-a-model.md)
- [Model cards](docs/overview/models)
- [Self-contained launcher ADR](docs/adr/ADR-0001-self-contained-model-launchers.md)
- [Architecture change](docs/changelog/2026-08-07-self-contained-launchers.md)
