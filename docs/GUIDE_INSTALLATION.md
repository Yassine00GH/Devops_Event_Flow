# Guide d'Installation et de Démarrage Backend

## 1. Prérequis Système
- **Java 17 (LTS)** (ex. Oracle JDK 17 ou Eclipse Temurin 17 configuré dans `JAVA_HOME`)
- **PostgreSQL 18** installé localement sur le port `5432` avec pgAdmin 4
- **Git**
- **Maven** (intégré via `backend/mvnw.cmd` sous Windows ou `backend/mvnw` sous Linux/macOS)
- **Eclipse IDE for Enterprise Java Developers 2022-06** (optionnel pour l'IDE, voir [docs/ECLIPSE_SETUP.md](ECLIPSE_SETUP.md))

---

## 2. Base de Données PostgreSQL

L'application utilise une instance PostgreSQL locale. Aucun conteneur Docker n'est requis.

1. **Vérifier le service PostgreSQL :**
   Assurez-vous que le service PostgreSQL est démarré et écoute sur le port `5432`.
   ```powershell
   Test-NetConnection -ComputerName localhost -Port 5432
   ```

2. **Créer les bases de données dans pgAdmin 4 ou via SQL :**
   Deux bases de données distinctes sont nécessaires :
   ```sql
   CREATE DATABASE eventflow;
   CREATE DATABASE eventflow_test;
   ```
   - `eventflow` : base de développement et d'exécution normale.
   - `eventflow_test` : base dédiée aux tests unitaires et d'intégration (les tests n'altèrent jamais la base de dev).

3. Laissez les bases vides : **Flyway** crée l'intégralité du schéma et insère les données de démarrage au premier lancement.

---

## 3. Configuration des Identifiants (`backend/.env`)

Le backend charge automatiquement les variables de connexion depuis le fichier `backend/.env` placé au niveau du `pom.xml`.

1. Créez le fichier `backend/.env` (ignoré par Git) :
   ```properties
   DB_USERNAME=postgres
   DB_PASSWORD=votre_mot_de_passe
   ```
   *(Important : aucun espace autour du signe `=`, pas de guillemets).*

2. Un fichier modèle `backend/.env.example` est disponible à titre de référence.

### Tableau récapitulatif des paramètres :

| Variable | Description | Valeur par défaut |
|---|---|---|
| `PORT` | Port d'écoute HTTP du serveur | `2525` |
| `DB_URL` | URL JDBC PostgreSQL | `jdbc:postgresql://localhost:5432/eventflow` (dev) / `eventflow_test` (test) |
| `DB_USERNAME` | Nom d'utilisateur de la base de données | `postgres` |
| `DB_PASSWORD` | Mot de passe de la base de données | Lu depuis `backend/.env` |
| `JWT_SECRET` | Clé secrète de signature HMAC JWT | *(Clé dev par défaut, personnalisable)* |
| `CORS_ALLOWED_ORIGINS` | Origines autorisées pour Next.js | `http://localhost:3000,http://127.0.0.1:3000` |

---

## 4. Démarrage du Backend

### A. Depuis le Terminal Windows (PowerShell avec JDK 17) :
```powershell
# Définir JAVA_HOME vers JDK 17 si nécessaire pour la session
$env:JAVA_HOME = "C:\Program Files\Java\jdk-17"
$env:Path = "$env:JAVA_HOME\bin;" + $env:Path

# Se positionner dans le dossier backend
cd backend

# Lancer l'application
.\mvnw.cmd spring-boot:run
```

### B. Depuis Eclipse IDE 2022-06 :
Consultez le guide détaillé [docs/ECLIPSE_SETUP.md](ECLIPSE_SETUP.md) pour importer le projet Maven et lancer `EventsApplication.java` en tant que *Java Application*.

Au lancement :
- Flyway applique automatiquement les migrations (`V1__init_schema.sql`, `V2__seed_admin.sql`, `V3__sample_data.sql`).
- Le serveur écoute sur **`http://localhost:2525`**.

---

## 5. Comptes de Démonstration Pré-configurés

La base de données est automatiquement alimentée au premier démarrage avec :

| Profil | Email | Mot de passe | Statut |
|---|---|---|---|
| **Administrateur** | `admin@example.com` | `admin12345678` | `ACTIF` |
| **Enseignant** | *(Créé via `/api/auth/register` puis validé par l'admin)* | Choisi à l'inscription | `ACTIF` (après validation) |
| **Étudiant** | *(Créé via `/api/auth/register` puis validé par l'admin)* | Choisi à l'inscription | `ACTIF` (après validation) |

---

## 6. Lancement des Tests Automatisés

### Exécuter la suite complète JUnit 5 avec Maven :
```powershell
cd backend
.\mvnw.cmd clean verify
```
Les 11 tests d'intégration s'exécutent sur la base isolée `eventflow_test` et valident l'ensemble des cas limites et scénarios métier.

### Exécuter le script de validation des APIs réelles :
Lorsque le serveur backend est en marche sur `http://localhost:2525` :
```powershell
powershell -ExecutionPolicy Bypass -File "backend\test_all_apis.ps1"
```
Ce script vérifie de bout en bout les 13 catégories d'endpoints REST (Auth, validation admin, mise à jour profil, événements, programme, catalogue public, réservations, paiement simulé, tickets, notifications, tableaux de bord, audit et annulation).
