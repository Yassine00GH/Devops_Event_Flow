#!/usr/bin/env bash
# Met en service une version immuable publiée sur GHCR, puis vérifie /health.
# Usage : ./scripts/deploy-staging.sh v1.0.0
# Rollback : relancer exactement le même script avec l'ancien tag.
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

TAG="${1:?Usage : $0 vX.Y.Z}"
if [[ ! "$TAG" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "[DEPLOY] tag invalide : $TAG (format attendu vX.Y.Z)" >&2
  exit 2
fi

if [[ ! -f .env.staging ]]; then
  echo "[DEPLOY] .env.staging absent : cp .env.staging.example .env.staging" >&2
  exit 2
fi

OWNER="${GHCR_OWNER:-$(git remote get-url origin | sed -E 's#.*github\.com[:/]([^/]+)/.*#\1#')}"
OWNER="$(echo "$OWNER" | tr '[:upper:]' '[:lower:]')"
STAGING_PORT="${STAGING_PORT:-8082}"

printf 'GHCR_OWNER=%s\nIMAGE_TAG=%s\nSTAGING_PORT=%s\n' "$OWNER" "$TAG" "$STAGING_PORT" > .env.deploy

compose() {
  docker compose --env-file .env.deploy -f compose.staging.yaml "$@"
}

echo "[DEPLOY] $(date +%T) déploiement de ghcr.io/$OWNER/eventflow-*:$TAG (port $STAGING_PORT)"
compose pull backend frontend proxy
compose up -d

if bash scripts/wait-healthy.sh "http://localhost:${STAGING_PORT}/health"; then
  echo "[DEPLOY] $(date +%T) version $TAG en service et saine"
else
  echo "[DEPLOY] $(date +%T) version $TAG NON SAINE — journaux récents :" >&2
  compose logs --tail=50 backend proxy >&2
  exit 1
fi
