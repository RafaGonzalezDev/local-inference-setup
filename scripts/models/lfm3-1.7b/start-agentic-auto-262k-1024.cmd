@echo off
setlocal
for %%I in ("%~dp0..\..\..") do set "LLM_ROOT=%%~fI"

rem Text agentic profile at the native 262,144-token context; runtime built from source (no release supports LFM3 yet).
set "SERVER=%LLM_ROOT%\runtimes\llama.cpp\19ff817-cuda13.4\llama-server.exe"

rem Model
set "MODEL_ARGS=--model "%LLM_ROOT%\models\lfm3-1.7b\LFM3-1.7B-Q8_0.gguf""

rem Context and performance
set "PERFORMANCE_ARGS=--gpu-layers auto --ctx-size 262144 --parallel 1 --cache-ram 0 --flash-attn on --split-mode none --fit on --fit-target 1024 --threads 8 --threads-batch 8 --batch-size 1024 --ubatch-size 1024 --jinja"

rem Network and API identity; the second alias is the profile ID this launcher serves to clients.
set "NETWORK_ARGS=--host 0.0.0.0 --port 8080 --alias lfm3-1.7b,lfm3-1.7b-262k"

rem Reasoning: thinking is on by default in the template and can be turned off per request
set "REASONING_ARGS=--reasoning auto"

rem Sampling: general profile from the model card and generation_config (temperature 0.1, top_k 50, repetition penalty 1.1)
set "SAMPLING_ARGS=--temp 0.1 --top-p 1 --top-k 50 --min-p 0 --presence-penalty 0 --repeat-penalty 1.1"

rem Runtime, cache, logging, and reasoning budget
set "RUNTIME_ARGS=--log-verbosity 3 --load-mode none --cache-type-k q8_0 --cache-type-v q8_0 --reasoning-budget 8192"

rem Vision and audio projector
set "VISION_ARGS="

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