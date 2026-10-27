# LFM3 models

Both publications are by LiquidAI under the LFM Open License v1.0 (`lfm1.0`), not gated.
`lfm3-1.7b` moved to the main catalog on 2026-10-28
([model card](../../../docs/overview/models/lfm3-1.7b.md)). Weights are the official GGUF conversions, pinned in `config/models/*.psd1`; the SHA-256 values
are the Hugging Face LFS checksums of the pinned revision.

## lfm3-audio-2b

- Source: [LiquidAI/LFM3-Audio-2B](https://huggingface.co/LiquidAI/LFM3-Audio-2B) (revision
  `9d49701c372d6011d900f6abb40c6b296fb706dd`); GGUF
  [LiquidAI/LFM3-Audio-2B-GGUF](https://huggingface.co/LiquidAI/LFM3-Audio-2B-GGUF) at
  `fcfae9027c00a6f3f872c48a841cfeb77e2b5a1c`.
- Artifacts: `LFM3-Audio-2B-Q8_0.gguf`, 1,846,236,704 bytes, SHA-256
  `d4e36902ba8f0ee7b333596030a59d650f88ac76660b4d9ba5ff77c3c2258fc0`;
  `mmproj-LFM3-Audio-2B-Q8_0.gguf` (audio encoder and LiquidCodec), 337,862,080 bytes, SHA-256
  `26601e904245a85bd8f3cf320a629e897cfc01c1d09369e8b4fd951f13024d3e`.
- Input text or 16 kHz audio; output text, 24 kHz speech or both. 32K context. ASR, live ASR,
  TTS in 18 languages with `female`/`male` voices, speech translation, audio understanding, tool
  calling; reasoning only when the assistant turn opens `<think>`.
- Profile `start-agentic-auto-audio-32k-1024.cmd`, alias `lfm3-audio-2b-audio-32k`: greedy text
  decoding (`generation_config`), `--fit-target 2048` for the projector. The audio sampling
  parameters (`audio_temperature 1.0`, `audio_top_k 128`, repetition penalty 1.1 over 4,096) are
  stored in the GGUF.

## lfm3-omni-2b

- Source: [LiquidAI/LFM3-Omni-2B](https://huggingface.co/LiquidAI/LFM3-Omni-2B) (revision
  `ce2458cbce4ad970f92032ed94e3d18d30b04f9c`); GGUF
  [LiquidAI/LFM3-Omni-2B-GGUF](https://huggingface.co/LiquidAI/LFM3-Omni-2B-GGUF) at
  `5bcc26f7968f71d26e066027a70978529dbb605d`.
- Artifacts: `LFM3-Omni-2B-Q8_0.gguf`, 1,846,240,768 bytes, SHA-256
  `59118f661eaacb93d204723d76355b53347f0940b508c11412f6290fd49158d4`;
  `mmproj-LFM3-Omni-2B-Q8_0.gguf` (vision and audio encoders, LiquidCodec), 540,892,768 bytes,
  SHA-256 `720ff4fc09df0e026c4ec641d0c698bf27b5bcd50561944c88eda5e3dffe1839`.
- Input text, images, video and audio; output text, speech or both. 32K context per the card
  (the text config declares 128,000). Non-reasoning: every assistant turn opens with an empty
  `<think></think>`.
- Profile `start-agentic-auto-omni-32k-1024.cmd`, alias `lfm3-omni-2b-omni-32k`: `--reasoning off`
  as the GGUF card asks, greedy text decoding, `--fit-target 2048`. Audio sampling
  (`audio_temperature 0.4`, repetition penalty 1.2) is stored in the GGUF.

## How to use each capability

- Speech recognition: chat completion with an `input_audio` part and the system prompt
  `Perform ASR in <language>.` (`Perform ASR.` lets LFM3-Audio infer the language).
- Speech synthesis: `POST /tts` with `input`, optional `lang` and `voice` (`female`/`male`);
  it returns WAV bytes. Offline alternative: `llama-tts -m <model> -mm <mmproj> -p "..."
  --tts-lang <code> --tts-voice <voice> -o out.wav`.
- Image understanding (Omni): chat completion with an `image_url` part.
- Live transcription: WebSocket `/v1/realtime` (transcription only) for streaming audio encoders.

## Not supported in this runtime

- Video input for Omni (the GGUF card says llama.cpp does not support it yet).
- Realtime voice conversation over `/v1/realtime` (announced as coming soon); only realtime
  transcription is documented.
- Interleaved text-and-speech chat replies through `/v1/chat/completions`.

## Test status

See the [changelog](changelog/2026-10-27-lfm3-experimental.md).
