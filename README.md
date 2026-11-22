# EventFlow — Plateforme d'événements étudiants (Chaîne DevOps L3 DSI)

Application web **EventFlow** composée de 4 services conteneurisés :
- **proxy** : Reverse proxy Nginx non-root (`nginxinc/nginx-unprivileged:1.27`, port `8080`) qui sert `/` (frontend) et `/api/` + `/health` (backend) sous une même origine.
- **frontend** : Next.js 16 (React 19, mode `standalone`, port interne `3000`).
- **backend** : API REST Spring Boot 3.5.6 (Java 17, Flyway, JWT, port interne `2525`).
- **db** : PostgreSQL 17 (`postgres:17-alpine`, port `5432` **non publié**, volume persistant `pgdata`).

## Prérequis

- Linux ou Windows + WSL2 (Ubuntu)
- Docker Engine / Docker Desktop avec Docker Compose v2 (`docker compose version`)
- Ports `8000` (dev) et `8080` (staging) disponibles sur l'hôte

## Démarrer en une commande (développement)

```bash
cp .env.example .env && docker compose up -d --build
```

*(Avant le lancement en production ou staging, remplacez les mots de passe fictifs dans `.env`, générez `JWT_SECRET` via `openssl rand -base64 32` et définissez un `ADMIN_PASSWORD` de 12 à 72 caractères.)*

Vérification :
- Application complète via le proxy : `http://localhost:8000`
- Contrôle de santé API : `curl -fsS http://localhost:8000/health` → `{"database":"up","status":"ok"}`
- Administration BD (profil debug optionnel) : `docker compose --profile debug up -d` → `http://localhost:8081`

## Variables d'environnement principales

| Variable | Rôle | Exemple / règle |
|---|---|---|
| `POSTGRES_PASSWORD` | Mot de passe de la base `eventflow` | Défini dans `.env` / `.env.staging` (jamais versionné) |
| `JWT_SECRET` | Clé de signature JWT HS256 | Base64 d'au moins 32 octets (`openssl rand -base64 32`) |
| `ADMIN_EMAIL` / `ADMIN_PASSWORD` | Compte administrateur initial | Mot de passe de **12 à 72 caractères** |
| `CORS_ALLOWED_ORIGINS` | Origines autorisées | `http://localhost:8000` (dev) / `http://localhost:8080` (staging) |
| `PAYMENT_API_KEY` / `PAYMENT_SECRET_KEY` | Clés de passerelle paiement | Valeurs fictives hors production |

## Tests automatisés

- **Frontend (Vitest + ESLint + TypeScript) :** `cd frontend && npm ci && npm run lint && npx tsc --noEmit && npm test`
- **Backend (Spring Boot + PostgreSQL) :** exécutés automatiquement en CI contre `postgres:17-alpine` via `./mvnw -B verify`
- **Contrôle du dépôt :** `./scripts/check-project.sh`

## Livraison, staging et rollback

```bash
./scripts/deploy-staging.sh v1.0.0   # met en service l'image publiée sur http://localhost:8080
./scripts/deploy-staging.sh v0.9.0   # retour arrière sans reconstruction
```
