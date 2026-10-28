@echo off
setlocal
for %%I in ("%~dp0..\..\..") do set "LLM_ROOT=%%~fI"

rem Automatic device placement vision profile; --fit does not account for the projector, so the margin is wider.
set "SERVER=%LLM_ROOT%\runtimes\llama.cpp\b11551-cuda13.4\llama-server.exe"

rem Model
set "MODEL_ARGS=--model "%LLM_ROOT%\models\occult-nail-1.0-35b-a3b\Occult-Nail-1.0-35B-A3B-UD-Q4_K_XL.gguf""

rem Context and performance
set "PERFORMANCE_ARGS=--gpu-layers auto --ctx-size 131072 --parallel 1 --cache-ram 0 --flash-attn on --split-mode none --fit on --fit-target 2048 --threads 6 --threads-batch 6 --batch-size 1024 --ubatch-size 1024 --jinja"

rem Network and API identity; the second alias is the profile ID this launcher serves to clients.
set "NETWORK_ARGS=--host 0.0.0.0 --port 8080 --alias occult-nail-1.0-35b-a3b,occult-nail-1.0-35b-a3b-vision-131k"

rem Reasoning
set "REASONING_ARGS=--reasoning auto"

rem Sampling
set "SAMPLING_ARGS=--temp 0.6 --top-p 0.95 --top-k 20 --min-p 0 --presence-penalty 0 --repeat-penalty 1"

rem Runtime, cache, logging, and reasoning budget
set "RUNTIME_ARGS=--log-verbosity 3 --no-log-timestamps --no-log-prefix --load-mode none --cache-type-k q8_0 --cache-type-v q8_0 --reasoning-budget 8192"

rem Vision
set "VISION_ARGS=--mmproj "%LLM_ROOT%\models\occult-nail-1.0-35b-a3b\mmproj-F16.gguf" --image-min-tokens 2048"

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
