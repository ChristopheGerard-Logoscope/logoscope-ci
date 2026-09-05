#!/usr/bin/env bash
# Test de faisabilité : dump des comptes rendus de séance (Débats) de l'Assemblée nationale
# Usage : ./test-assemblee-debats-dump.sh [numero_legislature] [mot_cle_test]
set -euo pipefail

LEGISLATURE="${1:-17}"
KEYWORD="${2:-congé climatique}"
URL="https://data.assemblee-nationale.fr/static/openData/repository/${LEGISLATURE}/vp/syceronbrut/syseron.xml.zip"
WORKDIR="$(mktemp -d)"
ZIP_PATH="${WORKDIR}/syseron.xml.zip"

echo "URL testée : $URL"
echo

echo "== Test 1 : en-têtes HTTP (sans télécharger) =="
curl -sI "$URL" | tee "${WORKDIR}/headers.txt"
echo

echo "== Test 2 : téléchargement réel =="
START=$(date +%s)
curl -sS -o "$ZIP_PATH" "$URL"
END=$(date +%s)
echo "Téléchargé en $((END - START))s"
ls -lh "$ZIP_PATH"
echo

echo "== Test 3 : décompression =="
EXTRACT_DIR="${WORKDIR}/extracted"
mkdir -p "$EXTRACT_DIR"
unzip -q "$ZIP_PATH" -d "$EXTRACT_DIR"
echo "Nombre de fichiers XML :"
find "$EXTRACT_DIR" -name "*.xml" | wc -l
echo "Taille totale décompressée :"
du -sh "$EXTRACT_DIR"
echo

echo "== Test 4 : recherche d'attestation (mot-clé test) =="
echo "Recherche de : \"$KEYWORD\""
grep -rli --include="*.xml" "$KEYWORD" "$EXTRACT_DIR" | head -20 || echo "Aucune occurrence trouvée."
echo

echo "== Nettoyage =="
rm -rf "$WORKDIR"
echo "OK — dossier temporaire supprimé."
