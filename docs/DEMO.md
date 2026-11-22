# Plan de démonstration — Soutenance (10 minutes)

## Préparation avant d'entrer en salle
- Précharger les images GHCR : `docker pull` pour `v1.0.0`, `v1.1.0` et `v1.2.0` (`ghcr.io/yassine00gh/eventflow-{backend,frontend,proxy}`).
- Ouvrir 4 onglets GitHub :
  1. Dépôt `main` : `https://github.com/Yassine00GH/Devops_Event_Flow`
  2. PR verte #11 (matrice) : `https://github.com/Yassine00GH/Devops_Event_Flow/pull/11` (`runs/45061679268`)
  3. PR rouge #6 (`demo/pipeline-rouge`, ouverte & bloquée) : `https://github.com/Yassine00GH/Devops_Event_Flow/pull/6` (`runs/45065038609`)
  4. Run du tag `v1.2.0` (deploy auto staging) : `https://github.com/Yassine00GH/Devops_Event_Flow/actions/runs/45065030416`
- Vérifier qu'aucun conteneur concurrent ne bloque le port staging (`8082`, ou personnalisable via `STAGING_PORT`) : `docker ps`.

## Chronologie (10 minutes)
1. **0:00 – 1:00 — Architecture :** présenter `compose.yaml` (4 services, `5432` fermé, `service_healthy`, `pgdata`) et `backend/Dockerfile` (`v1.1` multi-stage, `appuser`, `HEALTHCHECK`).
2. **1:00 – 3:00 — Pipeline vert :** montrer la PR verte #11 fusionnée en `--no-ff`, le graphe des jobs (`check`, matrices Node `20/22` & Java `17/21`, `docker-build`) et les artefacts JUnit/Surefire.
3. **3:00 – 5:00 — Pipeline rouge :** ouvrir la PR #6 `demo/pipeline-rouge`, montrer que `docker-build` ne s'est pas lancé (`needs`), ouvrir le log de `Tests backend` sur la **1re erreur utile** (`JSON path "$.status" expected:<ok> but was:<up>`), montrer l'artefact `rapport-tests-backend-java17` / `java21` présent (`if: always()`) et le bouton **Merge bloqué** (Bonus protection de `main`).
4. **5:00 – 7:00 — Mise en service `v1.0.0` :** lancer `./scripts/deploy-staging.sh v1.0.0`, montrer `docker compose --env-file .env.deploy -f compose.staging.yaml ps` (images `ghcr.io/yassine00gh/eventflow-*:v1.0.0`, aucun `build:`) et `http://localhost:8082` dans le navigateur.
5. **7:00 – 9:00 — Panne `v1.1.0` & Rollback `v1.0.0` :** lancer `TRIES=6 ./scripts/deploy-staging.sh v1.1.0` (échec code `1` + log `Tomcat started on port 9999`), puis `./scripts/deploy-staging.sh v1.0.0` (retour sain en ~26 s sans reconstruction).
6. **9:00 – 10:00 — Bonus deploy sur tag :** montrer l'exécution verte du job `Déploiement automatique staging` sur le tag `v1.2.0` (`runs/45065030416`).
