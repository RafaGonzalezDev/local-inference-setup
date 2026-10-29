@echo off
rem Double-click entry point: opens a file picker, prints the transcript and waits for a key.
pwsh -NoProfile -File "%~dp0Transcribe-Audio.ps1" %*
pause
