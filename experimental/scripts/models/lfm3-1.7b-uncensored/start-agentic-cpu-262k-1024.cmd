@echo off
setlocal
for %%I in ("%~dp0..\..\..") do set "LLM_ROOT=%%~fI"

rem CPU-only text profile at the native 262,144-token context; reuses the main D:\LLM runtime.
set "SERVER=%LLM_ROOT%\..\runtimes\llama.cpp\b11981-cuda13.4\llama-server.exe"

rem Model
set "MODEL_ARGS=--model "%LLM_ROOT%\models\lfm3-1.7b-uncensored\LFM3-1.7B-Uncensored-AD-Q6_K.gguf""

rem Context and performance: no devices are offloaded, so --fit has nothing to plan.
set "PERFORMANCE_ARGS=--device none --gpu-layers 0 --fit off --ctx-size 262144 --parallel 1 --cache-ram 8192 --flash-attn on --threads 8 --threads-batch 8 --batch-size 1024 --ubatch-size 1024 --jinja"

rem Network and API identity: loopback and port 8081 so it can run next to a main-catalog profile.
set "NETWORK_ARGS=--host 127.0.0.1 --port 8081 --alias lfm3-1.7b-uncensored,lfm3-1.7b-uncensored-cpu-262k"

rem Reasoning: thinking is on by default in the template and can be turned off per request
set "REASONING_ARGS=--reasoning auto"

rem Sampling: inherited from the LFM3 1.7B GGUF card; the uncensored card publishes none
set "SAMPLING_ARGS=--temp 0.1 --top-p 1 --top-k 50 --min-p 0 --presence-penalty 0 --repeat-penalty 1.1"

rem Runtime, cache, logging, and reasoning budget
set "RUNTIME_ARGS=--log-verbosity 3 --no-log-timestamps --no-log-prefix --load-mode none --cache-type-k q8_0 --cache-type-v q8_0 --reasoning-budget 8192"

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
