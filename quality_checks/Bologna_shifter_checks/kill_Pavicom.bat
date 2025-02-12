@echo off
set pavicom=true

:loop
tasklist | find /i "PAVModuleLoader.exe" && taskkill /im "PAVModuleLoader.exe" || echo process not running. && set pavicom=false

if "%pavicom%" == "false" (
    goto :break
)

:: Loop back
goto :loop

:break
echo Pavicom is closed 
