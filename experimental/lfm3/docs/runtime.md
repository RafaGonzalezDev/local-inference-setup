# LFM3 runtime: source build

The runtime in `runtimes\llama.cpp\19ff817-cuda13.4` is **built locally from source**, not an
official llama.cpp release, and has no SHA-256 published by upstream. The hashes below identify
this local build only.

## Why a source build

LFM3 support landed in `ggml-org/llama.cpp` on 2026-10-27 in two pull requests:

- [#31252](https://github.com/ggml-org/llama.cpp/pull/31252): `lfm3` text architecture
  (LFM3-1.7B, LFM3-VL-2B).
- [#31257](https://github.com/ggml-org/llama.cpp/pull/31257): LFM3-Audio-2B and LFM3-Omni-2B
  (audio encoder, LiquidCodec speech generation, `POST /tts`, `llama-tts` voices). Merged at
  17:47 UTC as commit `19ff817fb25e9a1b838b1d7f9f4325f7bf9779c4`.

No published build contained either change at that time: the latest nightly (`b11936`) was cut
from an earlier commit, and the stable v0.7.0 (`b11669`, used by the main catalog) predates both.
The build uses the merge commit on `master` rather than the PR branch, so it is the reviewed code.

## Build

- Script: [Build-LlamaRuntime.cmd](../scripts/setup/Build-LlamaRuntime.cmd). It fetches the pinned
  commit into `src\llama.cpp`, configures with Ninja and builds `llama-server`, `llama-mtmd-cli`,
  `llama-tts` and `llama-cli`, then copies the binaries and the CUDA 13.4 runtime DLLs into a new
  runtime directory (it refuses to overwrite an existing one).
- Toolchain: Visual Studio 2022 Build Tools, MSVC 19.44.35222.0, bundled CMake and Ninja,
  CUDA Toolkit 13.4.59.
- Options: `GGML_CUDA=ON`, `CMAKE_CUDA_ARCHITECTURES=120` (RTX 5080 only), `GGML_NATIVE=ON`
  (host CPU, Ryzen 7 9800X3D), `LLAMA_OPENSSL=OFF` (no `-hf` downloads; weights come from
  `Download-Model.ps1`), Release.
- Reported version: `0.7.0-dev (build 1, commit 19ff817)`. The build number is the commit count of
  the shallow checkout, not an upstream `bNNNNN` number.
- Because of `GGML_NATIVE` and `sm_120`, the binaries are not portable to other CPUs or GPUs.

## SHA-256 of the build (2026-10-28)

Also stored next to the runtime in `runtimes\llama.cpp\19ff817-cuda13.4.sha256.txt`.

| File | SHA-256 |
| --- | --- |
| `llama-server.exe` | `09d2510772010308343cdc684d28102f3c9ea71e296770ea7c9293d73e35c408` |
| `llama-tts.exe` | `e74f6fe7bec261a491687d644c0d4ee7cf49788f9ed39a887ef70d6e182abeda` |
| `llama-mtmd-cli.exe` | `9e4bcc5bdf325bb6919bae7c2bd6ba8fa8327efc8b50741b36fb96fa2df48210` |
| `llama-cli.exe` | `a32cfb6f13d33be46baaf5166227c0083227165d76c0da065c5efef10126e2d0` |
| `llama.dll` | `9c4afbd60edd4b816c90aca8253be72af2fdd61d9e9ff4e0923210feaa69307f` |
| `mtmd.dll` | `de038aefdda9ae37bb4c9d5b33930ec58c14c60196bb7fef1968448b50c874c2` |
| `ggml.dll` | `eb9898fcf97805449acf43a28043f57828c7e0dd98deeabc493e2b525be89b59` |
| `ggml-base.dll` | `ea624059b213fdbf2f96140eb43bd03e47ae0038ed5da15f9ab640246745f786` |
| `ggml-cpu.dll` | `7c5deb5bbe8ce9adfa098c2b09b39f0156e95f01dc4b28afe0fc1766a22f2d06` |
| `ggml-cuda.dll` | `c03ab3b0faacbc0f7e0ddd9580c62afe55b1dcc83d63a4b56062a32e6048a9d1` |
| `cudart64_13.dll` (CUDA 13.4) | `05bfafcb97bd53b0089568a96e1e5bd6921637bd0853ff7f5342bd31a6a16890` |

A rebuild with the same script and toolchain is expected to behave the same, but MSVC output is
not bit-for-bit reproducible, so new hashes are expected.

## Replacing it

When an official release includes both PRs, install it with `Install-LlamaRuntime.ps1`, point the
three launchers at it and repeat the capability tests; this runtime and `src\` can then be removed.
