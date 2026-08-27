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

## Installed Runtimes

The default runtime is the official `llama.cpp`:

- Version: `b10502`
- Commit: `0adcc3bb5`
- Reported version: `0.1.2-dev (build 10502, commit 0adcc3bb5)`
- Directory: `runtimes\llama.cpp\b10502-cuda13.3`
- Package: `llama-b10502-bin-win-cuda-13.3-x64.zip`
- SHA-256: `657ad104b7c2f3aaf9abac91b48ffb72a2556cb8a6a38d395eaaf64bc1f1f719`
- CUDA runtime SHA-256: `1462a050eb4c684921ba51dcc4cc488a036674c3e73e9945ee705b854808d03e`
- Validated GPU: NVIDIA RTX 5080
- Validated driver: 610.47

The previous `b10361-cuda13.3` runtime remains installed for rollback. The
installer accepts both the legacy numeric version output and the current
semantic-version output while still requiring the pinned build and commit.

All retained profiles use the official runtime. Runtime DLLs remain isolated and
the global `PATH` is not modified.

## Process and Logs

Normal execution calls `llama-server.exe` directly and keeps the terminal linked. There is no managed PID nor a global stop utility; the user stops the server with `Ctrl+C`.

All profiles use port 8080, so only one can listen at a time. `Test-Llm.ps1` starts each test in its own process tree, redirects its output to `logs\validation`, and terminates only that tree upon completion.

## Network

Profiles use `0.0.0.0:8080`, accessible from Windows, WSL, and the local network if the system configuration allows it. No Firewall rules are created and the API does not use authentication. It should not be exposed to a public or untrusted network.

## Customizing Parameters

Edit the literal values in the corresponding `.cmd`. To preserve a variant, copy the launcher with another name `start-<profile>.cmd` and validate the new total. There are no generic overrides for port, context, or reasoning from the command line.
