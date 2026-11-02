@echo off
setlocal
for %%I in ("%~dp0..\..\..") do set "LLM_ROOT=%%~fI"

rem CPU-only text profile at 8,192 tokens; one request needs under 2K (instructions, prompt, answer); reuses the main D:\LLM runtime and weights.
set "SERVER=%LLM_ROOT%\..\runtimes\llama.cpp\b11981-cuda13.4\llama-server.exe"

rem Model
set "MODEL_ARGS=--model "%LLM_ROOT%\..\models\gemma-4-26b-a4b-uncensored-balanced\Gemma4-26B-A4B-QAT-Uncensored-HauhauCS-Balanced-Q4_K_M.gguf""

rem Context and performance: no devices are offloaded, so --fit has nothing to plan.
set "PERFORMANCE_ARGS=--device none --gpu-layers 0 --fit off --ctx-size 8192 --parallel 1 --cache-ram 8192 --flash-attn on --threads 8 --threads-batch 8 --batch-size 1024 --ubatch-size 1024 --jinja"

rem Network and API identity: loopback and port 8081 so it can run next to a main-catalog profile.
set "NETWORK_ARGS=--host 127.0.0.1 --port 8081 --alias gemma-4-26b-a4b-uncensored-balanced,gemma-4-26b-a4b-uncensored-balanced-cpu-8k"

rem Reasoning off: rewriting an image prompt does not need it, and it spent thousands of tokens per request
set "REASONING_ARGS=--reasoning off"

rem Sampling: same as the main Gemma 4 26B A4B Uncensored profiles (card values for this build)
set "SAMPLING_ARGS=--temp 0.6 --top-p 0.9 --top-k 64 --min-p 0.05 --repeat-penalty 1.1"

rem Runtime, cache, and logging
set "RUNTIME_ARGS=--log-verbosity 3 --no-log-timestamps --no-log-prefix --load-mode none --cache-type-k q8_0 --cache-type-v q8_0"

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
