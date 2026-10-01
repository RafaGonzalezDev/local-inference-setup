## 2026-09-30 — Profile aliases for client selection

**What**: Every launcher now declares `--alias <model-id>,<profile-id>`. The bare
model id stays first, so no existing client breaks, and the second name
identifies the exact profile that launcher serves: `gemma-4-12b-v2-text`,
`gemma-4-26b-a4b-agentic-vision`, `qwen3.6-35b-a3b-262k`, and so on. The
per-profile mapping is in the launcher inventory in the README.

**Where**: All 17 launchers under `scripts/models/`, `scripts/common/Test-Llm.ps1`,
and the launcher inventory in `README.md`.

**Why**: A client could previously only name the bare model id, which several
profiles share: `qwen3.6-35b-a3b` is served at 131K and at 262K by two different
launchers, and `gemma-4-26b-a4b` at 262K, 131K, and 65K. `llama-server` validates
the requested model name against its own aliases and answers anything else with
`model '<id>' not found`, so a client catalog had no way to state which profile
its context window, modality, and output cap actually described — the DeepSeek
Harness catalog had to guess one context size per model and could silently
overrun a smaller profile. Naming the profile makes the client's declared
capacity checkable against the launcher that serves it.

The alias does not transfer control. Context, sampling, placement, reasoning
budget, and the projector still come from the launcher, only one profile can hold
port 8080, and a request naming a profile the running launcher does not serve
fails with `model '<id>' not found`.

**Validation**: `Test-Llm.ps1 -ConfigurationOnly` passes all 17 launchers. The
script now parses `--alias` as a comma-separated list, requires the first entry
to be the model id, and adds two invariants: profile aliases must be unique
across launchers, and a profile alias must not shadow a model id. Both catch
mistakes that a single running server could never reveal. No inference test was
run; the change touches only launcher arguments.
