@echo off
chcp 65001 >nul
echo [LoL 24 Inch Guard] Servis durduruluyor ve orijinal 2K (2560x1440) ayarlar geri yukleniyor...
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
  "Stop-ScheduledTask -TaskName 'LoL24InchGuard' -ErrorAction SilentlyContinue; " ^
  "Unregister-ScheduledTask -TaskName 'LoL24InchGuard' -Confirm:$false -ErrorAction SilentlyContinue; " ^
  "Get-Process -Name wscript -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue; " ^
  "Get-CimInstance Win32_Process -Filter \"Name='powershell.exe'\" | Where-Object { $_.CommandLine -like '*LoL24InchGuard.ps1*' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }; " ^
  "$candidates = @('C:\Riot Games\League of Legends\Config\game.cfg','D:\Riot Games\League of Legends\Config\game.cfg','E:\Riot Games\League of Legends\Config\game.cfg'); " ^
  "foreach ($cfg in $candidates) { if (Test-Path \"$cfg.bak\") { Copy-Item \"$cfg.bak\" $cfg -Force; Write-Host \"Yedekten geri yuklendi: $cfg\" } }"

echo.
echo Tamamlandi! Servis kaldirildi ve LoL orijinal ekran ayarlarina dondu.
pause
