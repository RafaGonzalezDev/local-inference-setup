@echo off
setlocal
for %%I in ("%~dp0..\..\..") do set "LLM_ROOT=%%~fI"

rem Audio in, text or speech out (POST /tts) at the native 32,768-token context; source-built runtime.
set "SERVER=%LLM_ROOT%\runtimes\llama.cpp\19ff817-cuda13.4\llama-server.exe"

rem Model
set "MODEL_ARGS=--model "%LLM_ROOT%\models\lfm3-audio-2b\LFM3-Audio-2B-Q8_0.gguf""

rem Context and performance
set "PERFORMANCE_ARGS=--gpu-layers auto --ctx-size 32768 --parallel 1 --cache-ram 0 --flash-attn on --split-mode none --fit on --fit-target 2048 --threads 8 --threads-batch 8 --batch-size 1024 --ubatch-size 1024 --jinja"

rem Network and API identity; the second alias is the profile ID this launcher serves to clients.
set "NETWORK_ARGS=--host 0.0.0.0 --port 8080 --alias lfm3-audio-2b,lfm3-audio-2b-audio-32k"

rem Reasoning: the model reasons only when the template opens a think block
set "REASONING_ARGS=--reasoning auto"

rem Sampling: greedy text decoding from generation_config; audio sampling defaults are stored in the GGUF
set "SAMPLING_ARGS=--temp 0 --top-k 1 --min-p 0 --presence-penalty 0 --repeat-penalty 1"

rem Runtime, cache, logging, and reasoning budget
set "RUNTIME_ARGS=--log-verbosity 3 --load-mode none --cache-type-k q8_0 --cache-type-v q8_0 --reasoning-budget 8192"

rem Vision and audio projector
set "VISION_ARGS=--mmproj "%LLM_ROOT%\models\lfm3-audio-2b\mmproj-LFM3-Audio-2B-Q8_0.gguf""

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