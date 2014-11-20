@echo off
set PAUSE_ERRORS=1
call bat\SetupSDK.bat
call bat\SetupApplication.bat

:menu
echo.
echo Select export target:
echo.
echo (1) Native .EXE with captive runtime
echo (2) Non-native .AIR
echo (3) Native .AIR with captive runtime
echo.

:choice
set /P C=Selection: 
echo.

set AIR_TARGET=

if "%C%"=="1" set STANDALONE=true
if "%C%"=="2" set STANDALONE=false
if "%C%"=="2" set OPTIONS=-tsa none
if "%C%"=="3" set AIR_TARGET=-captive-runtime

call bat\Packager.bat

pause