#!/usr/bin/env bash
# Interroge /health jusqu'à ce que l'API + PostgreSQL répondent HTTP 200.
# Code de sortie : 0 = sain, 1 = non sain.
set -euo pipefail

URL="${1:-http://localhost:${STAGING_PORT:-8082}/health}"
TRIES="${TRIES:-24}"

for i in $(seq 1 "$TRIES"); do
  if curl -fsS "$URL"; then
    echo
    echo "[SANTE] staging sain : $URL"
    exit 0
  fi
  echo "[SANTE] tentative $i/$TRIES : service pas encore prêt (attente 5 s)" >&2
  sleep 5
done

echo "[SANTE] staging NON sain après $((TRIES * 5)) s : $URL" >&2
exit 1
