@echo off
setlocal ENABLEDELAYEDEXPANSION

set "GAME_EXE=StarRail.exe"
set "GAME_ALIASES=StarRail.exe StarRail.exe StarRail GameClient.exe"

echo ===============================
echo Killing old processes...
echo ===============================
taskkill /IM "firefly-go_win.exe" /F >nul 2>&1
taskkill /IM "FireflyProxy.exe" /F >nul 2>&1
taskkill /IM "launcher.exe" /F >nul 2>&1

echo ===============================
echo Starting Server...
echo ===============================
cd /d "%~dp0PS 3.6.5X"
if exist "firefly-go_win.exe" (
    start "" "%~dp0PS 3.6.5X\firefly-go_win.exe"
) else (
    echo Not found firefly-go_win.exe --> "%~dp0PS 3.6.5X"
    pause & exit /b 1
)

echo ===============================
echo Starting Proxy...
echo ===============================
cd /d "%~dp0PS 3.6.5X\FireflyProxy"
timeout /t 3 /nobreak >nul
start "" "FireflyProxy.exe"

timeout /t 3 /nobreak >nul

echo ===============================
echo Starting Launcher...
echo ===============================
cd /d "%~dp0"
start "" "launcher.exe"

echo ===============================
echo Waiting for %GAME_EXE% to start...
echo ===============================

:wait_start
set "FOUND="
for %%N in (%GAME_ALIASES%) do (
    tasklist /FI "IMAGENAME eq %%~N" 2>nul | find /I "%%~N" >nul && set "FOUND=1"
)
if not defined FOUND (
    timeout /t 2 >nul
    goto :wait_start
)
echo Detected game process running.

echo ===============================
echo Monitoring until the game closes...
echo ===============================

:wait_exit
set "FOUND="
for %%N in (%GAME_ALIASES%) do (
    tasklist /FI "IMAGENAME eq %%~N" 2>nul | find /I "%%~N" >nul && set "FOUND=1"
)
if defined FOUND (
    timeout /t 5 >nul
    goto :wait_exit
)

echo ===============================
echo Game closed - shutting down helpers...
echo ===============================

taskkill /IM "FireflyProxy.exe" /F >nul 2>&1
taskkill /IM "launcher.exe" /F >nul 2>&1
taskkill /IM "firefly-go_win.exe" /F >nul 2>&1

exit /b 0
