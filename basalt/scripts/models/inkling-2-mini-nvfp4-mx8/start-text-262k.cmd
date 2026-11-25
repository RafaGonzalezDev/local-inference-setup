@echo off
setlocal
for %%I in ("%~dp0..\..\..\..") do set "LLM_ROOT=%%~fI"

rem Inkling 2 Mini NVFP4-MX8, text only, served by Basalt instead of llama-server.
rem The config beside this file holds the model entry (pack, alias, context, KV); its model path is relative to it.
set "BASALT_ROOT=%LLM_ROOT%\runtimes\basalt\0.5.7"
set "SERVER=%BASALT_ROOT%\bin\basalt.exe"
set "ENGINE_CONFIG=%~dp0text-262k.json"

rem Basalt keeps its engine log and conversation cache under ~\.cache\basalt; keep them inside its runtime folder.
rem The CUDA 13 runtime DLLs sit beside basalt.exe, so neither PATH nor the user profile changes.
set "USERPROFILE=%BASALT_ROOT%\home"
set "HOME=%BASALT_ROOT%\home"

rem Network: same port and exposure as the llama.cpp profiles (private network only, no authentication)
set "NETWORK_ARGS=--host 0.0.0.0 --port 8080"

if not exist "%BASALT_ROOT%\home" mkdir "%BASALT_ROOT%\home"
"%SERVER%" serve --config "%ENGINE_CONFIG%" %NETWORK_ARGS%
endlocal & exit /b %ERRORLEVEL%
