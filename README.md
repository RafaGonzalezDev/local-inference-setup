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
reference copy and the `b10502-cuda13.3` runtime were deleted on 2026-10-01. Every
launcher pins `b11981-cuda13.4` since 2026-10-30, when it replaced `b11551-cuda13.4`
after measuring faster on the catalog models; `b11551` was removed the same day
([changelog](docs/changelog/2026-10-30-llama-runtime-b11981-catalog.md)).
`b11669-cuda13.4` (llama.cpp v0.7.0) was used on 2026-10-27 and removed on 2026-10-28
because it performed worse for the user. `b11269-cuda13.4` was removed on 2026-10-22
and `b11827-cuda13.4`, which `flint` used until its retirement, on 2026-10-26; all four
can be reinstalled.

The LiquidAI LFM3 models (`lfm3-1.7b`, `lfm3-audio-2b`, `lfm3-omni-2b`) and the llama.cpp
runtime built from source for them were retired on 2026-10-28
([changelog](docs/changelog/2026-10-28-lfm3-retirement.md)), as were `lfm2.5-24b-a2b`,
`nemotron-3.5-bolt-e4b`, `ornith-1.5-35b-a3b` and the base `qwen3.6-35b-a3b`
([changelog](docs/changelog/2026-10-28-model-set-retirement.md)). The MTP profiles were
retired on 2026-10-28 and every model moved to its `UD-Q4_K_XL` build without an MTP head;
Tiel Coder and Cyber Tiel dropped the `-mtp` suffix from their IDs
([changelog](docs/changelog/2026-10-28-q4-k-xl-without-mtp.md)).

From 2026-10-29 `lfm3-1.7b` ran from `experimental/lfm3` with its own copy of `b11981-cuda13.4`
([changelog](docs/changelog/2026-10-29-lfm3-b11981.md)); the VL, Audio and Omni models installed with it
were removed the same day ([changelog](docs/changelog/2026-10-29-lfm3-multimodal-retirement.md)). On
2026-11-01 the four LFM3 models joined this catalog, since it runs the same build: Audio and Omni with
the newer projectors that quantize the codec decoder. Every LFM3 alias except Audio's is registered in
Pi, OpenCode and DSH ([changelog](docs/changelog/2026-11-01-lfm3-main-catalog.md)).

On 2026-10-29 `nemotron-3.5-lightning-30b-a3b`, retired on 2026-10-26, came back with the `AD-IQ4_NL`
build from `AtomicChat` instead of the earlier NVFP4: K-quants do not fit its tensor shapes, so it is the
only model not on `UD-Q4_K_XL` ([changelog](docs/changelog/2026-10-29-nemotron-3.5-lightning-30b-a3b.md)).

On 2026-10-30 `flint`, retired on 2026-10-26, came back with the same `UD-Q4_K_XL` revision on the
official runtime `b11981-cuda13.4`, because `b11551` cannot load its architecture. Its reasoning cannot
be turned off per request, only capped with a positive budget ([changelog](docs/changelog/2026-10-30-flint.md)).

On 2026-11-01 `apex-35b-v1.0` (Apex Intelligence, built on Qwen3.6-35B-A3B) joined with its imatrix
`Q4_K_S` build. It decides per turn whether and how long to think, so its launchers leave the reasoning
budget unlimited; its GGUF carries an MTP head that the profiles do not use ([changelog](docs/changelog/2026-11-01-apex-35b-v1.0.md)).

On 2026-11-02 `gemma-4-26b-a4b-uncensored-balanced` (HauhauCS, an uncensored build of Gemma 4 26B A4B from the official QAT weights) joined with its `Q4_K_M` build and BF16 projector, in text and vision profiles at 131K and 262K. Its MTP drafter ships as a separate file that is not installed ([changelog](docs/changelog/2026-11-02-gemma-4-26b-a4b-uncensored-balanced.md)).

On 2026-11-02 `experimental/` came back as a separate root, outside this catalog, with `lfm3-1.7b-uncensored` (`AtomicChat`, `AD-Q6_K`) in a CPU-only profile on loopback port 8081 and `Start-Assistant.cmd`, a terminal utility that starts the model, answers prompts with an instructions file and stops the model on exit. It is not registered in any client ([changelog](docs/changelog/2026-11-02-experimental-lfm3-1.7b-uncensored.md)).

The publisher is the Hugging Face organization whose GGUF files are installed; each
manifest pins the exact repository and revision.

| Identifier | Publisher | Profiles | Profile aliases |
| --- | --- | --- | --- |
| `tiel-coder-35b-a3b` | `peculiar-ragdoll` | `agentic-auto-131k-1024`, `agentic-auto-262k-1024`, `agentic-auto-vision-131k-1024`, `agentic-auto-vision-262k-1024` | `tiel-coder-35b-a3b-131k`, `tiel-coder-35b-a3b-262k`, `tiel-coder-35b-a3b-vision-131k`, `tiel-coder-35b-a3b-vision-262k` |
| `nail-qwen3.6-35b-a3b` | `peculiar-ragdoll` | `agentic-auto-131k-1024`, `agentic-auto-262k-1024`, `agentic-auto-vision-131k-1024`, `agentic-auto-vision-262k-1024` | `nail-qwen3.6-35b-a3b-131k`, `nail-qwen3.6-35b-a3b-262k`, `nail-qwen3.6-35b-a3b-vision-131k`, `nail-qwen3.6-35b-a3b-vision-262k` |
| `occult-nail-1.0-35b-a3b` | `peculiar-ragdoll` | `agentic-auto-131k-1024`, `agentic-auto-262k-1024`, `agentic-auto-vision-131k-1024`, `agentic-auto-vision-262k-1024` | `occult-nail-1.0-35b-a3b-131k`, `occult-nail-1.0-35b-a3b-262k`, `occult-nail-1.0-35b-a3b-vision-131k`, `occult-nail-1.0-35b-a3b-vision-262k` |
| `cyber-tiel-coder-35b-a3b` | `peculiar-ragdoll` | `agentic-auto-131k-1024`, `agentic-auto-262k-1024`, `agentic-auto-vision-131k-1024`, `agentic-auto-vision-262k-1024` | `cyber-tiel-coder-35b-a3b-131k`, `cyber-tiel-coder-35b-a3b-262k`, `cyber-tiel-coder-35b-a3b-vision-131k`, `cyber-tiel-coder-35b-a3b-vision-262k` |
| `nemotron-3.5-lightning-30b-a3b` | `AtomicChat` | `agentic-auto-131k-1024`, `agentic-auto-262k-1024` | `nemotron-3.5-lightning-30b-a3b-131k`, `nemotron-3.5-lightning-30b-a3b-262k` |
| `flint` | `unsloth` | `agentic-auto-131k-1024`, `agentic-auto-262k-1024` | `flint-131k`, `flint-262k` |
| `apex-35b-v1.0` | `Apexintelligence-AI` | `agentic-auto-131k-1024`, `agentic-auto-262k-1024` | `apex-35b-v1.0-131k`, `apex-35b-v1.0-262k` |
| `gemma-4-26b-a4b-uncensored-balanced` | `HauhauCS` | `agentic-auto-131k-1024`, `agentic-auto-262k-1024`, `agentic-auto-vision-131k-1024`, `agentic-auto-vision-262k-1024` | `gemma-4-26b-a4b-uncensored-balanced-131k`, `gemma-4-26b-a4b-uncensored-balanced-262k`, `gemma-4-26b-a4b-uncensored-balanced-vision-131k`, `gemma-4-26b-a4b-uncensored-balanced-vision-262k` |
| `lfm3-1.7b` | `LiquidAI` | `agentic-auto-262k-1024` | `lfm3-1.7b-262k` |
| `lfm3-vl-2b` | `LiquidAI` | `agentic-auto-vision-128k-1024` | `lfm3-vl-2b-vision-128k` |
| `lfm3-audio-2b` | `LiquidAI` | `agentic-auto-audio-32k-1024` | `lfm3-audio-2b-audio-32k` |
| `lfm3-omni-2b` | `LiquidAI` | `agentic-auto-omni-32k-1024` | `lfm3-omni-2b-omni-32k` |

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
├── experimental/                 # Separate root outside the catalog (see its README)
```

## Installation

1. Install the runtime:

```powershell
powershell -NoProfile -ExecutionPolicy RemoteSigned -File scripts/setup/Install-LlamaRuntime.ps1
```

The default is `b11981`, the build every launcher uses; `-Version b11551` reinstalls
the previous pinned build if a rollback is needed.

2. Download a model:

```powershell
powershell -NoProfile -ExecutionPolicy RemoteSigned -File scripts/setup/Download-Model.ps1 -Model nail-qwen3.6-35b-a3b
```

3. Validate integrity:

```powershell
powershell -NoProfile -ExecutionPolicy RemoteSigned -File scripts/common/Test-ModelIntegrity.ps1 -Model nail-qwen3.6-35b-a3b
```

## Launchers

The launchers are grouped by model (representative commands below):

```bat
scripts\models\tiel-coder-35b-a3b\start-agentic-auto-131k-1024.cmd
scripts\models\tiel-coder-35b-a3b\start-agentic-auto-vision-131k-1024.cmd
scripts\models\nail-qwen3.6-35b-a3b\start-agentic-auto-131k-1024.cmd
scripts\models\occult-nail-1.0-35b-a3b\start-agentic-auto-131k-1024.cmd
scripts\models\cyber-tiel-coder-35b-a3b\start-agentic-auto-131k-1024.cmd
scripts\models\nemotron-3.5-lightning-30b-a3b\start-agentic-auto-131k-1024.cmd
scripts\models\flint\start-agentic-auto-131k-1024.cmd
scripts\models\apex-35b-v1.0\start-agentic-auto-131k-1024.cmd
scripts\models\lfm3-1.7b\start-agentic-auto-262k-1024.cmd
scripts\models\lfm3-vl-2b\start-agentic-auto-vision-128k-1024.cmd
scripts\models\lfm3-audio-2b\start-agentic-auto-audio-32k-1024.cmd
scripts\models\lfm3-omni-2b\start-agentic-auto-omni-32k-1024.cmd
```

Each `.cmd` contains the runtime path, model path, and all effective parameters for its profile. The launchers materialize `--gpu-layers auto`, `--fit on` and `--fit-target 1024` —`2048` in the vision profiles, because `--fit` does not account for the projector— and declare the context explicitly, since `--fit` only adjusts unset arguments. They omit `--n-cpu-moe`: `--fit` places the weights with a per-layer `-ot` override instead of that lever. To customize context, port, sampling, or other values, edit the corresponding launcher directly. The scripts do not accept hidden additional arguments.

Every launcher declares its `--alias` as `<model-id>,<profile-id>`, listed in the table above. The bare model id stays first, so clients that already name it keep working, and `/v1/models` reports both names. The second alias lets a client ask for the exact profile that is running — `nail-qwen3.6-35b-a3b-262k` cannot be answered by the 131K launcher. It does not let a client *choose* a profile: the launcher still decides context, sampling, placement, and reasoning budget, and only one profile can hold port 8080 at a time. A request naming a profile the running launcher does not serve fails with `model '<id>' not found`.

`Test-Llm.ps1` requires the first alias to be the model id, requires each profile alias to be unique across launchers, and refuses a profile alias that shadows a model id.

The terminal remains linked to `llama-server` and displays loading, prompt processing, speed, and errors in real time. Stop the server with `Ctrl+C` in that same terminal.

## API

- Web interface: `http://localhost:8080`
- OpenAI API: `http://localhost:8080/v1`
- Health: `http://localhost:8080/health`
- Models: `http://localhost:8080/v1/models`

`/v1/models` reports the bare model id and the profile id of the running launcher; a request may name either one. `/health` answers only while a launcher is running, so it doubles as the check for whether port 8080 is free.

Profiles listen on `0.0.0.0:8080`
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
powershell -NoProfile -ExecutionPolicy RemoteSigned -File scripts/common/Test-ModelIntegrity.ps1 -Model nail-qwen3.6-35b-a3b
```

Run a brief functional test:

```powershell
powershell -NoProfile -ExecutionPolicy RemoteSigned -File scripts/common/Test-Llm.ps1 -Model nail-qwen3.6-35b-a3b -Profile agentic-auto-vision-131k-1024
```

Functional tests control and close only the process tree they initiate.

## Documentation

- [Backend and architecture](docs/overview/inference-backend.md)
- [Management, download, and testing](docs/overview/model-management.md)
- [How to add a model](docs/overview/adding-a-model.md)
- [Model cards](docs/overview/models)
- [Self-contained launcher ADR](docs/adr/ADR-0001-self-contained-model-launchers.md)
- [Architecture change](docs/changelog/2026-08-07-self-contained-launchers.md)
