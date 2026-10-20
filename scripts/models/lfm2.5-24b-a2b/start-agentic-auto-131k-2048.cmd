@echo off
setlocal
for %%I in ("%~dp0..\..\..") do set "LLM_ROOT=%%~fI"

rem Automatic device placement agentic profile; --fit resolves the layer split.
set "SERVER=%LLM_ROOT%\runtimes\llama.cpp\b11551-cuda13.4\llama-server.exe"

rem Model
set "MODEL_ARGS=--model "%LLM_ROOT%\models\lfm2.5-24b-a2b\LFM2.5-24B-A2B-Q4_K_M.gguf""

rem Context and performance
set "PERFORMANCE_ARGS=--gpu-layers auto --ctx-size 131072 --parallel 1 --cache-ram 0 --flash-attn on --split-mode none --fit on --fit-target 1024 --threads 8 --threads-batch 8 --batch-size 512 --ubatch-size 512 --jinja"

rem Network and API identity; the second alias is the profile ID this launcher serves to clients.
set "NETWORK_ARGS=--host 0.0.0.0 --port 8080 --alias lfm2.5-24b-a2b,lfm2.5-24b-a2b-131k"

rem Reasoning: the model always thinks; the budget is the local agentic cap
set "REASONING_ARGS=--reasoning on"

rem Sampling from the publication's generation_config and general.sampling metadata
set "SAMPLING_ARGS=--temp 0.1 --top-p 1 --top-k 50 --min-p 0 --presence-penalty 0 --repeat-penalty 1.05"

rem Runtime, cache, logging, and reasoning budget
set "RUNTIME_ARGS=--log-verbosity 3 --load-mode none --cache-type-k q8_0 --cache-type-v q8_0 --reasoning-budget 8192"

rem Vision
set "VISION_ARGS="

rem Speculative decoding
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
