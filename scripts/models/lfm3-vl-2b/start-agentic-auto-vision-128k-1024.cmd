@echo off
setlocal
for %%I in ("%~dp0..\..\..") do set "LLM_ROOT=%%~fI"

rem Image and video in, text out, at the native 128,000-token context (input plus output); --fit does not account for the projector, so the margin is wider.
set "SERVER=%LLM_ROOT%\runtimes\llama.cpp\b11981-cuda13.4\llama-server.exe"

rem Model
set "MODEL_ARGS=--model "%LLM_ROOT%\models\lfm3-vl-2b\LFM3-VL-2B-Q8_0.gguf""

rem Context and performance
set "PERFORMANCE_ARGS=--gpu-layers auto --ctx-size 128000 --parallel 1 --cache-ram 8192 --flash-attn on --split-mode none --fit on --fit-target 2048 --threads 6 --threads-batch 6 --batch-size 1024 --ubatch-size 1024 --jinja"

rem Network and API identity; the second alias is the profile ID this launcher serves to clients.
set "NETWORK_ARGS=--host 0.0.0.0 --port 8080 --alias lfm3-vl-2b,lfm3-vl-2b-vision-128k"

rem Reasoning: the model thinks before answering; the card drops past reasoning from the history
set "REASONING_ARGS=--reasoning auto"

rem Sampling: card recommendation (temperature 0.1, top_p 1.0, top_k 50, min_p 0, repeat penalty 1.1)
set "SAMPLING_ARGS=--temp 0.1 --top-p 1 --top-k 50 --min-p 0 --presence-penalty 0 --repeat-penalty 1.1"

rem Runtime, cache, logging, and reasoning budget
set "RUNTIME_ARGS=--log-verbosity 3 --no-log-timestamps --no-log-prefix --load-mode none --cache-type-k q8_0 --cache-type-v q8_0 --reasoning-budget 8192 --no-reasoning-preserve"

rem Vision projector (images and video; video needs ffmpeg in PATH)
set "VISION_ARGS=--mmproj "%LLM_ROOT%\models\lfm3-vl-2b\mmproj-LFM3-VL-2B-Q8_0.gguf""

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
