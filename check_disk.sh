#!/bin/bash
# Alerte si l'utilisation disque de / dépasse un seuil (80% par défaut)

SEUIL=${1:-80}

# Vérifie que le seuil est un nombre entier
if ! [[ "$SEUIL" =~ ^[0-9]+$ ]]; then
    echo "Erreur : le seuil doit être un nombre entier." >&2
    exit 1
fi

UTILISATION=$(df -P / | awk 'NR==2 {print $5}' | tr -d '%')

if [ "$UTILISATION" -ge "$SEUIL" ]; then
    echo "ALERTE : disque utilisé à ${UTILISATION}% (seuil : ${SEUIL}%)"
    exit 1
fi

echo "OK : disque utilisé à ${UTILISATION}% (seuil : ${SEUIL}%)"
exit 0
