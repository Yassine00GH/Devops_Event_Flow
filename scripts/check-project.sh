#!/usr/bin/env bash
# Script de contrôle automatique du dépôt EventFlow (atelier 2).
# Retourne 0 si tous les contrôles passent, 1 sinon.
set -u

cd "$(git rev-parse --show-toplevel)" || {
  echo "[ERREUR] Ce script doit être exécuté dans un dépôt Git." >&2
  exit 1
}

errors=0
ok() { echo "[OK] $1"; }
ko() { echo "[ERREUR] $1" >&2; errors=$((errors + 1)); }

echo "[CHECK] EventFlow Full-Stack"

# 1. Fichiers obligatoires du socle (étendu à l'Étape 6 avec Compose/Staging/CI)
required=(
  README.md
  .gitignore
  .gitattributes
  docs/COMPTES_ET_PROFILS.md
  backend/pom.xml
  backend/.env.example
  frontend/package.json
)

for file in "${required[@]}"; do
  if [[ -f "$file" ]]; then
    ok "présent : $file"
  else
    ko "fichier absent : $file"
  fi
done

# 2. Vérifier qu'aucun fichier .env réel ni consignes/ n'est suivi par Git
forbidden=$(git ls-files | grep -E '(^|/)\.env($|\.)|^consignes/' | grep -v '\.example$' || true)
if [[ -n "$forbidden" ]]; then
  ko "fichier(s) interdit(s) suivi(s) par Git : $forbidden"
else
  ok "aucun .env ni consignes/ suivi par Git"
fi

# 3. Contrôler les Dockerfiles dès qu'ils existent (USER non-root + HEALTHCHECK + pas de :latest)
for df in backend/Dockerfile frontend/Dockerfile proxy/Dockerfile; do
  [[ -f "$df" ]] || continue
  grep -Eq '^USER ' "$df" \
    && ok "$df : utilisateur non-root défini" \
    || ko "$df : instruction USER manquante"
  grep -Eq '^HEALTHCHECK ' "$df" \
    && ok "$df : HEALTHCHECK défini" \
    || ko "$df : HEALTHCHECK manquant"
  grep -Eq '^FROM .*:latest' "$df" \
    && ko "$df : tag :latest interdit dans FROM" \
    || ok "$df : tag de base explicite"
done

# 4. Contrôler les fichiers Compose dès qu'ils existent (pas de :latest, port 5432 fermé)
for cf in compose.yaml compose.staging.yaml; do
  [[ -f "$cf" ]] || continue
  grep -Eq 'image:.*:latest' "$cf" \
    && ko "$cf : tag :latest interdit" \
    || ok "$cf : tags d'images explicites"
  grep -Eq '5432:5432' "$cf" \
    && ko "$cf : le port 5432 de PostgreSQL ne doit pas être publié" \
    || ok "$cf : port 5432 non publié"
done

# 5. Garde-fou dépôt propre (défi final de l'atelier 2)
if [[ -n "$(git status --porcelain)" ]]; then
  ko "modifications locales non validées détectées (git status --porcelain)"
else
  ok "dépôt propre"
fi

if [[ $errors -gt 0 ]]; then
  echo "[ECHEC] $errors erreur(s) détectée(s)" >&2
  exit 1
fi

echo "[SUCCES] tous les contrôles sont validés"
exit 0
