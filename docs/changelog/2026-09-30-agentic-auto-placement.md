# 2026-09-30 - Automatic device placement across the catalog

## 2026-09-30 - Add `*-auto*` launchers to every model that has a pinned placement

**What**: Add seventeen launchers that leave the device placement to the runtime,
next to the existing ones, so both placements can be compared on the same
hardware:

- `qwen3.6-35b-a3b`: `start-agentic-auto-131k-2048.cmd`,
  `start-agentic-auto-262k-1024.cmd`, `start-agentic-auto-mtp-131k-2048.cmd` and
  `start-agentic-auto-vision-131k-2048.cmd`.
- `ornith-1.5-35b-a3b`: `start-agentic-auto-131k-2048.cmd` and
  `start-agentic-auto-262k-1024.cmd`.
- `gemma-4-26b-a4b`: `start-text-auto.cmd`, `start-text-auto-mtp.cmd`,
  `start-vision-auto.cmd`, `start-vision-auto-mtp.cmd`, `start-agentic-auto.cmd`
  and `start-agentic-auto-vision.cmd`.
- `gemma-4-12b-v2`: `start-text-auto.cmd` and `start-vision-auto.cmd`.
- `nemotron-3.5-lightning-30b-a3b`: `start-agentic-auto-131k-2048.cmd`.
- `ling-3.0-tiny`: `start-agentic-auto-262k-1024.cmd`.
- `ornith-1.5-9b`: `start-agentic-auto-262k-1024.cmd`.

Each new launcher replicates the context, batch, ubatch, sampling, alias and
port of its manual counterpart, and replaces `--gpu-layers 999 --n-cpu-moe <N>
--fit off` with `--gpu-layers auto --fit on --fit-target 1024`, dropping
`--n-cpu-moe` entirely. Where the manual profile used `--spec-draft-ngl 999`,
the new one uses `--spec-draft-ngl auto`. The `auto` segment is inserted after
the first segment of the name, which is the convention the earlier profiles
already followed.

No existing launcher was modified, renamed or removed, so every hand-tuned
profile remains as the reference point. The launcher count rises from 20 to 34.

**Where**: `scripts/models/` for the seven models, the seven model cards,
`README.md`, `docs/overview/inference-backend.md`,
`docs/overview/model-management.md` and `docs/changelog`.

**Why**: Make the runtime-resolved placement available for a side-by-side
comparison against the hand-tuned profiles without retiring the hand-tuned ones.
The lever under test is the expert offload, and `--n-cpu-ffn`, the new
dense-model lever in `b11269`, is not needed by any of these profiles.

## What `--fit` resolves

Measured with `llama-fit-params.exe` from `b11269-cuda13.4`, on a 16 GiB RTX 5080
whose desktop held about 1.6 GiB at the time. Memory is the sum of the model,
context and compute buffers, in MiB.

| Model | Profile | Context | Batch | `--fit` result | Manual `n-cpu-moe` | Auto GPU/host | Manual GPU/host |
| --- | --- | ---: | ---: | --- | ---: | ---: | ---: |
| gemma-4-12b-v2 | `text` | 262.144 | — | `-ngl -1`, no offload | — | 11.493 / 812 | 11.493 / 812 |
| gemma-4-12b-v2 | `vision` | 262.144 | — | `-ngl -1`, no offload | — | 11.493 / 812 | 11.493 / 812 |
| gemma-4-26b-a4b | `agentic` | 262.144 | 1024/1024 | `-ngl 31 -ot blk.19–30` | 12 | 13.936 / 5.158 | 13.373 / 5.835 |
| gemma-4-26b-a4b | `agentic-vision` | 262.144 | 1024/1024 | `-ngl 31 -ot blk.17–30` | 16 | 12.843 / 6.251 | 11.739 / 7.469 |
| gemma-4-26b-a4b | `text` | 131.072 | 1024/256 | `-ngl 31 -ot blk.25–30` | 5 | 13.899 / 2.239 | 13.760 / 2.508 |
| gemma-4-26b-a4b | `text-mtp` | 131.072 | 1024/256 | `-ngl 31 -ot blk.25–30` | 7 | 13.899 / 2.239 | 12.943 / 3.325 |
| gemma-4-26b-a4b | `vision` | 65.536 | 1024/1024 | `-ngl 31 -ot blk.23–30` | 8 | 12.931 / 3.140 | 12.253 / 3.818 |
| gemma-4-26b-a4b | `vision-mtp` | 65.536 | 1024/1024 | `-ngl 31 -ot blk.23–30` | 10 | 12.931 / 3.140 | 11.437 / 4.634 |
| ling-3.0-tiny | `agentic` | 262.144 | 1024/1024 | `-ngl -1`, no offload | 8 | 8.570 / 768 | 6.770 / 2.585 |
| nemotron-3.5 | `agentic` | 131.072 | 2048/2048 | `-ngl 53 -ot blk.34–52` | 23 | 13.610 / 7.637 | 12.996 / 8.077 |
| ornith-1.5-9b | `agentic` | 262.144 | 1024/1024 | `-ngl -1`, no offload | 20 | 10.756 / 1.089 | 10.756 / 1.089 |
| qwen3.6-35b-a3b | `agentic` | 131.072 | 2048/2048 | `-ngl 41 -ot blk.18–40` | 22 | 13.812 / 11.374 | 13.999 / 11.267 |
| qwen3.6-35b-a3b | `agentic` | 262.144 | 1024/1024 | `-ngl 41 -ot blk.17–40` | 24 | 13.717 / 11.822 | 13.528 / 12.179 |
| qwen3.6-35b-a3b | `agentic-mtp` | 131.072 | 1024/1024 | `-ngl 41 -ot blk.21–40` | 25 | 13.857 / 9.948 | 11.401 / 12.387 |
| qwen3.6-35b-a3b | `agentic-vision` | 131.072 | 2048/2048 | `-ngl 41 -ot blk.15–40` | 24 | 12.712 / 12.474 | 12.861 / 12.195 |
| ornith-1.5-35b-a3b | `agentic` | 131.072 | 2048/2048 | `-ngl 41 -ot blk.20–40` | 20 | 13.870 / 9.384 | 13.761 / 9.379 |
| ornith-1.5-35b-a3b | `agentic` | 262.144 | 1024/1024 | `-ngl 41 -ot blk.19–40` | 24 | 13.839 / 9.784 | 12.732 / 11.027 |

`-ngl <layers + 1>` means every layer stays on the GPU and the offload happens
only at the expert level. Four behaviours are worth recording:

- `--fit` does not use `--n-cpu-moe`. It emits an `-ot` override per layer
  instead, which is why the new launchers omit the flag rather than leaving it at
  a default. It extends the pattern one block past the last layer the model
  declares; that trailing entry matches no tensor.
- `--fit` offloads a trailing span of layers, whereas `--n-cpu-moe N` offloads
  the leading N. The two policies differ in position even when they agree on
  count, which is a confound to keep in mind when comparing throughput.
- The context must stay declared. `--fit` only adjusts unset arguments, and
  leaving `-c` out resolves it to `--fit-ctx`, 4096 tokens.
- The automatic repartition is not uniformly conservative: it is more aggressive
  than the hand-tuned profiles in most MoE cases, and least so in
  `qwen3.6-35b-a3b` MTP, `ornith-1.5-35b-a3b` 262k and `ling-3.0-tiny`.

The vision profiles use `--fit-target 2048` instead of 1024 because
`llama-fit-params.exe` does not accept `--mmproj` and the projector is offloaded
to the GPU by default (`--mmproj-offload` is enabled), so it is not part of the
`--fit` budget. That is the only difference from their non-vision counterparts.

## Findings

- `ornith-1.5-9b` declares architecture `qwen35` with no expert tensors
  (`n_expert = 0`), so the `--n-cpu-moe 20` in its manual launcher has no effect
  on the estimate. The launcher is left untouched because manual profiles are not
  modified by this change.
- `gemma-4-26b-a4b` declares 30 layers and `nemotron-3.5-lightning-30b-a3b` 52;
  the base `qwen35moe` models of `qwen3.6-35b-a3b` and `ornith-1.5-35b-a3b`
  declare 40, and the MTP artifact of Qwen3.6 declares 41 because it adds the
  draft module.
- The MTP estimates do not include the draft artifact, which
  `llama-fit-params.exe` never receives.

## Validation

- `Test-Llm.ps1 -ConfigurationOnly` and `Test-Llm.ps1 -ConfigurationOnly
  -RequireInstalledFiles` both report 34 of 34 launchers passing.
- Every long flag in the new launchers was checked against the `--help` output of
  `llama-server.exe` from `b11269-cuda13.4`; all are recognised.
- `--spec-draft-ngl auto` was verified to be accepted by the server argument
  parser, using a deliberately invalid flag as the control.
- The eleven pre-existing launchers of these five models keep their previous
  modification time and content; every new file is LF with no BOM.
- Functional validation, including the comparison these profiles exist for, is
  pending and belongs to a later session. No server was started and no inference
  was run for this change.
