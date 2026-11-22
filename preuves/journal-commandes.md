# Journal des commandes et preuves — EventFlow DevOps

> Règle de sécurité : ne jamais coller de mot de passe, jeton, ni la sortie brute de `docker compose config` dans ce fichier.

## Étape 0 — Audit et dépôt initial
- Outils vérifiés sous Ubuntu (WSL2) :
  - `git --version` → `git version 2.53.0` (code `0`)
  - `docker version` → Client `29.1.3` / Server `Docker Desktop 4.91.0` Engine `29.8.0` (code `0`)
  - `which git curl rsync tree openssl docker` → tous présents dans `/usr/bin/` (code `0`)
- Configuration Git :
  - `user.name=Yassine Ghorbel`
  - `user.email=yassineghorbel62@gmail.com`
  - `init.defaultbranch=main`
  - `credential.helper=/mnt/c/Program\ Files/Git/mingw64/bin/git-credential-manager.exe`
- Isolation du guide PDF : déplacé dans `consignes/guide_projet_devops_fullstack.pdf` (dossier ignoré par `.gitignore`).
- Copie propre depuis `"/mnt/c/Users/MSI/Desktop/integratin final"` (sans modifier la source) via `rsync` en excluant `target`, `.idea`, `.settings`, `.classpath`, `.project`, `.vscode`, `.env`, `HELP.md`, `node_modules`, `.next`, `.probe`, `.env.local`.
- Normalisation des permissions (`644` fichiers, `755` dossiers, `+x` sur `backend/mvnw`).
- Nettoyage de `backend/.env.example` : `JWT_SECRET=remplacer_par_une_cle_base64_32_octets`.
- Test explicite de `.gitignore` (`git check-ignore -v`) :
  ```text
  .gitignore:2:consignes/	consignes/
  .gitignore:2:consignes/	consignes/guide_projet_devops_fullstack.pdf
  backend/.gitignore:5:*.env	backend/.env
  frontend/.gitignore:28:.env*.local	frontend/.env.local
  .gitignore:7:.env.*	.env.deploy
  .gitignore:7:.env.*	.env.staging
  ```
- `git ls-files | grep -E 'env|consignes'` : uniquement `backend/.env.example` et `frontend/.env.example` (aucun `.env` réel ni `consignes/`).
- Commits atomiques initiaux sur `main` :
  - `chore: configurer gitignore et fins de ligne LF`
  - `feat: importer le backend Spring Boot sans secrets`
  - `feat: importer le frontend Next.js`
  - `docs: ajouter la documentation et le journal de preuves`
- Remote `origin` configuré sur `https://github.com/Yassine00GH/Devops_Event_Flow.git` et poussé sur `origin/main`.

## Étape 1 — Documentation & premières PR (`--no-ff`)
- PR #1 (`docs/readme`) :

## Étape 2 — Script de contrôle
- Succès (`$? = 0`) / Échecs (`$? = 1`) :

## Étape 3 — Conteneurisation (`v1.0` -> `v1.1`)
- Tailles `docker image ls` / `whoami` / `HEALTHCHECK` :
- Diagnostic d'incident conteneur :

## Étape 4 — Docker Compose
- `docker compose ps` (`healthy`), `getent hosts db`, port 5432 fermé :
- Persistance `essai` (`down` / `up -d`) :
- Incident `DB_URL=localhost` :

## Étape 5 — Pipeline CI
- URL exécution rouge + 1re erreur utile :
- URL exécution verte :

## Étape 6 — Release `v1.0.0` et staging
- Digest images GHCR + sortie `wait-healthy.sh` :

## Étape 7 — Incident `v1.1.0` et rollback `v1.0.0`
- Sortie `wait-healthy.sh` en échec (`v1.1.0`) + logs :
- Sortie `wait-healthy.sh` après rollback (`v1.0.0`) + durée :

## Étape 8 — Bonus
- Preuve protection `main` / matrice / tag `v1.2.0` :
