@echo off
setlocal
for %%I in ("%~dp0..\..\..") do set "LLM_ROOT=%%~fI"

rem Text, image, video and audio in, text or speech out (POST /tts, WebSocket /v1/realtime) at the 32,768-token card context.
set "SERVER=%LLM_ROOT%\runtimes\llama.cpp\b11981-cuda13.4\llama-server.exe"

rem Model
set "MODEL_ARGS=--model "%LLM_ROOT%\models\lfm3-omni-2b\LFM3-Omni-2B-Q8_0.gguf""

rem Context and performance
set "PERFORMANCE_ARGS=--gpu-layers auto --ctx-size 32768 --parallel 1 --cache-ram 8192 --flash-attn on --split-mode none --fit on --fit-target 2048 --threads 6 --threads-batch 6 --batch-size 1024 --ubatch-size 1024 --jinja"

rem Network and API identity; the second alias is the profile ID this launcher serves to clients.
set "NETWORK_ARGS=--host 0.0.0.0 --port 8080 --alias lfm3-omni-2b,lfm3-omni-2b-omni-32k"

rem Reasoning: non-reasoning model; the GGUF card asks for --reasoning off
set "REASONING_ARGS=--reasoning off"

rem Sampling: greedy text decoding from the GGUF card; audio sampling defaults are stored in the GGUF
set "SAMPLING_ARGS=--temp 0 --top-k 1 --min-p 0 --presence-penalty 0 --repeat-penalty 1"

rem Runtime, cache, logging, and reasoning budget
set "RUNTIME_ARGS=--log-verbosity 3 --no-log-timestamps --no-log-prefix --load-mode none --cache-type-k q8_0 --cache-type-v q8_0"

rem Vision and audio projector (video needs ffmpeg in PATH)
set "VISION_ARGS=--mmproj "%LLM_ROOT%\models\lfm3-omni-2b\mmproj-LFM3-Omni-2B-Q8_0.gguf""

rem MTP speculative decoding
set "MTP_ARGS="

"%SERVER%" ^
  %MODEL_ARGS% ^
  %PERFORMANCE_ARGS% ^
  %NETWORK_ARGS% ^
  %REASONING_ARGS% ^
  %SAMPLING_ARGS% ^
  %RUNTIME_ARGS% ^
  %VISION_ARGS% ^
  %MTP_ARGS%
set "EXIT_CODE=%ERRORLEVEL%"
endlocal & exit /b %EXIT_CODE%
