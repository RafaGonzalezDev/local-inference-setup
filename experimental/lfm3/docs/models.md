# LFM3 1.7B

Published by LiquidAI under the LFM Open License v1.0 (`lfm1.0`), not gated. The weights are the
official GGUF conversion, pinned in `config/models/lfm3-1.7b.psd1`; the SHA-256 is the Hugging Face LFS
checksum of the pinned revision. Runtime: `b11981-cuda13.4` in this directory; the GGUF card asks for
b11960 (v0.8.0) or newer.

| Model ID | GGUF revision | Weights (bytes, SHA-256) |
| --- | --- | --- |
| `lfm3-1.7b` | `bad5729bba61d076fff20d2548e62526665af215` | 1,846,238,496 `8f6b2418...af20b6` |

The file is byte-identical to the one installed on 2026-10-27/28 (same SHA-256); only the repository
revision moved.

## Model and profile

- Text model, GGUF architecture `lfm3`, native context 262,144. Post-trained for agent harnesses
  (Pi, Hermes): XML tool calling, structured outputs, deferred tool lookup. The card does not
  recommend it for agentic coding or knowledge-heavy tasks.
- Thinks by default: the template ends in `<think>`; `chat_template_kwargs.enable_thinking: false`
  turns it off per request.
- Profile `start-agentic-auto-262k-1024.cmd`, alias `lfm3-1.7b-262k`: `--reasoning auto` with an 8,192
  budget, card sampling `--temp 0.1 --top-k 50 --repeat-penalty 1.1` (math and science: temperature 1.0,
  top_p 0.95, top_k 20 per request). Registered in Pi and OpenCode.

## Validation (2026-10-29)

- Integrity, `Test-Llm.ps1 -RootDirectory .\experimental\lfm3` static with `-RequireInstalledFiles` and
  smoke. `/props` confirms 262,144 tokens and `/v1/models` both aliases; a request with the profile alias
  returns 200.
- Template ends in `<think>`; `enable_thinking: false` leaves no reasoning; `thinking_budget_tokens: 64`
  cut reasoning at about 52 words while the answer stayed complete.
- Tool call `get_weather` returned `{"location":"Madrid"}`. VRAM peak 6,670 MiB, including about
  1.9 GiB used by the desktop.
- Not tested: long prompts near the context limit, quality beyond these checks, and Pi or OpenCode
  sessions against the registered profile.
