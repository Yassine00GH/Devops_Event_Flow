# Fiche Projet DevOps — EventFlow Full-Stack (L3 DSI · ISET)

**Étudiant :** Yassine Ghorbel · **Dépôt :** `https://github.com/Yassine00GH/Devops_Event_Flow`

## 1. Architecture de la pile
- **Proxy (`proxy`) :** `nginxinc/nginx-unprivileged:1.27-alpine` (non-root `nginx`, écoute interne `:8080` exposée `:8000` en dev / `:8082` en staging via `STAGING_PORT`), route `/` → `frontend:3000` et `/api/` + `/health` → `backend:2525`.
- **Frontend (`frontend`) :** Next.js 16 `standalone` (Node 22 Alpine, non-root `node`, polices locales sans `next/font/google`, URLs API relatives).
- **Backend (`backend`) :** Spring Boot 3.5.6 / Java 17 (JRE Alpine, non-root `appuser`, `GET /health` testant `SELECT 1`).
- **Base (`db`) :** PostgreSQL 17 Alpine, port `5432` **non publié** sur l'hôte, volume nommé persistant (`pgdata` / `pgdata-staging`), démarrage conditionné à `service_healthy`.
- **Chaîne CI/CD :** `check` (`scripts/check-project.sh`) → matrices `frontend-tests` (`Node 20/22`) & `backend-tests` (`Java 17/21` + PostgreSQL 17) avec `fail-fast: false` et artefacts `if: always()` → `docker-build` (push GHCR sur `v*`) → `deploy-staging` automatique sur tag `v*`. Branche `main` protégée (PR obligatoire, 6 checks requis, *Do not allow bypassing*).

## 2. Version mise en service
- **Tags immuables :** `v1.0.0`, `v1.1.0` (incident conservé), `v1.1.1` (correctif), puis `v1.2.0` (`ghcr.io/yassine00gh/eventflow-{backend,frontend,proxy}:v1.2.0`).
- **Digests `v1.0.0` (GHCR) :**
  - Backend : `ghcr.io/yassine00gh/eventflow-backend@sha256:d3359c14e37676c5f62775a07f84ec1a18a92b781399037f09bae556bc174833`
  - Frontend : `ghcr.io/yassine00gh/eventflow-frontend@sha256:37de2db0afa8b42d699f303fcb63984ec274036eebbfa4e027076d7562118d7f`
  - Proxy : `ghcr.io/yassine00gh/eventflow-proxy@sha256:644f836257d2988c3510d54ac359b26b91657af37952d9a1fb3c10832c5416e2`
- **Mise en service staging :** `./scripts/deploy-staging.sh v1.0.0` (aucune reconstruction, `/health` HTTP `200` → `{"status":"ok","database":"up"}` sur `http://localhost:8082/health`).

## 3. Déroulé du retour arrière
1. Mise en service `v1.1.0` (`server.port` modifié en `9999` dans `backend/src/main/resources/application.yml`, passé inaperçu aux tests `MockMvc` en CI sur la PR #9).
2. Détection à `19:59:50` : `deploy-staging.sh` et `wait-healthy.sh` échouent (`exit 1`, `backend` `unhealthy`), journaux `Tomcat started on port 9999 (http) with context path '/'`.
3. Rollback immédiat via `./scripts/deploy-staging.sh v1.0.0` (sans aucune reconstruction, uniquement changement de `IMAGE_TAG`) → rétabli en **`26` s** (`real 0m25.694s`, indisponibilité totale `146` s jusqu'à `20:02:16`).
4. Correction propre par `git revert --no-edit d2c55d2` (`f70d82b`), post-mortem `docs/incident-postmortem.md` (PR #10) et publication du nouveau tag `v1.1.1` (`./scripts/deploy-staging.sh v1.1.1` → `exit 0`).

## 4. Adresses CI à remettre
- **Pipeline réussi (PR verte #11 — matrice Node 20/22 + Java 17/21) :** `https://github.com/Yassine00GH/Devops_Event_Flow/actions/runs/45061679268`
  *(PR verte initiale #5 : `https://github.com/Yassine00GH/Devops_Event_Flow/actions/runs/45045828874`)*
- **Pipeline en échec (PR rouge #6 `demo/pipeline-rouge` ouverte et bloquée) :** `https://github.com/Yassine00GH/Devops_Event_Flow/actions/runs/45065038609`
  *(Run rouge initial : `https://github.com/Yassine00GH/Devops_Event_Flow/actions/runs/45047350051`)*
- **Bonus déploiement automatique staging sur tag `v1.2.0` :** `https://github.com/Yassine00GH/Devops_Event_Flow/actions/runs/45065030416`
