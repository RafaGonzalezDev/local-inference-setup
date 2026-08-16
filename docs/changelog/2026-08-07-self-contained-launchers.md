# 2026-08-07 - Self-Contained Launchers

**What**: The active profiles invoke `llama-server.exe` directly with all
visible parameters. The current catalog contains 17 self-contained launchers.

**Where**: `scripts\models`, `scripts\common\Test-Llm.ps1`,
`config\models`, and the `docs\overview` guides.

**Why**: The inheritance between runtime, model, and profile made it difficult
to know with what parameters a model was started. Inspection and local editing
are prioritized over configuration deduplication.

**Validation**: Static validation checks paths, unique flags, and absence of
delegation or hidden arguments across all 17 launchers. Functional checks
release port 8080 after each test.
