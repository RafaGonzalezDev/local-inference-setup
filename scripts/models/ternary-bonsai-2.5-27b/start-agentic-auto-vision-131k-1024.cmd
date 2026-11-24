@echo off
setlocal
for %%I in ("%~dp0..\..\..") do set "LLM_ROOT=%%~fI"

rem Automatic device placement vision profile; --fit does not account for the projector, so the margin is wider.
rem PTQ1_0 ternary weights need the PrismML llama.cpp fork; stock llama.cpp rejects the type.
set "SERVER=%LLM_ROOT%\runtimes\llama.cpp\prism-b12178-cuda13.3\llama-server.exe"

rem Model
set "MODEL_ARGS=--model "%LLM_ROOT%\models\ternary-bonsai-2.5-27b\Ternary-Bonsai-2.5-27B-PTQ1_0.gguf""

rem Context and performance
set "PERFORMANCE_ARGS=--gpu-layers auto --ctx-size 131072 --parallel 1 --cache-ram 8192 --flash-attn on --split-mode none --fit on --fit-target 2048 --threads 6 --threads-batch 6 --batch-size 1024 --ubatch-size 1024 --jinja"

rem Network and API identity; the second alias is the profile ID this launcher serves to clients.
set "NETWORK_ARGS=--host 0.0.0.0 --port 8080 --alias ternary-bonsai-2.5-27b,ternary-bonsai-2.5-27b-vision-131k"

rem Reasoning; the template defaults to xhigh effort and only accepts xhigh, medium, and low.
set "REASONING_ARGS=--reasoning auto"

rem Sampling; Bonsai 2.5 card, thinking mode (llama.cpp defaults to min-p 0.05, hence explicit 0)
set "SAMPLING_ARGS=--temp 1.0 --top-p 0.95 --top-k 20 --min-p 0 --presence-penalty 0 --repeat-penalty 1"

rem Runtime, cache, logging, and reasoning budget
set "RUNTIME_ARGS=--log-verbosity 3 --no-log-timestamps --no-log-prefix --load-mode none --cache-type-k q8_0 --cache-type-v q8_0 --reasoning-budget 8192"

rem Vision
set "VISION_ARGS=--mmproj "%LLM_ROOT%\models\ternary-bonsai-2.5-27b\Ternary-Bonsai-2.5-27B-mmproj-BF16.gguf""

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
