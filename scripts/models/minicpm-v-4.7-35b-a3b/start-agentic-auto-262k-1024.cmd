@echo off
setlocal
for %%I in ("%~dp0..\..\..") do set "LLM_ROOT=%%~fI"

rem Automatic device placement profile for full-context workloads; --fit resolves the layer split.
set "SERVER=%LLM_ROOT%\runtimes\llama.cpp\b11551-cuda13.4\llama-server.exe"

rem Model
set "MODEL_ARGS=--model "%LLM_ROOT%\models\minicpm-v-4.7-35b-a3b\MiniCPM-V-4_7-35B-A3B-Q4_K_M.gguf""

rem Context and performance
set "PERFORMANCE_ARGS=--gpu-layers auto --ctx-size 262144 --parallel 1 --cache-ram 0 --flash-attn on --split-mode none --fit on --fit-target 1024 --threads 8 --threads-batch 8 --batch-size 1024 --ubatch-size 1024 --jinja"

rem Network and API identity; the second alias is the profile ID this launcher serves to clients.
set "NETWORK_ARGS=--host 0.0.0.0 --port 8080 --alias minicpm-v-4.7-35b-a3b,minicpm-v-4.7-35b-a3b-262k"

rem Reasoning
set "REASONING_ARGS=--reasoning auto"

rem Sampling from the official v4.7 llama.cpp guide
set "SAMPLING_ARGS=--temp 0.7 --top-p 0.8 --top-k 100 --min-p 0 --presence-penalty 0 --repeat-penalty 1.05"

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
