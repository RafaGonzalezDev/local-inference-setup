@echo off
rem Double-click entry point: starts lfm3-audio-2b if no server is running, asks for files until the
rem picker is cancelled, then stops it. Closing this window also ends the server it started.
pwsh -NoProfile -File "%~dp0Transcribe-Audio.ps1" -StartServer %*
pause
