@echo off
setlocal
cd /d "%~dp0"

set "CS_FILE=os_file_download.cs"
set "EXE_FILE=os_file_download.exe"
set "CSC=C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe"

echo Building Legacy Download Bridge...
"%CSC%" /nologo /platform:x86 /target:winexe /out:"%EXE_FILE%" "%CS_FILE%"

if %errorlevel% neq 0 (
    echo [ERROR] Compilation failed!
    pause
    exit /b %errorlevel%
)

echo Build Successful: %EXE_FILE%
pause