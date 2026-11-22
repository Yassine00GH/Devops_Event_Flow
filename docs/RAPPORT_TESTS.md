# Rapport de Tests Backend — EventFlow

Date d'exécution : **7 Novembre 2026**  
Environnement : **Java 17 (JDK 17.0.8 LTS), Spring Boot 3.5.6, PostgreSQL 18.6, Flyway 11.7.2**  
Résultat global : **100% SUCCÈS (0 échec, 0 erreur, 0 sauté)**

---

## 1. Synthèse de la Suite de Tests JUnit 5 & MockMvc (`mvnw.cmd clean verify`)

Les tests s'exécutent automatiquement contre la base de données isolée `eventflow_test` sur PostgreSQL 18.6.

| Classe de test | Tests exécutés | Succès | Échecs | Erreurs | Ignorés |
|---|---|---|---|---|---|
| `com.iset.events.EventsApplicationTests` | 1 | 1 | 0 | 0 | 0 |
| `com.iset.events.FullScenarioIntegrationTest` | 1 | 1 | 0 | 0 | 0 |
| `com.iset.events.EssentialEdgeCasesTest` | 9 | 9 | 0 | 0 | 0 |
| **Total JUnit** | **11** | **11** | **0** | **0** | **0** |

### Détail des Cas Limites Testés (`EssentialEdgeCasesTest`) :
1. **`testDuplicateEmailRejected`** : Vérifie qu'un email déjà existant est immédiatement rejeté avec le code `409 CONFLICT` et le code d'erreur `EMAIL_ALREADY_EXISTS`.
2. **`testPendingAccountCannotLogin`** : Vérifie qu'un compte non encore validé par l'administrateur (`EN_ATTENTE`) ne peut pas se connecter (`403 FORBIDDEN`, code `ACCOUNT_NOT_ACTIVE`).
3. **`testTeacherCannotModifyAnotherTeachersEvent`** : Vérifie l'isolation des données entre enseignants : un enseignant tentant de modifier l'événement d'un confrère reçoit `404 NOT_FOUND` ou `403 FORBIDDEN`.
4. **`testDoubleReservationPrevented`** : Vérifie qu'un étudiant ne peut pas réserver deux fois le même événement actif (`409 CONFLICT`, code `RESERVATION_CONFLICT`).
5. **`testFullEventRejectsNewReservations`** : Vérifie qu'un événement dont la capacité est atteinte (`availablePlaces == 0`) passe automatiquement au statut `COMPLET` et refuse toute nouvelle réservation (`409 CONFLICT`, code `INSUFFICIENT_CAPACITY`).
6. **`testFailedPaymentCancelsReservationAndFreesPlaces`** : Vérifie qu'un échec de paiement (`status: ECHOUE`) annule immédiatement la réservation et restitue les places dans le quota disponible de l'événement.
7. **`testAccentedAndArabicTextHandling`** : Vérifie la persistance et restitution sans altération des caractères accentués français (ex. « Conférence Événementielle Réussie ») et arabes (ex. « ورشة عمل الذكاء الاصطناعي », nom « محمد عزيز ») avec encodage UTF-8 sous PostgreSQL 18.
8. **`testSimultaneousBookingsForLastPlace`** : Vérifie la gestion de concurrence lors de deux réservations simultanées pour la dernière place restante (`capacity = 1`). Grâce au verrouillage pessimiste (`SELECT ... FOR UPDATE`), une seule réservation aboutit (`201 CREATED`) et l'autre est rejetée (`409 CONFLICT` avec `INSUFFICIENT_CAPACITY`).
9. **`testActionReorderAndDelete`** : Vérifie la création du programme d'un événement, le réordonnancement des actions (`PUT /actions/reorder`) avec mise à jour correcte des `displayOrder`, ainsi que la suppression d'une action (`DELETE /actions/{id}`).

### Détail du Scénario Intégral (`FullScenarioIntegrationTest`) :
Exécution séquentielle complète validant le cycle de vie de l'application :
1. Authentification administrateur par défaut.
2. Inscription d'un enseignant et d'un étudiant.
3. Blocage des comptes en attente de validation.
4. Validation administrative des comptes avec attribution des rôles.
5. Connexion réussie des comptes validés.
6. Mise à jour de profil et changement de mot de passe.
7. Création d'un événement avec actions et publication.
8. Consultation publique et recherche.
9. Réservation d'un événement payant par l'étudiant.
10. Paiement simulé réussi (`status: PAYE`).
11. Génération du ticket horodaté avec code de confirmation unique (`EVT-...`).
12. Notification envoyée à l'enseignant et à l'étudiant.
13. Consultation de la liste des participants par l'enseignant.
14. Consultation des tableaux de bord statistiques (Admin, Enseignant, Étudiant).
15. Consultation de l'historique d'audit filtré par rôle.

---

## 2. Validation de Bout en Bout via Requêtes HTTP (`test_all_apis.ps1`)

Exécution réelle effectuée contre le serveur démarré sur `http://localhost:2525` et la base `eventflow` :

```
========== TESTS API BACKEND EVENTFLOW ==========

--- 1. AUTHENTIFICATION ---
PASS | 1.1 Login Admin | 200
PASS | 1.2 Register Enseignant | 201
PASS | 1.3 Register Etudiant | 201
PASS | 1.4 Login EN_ATTENTE => 403 | 403
PASS | 1.5 Duplicate Email => 409 | 409

--- 2. ADMIN ---
PASS | 2.1 GET /admin/users/pending | 200
PASS | 2.2 Validate Enseignant | 200
PASS | 2.3 Validate Etudiant | 200
PASS | 2.4 GET /admin/users | 200

--- 3. LOGIN COMPTES VALIDES ---
PASS | 3.1 Login Enseignant | 200
PASS | 3.2 Login Etudiant | 200

--- 4. PROFIL ---
PASS | 4.1 GET /users/me | 200
PASS | 4.2 PUT /users/me | 200
PASS | 4.3 PATCH password | 200
PASS | 4.4 Re-login new pwd | 200

--- 5. EVENEMENTS ---
PASS | 5.1 Create event | 201
PASS | 5.2 GET mine | 200
PASS | 5.3 GET event detail | 200
PASS | 5.4 PUT update | 200
PASS | 5.5 Add action | 201
PASS | 5.6 GET actions | 200
PASS | 5.7 Publish | 200

--- 6. CONSULTATION PUBLIQUE ---
PASS | 6.1 GET /events | 200
PASS | 6.2 GET /events/{id} | 200
PASS | 6.3 GET /events?search=IA | 200
PASS | 6.4 GET actions (public) | 200

--- 7. RESERVATIONS ---
PASS | 7.1 Create reservation | 201
PASS | 7.2 GET /reservations/me | 200
PASS | 7.3 Double reservation => 409 | 409

--- 8. PAIEMENT ---
PASS | 8.1 Pay | 200
PASS | 8.2 Ticket | 200

--- 9. NOTIFICATIONS ---
PASS | 9.1 GET notifications | 200
PASS | 9.2 Mark read | 200
PASS | 9.3 Mark all read | 200

--- 10. PARTICIPANTS ---
PASS | 10.1 GET participants | 200

--- 11. DASHBOARD ---
PASS | 11.1 Admin stats | 200
PASS | 11.2 Teacher stats | 200
PASS | 11.3 Student stats | 200

--- 12. HISTORIQUE ---
PASS | 12.1 History admin | 200
PASS | 12.2 History teacher | 200
PASS | 12.3 History student | 200

--- 13. ANNULATION ---
PASS | 13.1 Cancel reservation | 200
PASS | 13.2 Verify places | 200
   Places: 50/50

========== TESTS TERMINES ==========
```

---

## 3. Compatibilité PostgreSQL 18 et Flyway

- **Flyway** : Les migrations `V1__init_schema.sql`, `V2__seed_admin.sql` et `V3__sample_data.sql` s'exécutent avec succès sur PostgreSQL 18.6.
- **Avertissement bénin** : Flyway signale un avertissement informatif (`PostgreSQL 18.6 is newer than this version of Flyway...`), mais toutes les migrations s'appliquent correctement et le schéma est parfaitement cohérent.
- **Transactions & Concurrence** : Le verrouillage de ligne `FOR UPDATE` est pleinement supporté et assure la cohérence des réservations simultanées.
