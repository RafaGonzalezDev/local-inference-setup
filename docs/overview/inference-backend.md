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

Two official `llama.cpp` runtimes are installed. Every launcher pins `b11669`
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

A source-built runtime (`19ff817-cuda13.4`, llama.cpp commit `19ff817`, compiled locally for the LFM3
models) was installed from 2026-10-27 and deleted on 2026-10-28 with those models; see the
[retirement changelog](../changelog/2026-10-28-lfm3-retirement.md). Compiling from a llama.cpp commit
is allowed when a model needs support no release has yet, provided the user is told and the commit,
toolchain and binary SHA-256 values are recorded.

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
