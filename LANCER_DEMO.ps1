# Script de lancement EventMate pour la présentation
# Double-cliquez sur ce fichier pour lancer l'application

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   EVENTMATE - Lancement de la Demo   " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Vérifier si Flutter est installé
Write-Host "Verification de Flutter..." -ForegroundColor Yellow
$flutterCheck = Get-Command flutter -ErrorAction SilentlyContinue

if (-not $flutterCheck) {
    Write-Host "ERREUR: Flutter n'est pas installe ou pas dans le PATH" -ForegroundColor Red
    Write-Host "Veuillez installer Flutter: https://flutter.dev" -ForegroundColor Red
    pause
    exit 1
}

Write-Host "Flutter detecte !" -ForegroundColor Green
Write-Host ""

# Se déplacer dans le dossier du projet
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath

Write-Host "Dossier du projet: $scriptPath" -ForegroundColor Cyan
Write-Host ""

# Vérifier les dépendances
Write-Host "Verification des dependances..." -ForegroundColor Yellow
if (-not (Test-Path "pubspec.lock")) {
    Write-Host "Installation des dependances..." -ForegroundColor Yellow
    flutter pub get
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "   Lancement de l'application...       " -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "COMPTES DE TEST:" -ForegroundColor Cyan
Write-Host "  Utilisateur: demo@eventmate.com / Demo123!" -ForegroundColor White
Write-Host "  Organisateur: organizer@eventmate.com / Orga123!" -ForegroundColor White
Write-Host "  Admin: admin@eventmate.com / Admin123!" -ForegroundColor White
Write-Host ""
Write-Host "L'application va s'ouvrir dans Chrome..." -ForegroundColor Yellow
Write-Host "Appuyez sur Ctrl+C pour arreter l'application" -ForegroundColor Yellow
Write-Host ""

# Lancer l'application
flutter run -d chrome

Write-Host ""
Write-Host "Application fermee." -ForegroundColor Yellow
pause
