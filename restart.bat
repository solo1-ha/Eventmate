@echo off
echo Redemarrage de l'application...
taskkill /F /IM flutter.exe 2>nul
timeout /t 2 /nobreak >nul
cd /d "%~dp0"
flutter run
