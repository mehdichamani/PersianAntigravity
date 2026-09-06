@echo off
:: Antigravity IDE Windows Proxy Launcher
:: Runs antigravity-proxy.ps1 in background without an open command prompt window

set SCRIPT_DIR=%~dp0
powershell -WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_DIR%antigravity-proxy.ps1" %*
exit /b 0
