@echo off
setlocal
pushd %~dp0

..\luajit ..\tes3mod.lua Tamriel_Data.txt tes3cn_Tamriel_Data.ext.txt topics_TD.txt tes3cn_Tamriel_Data.txt

pause
