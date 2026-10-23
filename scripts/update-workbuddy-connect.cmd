@echo off
chcp 65001 >nul
title Update dsh-workbuddy-connect to 0.7.9
echo ============================================================
echo  This will CLOSE DeepSeek Harness, install the plugin
echo  update, then start DeepSeek Harness again.
echo ============================================================
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0update-workbuddy-connect.ps1"
echo.
echo ------------------------------------------------------------
pause
