@echo off
setlocal
for %%I in ("%~dp0..\..\..") do set "LLM_ROOT=%%~fI"

rem This launcher is self-contained. Edit the literal values below to customize it.
set "SERVER=%LLM_ROOT%\runtimes\llama.cpp\b10273-cuda13.3\llama-server.exe"

rem Model
set "MODEL_ARGS=--model "%LLM_ROOT%\models\gemma-4-12b-v2\gemma-4-12B-it-qat-UD-Q4_K_XL.gguf""

rem Context and performance
set "PERFORMANCE_ARGS=--gpu-layers 999 --ctx-size 262144 --split-mode none --jinja"

rem Network and API identity
set "NETWORK_ARGS=--host 0.0.0.0 --port 8080 --alias gemma-4-12b-v2"

rem Reasoning
set "REASONING_ARGS=--reasoning on"

rem Sampling
set "SAMPLING_ARGS=--temp 1 --top-p 0.95 --top-k 64"

rem Runtime, cache, logging, and reasoning budget
set "RUNTIME_ARGS=--reasoning-budget 8192"

rem Vision
set "VISION_ARGS=--mmproj "%LLM_ROOT%\models\gemma-4-12b-v2\mmproj-F16.gguf""

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
