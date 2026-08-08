@echo off
setlocal
for %%I in ("%~dp0..\..\..") do set "LLM_ROOT=%%~fI"

rem This launcher is self-contained. Edit the literal values below to customize it.
set "SERVER=%LLM_ROOT%\runtimes\llama.cpp\b10273-cuda13.3\llama-server.exe"

rem Model
set "MODEL_ARGS=--model "%LLM_ROOT%\models\qwen3.6-35b-a3b\Qwen3.6-35B-A3B-UD-Q4_K_M.gguf""

rem Context and performance
set "PERFORMANCE_ARGS=--gpu-layers 999 --n-cpu-moe 23 --ctx-size 65536 --parallel 1 --cache-ram 0 --flash-attn on --split-mode none --fit off --threads 8 --threads-batch 8 --batch-size 1024 --ubatch-size 1024 --jinja"

rem Network and API identity
set "NETWORK_ARGS=--host 0.0.0.0 --port 8080 --alias qwen3.6-35b-a3b"

rem Reasoning
set "REASONING_ARGS=--reasoning on"

rem Sampling
set "SAMPLING_ARGS=--temp 1 --top-p 0.95 --top-k 20 --min-p 0 --presence-penalty 1.5 --repeat-penalty 1"

rem Runtime, cache, logging, and reasoning budget
set "RUNTIME_ARGS=--log-verbosity 3 --load-mode none --cache-type-k q8_0 --cache-type-v q8_0 --reasoning-budget 8192"

rem Vision
set "VISION_ARGS=--mmproj "%LLM_ROOT%\models\qwen3.6-35b-a3b\mmproj-F16.gguf" --image-min-tokens 1024"

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
