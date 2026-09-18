# 2026-09-18 - Incorporate Ternary Bonsai 2 27B

**What**: Add the ternary model `ternary-bonsai-2-27b` with a single vision
profile and the first non-official runtime of the repository.

- Model: `prism-ml/Ternary-Bonsai-2-27B-gguf` pinned at
  `6ed5e12bf84b7a63069882c91dd9e9218647d17b`.
- Artifacts: `Ternary-Bonsai-2-27B-PQ2_0.gguf` (7.206.168.928 bytes) and
  `Ternary-Bonsai-2-27B-mmproj-Q8_0.gguf` (629.246.976 bytes). The dense
  `PTQ1_0` packing and the BF16 projector stay out of the manifest.
- Launcher: `start-vision-131k-1024.cmd` (131.072 tokens, batch/ubatch
  1024/1024, image tokens fixed to 1024). The initial `text` (65.536, no vision)
  and `vision` (32.768) split was consolidated into this single profile the same
  day: the projector costs ~0.9 GB and the measured footprint at 131k leaves
  about 1 GB free, so one profile avoids duplicate configuration.
- Runtime: `PrismML-Eng/llama.cpp` release `prism-b10685-7dffb15` (commit
  `7dffb158`), installed in `runtimes\llama.cpp\prism-b10685-7dffb15-cuda13.3`
  by the new `scripts/setup/Install-BonsaiRuntime.ps1`. The official runtime
  rejects the `PQ2_0` and `PTQ1_0` types or produces invalid output without the
  Hadamard activation transform, so this is a hard dependency of the model and
  its DLLs stay isolated from `b10502-cuda13.3`.
- The catalog now contains nine models and 21 launchers.

**Validation**: All checks pass on 2026-09-18.

- SHA-256 and size verified for both artifacts.
- Declarative and installed-file validation: 21 launchers, no failures.
- Functional smoke test: `vision-131k-1024` in 5.03 s; it releases port 8080 and
  leaves no `llama-server` process behind.
- Coexistence: `ling-3.0-tiny/agentic-131k-1024` on the official runtime still
  passes with the fork runtime installed.
- Measured VRAM (RTX 5080, desktop baseline included): 15.257 MiB used at
  131.072 context with the Q8_0 projector, 1.046 MiB free. The retired profiles
  measured 11.667 MiB at 65.536 (text) and 11.269 MiB at 32.768 (vision).

A non-blocking warning from the fork (`--cache-idle-slots requires --cache-ram`)
is a direct consequence of the repository-wide `--cache-ram 0`. The vision
profile materializes `--image-min-tokens 1024 --image-max-tokens 1024` to satisfy
the fork's Qwen-VL grounding requirement while bounding prefill. Details in the
model card.
