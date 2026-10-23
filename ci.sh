#!/bin/bash
# Mini pipeline CI : synchronisation du dépôt, "tests", journalisation
# Codes de sortie : 0 succès | 1 usage | 2 échec git | 3 échec des tests
set -Eeuo pipefail

LOG_FILE="${LOG_FILE:-ci.log}"
WORKDIR="${WORKDIR:-ci-workspace}"
DEPOT=""

# Journalisation horodatée : affichage + ajout dans le fichier de log
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$1] $2" | tee -a "$LOG_FILE"
}

synchroniser() {
    local nom
    nom=$(basename "$REPO_URL" .git)
    DEPOT="$WORKDIR/$nom"
    mkdir -p "$WORKDIR"

    if [ -d "$DEPOT/.git" ]; then
        log INFO "Mise à jour du dépôt $nom (git pull)"
        git -C "$DEPOT" pull --ff-only 2>&1 | tee -a "$LOG_FILE"
    else
        log INFO "Clonage de $REPO_URL (git clone)"
        git clone "$REPO_URL" "$DEPOT" 2>&1 | tee -a "$LOG_FILE"
    fi
}

lancer_tests() {
    local echecs=0 script

    log INFO "Test 1 : vérification de la syntaxe des scripts .sh"
    for script in "$DEPOT"/*.sh; do
        [ -e "$script" ] || continue
        if bash -n "$script"; then
            log INFO "  OK : $(basename "$script")"
        else
            log ERREUR "  Syntaxe invalide : $(basename "$script")" >&2
            echecs=$((echecs + 1))
        fi
    done

    log INFO "Test 2 : présence du fichier .gitignore"
    if [ ! -f "$DEPOT/.gitignore" ]; then
        log ERREUR "  .gitignore manquant" >&2
        echecs=$((echecs + 1))
    fi

    [ "$echecs" -eq 0 ]
}

REPO_URL="${1:-}"
if [ -z "$REPO_URL" ]; then
    log ERREUR "Usage : $0 <url-ou-chemin-du-depot>" >&2
    exit 1
fi

log INFO "=== Début du pipeline ==="

if ! synchroniser; then
    log ERREUR "Échec de la synchronisation git" >&2
    exit 2
fi

if ! lancer_tests; then
    log ERREUR "Pipeline en échec : tests non passés" >&2
    exit 3
fi

log INFO "=== Pipeline réussi ==="
exit 0
