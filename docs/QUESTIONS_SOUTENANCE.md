# Réponses de révision pour les questions de soutenance

1. **Trois zones de Git & `git add` vs `git commit` :** Répertoire de travail → Index (`git add` prépare la sélection) → Dépôt local (`git commit` enregistre l'instantané atomique).
2. **Pourquoi ne pas pousser sur `main` ?** Pour garantir une relecture et un passage obligatoire du pipeline CI avant intégration.
3. **Que signifie `--ff-only` / `--no-ff` ?** `pull --ff-only` évite un merge automatique involontaire ; `merge --no-ff` (et *Create a merge commit*) conserve visiblement les branches dans l'historique.
4. **Conflit Git (`HEAD`, `=======`, `origin/main`) :** `HEAD` = branche courante, `origin/main` = branche entrante ; on résout à la main, on supprime les marqueurs, puis `git add` + `git commit --no-edit`.
5. **`set -u` et codes de sortie (`0` / `1`) :** `set -u` interdit les variables non définies ; le pipeline lit exclusivement le code de sortie (`0` = succès, non nul = échec).
6. **Image vs conteneur :** L'image est un modèle immuable en couches ; le conteneur est une exécution jetable de ce modèle.
7. **Pourquoi éviter `:latest` ?** Parce que `:latest` est une étiquette mouvante : deux machines peuvent exécuter deux versions différentes sous le même nom.
8. **Pourquoi un Dockerfile multi-stage et `USER` non-root ?** Diviser la taille de l'image (pas de JDK/Maven/sources en prod) et limiter l'impact d'une faille applicative dans le conteneur.
9. **Pourquoi `0.0.0.0` à l'écoute et `127.0.0.1` dans `HEALTHCHECK` ?** `0.0.0.0` accepte les requêtes externes au conteneur (proxy/hôte) ; le `HEALTHCHECK` s'exécute à l'intérieur du conteneur.
10. **Pourquoi `db` dans Compose, mais `localhost` en CI ?** Dans Compose, `backend` résout le service `db` via le DNS privé Compose ; en CI, `./mvnw` tourne sur l'hôte du runner où Postgres publie `5432:5432`.
11. **Pourquoi ne pas publier le port `5432` ?** Moindre exposition : seul `backend` doit pouvoir interroger PostgreSQL sur le réseau privé.
12. **`stop`, `down`, `down -v` :** `stop` arrête ; `down` supprime conteneurs/réseau et garde les volumes ; `down -v` détruit les volumes (données perdues).
13. **`depends_on` vs `service_healthy` :** `depends_on` seul n'attend pas que PostgreSQL soit prêt à répondre (`pg_isready`).
14. **Job vs Step & `needs` & `if: always()` :** Un job tourne sur un runner isolé ; un step est séquentiel dans un job ; `needs` ordonne les jobs ; `if: always()` sauvegarde les rapports même en échec.
15. **Livraison continue vs Déploiement continu :** Livraison = version immuable prête mais déploiement manuel ; Déploiement continu = mise en service automatique sur tag `v*` sans intervention humaine.
16. **Pourquoi ne jamais reconstruire pendant un rollback ?** Reconstruire introduit des inconnues au pire moment ; on revient sur une image déjà validée.
17. **Pourquoi Nginx devant frontend + backend ?** Même origine (`/` et `/api/`), image frontend immuable avec URLs relatives sans reconstruire par environnement.
18. **Pourquoi supprimer `next/font/google` ?** Pour rendre le `docker build` du frontend reproductible et indépendant d'Internet.
