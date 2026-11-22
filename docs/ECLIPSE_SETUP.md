# Guide de Configuration Eclipse IDE (2022-06) — Backend EventFlow

Ce guide décrit pas à pas la configuration et l'exécution du backend EventFlow dans **Eclipse IDE for Enterprise Java Developers 2022-06** avec **JDK 17** et **PostgreSQL 18 local**, sans aucun plugin supplémentaire (aucun plugin Lombok, aucun STS).

---

## 1. Vérification du Service PostgreSQL 18

Avant de démarrer le projet, assurez-vous que le service local PostgreSQL est actif :
1. Ouvrez le gestionnaire des services Windows (`services.msc`) ou un terminal PowerShell.
2. Vérifiez que le service `postgresql-x64-18` (ou votre service PostgreSQL local) a le statut **En cours d'exécution** (Running).
3. Vérifiez que PostgreSQL écoute bien sur le port par défaut **5432** :
   ```powershell
   Test-NetConnection -ComputerName localhost -Port 5432
   ```
   Le résultat doit indiquer `TcpTestSucceeded : True`.

---

## 2. Création des Bases de Données dans pgAdmin 4

Deux bases de données distinctes sont requises :
- `eventflow` : base principale utilisée lors du développement et de l'exécution normale de l'application.
- `eventflow_test` : base dédiée exclusivement aux tests automatisés (JUnit / Maven).

### Procédure dans pgAdmin 4 :
1. Lancez **pgAdmin 4** et connectez-vous à votre serveur local PostgreSQL (port 5432).
2. Faites un clic droit sur **Databases** > **Create** > **Database...**.
3. Dans le champ **Database**, saisissez `eventflow` puis cliquez sur **Save**.
4. Répétez l'opération : clic droit sur **Databases** > **Create** > **Database...**, saisissez `eventflow_test` puis cliquez sur **Save**.
5. Les deux bases doivent être vides : les tables et données initiales sont générées automatiquement par **Flyway** au premier démarrage.

---

## 3. Configuration des Identifiants (`backend/.env`)

Le backend charge automatiquement les identifiants de base de données depuis le fichier `backend/.env` (grâce à `spring.config.import=optional:file:.env[.properties],optional:file:backend/.env[.properties]`).

1. À la racine du dossier `backend/` (au même niveau que `pom.xml`), créez le fichier `.env` s'il n'existe pas déjà.
2. Définissez vos identifiants PostgreSQL personnels :
   ```properties
   DB_USERNAME=postgres
   DB_PASSWORD=votre_mot_de_passe
   ```
   *(Important : aucun espace autour du signe `=`, pas de guillemets sauf si votre mot de passe contient des caractères spéciaux).*
3. Le fichier `backend/.env` est exclu du contrôle de version Git via `.gitignore`. Un gabarit d'exemple est fourni dans `backend/.env.example`.

---

## 4. Configuration du JDK 17 dans Eclipse 2022-06

### A. Ajouter le JDK 17 dans les JREs installés :
1. Dans Eclipse, ouvrez le menu **Window** > **Preferences**.
2. Déroulez **Java** > **Installed JREs**.
3. Si le JDK 17 n'apparaît pas dans la liste :
   - Cliquez sur **Add...**.
   - Sélectionnez **Standard VM** puis cliquez sur **Next >**.
   - Cliquez sur **Directory...** et sélectionnez le dossier d'installation du JDK 17 (ex. : `C:\Program Files\Java\jdk-17`).
   - Cliquez sur **Finish**.
4. Cochez la case en face du **JDK 17** pour le définir comme JRE par défaut.

### B. Vérifier la conformité du compilateur (Compiler Compliance) :
1. Toujours dans **Window** > **Preferences**, allez sur **Java** > **Compiler**.
2. Vérifiez que **Compiler compliance level** est réglé sur **17**.
3. Cliquez sur **Apply and Close**.

---

## 5. Importation du Projet dans Eclipse

1. Allez dans le menu **File** > **Import...**.
2. Sélectionnez **Maven** > **Existing Maven Projects** puis cliquez sur **Next >**.
3. Pour **Root Directory**, cliquez sur **Browse...** et sélectionnez le dossier `backend` du dépôt :
   `c:\Users\...\ProjetIntegration\backend`
4. Eclipse détecte automatiquement le fichier `pom.xml` (`com.iset.events:eventflow-backend`).
5. Cochez le projet et cliquez sur **Finish**.
6. Eclipse télécharge les dépendances et compile le projet.
7. Dans l'onglet **Problems**, vérifiez qu'il y a **0 erreur** de compilation.

---

## 6. Lancement de l'Application depuis Eclipse

1. Dans l'arborescence du projet (**Package Explorer**), naviguez vers :
   `src/main/java` > `com.iset.events` > `EventsApplication.java`.
2. Faites un clic droit sur `EventsApplication.java`.
3. Sélectionnez **Run As** > **Java Application**.
4. Dans la console Eclipse :
   - Vous observerez la bannière Spring Boot 3.5.x.
   - Flyway exécute les migrations et crée l'ensemble des tables dans la base `eventflow`.
   - `BootstrapAdminRunner` initialise le compte administrateur `admin@example.com`.
   - Tomcat démarre sur le port **2525** :
     `Tomcat started on port 2525 (http) with context path '/'`.
5. Testez l'accessibilité dans votre navigateur ou via un terminal :
   `http://localhost:2525/api/events` (doit renvoyer le catalogue public au format JSON).

---

## 7. Exécution des Tests JUnit depuis Eclipse

1. Faites un clic droit sur le dossier `src/test/java` (ou sur la classe `com.iset.events.EssentialEdgeCasesTest.java`).
2. Sélectionnez **Run As** > **JUnit Test**.
3. Les tests s'exécutent contre la base isolée `eventflow_test` (profil `test`).
4. La barre JUnit passe au vert (**0 failure, 0 error**).

