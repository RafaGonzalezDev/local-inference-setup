# LFM3 deployment

Self-contained deployment for the LiquidAI LFM3 family, kept apart from the main catalog in `D:\LLM`
with its own llama.cpp runtime, `b11981-cuda13.4` (build 11981, commit `da6c30ade`). That release
contains native LFM3 support (PR #31252, #31257), video input for the family (PR #31283) and realtime
voice conversation with tool calls on `/v1/realtime` (PR #31269, #31287); no source build is needed.
The main catalog stays on `b11551`.

The directory follows the same layout and launcher contract as `D:\LLM`
([ADR-0001](../../docs/adr/ADR-0001-self-contained-model-launchers.md)): launchers compute
`LLM_ROOT` as this directory and resolve `models\` and `runtimes\` here.

| Path | Content |
| --- | --- |
| `config/catalog.psd1`, `config/models/*.psd1` | Catalog and pinned manifests (revision, size, SHA-256) |
| `scripts/models/<model-id>/start-*.cmd` | Self-contained launchers |
| `docs/` | Model notes and changelog |
| `models/`, `runtimes/`, `packages/`, `logs/` | Weights, runtime, packages and validation logs (not mirrored) |

## Models

| Model ID | Publication | Weights / projector | Context | Launcher | Profile alias | Clients |
| --- | --- | --- | ---: | --- | --- | --- |
| `lfm3-1.7b` | [LFM3-1.7B-GGUF](https://huggingface.co/LiquidAI/LFM3-1.7B-GGUF) | `Q8_0` / - | 262,144 | `start-agentic-auto-262k-1024.cmd` | `lfm3-1.7b-262k` | Pi, OpenCode |
| `lfm3-vl-2b` | [LFM3-VL-2B-GGUF](https://huggingface.co/LiquidAI/LFM3-VL-2B-GGUF) | `Q8_0` / `Q8_0` | 128,000 | `start-agentic-auto-vision-128k-1024.cmd` | `lfm3-vl-2b-vision-128k` | - |
| `lfm3-audio-2b` | [LFM3-Audio-2B-GGUF](https://huggingface.co/LiquidAI/LFM3-Audio-2B-GGUF) | `Q8_0` / `Q8_0` | 32,768 | `start-agentic-auto-audio-32k-1024.cmd` | `lfm3-audio-2b-audio-32k` | - |
| `lfm3-omni-2b` | [LFM3-Omni-2B-GGUF](https://huggingface.co/LiquidAI/LFM3-Omni-2B-GGUF) | `Q8_0` / `Q8_0` | 32,768 | `start-agentic-auto-omni-32k-1024.cmd` | `lfm3-omni-2b-omni-32k` | Pi, OpenCode (text and image) |

Not installed: `LFM3-1.7B-Base` (no GGUF, base model for fine-tuning) and the d1 decision models
(`d1-2B`, `d1-Omni-2B`: no text generation, partial llama.cpp support). Details, capabilities and test
status: [docs/models.md](docs/models.md).

## Usage

Run from `D:\LLM`. The shared scripts take `-RootDirectory`:

```powershell
# Runtime and weights (pinned and verified)
& .\scripts\setup\Install-LlamaRuntime.ps1 -RootDirectory .\experimental\lfm3 -Version b11981
& .\scripts\setup\Download-Model.ps1 -Model lfm3-omni-2b -RootDirectory .\experimental\lfm3
& .\scripts\common\Test-ModelIntegrity.ps1 -RootDirectory .\experimental\lfm3

# Static validation
& .\scripts\common\Test-Llm.ps1 -RootDirectory .\experimental\lfm3 -ConfigurationOnly -RequireInstalledFiles

# Start a profile (terminal-bound, Ctrl+C to stop); it uses port 8080 like the main profiles
& .\experimental\lfm3\scripts\models\lfm3-omni-2b\start-agentic-auto-omni-32k-1024.cmd
```

## Audio summaries

Double-click `scripts\summarize-audio.cmd` and pick an audio or video file. If no server answers on
port 8080 it starts `lfm3-omni-2b` in the same window (log in `logs\summary-server.*.log`); Cancel in
the picker stops it, and closing the window ends it too. A server already running with audio is reused
and left running. Each summary, one or two paragraphs in Spanish, replaces `scripts\SUMMARY.md`.

The script transcribes the audio in 30 s segments (`Perform ASR in Spanish.`; `-Language auto` lets the
model detect it) and then asks the model for the summary from that text. Asking for a summary straight
from the audio did not work: both Audio and Omni returned a transcription of each segment. Long audio
must be segmented because a single request over 135 s dropped a third of its text. Omni is used
because Audio cut one summary short mid-sentence. From PowerShell, with a server already running:
`& .\experimental\lfm3\scripts\Summarize-Audio.ps1 -Path .\note.ogg`. The llama.cpp Web UI is not
suitable: it offers its built-in tools to the model, which LFM3-Audio called instead of answering, and
it skips audio files whose MIME type it does not list (`.m4a`, `.flac`).

Profiles listen on `0.0.0.0:8080` without authentication: trusted private network only, and only
one profile (main or LFM3) can run at a time. Video input needs `ffmpeg` and `ffprobe` in `PATH`.
