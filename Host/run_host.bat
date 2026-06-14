@echo off
cd /d "%~dp0"
C:\Windows\SysWOW64\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -File bridge.ps1
exit