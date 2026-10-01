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

All profiles are automatic: every launcher declares `--gpu-layers auto --fit on`
and lets the runtime resolve the device placement. The hand-tuned profiles that
pinned `--gpu-layers 999` with `--n-cpu-moe` were retired on 2026-09-30. Their
reference copy and the `b10502-cuda13.3` runtime were deleted on 2026-10-01, so
only `b11269-cuda13.4` remains installed.

| Identifier | Profiles | Profile aliases |
| --- | --- | --- |
| `gemma-4-12b-v2` | `text-auto`, `vision-auto` | `gemma-4-12b-v2-text`, `gemma-4-12b-v2-vision` |
| `gemma-4-26b-a4b` | `text-auto`, `text-auto-mtp`, `vision-auto`, `agentic-auto`, `agentic-auto-vision`, `vision-auto-mtp` | `gemma-4-26b-a4b-text`, `gemma-4-26b-a4b-text-mtp`, `gemma-4-26b-a4b-vision`, `gemma-4-26b-a4b-agentic`, `gemma-4-26b-a4b-agentic-vision`, `gemma-4-26b-a4b-vision-mtp` |
| `qwen3.6-35b-a3b` | `agentic-auto-131k-2048`, `agentic-auto-262k-1024`, `agentic-auto-mtp-131k-1024`, `agentic-auto-vision-131k-2048` | `qwen3.6-35b-a3b-131k`, `qwen3.6-35b-a3b-262k`, `qwen3.6-35b-a3b-mtp-131k`, `qwen3.6-35b-a3b-vision-131k` |
| `nemotron-3.5-lightning-30b-a3b` | `agentic-auto-131k-2048` | `nemotron-3.5-lightning-30b-a3b-131k` |
| `ornith-1.5-35b-a3b` | `agentic-auto-131k-2048`, `agentic-auto-262k-1024` | `ornith-1.5-35b-a3b-131k`, `ornith-1.5-35b-a3b-262k` |
| `ling-3.0-tiny` | `agentic-auto-262k-1024` | `ling-3.0-tiny-262k` |
| `ornith-1.5-9b` | `agentic-auto-262k-1024` | `ornith-1.5-9b-262k` |
| `tiel-coder-35b-a3b-mtp` | `agentic-auto-mtp-131k-1024`, `agentic-auto-mtp-262k-1024`, `agentic-auto-mtp-vision-131k-1024` | `tiel-coder-35b-a3b-mtp-131k`, `tiel-coder-35b-a3b-mtp-262k`, `tiel-coder-35b-a3b-mtp-vision-131k` |
| `tiel-coder-35b-a3b` | `agentic-auto-131k-2048`, `agentic-auto-262k-1024`, `agentic-auto-vision-131k-2048` | `tiel-coder-35b-a3b-131k`, `tiel-coder-35b-a3b-262k`, `tiel-coder-35b-a3b-vision-131k` |

## Repository Structure

```
├── config/
│   ├── catalog.psd1              # Model catalog
│   └── models/                   # Per-model manifests
├── scripts/
│   ├── common/                   # Launcher and integrity validation
│   ├── models/<model-id>/        # start-<profile>-auto.cmd launchers
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
scripts\models\gemma-4-12b-v2\start-text-auto.cmd
scripts\models\gemma-4-12b-v2\start-vision-auto.cmd
scripts\models\gemma-4-26b-a4b\start-vision-auto-mtp.cmd
scripts\models\qwen3.6-35b-a3b\start-agentic-auto-mtp-131k-1024.cmd
scripts\models\qwen3.6-35b-a3b\start-agentic-auto-131k-2048.cmd
scripts\models\ornith-1.5-35b-a3b\start-agentic-auto-262k-1024.cmd
scripts\models\tiel-coder-35b-a3b-mtp\start-agentic-auto-mtp-131k-1024.cmd
scripts\models\tiel-coder-35b-a3b-mtp\start-agentic-auto-mtp-vision-131k-1024.cmd
scripts\models\tiel-coder-35b-a3b\start-agentic-auto-131k-2048.cmd
scripts\models\tiel-coder-35b-a3b\start-agentic-auto-vision-131k-2048.cmd
scripts\models\nemotron-3.5-lightning-30b-a3b\start-agentic-auto-131k-2048.cmd
scripts\models\ling-3.0-tiny\start-agentic-auto-262k-1024.cmd
scripts\models\ornith-1.5-9b\start-agentic-auto-262k-1024.cmd
```

Each `.cmd` contains the runtime path, model path, and all effective parameters for its profile. The launchers materialize `--gpu-layers auto`, `--fit on` and `--fit-target 1024` —`2048` in the vision profiles, because `--fit` does not account for the projector— and declare the context explicitly, since `--fit` only adjusts unset arguments. They omit `--n-cpu-moe`: `--fit` places the weights with a per-layer `-ot` override instead of that lever. To customize context, port, sampling, or other values, edit the corresponding launcher directly. The scripts do not accept hidden additional arguments.

Every launcher declares its `--alias` as `<model-id>,<profile-id>`, listed in the table above. The bare model id stays first, so clients that already name it keep working, and `/v1/models` reports both names. The second alias lets a client ask for the exact profile that is running — `qwen3.6-35b-a3b-262k` cannot be answered by the 131K launcher. It does not let a client *choose* a profile: the launcher still decides context, sampling, placement, and reasoning budget, and only one profile can hold port 8080 at a time. A request naming a profile the running launcher does not serve fails with `model '<id>' not found`.

`Test-Llm.ps1` requires the first alias to be the model id, requires each profile alias to be unique across launchers, and refuses a profile alias that shadows a model id.

The terminal remains linked to `llama-server` and displays loading, prompt processing, speed, and errors in real time. Stop the server with `Ctrl+C` in that same terminal.

## API

- Web interface: `http://localhost:8080`
- OpenAI API: `http://localhost:8080/v1`
- Health: `http://localhost:8080/health`
- Models: `http://localhost:8080/v1/models`

`/v1/models` reports the bare model id and the profile id of the running launcher; a request may name either one. `/health` answers only while a launcher is running, so it doubles as the check for whether port 8080 is free.

Profiles, including Ornith 1.5 9B, listen on `0.0.0.0:8080`
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
powershell -NoProfile -ExecutionPolicy RemoteSigned -File scripts/common/Test-Llm.ps1 -Model qwen3.6-35b-a3b -Profile agentic-auto-vision-131k-2048
```

Functional tests control and close only the process tree they initiate.

## Documentation

- [Backend and architecture](docs/overview/inference-backend.md)
- [Management, download, and testing](docs/overview/model-management.md)
- [How to add a model](docs/overview/adding-a-model.md)
- [Model cards](docs/overview/models)
- [Self-contained launcher ADR](docs/adr/ADR-0001-self-contained-model-launchers.md)
- [Architecture change](docs/changelog/2026-08-07-self-contained-launchers.md)
