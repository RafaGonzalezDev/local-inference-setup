# Qwen3.6 27B MTP

Native Windows profiles for `unsloth/Qwen3.6-27B-MTP-GGUF`, served with the
official `llama.cpp b10273-cuda13.3` runtime. The model is dense, so the
remaining layers stay in system memory through hybrid offload. No CPU-MoE
offload is configured.

## Artifacts

| Quantization | File | Size | SHA-256 |
| --- | --- | ---: | --- |
| `Q4_K_M` | `Qwen3.6-27B-Q4_K_M.gguf` | 17.1 GB | `a7cbd3ecc0e3f9b333edee61ae66bc87ed713c5d49587a8355814722ed329e0f` |
| `IQ4_XS` | `Qwen3.6-27B-IQ4_XS.gguf` | 15.7 GB | `89f2c7e4f9f91d17ba9df6f0eef67cb909bc67d91cd035291be35cd88f1848ba` |

Both files are pinned to revision
`5cb35eb3dcbf52dbce5f87dbc64df6aaffadcace`. `UD-Q4_K_XL` and the multimodal
projector are intentionally not installed: this MTP deployment does not
combine MTP with `mmproj`.

## Profiles

| Launcher | Quantization | Context | MTP |
| --- | --- | ---: | :---: |
| `start-agentic.cmd` | `Q4_K_M` | 262,144 | yes |
| `start-text.cmd` | `Q4_K_M` | 131,072 | yes |
| `start-agentic-iq4-xs.cmd` | `IQ4_XS` | 262,144 | yes |
| `start-text-iq4-xs.cmd` | `IQ4_XS` | 131,072 | yes |

All four profiles use `--fit on --fit-target 768`,
`--gpu-layers auto`, and `--spec-draft-n-max 2`. The 768 MiB target is the
margin requested from the fit mechanism; the Q4_K_M `text` probe observed
approximately 983 MiB free in native Windows WDDM dedicated memory. This avoids
depending on a fixed layer count when context size, runtime state, or desktop
memory usage changes.

## MTP calibration

Memory was measured with native Windows WDDM metrics rather than WSL while the
server was loaded. Functional smoke tests also recorded MTP acceptance and
generation speed:

| Profile | Quantization | `n-max` | Acceptance | Generation |
| --- | --- | ---: | ---: | ---: |
| `text` | `Q4_K_M` | 1 | 1.000 (10/10) | 12.86 tok/s |
| `text` | `Q4_K_M` | 2 | 1.000 (10/10) | 13.05 tok/s |
| `text` | `Q4_K_M` | 3 | 0.818 (9/11) | 11.47 tok/s |
| `text` | `Q4_K_M` | 4 | 1.000 (10/10) | 13.43 tok/s |
| `agentic` | `Q4_K_M` | 2 | 1.000 (10/10) | 9.95 tok/s |
| `agentic` | `Q4_K_M` | 4 | 1.000 (10/10) | 10.19 tok/s |
| `text-iq4-xs` | `IQ4_XS` | 2 | 1.000 (10/10) | 18.41 tok/s |
| `agentic-iq4-xs` | `IQ4_XS` | 2 | 1.000 (10/10) | 13.00 tok/s |

The smoke request is short, so the difference between 2 and 4 is not
conclusive. `n-max=2` is retained as the conservative final value: it outperforms
3 in the observed test, preserves full acceptance, and avoids extra speculative
work for longer prompts. IQ4_XS remains available as the smaller and faster
option; Q4_K_M remains the more quality-conservative alternative.

## Dependencies

- `config/models/qwen3.6-27b-mtp.psd1`
- `scripts/models/qwen3.6-27b-mtp/`
- `scripts/common/Test-Llm.ps1`

## Related ADRs

- [ADR-0001: self-contained model launchers](../../adr/ADR-0001-self-contained-model-launchers.md)
