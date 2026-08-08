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

- Version: `b10273`
- Commit: `a6aa6f545`
- Directory: `runtimes\llama.cpp\b10273-cuda13.3`
- Package: `llama-b10273-bin-win-cuda-13.3-x64.zip`
- SHA-256: `2354c37455b4371145589d87cdd468a19c1fe6420649aaec3cf3ed68b20a61c6`
- CUDA runtime SHA-256: `1462a050eb4c684921ba51dcc4cc488a036674c3e73e9945ee705b854808d03e`
- Validated GPU: NVIDIA RTX 5080
- Validated driver: 610.47

Ternary Bonsai 27B uses the PrismML fork because its `Q2_0` quantization with 128-element groups is not compatible with the main runtime:

- Release: `prism-b9599-9ca265a`
- Commit: `9ca265a57f85f2117942490f421f64a226dd9847`
- Directory: `runtimes\llama.cpp\prism-b9599-9ca265a-cuda12.4`
- Package SHA-256: `d6b473338a05a56b815044a7a02caeea04942bb6dda8b8de019a9a5252c6f50a`
- CUDA runtime SHA-256: `8c79a9b226de4b3cacfd1f83d24f962d0773be79f1e7b75c6af4ded7e32ae1d6`

The three Ternary launchers directly pin this runtime. DLLs are not mixed between installations and the global `PATH` is not modified.

## Process and Logs

Normal execution calls `llama-server.exe` directly and keeps the terminal linked. There is no managed PID nor a global stop utility; the user stops the server with `Ctrl+C`.

All profiles use port 8080, so only one can listen at a time. `Test-Llm.ps1` starts each test in its own process tree, redirects its output to `logs\validation`, and terminates only that tree upon completion.

## Network

Profiles use `0.0.0.0:8080`, accessible from Windows, WSL, and the local network if the system configuration allows it. No Firewall rules are created and the API does not use authentication. It should not be exposed to a public or untrusted network.

## Customizing Parameters

Edit the literal values in the corresponding `.cmd`. To preserve a variant, copy the launcher with another name `start-<profile>.cmd` and validate the new total. There are no generic overrides for port, context, or reasoning from the command line.
