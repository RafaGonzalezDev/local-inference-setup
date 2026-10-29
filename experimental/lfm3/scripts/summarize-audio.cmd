@echo off
rem Double-click entry point: starts lfm3-omni-2b if no server is running, writes SUMMARY.md for each
rem selected file until the picker is cancelled, then stops it. Closing this window also ends the server.
pwsh -NoProfile -File "%~dp0Summarize-Audio.ps1" -StartServer %*
pause
