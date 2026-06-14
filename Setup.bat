@echo off
color 17
setlocal enabledelayedexpansion

:: ==========================================
:: 1. Privilege Integrity Check
:: ==========================================
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo =====================================================
    echo  [Access Denied] Administrator privileges are required.
    echo  Please right-click this setup file and select 
    echo  'Run as administrator' to allow registry modifications.
    echo =====================================================
    pause
    exit /b 1
)

echo.
echo WARNING:
echo Non-English installation paths may cause Native Messaging failures.
echo Recommended path:
echo C:\Tools\LegacyDownloadBridge
echo.
timeout /t 2 >nul
pause

:: Global Environment Variables
set "HOST_DIR=%~dp0Host"
set "JSON_FILE=%HOST_DIR%\com.dowon.urlmon_bridge.json"
set "REG_CHROME=HKLM\Software\Google\Chrome\NativeMessagingHosts\com.dowon.urlmon_bridge"
set "REG_EDGE=HKLM\Software\Microsoft\Edge\NativeMessagingHosts\com.dowon.urlmon_bridge"

:MENU
cls
echo ======================================================================
echo                 Legacy URLMon Download Bridge
echo ======================================================================
echo  This program installs a Native Messaging Host that bypasses the
echo  modern Chromium browser download sandbox and calls the pure 
echo  Windows (IE) legacy download dialog.
echo ======================================================================
echo.
echo  [1] Setup / Configuration
echo  [2] Verify Status / Diagnostics
echo  [3] Uninstall
echo  [4] Exit
echo.
set /p "menuchc=Select an option (1-4) : "
if "%menuchc%"=="1" goto ENTER
if "%menuchc%"=="2" goto CHECK
if "%menuchc%"=="3" goto UNINSTALL
if "%menuchc%"=="4" goto END_EXIT
goto MENU

:ENTER
:: Bypass creation if JSON already exists and targets are mapped
if exist "%JSON_FILE%" (
    reg query "%REG_CHROME%" >nul 2>&1
    if !errorlevel! equ 0 goto ID
    reg query "%REG_EDGE%" >nul 2>&1
    if !errorlevel! equ 0 goto ID
)
goto INSTALL

:INSTALL
cls
echo ======================================================================
echo  Step 1. Target Browser Selection
echo ======================================================================
echo  Which browser environment would you like to install the bridge for?
echo.
echo  [1] Microsoft Edge (Blink engine)
echo  [2] Other Chromium (Vivaldi, Chrome, Opera, Brave, etc.)
echo  [3] Install for ALL Chromium browsers
echo.
set /p "browser_choice=Select (1-3) : "

if "%browser_choice%"=="1" (
    set "TARGET_REG_1=%REG_EDGE%"
    set "TARGET_REG_2="
    set "BROWSER_NAME=Microsoft Edge"
) else if "%browser_choice%"=="2" (
    set "TARGET_REG_1=%REG_CHROME%"
    set "TARGET_REG_2="
    set "BROWSER_NAME=Chromium Based Browser"
) else if "%browser_choice%"=="3" (
    set "TARGET_REG_1=%REG_EDGE%"
    set "TARGET_REG_2=%REG_CHROME%"
    set "BROWSER_NAME=All Chromium Browsers"
) else (
    goto INSTALL
)

:: Escape backslashes for JSON format (\ -> \\)
set "JSON_PATH_ESC=!HOST_DIR:\=\\!"

echo.
echo  Creating registry keys and initial JSON for [%BROWSER_NAME%]...
(
    echo {
    echo   "name": "com.dowon.urlmon_bridge",
    echo   "description": "Legacy URLMon Download Bridge Host",
    echo   "path": "%JSON_PATH_ESC%\\run_host.bat",
    echo   "type": "stdio",
    echo   "allowed_origins": [
    echo     "chrome-extension://PENDING_ID/"
    echo   ]
    echo }
) > "%JSON_FILE%"

if defined TARGET_REG_1 reg add "!TARGET_REG_1!" /ve /t REG_SZ /d "%JSON_FILE%" /f >nul
if defined TARGET_REG_2 reg add "!TARGET_REG_2!" /ve /t REG_SZ /d "%JSON_FILE%" /f >nul

echo  Initial setup complete.
timeout /t 2 >nul
goto ID

:ID
cls
timeout /t 1 >nul
reg query "%REG_CHROME%" >nul 2>&1
    if !errorlevel! equ 0 echo Step 1 has been already completed, Setup is instucting you to Step 2.
echo ======================================================================
echo  Step 2. Extension ID Configuration
echo ======================================================================
echo  A unique Extension ID is required to link the browser and local host.
echo.
echo  1. Open your browser's extensions page (chrome://extensions).
echo  2. Turn on "Developer mode".
echo  3. Load this folder as an unpacked extension:
echo.
echo %~dp0Host
echo.
echo  4. Copy the generated '32-character ID' and paste it below.
echo.
echo  * Note: You must restart your browser for changes to take effect 
echo    (now or later).
echo  You may type the ID later. To do so, just close this window and open Setup again whenever you want. However, this is necessary to complete installation.
echo ======================================================================
set /p "EXT_ID=Enter 32-character ID : "

:: Length validation (Exact 32 chars)
set "ID_TEST=%EXT_ID%"
if "!ID_TEST:~31,1!"=="" (
    echo.
    echo  [ERROR] The ID is too short. It must be exactly 32 characters.
    pause
    goto ID
)
if not "!ID_TEST:~32,1!"=="" (
    echo.
    echo  [ERROR] The ID is too long. It must be exactly 32 characters.
    pause
    goto ID
)

:: Final JSON update with the correct ID
set "JSON_PATH_ESC=!HOST_DIR:\=\\!"
(
    echo {
    echo   "name": "com.dowon.urlmon_bridge",
    echo   "description": "Legacy URLMon Download Bridge Host",
    echo   "path": "%JSON_PATH_ESC%\\run_host.bat",
    echo   "type": "stdio",
    echo   "allowed_origins": [
    echo     "chrome-extension://%EXT_ID%/"
    echo   ]
    echo }
) > "%JSON_FILE%"

goto END

:CHECK
cls
echo ======================================================================
echo  System Diagnostics
echo ======================================================================
echo [1. File Integrity]
if exist "%HOST_DIR%\run_host.bat" (echo  [OK] run_host.bat) else (echo  [FAIL] run_host.bat)
if exist "%HOST_DIR%\bridge.ps1" (echo  [OK] bridge.ps1) else (echo  [FAIL] bridge.ps1)
if exist "%HOST_DIR%\os_file_download.cs" (echo  [OK] os_file_download.cs) else (echo  [WARN] os_file_download.cs)
if exist "%HOST_DIR%\os_file_download.exe" (echo  [OK] os_file_download.exe) else (echo  [WARN] os_file_download.exe)
echo.
echo [2. Registry Mapping]
reg query "%REG_EDGE%" >nul 2>&1
if !errorlevel! equ 0 (echo  - Edge Target : Found) else (echo  - Edge Target : Not Found)
reg query "%REG_CHROME%" >nul 2>&1
if !errorlevel! equ 0 (echo  - Chrome/Vivaldi Target : Found) else (echo  - Chrome/Vivaldi Target : Not Found)
echo.
echo [3. Current JSON Parameters]
if exist "%JSON_FILE%" (
    type "%JSON_FILE%"
) else (
    echo  - JSON Configuration file is missing. Run Setup [1].
)
echo ======================================================================
timeout /t 1 >nul
pause
goto MENU

:UNINSTALL
cls
echo ======================================================================
echo  Removing Legacy URLMon Bridge...
echo ======================================================================
reg delete "%REG_EDGE%" /f >nul 2>&1
reg delete "%REG_CHROME%" /f >nul 2>&1
if exist "%JSON_FILE%" del /q "%JSON_FILE%"
echo.
echo  Registry keys and JSON configuration have been removed.
echo  (Please remove the extension from your browser manually.)
timeout /t 1 >nul
pause
goto MENU

:END
cls
echo ======================================================================
echo  Setup Completed Successfully!
echo ======================================================================
echo  [Execution Manual]
echo.
echo  1. Close all open browser windows and launch it again.
echo  2. Right-click on a download link while browsing.
echo  3. Select "Download via Legacy IE" from the context menu.
echo  4. The classic Windows download dialog will pop up.
echo.
echo  [Troubleshooting Guide]
echo  If the download fails to start, does not respond, or downloads 
echo  a 0-byte file, please refer to the provided readme.txt. 
echo  The URLMon API may fail if the target link uses Redirection, 
echo  dynamic JavaScript rendering, or requires rigid Session/Token 
echo  authentication (e.g., Cloud drives, Bank portals).
echo ======================================================================
timeout /t 1 >nul
pause
exit

:END_EXIT
exit