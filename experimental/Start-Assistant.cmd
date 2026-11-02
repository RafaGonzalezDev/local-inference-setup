@echo off
setlocal

rem Entry point: loads the model and opens the prompt interface; the model stops when it closes.
rem The instructions file is the system prompt and is always set explicitly here.
pwsh -NoProfile -File "%~dp0Start-Assistant.ps1" -Instructions qwen-image-2.1
set "EXIT_CODE=%ERRORLEVEL%"

rem Keep the window open on failure when started by double-click.
if not "%EXIT_CODE%"=="0" pause
endlocal & exit /b %EXIT_CODE%
