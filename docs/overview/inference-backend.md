# Inference Backend

## Responsibilities

- `models`: GGUF artifacts without operational scripts.
- `runtimes`: versioned `llama.cpp` runtimes.
- `config`: declarative catalog with verifiable download and integrity metadata.
- `scripts/models`: source of truth for each profile's parameters.
- `scripts/common`: launcher and integrity validation, no common startup.
- `logs`: validation results and historical references.
- `tests/assets`: small files for functional tests.

Each `start-*.cmd` resolves `LLM_ROOT` locally, pins the runtime, and materializes all its arguments. This controlled duplication makes the effective configuration visible and avoids inheritance between runtime, model, and profile. The decision and its consequences are documented in
[ADR-0001](../adr/ADR-0001-self-contained-model-launchers.md).

Every profile materializes `--gpu-layers auto`, `--fit on` and `--fit-target
1024` — `2048` in the vision profiles, because `--fit` does not account for the
projector — which declares a delegated placement policy instead of a fixed layer
count. The runtime resolves it by emitting a per-layer `-ot` override, so the
launchers omit `--n-cpu-moe` entirely, and the context stays declared because
`--fit` only adjusts unset arguments. Every other argument in those launchers
stays materialized. The hand-tuned profiles that pinned `--gpu-layers 999` with
`--n-cpu-moe` were retired on 2026-09-30; their reference copy was deleted on
2026-10-01.

## Installed Runtimes

Two official `llama.cpp` runtimes and one source build are installed. Every launcher except `lfm3-1.7b` pins `b11669`
since 2026-10-27; `b11551`, the previous pinned build, stays installed for
rollback. `b11269` was uninstalled on 2026-10-22 and `b11827`, which only the
retired `flint` used, on 2026-10-26; `Install-LlamaRuntime.ps1` installs any of
the four with `-Version`.

`b11669` is the build behind the stable release v0.7.0: the release ships no
binaries and its `nightly-tag.txt` asset points to `b11669`. Every flag and value
the launchers use is present in its `--help`. No profile has been smoke-tested or
calibrated on it yet; see the
[runtime changelog](../changelog/2026-10-27-llama-runtime-b11669.md).

- Version: `b11669` (v0.7.0)
- Commit: `620d2225c`
- Reported version: `0.7.0-dev (build 11669, commit 620d2225c)`
- Directory: `runtimes\llama.cpp\b11669-cuda13.4`
- Package: `llama-b11669-bin-win-cuda-13.4-x64.zip`
- SHA-256: `3b92d5c064f5032e603e531d3ec8961f3bd6613e5dfad047399a92dec8e95dbc`
- CUDA runtime SHA-256: `738f8c251ac22b70c3ae6f83a10cf222725df0395246a2cf58f32bdb85fbe668`
- Functional validation: pending

`b11551` (nightly) was the first build that contained MiniCPM-V 4.7 support
(PR #29416); MiniCPM-V was retired on 2026-10-26 and the remaining models were
validated on it. Returning to it is editing one `SERVER` line per launcher:

- Version: `b11551` (nightly)
- Commit: `69f201a20` (merge commit of PR #29416)
- Reported version: `0.6.0-dev (build 11551, commit 69f201a20)`
- Directory: `runtimes\llama.cpp\b11551-cuda13.4`
- Package: `llama-b11551-bin-win-cuda-13.4-x64.zip`
- SHA-256: `80c5f94fe5ecd8090fe682c89861a949efb4a3487782cfcd99252a18f571afc7`
- CUDA runtime SHA-256: `738f8c251ac22b70c3ae6f83a10cf222725df0395246a2cf58f32bdb85fbe668`
- Validated GPU: NVIDIA RTX 5080
- Validated driver: 616.56

`b11827` (nightly, commit `970b51ce7`, package SHA-256
`5d54c5fa2f26d9c80fa7439692e5929e8f7f1e7b2d00e3d6ab5a919154c768fa`) was installed
for Flint support (PR #30928) and its template's Jinja escapes (PR #30929). It was
removed with `flint` on 2026-10-26 and can be reinstalled with `-Version b11827`.

`b11269` is no longer installed; returning to it is running the installer with
`-Version b11269` and editing one `SERVER` line per launcher:

- Version: `b11269`
- Commit: `cee37ffea`
- Reported version: `0.5.0-dev (build 11269, commit cee37ffea)`
- Directory: `runtimes\llama.cpp\b11269-cuda13.4`
- Package: `llama-b11269-bin-win-cuda-13.4-x64.zip`
- SHA-256: `79e8431306e0d5dad9f7d429272226387d449a167d3e9285cdf0ec0edce8b27e`
- CUDA runtime SHA-256: `738f8c251ac22b70c3ae6f83a10cf222725df0395246a2cf58f32bdb85fbe668`
- Validated GPU: NVIDIA RTX 5080
- Validated driver: 616.56

### Source-built runtime (19ff817)

`lfm3-1.7b` and the experimental `lfm3-audio-2b` and `lfm3-omni-2b` use
`runtimes\llama.cpp\19ff817-cuda13.4`, **built locally from source**, because no
official release contained LFM3 support when they were added: the `lfm3` text
architecture (PR #31252) and LFM3-Audio/Omni (PR #31257) were merged on
2026-10-27, after the latest nightly then available (`b11936`). It has no SHA-256
published upstream; the hashes below identify this local build only.

- Commit: `19ff817fb25e9a1b838b1d7f9f4325f7bf9779c4` (merge commit of PR #31257 on
  `master`, which already contains PR #31252)
- Reported version: `0.7.0-dev (build 1, commit 19ff817)`; the build number is the
  commit count of the shallow checkout, not an upstream `bNNNNN`
- Script: [Build-LlamaRuntime.cmd](../../scripts/setup/Build-LlamaRuntime.cmd); source
  and build tree in `packages\llama.cpp\19ff817\src`
- Toolchain: Visual Studio 2022 Build Tools (MSVC 19.44.35222.0, bundled CMake and
  Ninja), CUDA Toolkit 13.4.59
- Options: `GGML_CUDA=ON`, `CMAKE_CUDA_ARCHITECTURES=120` (RTX 5080 only),
  `GGML_NATIVE=ON` (host CPU), `LLAMA_OPENSSL=OFF` (weights come from
  `Download-Model.ps1`); not portable to other CPUs or GPUs
- Hashes also stored in `runtimes\llama.cpp\19ff817-cuda13.4.sha256.txt`

| File | SHA-256 |
| --- | --- |
| `llama-server.exe` | `09d2510772010308343cdc684d28102f3c9ea71e296770ea7c9293d73e35c408` |
| `llama-tts.exe` | `e74f6fe7bec261a491687d644c0d4ee7cf49788f9ed39a887ef70d6e182abeda` |
| `llama-mtmd-cli.exe` | `9e4bcc5bdf325bb6919bae7c2bd6ba8fa8327efc8b50741b36fb96fa2df48210` |
| `llama-cli.exe` | `a32cfb6f13d33be46baaf5166227c0083227165d76c0da065c5efef10126e2d0` |
| `llama.dll` | `9c4afbd60edd4b816c90aca8253be72af2fdd61d9e9ff4e0923210feaa69307f` |
| `mtmd.dll` | `de038aefdda9ae37bb4c9d5b33930ec58c14c60196bb7fef1968448b50c874c2` |
| `ggml.dll` | `eb9898fcf97805449acf43a28043f57828c7e0dd98deeabc493e2b525be89b59` |
| `ggml-base.dll` | `ea624059b213fdbf2f96140eb43bd03e47ae0038ed5da15f9ab640246745f786` |
| `ggml-cpu.dll` | `7c5deb5bbe8ce9adfa098c2b09b39f0156e95f01dc4b28afe0fc1766a22f2d06` |
| `ggml-cuda.dll` | `c03ab3b0faacbc0f7e0ddd9580c62afe55b1dcc83d63a4b56062a32e6048a9d1` |
| `cudart64_13.dll` (CUDA 13.4) | `05bfafcb97bd53b0089568a96e1e5bd6921637bd0853ff7f5342bd31a6a16890` |

MSVC output is not bit-for-bit reproducible, so a rebuild yields new hashes. When
an official release contains both PRs, install it with `Install-LlamaRuntime.ps1`,
point the LFM3 launchers at it and repeat their tests; this runtime and its source
tree can then be removed.

The installer accepts both the legacy numeric version output and the current
semantic-version output while still requiring the pinned build and commit. Both
pin the same `cudart` archive and the 13.4 toolkit, which is why the runtime
directory is suffixed `cuda13.4`. Each install is verified through
`llama-server --version`. The `b10502-cuda13.3` runtime was deleted on
2026-10-01 and the `b11269-cuda13.4` runtime on 2026-10-22.

The swap of 2026-10-13 changed only the executable each launcher pins. On the
same profile and arguments `b11551` keeps the same `--fit` placement and the same
KV allocation as `b11269`, uses 26–32 MiB more compute buffer, improves prefill
by 28 % and leaves decode within noise; the calibration tables in the model cards
were measured with `b11269` and stay recorded as such in the
[runtime changelog](../changelog/2026-10-13-llama-runtime-b11551-catalog.md).

Launchers pin the executable they need, no DLL is copied between runtime
directories, and the global `PATH` is not modified.

## Process and Logs

Normal execution calls `llama-server.exe` directly and keeps the terminal linked. There is no managed PID nor a global stop utility; the user stops the server with `Ctrl+C`.

All profiles use port 8080, so only one can listen at a time. `Test-Llm.ps1` starts each test in its own process tree, redirects its output to `logs\validation`, and terminates only that tree upon completion.

## Network

Profiles use `0.0.0.0:8080`, accessible from Windows, WSL, and the local network if the system configuration allows it. No Firewall rules are created and the API does not use authentication. It should not be exposed to a public or untrusted network.

## Reasoning

Launchers use `--reasoning auto`: thinking stays on by default when the template supports it, and each request can turn it off. With `--reasoning on`, the server injects `enable_thinking=true` as a template kwarg that overrides `reasoning_effort: "none"` (measured on build `11551`). Per-request controls that reach the model:

- `reasoning_effort: "none"` (Chat Completions) or `reasoning.effort: "none"` (Responses) turns thinking off.
- `chat_template_kwargs: {"enable_thinking": false}` turns thinking off.
- `thinking_budget_tokens` / `reasoning_budget_tokens` overrides the launcher's `--reasoning-budget`.
- Other `reasoning_effort` levels are passed to the template; only templates that read them (Tiel) change behavior.
- Anthropic `thinking: {"type": "disabled"}` is not mapped by the server and does not turn thinking off.

## Customizing Parameters

Edit the literal values in the corresponding `.cmd`. To preserve a variant, copy the launcher with another name `start-<profile>.cmd` and validate the new total. There are no generic overrides for port, context, or reasoning from the command line.
