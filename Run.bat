@echo off
setlocal ENABLEDELAYEDEXPANSION

REM ====== CONFIG ======
set "GAME_NAMES=StarRail.exe GameClient.exe"
set "HELPERS=firefly-go_win.exe FireflyProxy.exe launcher.exe"

REM ====== STOP OLD HELPERS ======
echo ===============================
echo Killing old helper processes...
echo ===============================
for %%P in (%HELPERS%) do (
    taskkill /IM "%%~P" /T /F >nul 2>&1
)

REM ====== START SERVER ======
echo ===============================
echo Starting Server...
echo ===============================
cd /d "%~dp0FireflyGo 3.6.5X"
if exist "firefly-go_win.exe" (
    start "" "%CD%\firefly-go_win.exe"
) else (
    echo Not found firefly-go_win.exe --> "%~dp0FireflyGo 3.6.5X"
    pause & exit /b 1
)

REM ====== START PROXY ======
echo ===============================
echo Starting Proxy...
echo ===============================
cd /d "%~dp0FireflyGo 3.6.5X\FireflyProxy"
timeout /t 3 /nobreak >nul
start "" "%CD%\FireflyProxy.exe"

timeout /t 3 /nobreak >nul

REM ====== START LAUNCHER ======
echo ===============================
echo Starting Launcher...
echo ===============================
cd /d "%~dp0"
start "" "%CD%\launcher.exe"

REM ====== WAIT GAME START ======
echo ===============================
echo Waiting for game to start...
echo ===============================
:WAIT_START
set "FOUND="
for %%N in (%GAME_NAMES%) do (
    for /f "tokens=2 delims=," %%A in ('tasklist /FI "IMAGENAME eq %%~N" /FO CSV /NH ^| find /I "%%~N"') do (
        set "FOUND=1"
    )
)
if not defined FOUND (
    timeout /t 2 >nul
    goto :WAIT_START
)
echo Detected game process.

REM ====== MONITOR UNTIL GAME CLOSES ======
echo ===============================
echo Monitoring until the game closes...
echo ===============================
:WAIT_EXIT
set "FOUND="
for %%N in (%GAME_NAMES%) do (
    for /f "tokens=2 delims=," %%A in ('tasklist /FI "IMAGENAME eq %%~N" /FO CSV /NH ^| find /I "%%~N"') do (
        set "FOUND=1"
    )
)
if defined FOUND (
    timeout /t 5 >nul
    goto :WAIT_EXIT
)

REM ====== SHUTDOWN HELPERS ======
echo ===============================
echo Game closed - shutting down helpers...
echo ===============================
for %%P in (%HELPERS%) do (
    taskkill /IM "%%~P" /T /F >nul 2>&1
)

exit /b 0
