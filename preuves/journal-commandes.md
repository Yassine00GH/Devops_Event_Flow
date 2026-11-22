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

### 1.1 Synchronisation de `main` et création de la branche dédiée `docs/readme`

```bash
git switch main
git pull --ff-only origin main
git switch -c docs/readme
```
Sortie (`$? = 0`) :
```text
Already on 'main'
Your branch is up to date with 'origin/main'.
From https://github.com/Yassine00GH/Devops_Event_Flow
 * branch            main       -> FETCH_HEAD
Already up to date.
Switched to a new branch 'docs/readme'
```

### 1.2 Création et commit de `README.md` et `docs/COMPTES_ET_PROFILS.md`

```bash
git add README.md docs/COMPTES_ET_PROFILS.md
git commit -m "docs: ajouter le README et la documentation des profils"
```
Sortie (`$? = 0`) :
```text
[docs/readme be9382d] docs: ajouter le README et la documentation des profils
 2 files changed, 62 insertions(+)
 create mode 100644 README.md
 create mode 100644 docs/COMPTES_ET_PROFILS.md
```

### 1.3 Publication de la branche et fusion PR #1 (`Create a merge commit` / `--no-ff`)

```bash
git add preuves/journal-commandes.md
git commit -m "docs: journaliser les commandes de l'étape 1"
git push -u origin docs/readme
```
Sortie (`$? = 0`) :
```text
[docs/readme fdcab64] docs: journaliser les commandes de l'étape 1
 1 file changed, 35 insertions(+), 1 deletion(-)
To https://github.com/Yassine00GH/Devops_Event_Flow.git
 * [new branch]      docs/readme -> docs/readme
branch 'docs/readme' set up to track 'origin/docs/readme'.
```

- **PR #1 fusionnée (`Create a merge commit` / `--no-ff`)** : `https://github.com/Yassine00GH/Devops_Event_Flow/pull/1` (merge commit `25c2dc8`).

```bash
git switch main
git pull --ff-only origin main
git branch -d docs/readme
git branch -a
git log --oneline --graph --decorate --all -n 10
```
Sortie (`$? = 0`) :
```text
Switched to branch 'main'
From https://github.com/Yassine00GH/Devops_Event_Flow
 * branch            main       -> FETCH_HEAD
   f53317d..25c2dc8  main       -> origin/main
Updating f53317d..25c2dc8
Fast-forward
 README.md                    | 49 ++++++++++++++++++++++++++++++++++++++++++++
 docs/COMPTES_ET_PROFILS.md   | 13 ++++++++++++
 preuves/journal-commandes.md | 36 +++++++++++++++++++++++++++++++-
 3 files changed, 97 insertions(+), 1 deletion(-)
Deleted branch docs/readme (was fdcab64).
* main
  remotes/origin/docs/readme
  remotes/origin/main
*   25c2dc8 (HEAD -> main, origin/main) Merge pull request #1 from Yassine00GH/docs/readme
|\  
| * fdcab64 (origin/docs/readme) docs: journaliser les commandes de l'étape 1
| * be9382d docs: ajouter le README et la documentation des profils
|/  
* f53317d docs: détailler les commandes et sorties de l'étape 0 dans le journal
* 02a1d10 docs: ajouter la documentation et le journal de preuves
* 4ba2d64 feat: importer le frontend Next.js
* 7c99fef feat: importer le backend Spring Boot sans secrets
* eb544b2 chore: configurer gitignore et fins de ligne LF
```

---

## Étape 2 — Script de contrôle (`chore/project-check` + PR #2)

### 2.1 Préparation de la branche et création de `scripts/check-project.sh`

```bash
git pull --ff-only origin main
git switch -c chore/project-check
mkdir -p scripts
chmod +x scripts/check-project.sh
file scripts/check-project.sh
```
Sortie (`$? = 0`) :
```text
From https://github.com/Yassine00GH/Devops_Event_Flow
 * branch            main       -> FETCH_HEAD
Already up to date.
Switched to a new branch 'chore/project-check'
scripts/check-project.sh: Bourne-Again shell script, Unicode text, UTF-8 text executable
```

### 2.2 Test 1 — Échec attendu avant commit (dépôt sale) et vérification `stderr`

```bash
./scripts/check-project.sh
echo "Code sortie (attendu 1) : $?"
./scripts/check-project.sh 1>/dev/null
echo "Code sortie stderr check : $?"
```
Sortie :
```text
[CHECK] EventFlow Full-Stack
[OK] présent : README.md
[OK] présent : .gitignore
[OK] présent : .gitattributes
[OK] présent : docs/COMPTES_ET_PROFILS.md
[OK] présent : backend/pom.xml
[OK] présent : backend/.env.example
[OK] présent : frontend/package.json
[OK] aucun .env ni consignes/ suivi par Git
[ERREUR] modifications locales non validées détectées (git status --porcelain)
[ECHEC] 1 erreur(s) détectée(s)
Code sortie (attendu 1) : 1

(avec 1>/dev/null, stderr seul :)
[ERREUR] modifications locales non validées détectées (git status --porcelain)
[ECHEC] 1 erreur(s) détectée(s)
Code sortie stderr check : 1
```

### 2.3 Commit du script et Test 2 — Succès attendu (`$? = 0`)

```bash
git add scripts/check-project.sh
git commit -m "chore: ajouter le script de contrôle du projet"
./scripts/check-project.sh
echo "Code sortie (attendu 0) : $?"
```
Sortie :
```text
[chore/project-check 27221b5] chore: ajouter le script de contrôle du projet
 1 file changed, 82 insertions(+)
 create mode 100755 scripts/check-project.sh
[CHECK] EventFlow Full-Stack
[OK] présent : README.md
[OK] présent : .gitignore
[OK] présent : .gitattributes
[OK] présent : docs/COMPTES_ET_PROFILS.md
[OK] présent : backend/pom.xml
[OK] présent : backend/.env.example
[OK] présent : frontend/package.json
[OK] aucun .env ni consignes/ suivi par Git
[OK] dépôt propre
[SUCCES] tous les contrôles sont validés
Code sortie (attendu 0) : 0
```

### 2.4 Test 3 — Échec attendu sur fichier manquant puis restauration (`$? = 1` puis `$? = 0`)

```bash
mv README.md /tmp/README.md.bak
./scripts/check-project.sh
echo "Code sortie (attendu 1) : $?"
mv /tmp/README.md.bak README.md
./scripts/check-project.sh
echo "Code sortie (attendu 0) : $?"
```
Sortie :
```text
[CHECK] EventFlow Full-Stack
[ERREUR] fichier absent : README.md
[OK] présent : .gitignore
[OK] présent : .gitattributes
[OK] présent : docs/COMPTES_ET_PROFILS.md
[OK] présent : backend/pom.xml
[OK] présent : backend/.env.example
[OK] présent : frontend/package.json
[OK] aucun .env ni consignes/ suivi par Git
[ERREUR] modifications locales non validées détectées (git status --porcelain)
[ECHEC] 2 erreur(s) détectée(s)
Code sortie (attendu 1) : 1

(après restauration de README.md :)
[CHECK] EventFlow Full-Stack
[OK] présent : README.md
[OK] présent : .gitignore
[OK] présent : .gitattributes
[OK] présent : docs/COMPTES_ET_PROFILS.md
[OK] présent : backend/pom.xml
[OK] présent : backend/.env.example
[OK] présent : frontend/package.json
[OK] aucun .env ni consignes/ suivi par Git
[OK] dépôt propre
[SUCCES] tous les contrôles sont validés
Code sortie (attendu 0) : 0
```

### 2.5 Publication et fusion PR #2 (`chore/project-check` → `main`)

```bash
git add preuves/journal-commandes.md
git commit -m "docs: consigner les sorties du script de contrôle"
git push -u origin chore/project-check
```
Sortie (`$? = 0`) :
```text
[chore/project-check d2816ca] docs: consigner les sorties du script de contrôle
 1 file changed, 172 insertions(+), 4 deletions(-)
To https://github.com/Yassine00GH/Devops_Event_Flow.git
 * [new branch]      chore/project-check -> chore/project-check
branch 'chore/project-check' set up to track 'origin/chore/project-check'.
```

- **PR #2 fusionnée (`Create a merge commit` / `--no-ff`)** : `https://github.com/Yassine00GH/Devops_Event_Flow/pull/2` (merge commit `6b0ab40`).

```bash
git switch main
git pull --ff-only origin main
git branch -d chore/project-check
./scripts/check-project.sh
git log --oneline --graph --decorate --all -n 12
```
Sortie (`$? = 0`) :
```text
Updating 25c2dc8..6b0ab40
Fast-forward
Deleted branch chore/project-check (was d2816ca).
[SUCCES] tous les contrôles sont validés
*   6b0ab40 (HEAD -> main, origin/main) Merge pull request #2 from Yassine00GH/chore/project-check
|\  
| * d2816ca (origin/chore/project-check) docs: consigner les sorties du script de contrôle
| * 27221b5 chore: ajouter le script de contrôle du projet
|/  
*   25c2dc8 Merge pull request #1 from Yassine00GH/docs/readme
```

---

## Étape 3 — Conteneurisation (`v1.0` -> `v1.1`, `feat/dockerfiles` + PR #3)

### 3.1 Branche dédiée et adaptations applicatives (Partie A)

```bash
git switch -c feat/dockerfiles
mkdir -p proxy
git add backend/src/main/java/com/iset/events/controller/HealthController.java \
  backend/src/main/java/com/iset/events/config/SecurityConfiguration.java \
  backend/src/test/java/com/iset/events/HealthControllerTest.java
git commit -m "feat(backend): ajouter et tester la route publique /health"

git add frontend/src/lib/api.ts frontend/src/app/layout.tsx frontend/src/styles/theme.css frontend/next.config.ts
git commit -m "feat(frontend): activer standalone, URLs relatives et polices locales"
```
Sortie (`$? = 0`) :
```text
Switched to a new branch 'feat/dockerfiles'
[feat/dockerfiles 4e7bab4] feat(backend): ajouter et tester la route publique /health
 3 files changed, 59 insertions(+)
[feat/dockerfiles eb638f9] feat(frontend): activer standalone, URLs relatives et polices locales
 4 files changed, 12 insertions(+), 18 deletions(-)
```

### 3.2 Construction et commit des Dockerfiles `v1.0` (root, sans `HEALTHCHECK`)

```bash
docker build -t eventflow-backend:1.0 ./backend
docker build -t eventflow-frontend:1.0 ./frontend
docker run --rm --entrypoint whoami eventflow-backend:1.0
git add backend/.dockerignore frontend/.dockerignore proxy/.dockerignore backend/Dockerfile frontend/Dockerfile
git commit -m "feat(docker): ajouter les Dockerfiles v1.0 et .dockerignore"
```
Sortie (`$? = 0`) :
```text
[+] Building 500.4s (15/15) FINISHED -> naming to docker.io/library/eventflow-backend:1.0
[+] Building 165.8s (14/14) FINISHED -> naming to docker.io/library/eventflow-frontend:1.0
root
[feat/dockerfiles 9ff7b92] feat(docker): ajouter les Dockerfiles v1.0 et .dockerignore
 5 files changed, 51 insertions(+)
```

### 3.3 Durcissement `v1.1` (non-root, `HEALTHCHECK`, proxy Nginx unprivileged) et inspection des couches

> Note : `HOSTNAME=0.0.0.0` dans `frontend/Dockerfile` empêche l'erreur classique d'écoute sur `127.0.0.1` qui bloquerait les connexions depuis le conteneur `proxy`.

```bash
docker build -t eventflow-backend:1.1 ./backend
docker build -t eventflow-frontend:1.1 ./frontend
docker build -t eventflow-proxy:1.1 ./proxy
docker image ls "eventflow-*"
```
Sortie (`$? = 0`) :
```text
[+] Building 3.9s (16/16) FINISHED  -> docker.io/library/eventflow-backend:1.1
[+] Building 22.0s (14/14) FINISHED -> docker.io/library/eventflow-frontend:1.1
[+] Building 20.4s (7/7) FINISHED   -> docker.io/library/eventflow-proxy:1.1

IMAGE                    ID             DISK USAGE   CONTENT SIZE
eventflow-backend:1.0    cba9fdf624c7        379MB          124MB
eventflow-backend:1.1    dea99d4eaaf4        379MB          124MB
eventflow-frontend:1.0   e7e170e0812b        340MB         86.6MB
eventflow-frontend:1.1   4159862016fc        340MB         86.7MB
eventflow-proxy:1.1      668dfef6f5e7       73.7MB           21MB
```

```bash
docker history eventflow-backend:1.1
docker history eventflow-frontend:1.1
```
Sortie (`$? = 0`) :
```text
# eventflow-backend:1.1 (extraits couches supérieures)
ENTRYPOINT ["java" "-jar" "/app/app.jar"]       0B
HEALTHCHECK {Test:[CMD-SHELL wget -qO- http:…   0B
EXPOSE [2525/tcp]                               0B
ENV SPRING_PROFILES_ACTIVE=prod                 0B
USER appuser                                    0B
COPY --chown=appuser:app /src/target/*.jar a…   60.1MB
RUN /bin/sh -c addgroup -S app && adduser -S…   41kB

# eventflow-frontend:1.1 (extraits couches supérieures)
CMD ["node" "server.js"]                        0B
HEALTHCHECK {Test:[CMD-SHELL wget -qO- http:…   0B
EXPOSE [3000/tcp]                               0B
USER node                                       0B
COPY --chown=node:node /app/public ./public …   897kB
COPY --chown=node:node /app/.next/static ./.…   1.38MB
COPY --chown=node:node /app/.next/standalone…   73.5MB
ENV HOSTNAME=0.0.0.0                            0B
```

```bash
docker run --rm --entrypoint whoami eventflow-backend:1.1
docker run --rm --entrypoint whoami eventflow-frontend:1.1
docker run --rm --entrypoint whoami eventflow-proxy:1.1
```
Sortie (`$? = 0`) :
```text
appuser
node
nginx
```

### 3.4 Vérification `HEALTHCHECK` en exécution réelle (proxy et frontend)

```bash
docker run -d --name ef-proxy-test --add-host backend:127.0.0.1 --add-host frontend:127.0.0.1 -p 8089:8080 eventflow-proxy:1.1
docker exec ef-proxy-test whoami
sleep 12
docker inspect --format '{{.State.Health.Status}}' ef-proxy-test
curl -fsS http://127.0.0.1:8089/nginx-health
docker rm -f ef-proxy-test
```
Sortie (`$? = 0`) :
```text
nginx
healthy
ok
ef-proxy-test
```
*(Remarque technique : lancé totalement isolé sans réseau Compose ni `--add-host`, Nginx signale logiquement `host not found in upstream "backend"` car les noms DNS internes `backend` et `frontend` sont fournis par Docker Compose à l'Étape 4 ; `--add-host` permet de valider `/nginx-health` et le `HEALTHCHECK` en autonomie.)*

```bash
docker run -d --name ef-front-test -p 3009:3000 eventflow-frontend:1.1
docker exec ef-front-test whoami
sleep 17
docker inspect --format '{{.State.Health.Status}}' ef-front-test
docker rm -f ef-front-test
```
Sortie (`$? = 0`) :
```text
node
healthy
ef-front-test
```

### 3.5 Incident volontaire conteneur (`ef-casse`, diagnostic `docker ps -a` et `docker logs`)

```bash
docker run -d --name ef-casse -p 2525:2525 eventflow-backend:1.1
sleep 5
docker ps
docker ps -a --filter name=ef-casse
docker logs ef-casse 2>&1 | head -n 40
docker rm -f ef-casse
```
Sortie (`$? = 0`) :
```text
=== docker ps ===
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
=== docker ps -a ===
CONTAINER ID   IMAGE                   COMMAND                  CREATED         STATUS                    PORTS     NAMES
b926358d7b24   eventflow-backend:1.1   "java -jar /app/app.…"   5 seconds ago   Exited (1) 1 second ago             ef-casse
=== docker logs ef-casse (extrait clé) ===
Starting EventsApplication v0.0.1-SNAPSHOT using Java 17.0.21.1 with PID 1 (/app/app.jar started by appuser in /app)
The following 1 profile is active: "prod"
...
ERROR 1 --- [eventflow-backend] [main] o.s.boot.SpringApplication : Application run failed
org.springframework.beans.factory.BeanCreationException: ... Factory method 'dataSource' threw exception with message: 'url' must start with "jdbc"
```
- **Diagnostic** : `backend` démarre en profil `prod` sous `appuser`, sans variable `DB_URL` définie (`application-prod.yml` n'a aucune valeur par défaut) → HikariDataSource échoue (`'url' must start with "jdbc"`) et le conteneur s'arrête avec `Exited (1)`.

### 3.6 Publication et PR #3 (`feat/dockerfiles` → `main`)
- Push : `git push -u origin feat/dockerfiles`
- PR #3 (`feat/dockerfiles` → `main`) : *(fusion `--no-ff` à compléter après validation sur GitHub)*

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
