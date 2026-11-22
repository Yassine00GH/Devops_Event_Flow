# Journal des commandes et preuves — EventFlow DevOps

> Règle de sécurité : ne jamais coller de mot de passe, jeton, ni la sortie brute de `docker compose config` dans ce fichier.

---

## Étape 0 — Audit et dépôt initial (`main` avant verrouillage)

### 0.1 Vérification de l'environnement Ubuntu (WSL2) et Docker

```bash
which git curl rsync tree openssl docker
git --version
```
Sortie (`$? = 0`) :
```text
/usr/bin/git
/usr/bin/curl
/usr/bin/rsync
/usr/bin/tree
/usr/bin/openssl
/usr/bin/docker
git version 2.53.0
```

```bash
docker version
```
Sortie (`$? = 0`) :
```text
Client:
 Version:           29.1.3
 API version:       1.52
 Go version:        go1.24.13
 Git commit:        29.1.3-0ubuntu4.1
 OS/Arch:           linux/amd64
 Context:           default

Server: Docker Desktop 4.91.0 (239619)
 Engine:
  Version:          29.8.0
  API version:      1.56 (minimum version 1.40)
  OS/Arch:          linux/amd64
```

### 0.2 Configuration Git globale

```bash
git config --global user.name "Yassine Ghorbel"
git config --global user.email "yassineghorbel62@gmail.com"
git config --global init.defaultBranch main
git config --global credential.helper "/mnt/c/Program\ Files/Git/mingw64/bin/git-credential-manager.exe"
git config --global --list
```
Sortie (`$? = 0`) :
```text
user.name=Yassine Ghorbel
user.email=yassineghorbel62@gmail.com
init.defaultbranch=main
credential.helper=/mnt/c/Program\ Files/Git/mingw64/bin/git-credential-manager.exe
```

### 0.3 Vérification du dépôt distant GitHub et isolation du PDF de consigne

```bash
git ls-remote https://github.com/Yassine00GH/Devops_Event_Flow.git
```
Sortie (`$? = 0`) :
```text
(vide — dépôt distant créé et vide)
```

```bash
mkdir -p consignes preuves
mv guide_projet_devops_fullstack.pdf consignes/
ls -la consignes/
```
Sortie (`$? = 0`) :
```text
total 1968
drwxrwxrwx 2 yassinegh yassinegh    4096 Nov 22 12:38 .
drwxr-xr-x 4 yassinegh yassinegh    4096 Nov 22 12:38 ..
-rw-r--r-- 1 yassinegh yassinegh 2004276 Nov 22 12:21 guide_projet_devops_fullstack.pdf
```

### 0.4 Copie propre des sources (sans secrets ni dossiers parasites) et normalisation des droits

```bash
SRC="/mnt/c/Users/MSI/Desktop/integratin final"

rsync -a \
  --exclude target --exclude .idea --exclude .settings \
  --exclude .classpath --exclude .project --exclude .vscode \
  --exclude .env --exclude HELP.md \
  "$SRC/ProjetIntegration/backend/" backend/

rsync -a \
  --exclude node_modules --exclude .next --exclude .probe --exclude .env.local \
  "$SRC/projet_integration_front/" frontend/

rsync -a "$SRC/ProjetIntegration/docs/" docs/
```
Sortie (`$? = 0` pour les 3 commandes `rsync`, dossier source Windows intact).

```bash
find . -type f -exec chmod 644 {} +
find . -type d -exec chmod 755 {} +
chmod +x backend/mvnw
```
Sortie (`$? = 0`).

### 0.5 Nettoyage du placeholder JWT dans `backend/.env.example` et audit des fichiers `*env*` / cachés

```bash
sed -i 's|^JWT_SECRET=.*|JWT_SECRET=remplacer_par_une_cle_base64_32_octets|' backend/.env.example
cat backend/.env.example
```
Sortie (`$? = 0`) :
```text
# Database Configuration
DB_URL=jdbc:postgresql://localhost:5432/eventflow
DB_USERNAME=postgres
DB_PASSWORD=your_password_here

# JWT Configuration (optional dev override)
JWT_SECRET=remplacer_par_une_cle_base64_32_octets
```

```bash
find backend frontend docs -maxdepth 3 -name "*env*" -o -name ".*"
```
Sortie (`$? = 0`) :
```text
backend/.gitignore
backend/.mvn
backend/.env.example
backend/.gitattributes
frontend/.gitignore
frontend/.env.example
frontend/next-env.d.ts
```

### 0.6 Initialisation Git et vérification explicite de `.gitignore`

```bash
git init
git status
```
Sortie (`$? = 0`) :
```text
Initialized empty Git repository in /home/yassinegh/devops-l3/Devops_eventFlow/.git/
On branch main

No commits yet

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	.gitattributes
	.gitignore
	backend/
	docs/
	frontend/

nothing added to commit but untracked files present (use "git add" to track)
```

```bash
touch backend/.env frontend/.env.local .env.deploy .env.staging
git check-ignore -v consignes/ consignes/guide_projet_devops_fullstack.pdf backend/.env frontend/.env.local .env.deploy .env.staging
rm -f backend/.env frontend/.env.local .env.deploy .env.staging
```
Sortie (`$? = 0`) :
```text
.gitignore:2:consignes/	consignes/
.gitignore:2:consignes/	consignes/guide_projet_devops_fullstack.pdf
backend/.gitignore:5:*.env	backend/.env
frontend/.gitignore:28:.env*.local	frontend/.env.local
.gitignore:7:.env.*	.env.deploy
.gitignore:7:.env.*	.env.staging
```

### 0.7 Commits atomiques initiaux, vérification `git ls-files` et push vers `origin/main`

```bash
git add .gitignore .gitattributes
git commit -m "chore: configurer gitignore et fins de ligne LF"

git add backend/
git commit -m "feat: importer le backend Spring Boot sans secrets"

git add frontend/
git commit -m "feat: importer le frontend Next.js"

git add docs/ preuves/journal-commandes.md
git commit -m "docs: ajouter la documentation et le journal de preuves"
```
Sortie (`$? = 0`) :
```text
[main (root-commit) eb544b2] chore: configurer gitignore et fins de ligne LF
 2 files changed, 47 insertions(+)
[main 7c99fef] feat: importer le backend Spring Boot sans secrets
 103 files changed, 6300 insertions(+)
 create mode 100755 backend/mvnw
[main 4ba2d64] feat: importer le frontend Next.js
 68 files changed, 17338 insertions(+)
[main 02a1d10] docs: ajouter la documentation et le journal de preuves
 6 files changed, 942 insertions(+)
```

```bash
git ls-files | grep -E 'env|consignes'
```
Sortie (`$? = 0`) :
```text
backend/.env.example
frontend/.env.example
```

```bash
git status
```
Sortie (`$? = 0`) :
```text
On branch main
nothing to commit, working tree clean
```

```bash
git log --format="%h %an <%ae> %s"
```
Sortie (`$? = 0`) :
```text
02a1d10 Yassine Ghorbel <yassineghorbel62@gmail.com> docs: ajouter la documentation et le journal de preuves
4ba2d64 Yassine Ghorbel <yassineghorbel62@gmail.com> feat: importer le frontend Next.js
7c99fef Yassine Ghorbel <yassineghorbel62@gmail.com> feat: importer le backend Spring Boot sans secrets
eb544b2 Yassine Ghorbel <yassineghorbel62@gmail.com> chore: configurer gitignore et fins de ligne LF
```

```bash
git remote add origin https://github.com/Yassine00GH/Devops_Event_Flow.git
git push -u origin main
```
Sortie (`$? = 0`) :
```text
Enumerating objects: 259, done.
Total 259 (delta 43), reused 0 (delta 0), pack-reused 0 (from 0)
To https://github.com/Yassine00GH/Devops_Event_Flow.git
 * [new branch]      main -> main
branch 'main' set up to track 'origin/main'.
```

---

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
