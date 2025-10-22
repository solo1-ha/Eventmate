# Script pour supprimer tous les événements de Firebase Firestore
# ATTENTION : Cette action est irréversible !

Write-Host "========================================" -ForegroundColor Yellow
Write-Host "  SUPPRESSION DE TOUS LES ÉVÉNEMENTS" -ForegroundColor Red
Write-Host "========================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "Ce script va supprimer TOUS les événements de votre base de données Firebase." -ForegroundColor Red
Write-Host "Cette action est IRRÉVERSIBLE !" -ForegroundColor Red
Write-Host ""

$confirmation = Read-Host "Êtes-vous sûr de vouloir continuer ? (tapez 'OUI' en majuscules pour confirmer)"

if ($confirmation -ne "OUI") {
    Write-Host ""
    Write-Host "Opération annulée." -ForegroundColor Green
    exit
}

Write-Host ""
Write-Host "Suppression en cours..." -ForegroundColor Yellow
Write-Host ""

# Commande Firebase CLI pour supprimer tous les documents de la collection 'events'
# Assurez-vous d'avoir Firebase CLI installé : npm install -g firebase-tools
# Et d'être connecté : firebase login

try {
    # Supprimer tous les événements
    firebase firestore:delete events --recursive --force
    
    Write-Host ""
    Write-Host "✓ Tous les événements ont été supprimés avec succès !" -ForegroundColor Green
    
    # Optionnel : Supprimer aussi toutes les inscriptions
    $deleteRegistrations = Read-Host "Voulez-vous aussi supprimer toutes les inscriptions ? (O/N)"
    
    if ($deleteRegistrations -eq "O" -or $deleteRegistrations -eq "o") {
        firebase firestore:delete registrations --recursive --force
        Write-Host "✓ Toutes les inscriptions ont été supprimées avec succès !" -ForegroundColor Green
    }
    
} catch {
    Write-Host ""
    Write-Host "✗ Erreur lors de la suppression : $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Assurez-vous que :" -ForegroundColor Yellow
    Write-Host "1. Firebase CLI est installé (npm install -g firebase-tools)" -ForegroundColor Yellow
    Write-Host "2. Vous êtes connecté (firebase login)" -ForegroundColor Yellow
    Write-Host "3. Vous êtes dans le bon projet Firebase" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Script terminé." -ForegroundColor Cyan
Write-Host ""
