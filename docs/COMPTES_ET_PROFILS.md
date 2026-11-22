# Comptes, rôles et profils Spring Boot — EventFlow

## Profils applicatifs (`backend/src/main/resources/`)

- **`dev` (défaut local) :** lit `.env` s'il existe, cible `localhost:5432/eventflow`, utilise des valeurs de secours locales non sensibles.
- **`test` :** utilisé par `@ActiveProfiles("test")` (12 tests d'intégration) contre la base `eventflow_test`.
- **`prod` (utilisé dans Docker et Staging) :** **aucune valeur par défaut** pour `DB_URL`, `DB_USERNAME`, `DB_PASSWORD`, `JWT_SECRET`, `CORS_ALLOWED_ORIGINS`, `PAYMENT_API_KEY` et `PAYMENT_SECRET_KEY`. Toute variable absente bloque le démarrage.

## Rôles et création de l'administrateur initial

- **Rôles :** `ADMIN`, `ENSEIGNANT` (validation admin requise), `ETUDIANT` (inscription active).
- **`BootstrapAdminRunner` :** si `ADMIN_EMAIL` et `ADMIN_PASSWORD` sont définis ensemble (mot de passe entre **12 et 72 octets UTF-8**), le compte `ADMIN` est créé automatiquement au premier démarrage.
- **`JwtConfiguration` :** exige une clé `JWT_SECRET` encodée en Base64 représentant **au moins 32 octets** (`openssl rand -base64 32`).
