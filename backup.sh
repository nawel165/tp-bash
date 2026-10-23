#!/bin/bash
set -Eeuo pipefail

DOSSIER="${1:-data}"        # dossier à sauvegarder
DEST="${2:-backups}"        # dossier de destination

if [ ! -d "$DOSSIER" ]; then
    echo "Erreur : le dossier '$DOSSIER' n'existe pas." >&2
    exit 1
fi

mkdir -p "$DEST"

HORODATAGE=$(date +%Y-%m-%d_%H-%M-%S)
ARCHIVE="$DEST/$(basename "$DOSSIER")_${HORODATAGE}.tar.gz"

tar -czf "$ARCHIVE" "$DOSSIER"
echo "Archive créée : $ARCHIVE"

# Suppression des sauvegardes de plus de 7 jours
for fichier in $(find "$DEST" -name "*.tar.gz" -mtime +7); do
    echo "Suppression de l'ancienne sauvegarde : $fichier"
    rm "$fichier"
done

echo "Sauvegarde terminée."
