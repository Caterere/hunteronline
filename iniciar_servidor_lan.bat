@echo off
title Hunter MMORPG Dedicated Server
setlocal EnableExtensions

echo ============================================================
echo         INICIANDO HUNTER MMORPG DEDICATED SERVER
echo ============================================================
echo [LAN / Radmin VPN / futuro VPS]
echo Porta Padrao: 7777 (ENet UDP)
echo Descoberta LAN: 7778 (UDP Broadcast)
echo.
echo Dica: outros PCs na mesma rede conectam no IP deste host:porta 7777
echo       (firewall: liberar UDP 7777; discovery UDP 7778 so na LAN)
echo.

REM Prefer GODOT_BIN env, then PATH, then common local names.
set "GODOT_EXE="
if defined GODOT_BIN if exist "%GODOT_BIN%" set "GODOT_EXE=%GODOT_BIN%"
if not defined GODOT_EXE where godot >nul 2>&1 && for /f "delims=" %%i in ('where godot') do set "GODOT_EXE=%%i" & goto :found
if not defined GODOT_EXE if exist "Godot_v4.6-stable_win64_console.exe" set "GODOT_EXE=Godot_v4.6-stable_win64_console.exe"
if not defined GODOT_EXE if exist "Godot_v4.6-stable_win64.exe" set "GODOT_EXE=Godot_v4.6-stable_win64.exe"
if not defined GODOT_EXE if exist "godot.exe" set "GODOT_EXE=godot.exe"

:found
if not defined GODOT_EXE (
  echo [ERRO] Godot nao encontrado.
  echo Defina GODOT_BIN com o caminho do Godot 4.6 console, ou coloque o exe na pasta do projeto.
  pause
  exit /b 1
)

echo Usando: %GODOT_EXE%
"%GODOT_EXE%" --headless --path "%~dp0." "res://server/HunterServer.tscn" %*
set "ERR=%ERRORLEVEL%"
echo.
echo Servidor encerrado com codigo %ERR%
pause
exit /b %ERR%
