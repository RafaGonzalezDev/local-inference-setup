@echo off
setlocal
for %%I in ("%~dp0..\..\..") do set "LLM_ROOT=%%~fI"

rem CPU-only vision profile at 16,384 tokens: instructions, up to five images and the answer; reuses the main D:\LLM runtime and weights.
set "SERVER=%LLM_ROOT%\..\runtimes\llama.cpp\b11981-cuda13.4\llama-server.exe"

rem Model
set "MODEL_ARGS=--model "%LLM_ROOT%\..\models\gemma-4-26b-a4b-uncensored-balanced\Gemma4-26B-A4B-QAT-Uncensored-HauhauCS-Balanced-Q4_K_M.gguf""

rem Context and performance: no devices are offloaded, so --fit has nothing to plan.
set "PERFORMANCE_ARGS=--device none --gpu-layers 0 --fit off --ctx-size 16384 --parallel 1 --cache-ram 8192 --flash-attn on --threads 8 --threads-batch 8 --batch-size 2048 --ubatch-size 2048 --jinja"

rem Network and API identity: loopback and port 8081 so it can run next to a main-catalog profile.
set "NETWORK_ARGS=--host 127.0.0.1 --port 8081 --alias gemma-4-26b-a4b-uncensored-balanced,gemma-4-26b-a4b-uncensored-balanced-cpu-vision-16k"

rem Reasoning off: rewriting an image prompt does not need it, and it spent thousands of tokens per request
set "REASONING_ARGS=--reasoning off"

rem Sampling: same as the main Gemma 4 26B A4B Uncensored profiles (card values for this build)
set "SAMPLING_ARGS=--temp 0.6 --top-p 0.9 --top-k 64 --min-p 0.05 --repeat-penalty 1.1"

rem Runtime, cache, and logging
set "RUNTIME_ARGS=--log-verbosity 3 --no-log-timestamps --no-log-prefix --load-mode none --cache-type-k q8_0 --cache-type-v q8_0"

rem Vision projector, kept on the CPU like the model (offloading is on by default even with --device none).
rem Every image gets the model's maximum budget of 1,120 tokens; it needs ubatch >= 1,120, hence batch 2048.
set "VISION_ARGS=--mmproj "%LLM_ROOT%\..\models\gemma-4-26b-a4b-uncensored-balanced\mmproj-Gemma4-26B-A4B-QAT-Uncensored-HauhauCS-Balanced-BF16.gguf" --no-mmproj-offload --image-min-tokens 1120 --image-max-tokens 1120"

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
