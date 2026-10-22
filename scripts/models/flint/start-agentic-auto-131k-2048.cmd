@echo off
setlocal
for %%I in ("%~dp0..\..\..") do set "LLM_ROOT=%%~fI"

rem Automatic device placement profile for high-prefill workloads; --fit resolves the layer split.
rem Flint support (FlintForCausalLM) first ships in b11803; the default runtime b11551 cannot load it.
set "SERVER=%LLM_ROOT%\runtimes\llama.cpp\b11827-cuda13.4\llama-server.exe"

rem Model
set "MODEL_ARGS=--model "%LLM_ROOT%\models\flint\flint-UD-Q4_K_XL.gguf""

rem Context and performance
set "PERFORMANCE_ARGS=--gpu-layers auto --ctx-size 131072 --parallel 1 --cache-ram 0 --flash-attn on --split-mode none --fit on --fit-target 1024 --threads 8 --threads-batch 8 --batch-size 2048 --ubatch-size 2048 --jinja"

rem Network and API identity; the second alias is the profile ID this launcher serves to clients.
set "NETWORK_ARGS=--host 0.0.0.0 --port 8080 --alias flint,flint-131k"

rem Reasoning
set "REASONING_ARGS=--reasoning auto"

rem Sampling recommended by Recursive for Flint.
set "SAMPLING_ARGS=--temp 1.0 --top-p 0.95 --top-k 20 --min-p 0 --presence-penalty 0 --repeat-penalty 1"

rem Runtime, cache, logging, and reasoning budget; unlimited because the card asks for 32K+ output on hard problems.
set "RUNTIME_ARGS=--log-verbosity 3 --load-mode none --cache-type-k q8_0 --cache-type-v q8_0 --reasoning-budget -1"

rem Vision
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
