# 2026-08-05 - Windows LLM Environment Consolidation

**What**: The runtime, five model families, profiles, launchers, tests, and documentation were consolidated into `D:\LLM`. Gemma 4 12B v2, Qwen3.6 35B uncensored, and Ornith 1.0 35B were added by copying existing artifacts, without re-downloading them.

**Where**: `D:\LLM\models`, `config`, `scripts`, `tests`, `logs`, and `docs`.

**Why**: Windows loads the models with good behavior on the machine and the WSL environment should no longer be an operational dependency. The declarative catalog avoids duplicating parameters and allows adding models without modifying the common engine.

**Validation**: The five new artifacts matched in source and destination via SHA-256. The catalog contains 11 artifacts and 15 profiles, all profiles generate valid arguments in PowerShell 5.1, and all 15 launchers are present. Brief functional tests passed Gemma 4 12B text and vision, Qwen uncensored text, Qwen base text, and Gemma 26B text. Ornith is deferred for manual testing. Results are preserved in `logs\validation`.

**WSL Cleanup**: `~/models` and the three copies of `llama.cpp` were removed after verifying the 11 Windows artifacts. WSL went from 218 GiB to 69 GiB used and `fstrim` reported 804 GiB of free blocks to the virtual disk. Compaction with `diskpart` reduced the VHDX from 249,369,198,592 to 83,303,071,744 bytes, recovering 166,066,126,848 physical bytes. Ubuntu booted correctly again as a WSL 2 distribution. The VHDX remains dynamic and not sparse.
