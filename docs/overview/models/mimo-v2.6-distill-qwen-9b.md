# MiMo V2.6 Distill Qwen 9B Q6_K

MiMo is a Qwen3.5-9B-derived agentic model with hybrid linear/full attention,
a native 262,144-token context, and optional image input. Its GGUF architecture
is `qwen35`; it is not a mixture-of-experts model.

## Provenance and artifacts

- Model/API ID: `mimo-v2.6-distill-qwen-9b`.
- Repository: `bartowski/MiMo-V2.6-Distill-Qwen-9B-GGUF`.
- Pinned revision: `4371da10c84fb26da3592d4cf312d24aa82b7b65`.
- Upstream: `XiaomiMiMo/MiMo-V2.6-Distill-Qwen-9B`, MIT license.

| Artifact | Bytes | SHA-256 |
| --- | ---: | --- |
| `MiMo-V2.6-Distill-Qwen-9B-Q6_K.gguf` | 7,793,710,624 | `ef96d05a2ddf2cbb450d1af1ac3860ec769d3575bafa70692ee5609bda3fad7d` |
| `mmproj-MiMo-V2.6-Distill-Qwen-9B-f16.gguf` | 918,166,048 | `ff348f3180a63188aa7285db85f550fe38acb61dd013c599eb8bad08d2cc2576` |

The text-only profiles do not load the projector. No imatrix or calibration
files are required for inference. This distribution does not provide a
speculative draft model; MTP is disabled.

## Profiles

Launchers live in `scripts/models/mimo-v2.6-distill-qwen-9b/`.

| Launcher | Context | Batch/UBatch | Vision |
| --- | ---: | ---: | --- |
| `start-agentic-131k-1024.cmd` | 131,072 | 1,024/1,024 | no |
| `start-agentic-262k-1024.cmd` | 262,144 | 1,024/1,024 | no |
| `start-agentic-vision-131k-1024.cmd` | 131,072 | 1,024/1,024 | yes |
| `start-agentic-vision-262k-1024.cmd` | 262,144 | 1,024/1,024 | yes |

All profiles use GPU offload, one slot, Flash Attention, eight CPU threads,
Jinja with the embedded MiMo template, and `q8_0` K/V caches. Automatic fitting
is disabled so the requested context is not silently reduced. No `n-cpu-moe`
option is applied. Batch sizes and cache settings are local adaptations, not
upstream performance recommendations.

Sampling follows upstream `generation_config.json`: temperature `0.6`, top-p
`0.95`, top-k `20`. Min-p and presence penalty are explicitly zero and repeat
penalty is `1`. Reasoning is enabled with no artificial reasoning budget
(`--reasoning-budget -1`); clients must still set a suitable `max_tokens`.

All four Windows launchers bind to `0.0.0.0:8080`, like Ornith 1.5 9B.
The WSL clients use `http://192.168.1.100:8080/v1`; Windows-only loopback was
not reachable from WSL. Restart a running server after changing the binding.
No firewall rules are created and the API has no authentication: use a trusted
network only. Only one profile can run on port 8080. Stop it with `Ctrl+C`.

Pi/OpenCode retain client selection aliases ending in `-131k` and `-262k`,
but both map to the server ID `mimo-v2.6-distill-qwen-9b`. Selecting an alias
does not change server context or load the projector. Start the corresponding
Windows launcher; images require a `vision` profile. The client output cap
of 16,384 tokens is a policy, not a measured model limit.

## Runtime and installation

These profiles pin official llama.cpp `b10964-cuda13.3`, commit
`b29c606e28a01b1bc8c1351026a0fa6e616bf6c4`, matching the release used for
quantization. It is installed side by side with `b10502`; other launchers and
the default installer version remain unchanged. DLLs are not shared.

Run from `D:\LLM` in PowerShell:

```powershell
powershell -NoProfile -ExecutionPolicy RemoteSigned -File scripts/setup/Install-LlamaRuntime.ps1 -Version b10964
powershell -NoProfile -ExecutionPolicy RemoteSigned -File scripts/setup/Download-Model.ps1 -Model mimo-v2.6-distill-qwen-9b
powershell -NoProfile -ExecutionPolicy RemoteSigned -File scripts/common/Test-ModelIntegrity.ps1 -Model mimo-v2.6-distill-qwen-9b
powershell -NoProfile -ExecutionPolicy RemoteSigned -File scripts/common/Test-Llm.ps1 -Model mimo-v2.6-distill-qwen-9b -ConfigurationOnly -RequireInstalledFiles
powershell -NoProfile -ExecutionPolicy RemoteSigned -File scripts/common/Test-Llm.ps1 -Model mimo-v2.6-distill-qwen-9b
```

## Validation status

Verified on 2026-09-22 against the pinned revision and artifacts:

- `Test-ModelIntegrity.ps1 -Model mimo-v2.6-distill-qwen-9b`: both artifacts
  reported `Passed` (on-disk size and SHA-256 match the manifest).
- `Test-Llm.ps1 -Model mimo-v2.6-distill-qwen-9b -ConfigurationOnly
  -RequireInstalledFiles`: all four launchers `Passed` (runtime executable and
  declared artifact paths found, no duplicate flags).
- `Test-Llm.ps1 -Model mimo-v2.6-distill-qwen-9b -Profile agentic-262k-1024`:
  `Passed`; the server logged `n_ctx_slot = 262144` and returned `pong`.
- `Test-Llm.ps1 -Model mimo-v2.6-distill-qwen-9b -Profile
  agentic-vision-262k-1024`: `Passed`; the multimodal projector loaded and the
  server described the test image (a three-column panel layout).

These smoke tests ran before the network binding correction and do not prove
WSL access. The 131k profiles received declarative validation only; inference
at 131k has not been tested here. The vision response was limited to 16 output
tokens and was truncated; this was an image-processing smoke test, not a
vision-quality evaluation.

Port 8080 was released after each smoke test and no `llama-server` process remained.
These are short-completion smoke tests: they do not prove that a full
131k/262k prompt fits memory, and tool-call parsing and reasoning separation
remain unverified.

## Dependencies and sources

- `config/models/mimo-v2.6-distill-qwen-9b.psd1` and `config/catalog.psd1`.
- `scripts/setup/Install-LlamaRuntime.ps1`, `Download-Model.ps1`.
- [Pinned GGUF repository](https://huggingface.co/bartowski/MiMo-V2.6-Distill-Qwen-9B-GGUF/tree/4371da10c84fb26da3592d4cf312d24aa82b7b65).
- [Upstream model](https://huggingface.co/XiaomiMiMo/MiMo-V2.6-Distill-Qwen-9B).
- [Runtime release and package digests](https://github.com/ggml-org/llama.cpp/releases/tag/b10964).
- [Self-contained launchers](../../adr/ADR-0001-self-contained-model-launchers.md).
