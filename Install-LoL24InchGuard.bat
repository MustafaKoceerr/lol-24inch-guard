@echo off
chcp 65001 >nul
set "SCRIPT_DIR=%~dp0"
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

echo [LoL 24 Inch Guard] Kurulum baslatiliyor...
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
  "$dir = '%SCRIPT_DIR%'; " ^
  "$vbs = Join-Path $dir 'Start-LoL24InchGuard.vbs'; " ^
  "$candidates = @('C:\Riot Games\League of Legends\Config\game.cfg','D:\Riot Games\League of Legends\Config\game.cfg','E:\Riot Games\League of Legends\Config\game.cfg'); " ^
  "foreach ($cfg in $candidates) { if (Test-Path $cfg) { if (-not (Test-Path \"$cfg.bak\")) { Copy-Item $cfg \"$cfg.bak\" -Force }; $c = [System.IO.File]::ReadAllText($cfg); $c = $c -replace '(?m)^WindowMode=\d+\r?$', 'WindowMode=2' -replace '(?m)^Height=\d+\r?$', 'Height=1280' -replace '(?m)^Width=\d+\r?$', 'Width=2276'; [System.IO.File]::WriteAllText($cfg, $c); Write-Host \"Guncellendi: $cfg\" } }; " ^
  "$action = New-ScheduledTaskAction -Execute 'wscript.exe' -Argument ('\"' + $vbs + '\"'); " ^
  "$trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME; " ^
  "$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit ([TimeSpan]::Zero); " ^
  "Register-ScheduledTask -TaskName 'LoL24InchGuard' -Action $action -Trigger $trigger -Settings $settings -Force | Out-Null; " ^
  "Start-ScheduledTask -TaskName 'LoL24InchGuard'"

echo.
echo Kurulum tamamlandi! LoL24InchGuard arka planda aktif ve bilgisayar acilisinda otomatik baslayacak.
pause
