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
launcher except those of `ternary-bonsai-2.5-27b` (PrismML fork, see below) pins `b12359-cuda13.5` (the build behind llama.cpp v1.0.0) since 2026-11-15,
when it replaced `b11981-cuda13.4` after measuring faster without MTP on Qwen3.6-35B-A3B;
`b11981` was removed the same day
([changelog](docs/changelog/2026-11-15-llama-runtime-b12359-v1.0.0.md)). `b11981` had
replaced `b11551-cuda13.4` on 2026-10-30, and `b11551` was removed that day
([changelog](docs/changelog/2026-10-30-llama-runtime-b11981-catalog.md)).
`b11669-cuda13.4` (llama.cpp v0.7.0) was used on 2026-10-27 and removed on 2026-10-28
because it performed worse for the user. `b11269-cuda13.4` was removed on 2026-10-22
and `b11827-cuda13.4`, which `flint` used until its retirement, on 2026-10-26; all five
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

On 2026-11-02 `experimental/` came back as a separate root, outside this catalog, with a CPU-only 8K profile of `gemma-4-26b-a4b-uncensored-balanced` (sharing this catalog's GGUF) on loopback port 8081 and `Start-Assistant.cmd`, a terminal utility that starts the model, answers prompts with an instructions file and stops the model on exit. `lfm3-1.7b-uncensored` (poor prompt quality) and `occult-nail-1.0-35b-a3b` were tried first the same day. It is not registered in any client ([changelog](docs/changelog/2026-11-02-experimental-lfm3-1.7b-uncensored.md)).

On 2026-11-11 `qwen3.6-35b-a3b`, retired on 2026-10-28, came back as the official Unsloth `UD-Q4_K_XL` build (the GGUF with the MTP layer, kept from a Strata comparison; the profiles do not use the layer) with the projector shared with Nail, in text and vision profiles at 131K and 262K. Strata was evaluated and removed the same day ([changelog](docs/changelog/2026-11-11-qwen3.6-35b-a3b.md)).

On 2026-11-16 `ornith-1.5-9b` (the official `Q4_K_M` from `ornith-ai`) and `gemma-4-12b-it-qat` (the Unsloth `UD-Q4_K_XL` QAT build with a BF16 projector and the external MTP drafter) came back. Ornith has text profiles at 131K and 262K, and the same day gained its BF16 projector with vision profiles at both contexts that have not been run yet ([changelog](docs/changelog/2026-11-16-ornith-1.5-9b-vision.md)); Gemma has text, MTP and vision profiles at 131K and 262K, and the MTP profiles are the only ones using speculative decoding ([changelog](docs/changelog/2026-11-16-ornith-1.5-9b-gemma-4-12b-it-qat.md)).

On 2026-11-17 `gemma-4-26b-a4b-it-qat` (the Unsloth `UD-Q4_K_XL` QAT build, Q4_0 in its tensors, with a BF16 projector) replaced `gemma-4-26b-a4b-uncensored-balanced` in this catalog, in text and vision profiles at 131K and 262K without MTP; its profiles were not run, at the user's request. The HauhauCS weights stay in `models\` because the unused Gemma launcher and manifest of `experimental/` still reference them. The same day `gemma-4-e4b-it-qat` (Google's official Q4_0 QAT GGUF, with a projector for image and audio) joined with text and vision profiles at its native 131K ([changelog](docs/changelog/2026-11-17-gemma-4-26b-a4b-it-qat-gemma-4-e4b-it-qat.md)).

On 2026-11-21 `gemma-4-12b-uncensored-balanced` (HauhauCS, an uncensored build of Gemma 4 12B from the official QAT weights) joined with its `Q4_K_M` build, BF16 projector and bundled MTP drafter, in the same six profiles as `gemma-4-12b-it-qat` and with the sampling its card recommends; its profiles were not run, at the user's request ([changelog](docs/changelog/2026-11-21-gemma-4-12b-uncensored-balanced.md)).

On 2026-11-23 Strata moved to 0.2.20, and `inkling-2-mini-ud-q4_k_xl` (the Unsloth `UD-Q4_K_XL` GGUF of Inkling 2 Mini with its DSpark drafter) joined the `strata/` sub-root in text profiles at 131K, 262K and its native 1M, served without reasoning ([changelog](docs/changelog/2026-11-23-strata-0.2.20-inkling-ud-q4_k_xl.md)). It was removed the same day, together with Strata 0.2.18 and 0.2.19: its DSpark drafter does not load from a GGUF on Strata's CUDA backend, and without it the model generated under 20 tok/s ([changelog](docs/changelog/2026-11-23-inkling-2-mini-ud-q4_k_xl-removal.md)).

On 2026-11-24 Strata 0.2.21 was installed next to 0.2.20, and `inkling-2-mini-ud-q4_k_xl` came back on it with the same three profiles: Unsloth's re-uploaded `UD-Q4_K_XL` GGUF, Thinking Machines' `mtp.safetensors` as the DSpark drafter (0.2.21 loads it) and reasoning, which 0.2.21 now serves. The Qwen3.8 Flash Next launchers stay on 0.2.20 ([changelog](docs/changelog/2026-11-24-strata-0.2.21-inkling-ud-q4_k_xl.md)). Both were ruled out the same day and removed: Inkling generated about 45-50 tok/s at 262K and half that at 131K, with very slow prompt processing, and Flash Next on 0.2.21 did not pass 65-70 tok/s where 0.2.20 stays above 100 tok/s ([changelog](docs/changelog/2026-11-24-inkling-2-mini-ud-q4_k_xl-strata-0.2.21-removal.md)).

On 2026-11-25 `ternary-bonsai-2.5-27b` (PrismML's ternary build of Qwen3.8-27B, 1.76 bits per weight) joined with its `PTQ1_0` files with and without the integrated MTP head and a BF16 projector, in text, MTP and vision profiles at 131K; 262K does not fit in VRAM with a `q8_0` KV cache. It is the only model on the PrismML fork runtime `prism-b12178-cuda13.3`, since stock llama.cpp rejects `PTQ1_0` ([changelog](docs/changelog/2026-11-25-ternary-bonsai-2.5-27b.md)).

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
| `gemma-4-26b-a4b-it-qat` | `unsloth` | `agentic-auto-131k-1024`, `agentic-auto-262k-1024`, `agentic-auto-vision-131k-1024`, `agentic-auto-vision-262k-1024` | `gemma-4-26b-a4b-it-qat-131k`, `gemma-4-26b-a4b-it-qat-262k`, `gemma-4-26b-a4b-it-qat-vision-131k`, `gemma-4-26b-a4b-it-qat-vision-262k` |
| `lfm3-1.7b` | `LiquidAI` | `agentic-auto-262k-1024` | `lfm3-1.7b-262k` |
| `lfm3-vl-2b` | `LiquidAI` | `agentic-auto-vision-128k-1024` | `lfm3-vl-2b-vision-128k` |
| `lfm3-audio-2b` | `LiquidAI` | `agentic-auto-audio-32k-1024` | `lfm3-audio-2b-audio-32k` |
| `lfm3-omni-2b` | `LiquidAI` | `agentic-auto-omni-32k-1024` | `lfm3-omni-2b-omni-32k` |
| `qwen3.6-35b-a3b` | `unsloth` | `agentic-auto-131k-1024`, `agentic-auto-262k-1024`, `agentic-auto-vision-131k-1024`, `agentic-auto-vision-262k-1024` | `qwen3.6-35b-a3b-131k`, `qwen3.6-35b-a3b-262k`, `qwen3.6-35b-a3b-vision-131k`, `qwen3.6-35b-a3b-vision-262k` |
| `ornith-1.5-9b` | `ornith-ai` | `agentic-auto-131k-1024`, `agentic-auto-262k-1024`, `agentic-auto-vision-131k-1024`, `agentic-auto-vision-262k-1024` | `ornith-1.5-9b-131k`, `ornith-1.5-9b-262k`, `ornith-1.5-9b-vision-131k`, `ornith-1.5-9b-vision-262k` |
| `gemma-4-12b-it-qat` | `unsloth` | `agentic-auto-131k-1024`, `agentic-auto-262k-1024`, `agentic-auto-mtp-131k-1024`, `agentic-auto-mtp-262k-1024`, `agentic-auto-vision-131k-2048`, `agentic-auto-vision-262k-2048` | `gemma-4-12b-it-qat-131k`, `gemma-4-12b-it-qat-262k`, `gemma-4-12b-it-qat-mtp-131k`, `gemma-4-12b-it-qat-mtp-262k`, `gemma-4-12b-it-qat-vision-131k`, `gemma-4-12b-it-qat-vision-262k` |
| `gemma-4-12b-uncensored-balanced` | `HauhauCS` | `agentic-auto-131k-1024`, `agentic-auto-262k-1024`, `agentic-auto-mtp-131k-1024`, `agentic-auto-mtp-262k-1024`, `agentic-auto-vision-131k-2048`, `agentic-auto-vision-262k-2048` | `gemma-4-12b-uncensored-balanced-131k`, `gemma-4-12b-uncensored-balanced-262k`, `gemma-4-12b-uncensored-balanced-mtp-131k`, `gemma-4-12b-uncensored-balanced-mtp-262k`, `gemma-4-12b-uncensored-balanced-vision-131k`, `gemma-4-12b-uncensored-balanced-vision-262k` |
| `gemma-4-e4b-it-qat` | `google` | `agentic-auto-131k-1024`, `agentic-auto-vision-131k-1024` | `gemma-4-e4b-it-qat-131k`, `gemma-4-e4b-it-qat-vision-131k` |
| `ternary-bonsai-2.5-27b` | `prism-ml` | `agentic-auto-131k-1024`, `agentic-auto-mtp-131k-1024`, `agentic-auto-vision-131k-1024` | `ternary-bonsai-2.5-27b-131k`, `ternary-bonsai-2.5-27b-mtp-131k`, `ternary-bonsai-2.5-27b-vision-131k` |

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
├── strata/                       # Qwen3.8 Flash Next on Strata, outside the llama.cpp catalog but registered in the clients (see its README)
├── speech/                       # Speech models on NeMo-Speech.cpp, outside the catalog and its clients (see its README)
```

## Installation

1. Install the runtime:

```powershell
powershell -NoProfile -ExecutionPolicy RemoteSigned -File scripts/setup/Install-LlamaRuntime.ps1
```

The default is `b12359`, the build every launcher uses except Ternary Bonsai; `-Version b11981` reinstalls
the previous pinned build if a rollback is needed. `-Version prism-b12178` installs the PrismML fork
release that `ternary-bonsai-2.5-27b` needs.

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

Every launcher declares its `--alias` as `<model-id>,<profile-id>`, listed in the table above. The bare model id stays first, so clients that already name it keep working, and `/v1/models` reports both names. The second alias is a label: each client lists one entry per profile alias so the user can see which model, context and vision mode they picked. It does not route or choose a profile: every entry points at the same endpoint, the running launcher answers a request whatever alias it names (on 2026-11-11 the vision 131K launcher of `qwen3.6-35b-a3b` answered `qwen3.6-35b-a3b-262k`), and it still decides context, sampling, placement, reasoning budget and whether images are accepted. Only one profile can hold port 8080 at a time, so pick the client entry that matches the launcher you started.

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
- [Speech transcription (Nemotron 3.5 Transcribe, port 8090)](speech/README.md)
- [Qwen3.8 Flash Next on Strata (port 8080)](strata/README.md)
- [Self-contained launcher ADR](docs/adr/ADR-0001-self-contained-model-launchers.md)
- [Architecture change](docs/changelog/2026-08-07-self-contained-launchers.md)
