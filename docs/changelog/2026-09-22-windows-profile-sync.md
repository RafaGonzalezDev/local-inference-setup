## 2026-09-22 — Windows profile synchronization

**What**: Mirror the effective Windows profile inventory: Ling 3.0 Tiny now
has `agentic-262k-1024`, and Ternary Bonsai 2 27B has both text and vision
profiles at 131k. Preserve historical validation results as historical, not
as evidence for the newly synchronized profiles.

**Where**: `scripts/models/ling-3.0-tiny/`,
`scripts/models/ternary-bonsai-2-27b/`, and their model cards.

**Why**: The deployed artifacts in `D:\LLM\models` and effective arguments in
`D:\LLM\scripts\models` are authoritative. The repository mirrors launcher
files byte for byte, including legacy comments; actual flags determine the
configuration. It does not contain weights, runtime binaries, or logs.

The repository retains portable root discovery in setup/integrity scripts
rather than copying the Windows-only `D:\LLM` default. Historical changelogs
are retained even when absent from the Windows deployment. MiMo registration
and its side-by-side runtime are recorded separately in
[the MiMo change](2026-09-22-mimo-v2.6-distill-qwen-9b.md).

**Validation**: The synchronized 26-launcher catalog passed configuration-only
validation in a temporary Windows staging directory. All 11 configuration
files and all 26 launchers match the Windows source (normalizing line endings
for comparisons). MiMo's four deployed launchers also passed checks requiring
installed files. No inference tests were rerun for Ling or Bonsai.
