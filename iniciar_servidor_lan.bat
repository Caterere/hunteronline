@echo off
title Hunter MMORPG Dedicated Server
echo ============================================================
echo         INICIANDO HUNTER MMORPG DEDICATED SERVER
echo ============================================================
echo [LAN / Radmin VPN Server]
echo Porta Padrao: 7777 (ENet UDP)
echo Descoberta LAN: 7778 (UDP Broadcast)
echo.
"C:\Users\dadol\OneDrive\Documentos\Godot_v4.6-stable_win64.exe\Godot_v4.6-stable_win64_console.exe" --headless --path . "res://server/HunterServer.tscn" %*
pause
