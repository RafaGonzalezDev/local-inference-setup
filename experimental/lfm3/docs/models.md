# LFM3 models

All four publications are by LiquidAI under the LFM Open License v1.0 (`lfm1.0`), not gated. Weights
are the official GGUF conversions, pinned in `config/models/*.psd1`; the SHA-256 values are the Hugging
Face LFS checksums of the pinned revision. All use `Q8_0` weights and projectors: at about 2B
parameters memory is not a constraint, and every profile peaked at 5.4-6.7 GiB of VRAM including
about 1.9 GiB used by the desktop. Runtime: `b11981-cuda13.4` in this directory; the GGUF cards ask
for b11960 (v0.8.0) or newer.

| Model ID | GGUF revision | Weights (bytes, SHA-256) | Projector (bytes, SHA-256) |
| --- | --- | --- | --- |
| `lfm3-1.7b` | `bad5729bba61d076fff20d2548e62526665af215` | 1,846,238,496 `8f6b2418...af20b6` | - |
| `lfm3-vl-2b` | `b36554cfd35854b06429900131730cd80f092cdb` | 1,846,238,496 `e138e541...6fa6727` | 203,031,872 `c5c5b58d...5918ab` |
| `lfm3-audio-2b` | `642697a5597a675cb819ed236ac415c1e60a4f6f` | 1,846,236,704 `d4e36902...2258fc0` | 337,862,080 `26601e90...13024d3e` |
| `lfm3-omni-2b` | `2918dd47cfceb4f260cd1734cd1aac1b22bbe4b6` | 1,846,240,768 `59118f66...49158d4` | 540,892,768 `720ff4fc...dffe1839` |

Full hashes are in the manifests. The `lfm3-1.7b` and `lfm3-omni-2b` files are byte-identical to the
ones installed on 2026-10-27/28 (same SHA-256); only the repository revision moved.

## lfm3-1.7b

- Text model, GGUF architecture `lfm3`, native context 262,144. Post-trained for agent harnesses
  (Pi, Hermes): XML tool calling, structured outputs, deferred tool lookup. The card does not
  recommend it for agentic coding or knowledge-heavy tasks.
- Thinks by default: the template ends in `<think>`; `chat_template_kwargs.enable_thinking: false`
  turns it off per request.
- Profile `start-agentic-auto-262k-1024.cmd`, alias `lfm3-1.7b-262k`: `--reasoning auto` with an 8,192
  budget, card sampling `--temp 0.1 --top-k 50 --repeat-penalty 1.1` (math and science: temperature 1.0,
  top_p 0.95, top_k 20 per request). Registered in Pi and OpenCode.

## lfm3-vl-2b

- Image and video in, text out. Native context 128,000 (input plus output), which the profile uses
  in full; its `128k` label is that exact integer, not 131,072. Thinks before answering. The card targets documents,
  charts, app screens, object grounding and recorded video; it does not recommend it for coding,
  multi-turn conversation or complex reasoning.
- Profile `start-agentic-auto-vision-128k-1024.cmd`, alias `lfm3-vl-2b-vision-128k`: card sampling
  (`--temp 0.1 --top-p 1 --top-k 50 --min-p 0 --repeat-penalty 1.1`), `--no-reasoning-preserve` as the
  card's llama.cpp command, `--fit-target 2048` for the projector. Video uses ffmpeg (sampled at
  `--video-fps`, default 4; the model card samples at 2 fps). No audio track. Not in any client.

## lfm3-audio-2b

- Audio in; text, 24 kHz speech or both out. 32K context. ASR (also live ASR, English only), TTS and
  speech translation in 18 languages including Spanish, with `female` and `male` voices; voice chat is
  English only per the card. Reasons only when the assistant turn opens `<think>`.
- Profile `start-agentic-auto-audio-32k-1024.cmd`, alias `lfm3-audio-2b-audio-32k`: greedy text
  decoding, audio sampling stored in the GGUF (`audio_temperature 1.0`, `audio_top_k 128`). Not in any
  client.

## lfm3-omni-2b

- Text, images, video with its soundtrack and audio in; text, speech or both out. 32K context per the
  card. Non-reasoning (`--reasoning off`, every turn opens with an empty think block). Speech in the same
  18 languages and two voices.
- Profile `start-agentic-auto-omni-32k-1024.cmd`, alias `lfm3-omni-2b-omni-32k`: greedy text decoding,
  audio sampling stored in the GGUF (`audio_temperature 0.4`, repetition penalty 1.2). Registered in Pi
  and OpenCode with text and image input only: neither client sends audio or video nor plays speech.

## How to use each capability

- Speech recognition: chat completion with an `input_audio` part and the system prompt
  `Perform ASR in <language>.` (`Perform ASR.` lets LFM3-Audio infer the language). Keep each request
  to about 30 s of audio: a 45 s clip came back complete, a 135 s one lost a third of its text with a
  normal `stop`. Summaries: `scripts/Summarize-Audio.ps1` (see the README).
- Speech synthesis: `POST /tts` with `input`, optional `lang` and `voice` (`female`/`male`); it returns
  WAV bytes.
- Image: chat completion with an `image_url` part. Video: an `input_video` part (`data` in base64 or
  `url`; local files need `--media-path`); Omni also hears the soundtrack. Suggested system prompt for
  Omni: `Answer questions about the video using what you see and hear.`
- Realtime voice conversation (Audio, Omni): WebSocket `/v1/realtime`, PCM16 mono at the rate given in
  `session.created`, with `session.update` for `instructions`, `output_modalities` (`["text"]`,
  `["audio"]` or `["audio", "text"]` for interleaved speech) and `tools`. Reference client:
  `examples/realtime_client.py` in llama.cpp. Live transcription: `/v1/realtime?intent=transcription`.

## Not supported in this runtime

- Image or video input inside a `/v1/realtime` session: user items accept `input_text` and audio
  only, so "talk while sharing the screen" needs a client that sends recorded clips as `input_video`
  to `/v1/chat/completions` turn by turn.
- LiveASR is English only, and LFM3-Audio voice chat is English only (model limits, not runtime).

## Validation (2026-10-29)

- Integrity of the 7 artifacts; `Test-Llm.ps1 -RootDirectory .\experimental\lfm3` static with
  `-RequireInstalledFiles` and smoke: 4/4. `/props` and `/v1/models` confirm each context, modality set
  and both aliases; a request with each profile alias returns 200.
- Functional checks (scratch script, results in `logs/validation/functional-*.json`):

| Check | `lfm3-1.7b` | `lfm3-vl-2b` | `lfm3-audio-2b` | `lfm3-omni-2b` |
| --- | --- | --- | --- | --- |
| Context (`/props`) | 262,144 | 128,000 | 32,768 | 32,768 |
| Text | correct, with reasoning | - | - | - |
| `enable_thinking: false` | no reasoning | - | - | - |
| Tool call `get_weather` | `{"location":"Madrid"}` | - | - | `{"location":"Madrid"}` |
| Image `panels-1080p.png` | - | red, green, blue correct | - | red, green, blue correct |
| Video (`testsrc2`, 4 s) | - | colour bars and moving streaks | - | bars, timer and the Spanish sentence it hears |
| `/tts` Spanish | - | - | 0.36 s | 0.40 s |
| ASR of that audio | - | - | exact | exact |
| Realtime, text | - | - | invented a `web_search` call with no tools declared | correct, first token 0.11 s |
| Realtime, voice (English) | - | - | correct, first output 0.09 s, 4.6 s of speech | correct, first output 0.08 s, 5.0 s of speech |
| Realtime, voice (Spanish) | - | - | not tested | first output 0.11 s, 15.3 s of speech in 1.8 s; two place names wrong |
| VRAM peak | 6,670 MiB | 6,340 MiB (127,965-token load) | 5,439 MiB | 6,146 MiB |

- VL load at 128,000: image plus a 127,080-token prompt and 885 generated tokens, prefill
  15,161 t/s, decode 177 t/s, VRAM peak 6,340 MiB. It named the image colours correctly but got the
  retrieval question wrong (sensor 0, 327 units; the log said sensor 53, 95 degrees): long-context recall
  is weak. Log: `logs/validation/load-lfm3-vl-2b-128k-*.json`.
- Speech samples: `logs/validation/audio-samples/` (not mirrored).
- Not tested: long prompts near each context limit, live ASR, video longer than 4 s, quality beyond
  these checks, and Pi or OpenCode sessions against the registered profiles.
