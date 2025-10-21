# Script PowerShell pour créer les index Firestore
# Exécutez ce script avec : .\create_firestore_indexes.ps1

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Création des index Firestore" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Vérifier si Firebase CLI est installé
Write-Host "Vérification de Firebase CLI..." -ForegroundColor Yellow
$firebaseInstalled = Get-Command firebase -ErrorAction SilentlyContinue

if (-not $firebaseInstalled) {
    Write-Host "❌ Firebase CLI n'est pas installé." -ForegroundColor Red
    Write-Host ""
    Write-Host "Installation de Firebase CLI..." -ForegroundColor Yellow
    Write-Host "Exécutez cette commande dans un nouveau terminal :" -ForegroundColor Cyan
    Write-Host "  npm install -g firebase-tools" -ForegroundColor White
    Write-Host ""
    Write-Host "Puis relancez ce script." -ForegroundColor Yellow
    Write-Host ""
    
    # Proposer d'ouvrir le lien d'erreur
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  SOLUTION ALTERNATIVE (PLUS RAPIDE)" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. Regardez l'erreur dans votre console Flutter" -ForegroundColor Yellow
    Write-Host "2. Copiez le lien qui commence par :" -ForegroundColor Yellow
    Write-Host "   https://console.firebase.google.com/v1/r/project/..." -ForegroundColor White
    Write-Host "3. Collez-le dans votre navigateur" -ForegroundColor Yellow
    Write-Host "4. Cliquez sur 'Create Index'" -ForegroundColor Yellow
    Write-Host "5. Attendez 2-5 minutes" -ForegroundColor Yellow
    Write-Host ""
    
    pause
    exit
}

Write-Host "✅ Firebase CLI est installé" -ForegroundColor Green
Write-Host ""

# Connexion à Firebase
Write-Host "Connexion à Firebase..." -ForegroundColor Yellow
firebase login

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Erreur de connexion à Firebase" -ForegroundColor Red
    pause
    exit
}

Write-Host "✅ Connecté à Firebase" -ForegroundColor Green
Write-Host ""

# Déploiement des index
Write-Host "Déploiement des index Firestore..." -ForegroundColor Yellow
Write-Host "Cela peut prendre quelques minutes..." -ForegroundColor Cyan
Write-Host ""

firebase deploy --only firestore:indexes --project eventmate-61924

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  ✅ Index créés avec succès !" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Les index sont en cours de création dans Firestore." -ForegroundColor Yellow
    Write-Host "Cela prend généralement 2-5 minutes." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Vous pouvez vérifier l'état ici :" -ForegroundColor Cyan
    Write-Host "https://console.firebase.google.com/project/eventmate-61924/firestore/indexes" -ForegroundColor White
    Write-Host ""
    Write-Host "Une fois les index créés (statut 'Enabled'), relancez votre application Flutter." -ForegroundColor Yellow
} else {
    Write-Host ""
    Write-Host "❌ Erreur lors du déploiement" -ForegroundColor Red
    Write-Host ""
    Write-Host "Essayez la solution alternative :" -ForegroundColor Yellow
    Write-Host "1. Copiez le lien dans l'erreur Flutter" -ForegroundColor Yellow
    Write-Host "2. Collez-le dans votre navigateur" -ForegroundColor Yellow
    Write-Host "3. Cliquez sur 'Create Index'" -ForegroundColor Yellow
}

Write-Host ""
pause
