@echo off
setlocal
pushd %~dp0

@echo on

..\luajit ..\tes3fix.lua tes3cn_TR_Mainland.ext.txt

pause