# 2026-08-27 - Reconcile the active model set

**What**: Reconcile the declarative catalog, installed artifacts, launchers,
validation tooling, and documentation with the model set that is actually
retained on Windows.

- Ornith 1.5 9B uses `Ornith-1.5-9B-AD-IQ4_XS.gguf` consistently in the
  manifest, `SHA256SUMS`, launcher, and model card. The launcher materializes
  `--n-cpu-moe 20`.
- Qwen3.8 27B uses `Qwen3.8-27B-UD-IQ3_XXS.gguf` in all three profiles. The
  unmanifested `Qwen3.8-27B-UD-Q2_K_XL.gguf` is retired.
- Ling 3.0 Tiny uses the self-contained
  `start-agentic-131k-1024.cmd` profile.
- Qwen3.6 35B A3B NVFP4 Fast is removed from the catalog and documentation;
  its intended artifacts and launchers were never present in the active tree.
- The active catalog now contains eight models and 20 launchers.

**Validation tooling**: `Test-Llm.ps1` no longer depends on a hardcoded
launcher count. It verifies catalog-to-launcher coverage, manifest IDs,
launcher aliases, and that every launcher artifact is declared and every
declared artifact is used. `-ConfigurationOnly` performs a portable
declarative validation; `-RequireInstalledFiles` additionally checks runtime
and artifact presence. Result filenames include milliseconds and a random
suffix to prevent collisions.

**Validation**: All 20 launchers pass declarative validation and installed-file
validation. Focused SHA-256 integrity checks cover Ornith 1.5 9B, Ling 3.0
Tiny, and Qwen3.8 27B. Functional smoke tests pass for Ling 3.0 Tiny
`agentic-131k-1024` (4.28 seconds) and Ornith 1.5 9B
`agentic-262k-1024` (4.19 seconds); each test leaves no `llama-server` process
and releases port 8080.
