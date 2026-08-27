# 2026-08-19 - Align the launcher inventory with 15 profiles

## 2026-08-19 - Document the current launcher set

**What**: Update the active catalog documentation and validation count from 17
to 15 launchers after two user-directed launcher removals. Synchronize the Qwen
and Nemotron model cards with the profiles that remain on disk.

**Where**: `README.md`, `docs/overview/model-management.md`,
`docs/overview/models/qwen3.6-35b-a3b.md`,
`docs/overview/models/nemotron-3.5-lightning-30b-a3b.md`, and
`scripts/common/Test-Llm.ps1`.

**Why**: Keep the current documentation and the global configuration-count
guard aligned with the 15 user-maintained launchers under
`scripts/models/`. Historical changelog entries retain their original counts.

## Validation

- The active directory contains 15 `start-*.cmd` launchers.
- README, overview documentation, model cards, and the validation guard now
  describe the same active inventory.
- No launcher file was created, deleted, or modified by this documentation
  synchronization.
