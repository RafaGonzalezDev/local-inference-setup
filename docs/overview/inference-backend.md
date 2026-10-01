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

## Installed Runtime

The runtime is the official `llama.cpp`:

- Version: `b11269`
- Commit: `cee37ffea`
- Reported version: `0.5.0-dev (build 11269, commit cee37ffea)`
- Directory: `runtimes\llama.cpp\b11269-cuda13.4`
- Package: `llama-b11269-bin-win-cuda-13.4-x64.zip`
- SHA-256: `79e8431306e0d5dad9f7d429272226387d449a167d3e9285cdf0ec0edce8b27e`
- CUDA runtime SHA-256: `738f8c251ac22b70c3ae6f83a10cf222725df0395246a2cf58f32bdb85fbe668`
- Validated GPU: NVIDIA RTX 5080
- Validated driver: 616.56

The installer accepts both the legacy numeric version output and the current
semantic-version output while still requiring the pinned build and commit. The
`b11269` release moves the Windows x64 CUDA asset from the 13.3 toolkit to 13.4,
which is why the runtime directory is suffixed `cuda13.4`. The install was
verified through `llama-server --version`; functional validation of the profiles
against this runtime is still pending. The `b10502-cuda13.3` runtime was deleted
on 2026-10-01, so this is the only installed runtime.

The runtime is installed in its own immutable directory. Launchers pin the
executable they need and no DLL is copied between runtime directories.

All retained profiles use this runtime. Runtime DLLs remain isolated
and the global `PATH` is not modified.

## Process and Logs

Normal execution calls `llama-server.exe` directly and keeps the terminal linked. There is no managed PID nor a global stop utility; the user stops the server with `Ctrl+C`.

All profiles use port 8080, so only one can listen at a time. `Test-Llm.ps1` starts each test in its own process tree, redirects its output to `logs\validation`, and terminates only that tree upon completion.

## Network

Profiles use `0.0.0.0:8080`, accessible from Windows, WSL, and the local network if the system configuration allows it. No Firewall rules are created and the API does not use authentication. It should not be exposed to a public or untrusted network.

## Customizing Parameters

Edit the literal values in the corresponding `.cmd`. To preserve a variant, copy the launcher with another name `start-<profile>.cmd` and validate the new total. There are no generic overrides for port, context, or reasoning from the command line.
