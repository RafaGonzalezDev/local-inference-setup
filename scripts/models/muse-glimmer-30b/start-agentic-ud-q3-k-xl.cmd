@echo off
setlocal
for %%I in ("%~dp0..\..\..") do set "LLM_ROOT=%%~fI"

rem This launcher is self-contained. Edit the literal values below to customize it.
set "SERVER=%LLM_ROOT%\runtimes\llama.cpp\b10361-cuda13.3\llama-server.exe"

rem Model
set "MODEL_ARGS=--model "%LLM_ROOT%\models\muse-glimmer-30b\Muse-Glimmer-30B-UD-Q3_K_XL.gguf""

rem Context and performance
set "PERFORMANCE_ARGS=--gpu-layers auto --ctx-size 131072 --parallel 1 --cache-ram 0 --flash-attn on --split-mode none --fit on --fit-target 768 --threads 8 --threads-batch 8 --batch-size 1024 --ubatch-size 512 --jinja"

rem Network and API identity
set "NETWORK_ARGS=--host 0.0.0.0 --port 8080 --alias muse-glimmer-30b"

rem Reasoning
set "REASONING_ARGS=--reasoning on"

rem Sampling recommended by Meta/Unsloth
set "SAMPLING_ARGS=--temp 1 --top-p 0.95 --top-k 64 --min-p 0 --presence-penalty 0 --repeat-penalty 1"

rem Runtime, cache, logging, and reasoning budget
set "RUNTIME_ARGS=--log-verbosity 3 --load-mode none --cache-type-k q8_0 --cache-type-v q8_0 --reasoning-budget 8192"

rem Vision is intentionally deferred; this profile compares the main GGUF only.
set "VISION_ARGS="

rem DFlash speculative decoding is intentionally deferred.
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
