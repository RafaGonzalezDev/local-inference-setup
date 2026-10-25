@echo off
setlocal
for %%I in ("%~dp0..\..\..") do set "LLM_ROOT=%%~fI"

rem Automatic device placement agentic profile; use the model's native 65536-token context.
set "SERVER=%LLM_ROOT%\runtimes\llama.cpp\b11551-cuda13.4\llama-server.exe"

rem Model
set "MODEL_ARGS=--model "%LLM_ROOT%\models\nemotron-3.5-bolt-e4b\Nemotron-3.5-Bolt-E4B-Q4_K_M.gguf""

rem Context and performance
set "PERFORMANCE_ARGS=--gpu-layers auto --ctx-size 65536 --parallel 1 --cache-ram 0 --flash-attn on --split-mode none --fit on --fit-target 1024 --threads 8 --threads-batch 8 --batch-size 1024 --ubatch-size 1024 --jinja"

rem Network and API identity; the second alias is the profile ID this launcher serves to clients.
set "NETWORK_ARGS=--host 0.0.0.0 --port 8080 --alias nemotron-3.5-bolt-e4b,nemotron-3.5-bolt-e4b-65k"

rem Reasoning
set "REASONING_ARGS=--reasoning auto"

rem Sampling; temperature and top-p from the model card, top-k from the BF16 generation_config.json.
set "SAMPLING_ARGS=--temp 1 --top-p 0.95 --top-k 64"

rem Runtime, cache, logging, and reasoning budget
set "RUNTIME_ARGS=--log-verbosity 3 --load-mode none --cache-type-k q8_0 --cache-type-v q8_0 --reasoning-budget 8192"

rem The published GGUF is text-only; no projector is shipped.
set "VISION_ARGS="

rem The DFlash drafter is published in a separate repository and is not installed.
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
