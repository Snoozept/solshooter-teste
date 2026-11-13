@echo off
rem SolShoot online server for Windows. Double-click it, or let it start with Windows.
rem The first time it downloads Node.js and cloudflared into this folder (nothing is installed on the PC).
rem Every start it fetches the newest server, so it always matches the newest test build of the game; while it
rem runs, the server updates itself (server/update.js) and exits, and the loop below starts the new one.
chcp 65001 >nul
setlocal
title Servidor SolShoot
cd /d "%~dp0"
echo.
echo  SolShoot - servidor online
echo  --------------------------
echo  Deixa esta janela aberta. Para desligar o servidor, fecha-a.
echo  Atualiza-se sozinho quando sai uma versao nova do jogo.
echo.

rem the PC must not go to sleep while it serves games (only when plugged in)
powercfg /change standby-timeout-ac 0 >nul 2>&1
powercfg /change hibernate-timeout-ac 0 >nul 2>&1

rem start with Windows (a small file in the Startup folder that opens this one)
set "STARTUP=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
if not exist "%STARTUP%\SolShoot-Servidor.cmd" echo @start "Servidor SolShoot" /min "%~f0">"%STARTUP%\SolShoot-Servidor.cmd"

if exist "node\node.exe" goto haveNode
echo  A transferir o Node.js - so da primeira vez...
curl -L --fail -s -o node.zip https://nodejs.org/dist/v22.22.0/node-v22.22.0-win-x64.zip
if errorlevel 1 goto failed
tar -xf node.zip
if errorlevel 1 goto failed
ren node-v22.22.0-win-x64 node
del node.zip
:haveNode

if exist "cloudflared.exe" goto haveTunnel
echo  A transferir o cloudflared - so da primeira vez...
curl -L --fail -s -o cloudflared.exe https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.exe
if errorlevel 1 goto failed
:haveTunnel

echo  A procurar a versao mais recente do servidor...
curl -L --fail -s -o solshoot-server.new https://github.com/Snoozept/solshooter-teste/raw/main/solshoot-server.cjs
if not errorlevel 1 move /y solshoot-server.new solshoot-server.cjs >nul
if not exist "solshoot-server.cjs" goto failed

:run
"node\node.exe" solshoot-server.cjs 8787
echo.
echo  O servidor parou. Volta a arrancar daqui a 5 segundos...
timeout /t 5 /nobreak >nul
goto run

:failed
echo.
echo  ERRO: nao foi possivel transferir os ficheiros. Confirma a ligacao a internet
echo  e volta a abrir este ficheiro.
pause
