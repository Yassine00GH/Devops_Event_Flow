# Rapport final — EventFlow DevOps

- **Étudiant :** Yassine Ghorbel · **Dépôt :** `https://github.com/Yassine00GH/Devops_Event_Flow`
- **Architecture :** Monorepo `Devops_Event_Flow` à 4 services conteneurisés (`proxy`, `frontend`, `backend`, `db`) + profil debug optionnel (`adminer`), port PostgreSQL `5432` non publié sur l'hôte, utilisateurs non-root (`nginx`, `node`, `appuser`), `HEALTHCHECK` et synchronisation `service_healthy`.
- **Chaîne CI/CD & Bonus (+4 pts) :**
  - Protection de la branche `main` (PR obligatoire, 6 checks requis, *Do not allow bypassing* — PR #6 rouge bloquée).
  - Matrice `Node ['20', '22']` + `Java ['17', '21']` (`fail-fast: false`, 4 artefacts distincts `if: always()`).
  - Publication immuable des 3 images sur GHCR (`v1.0.0`, `v1.1.0`, `v1.1.1`, `v1.2.0`) et déploiement automatique staging en CI sur tag `v1.2.0` (`runs/45065030416`).
- **Preuves archivées dans `preuves/journal-commandes.md` :** captures textuelles complètes de toutes les commandes et sorties exactes des Étapes 0 à 9 (`git ls-files`, `git check-ignore -v`, `scripts/check-project.sh`, `whoami`, `HEALTHCHECK`, persistance `pgdata`, incident `DB_URL=localhost`, URLs CI vert/rouge, déploiement `v1.0.0` + digests SHA-256, panne `v1.1.0` et rollback `v1.0.0` en 26 s, correctif `v1.1.1` et bonus `v1.2.0`).

## Index des livrables de soutenance
- `README.md` : vue d'ensemble, prérequis, démarrage en 1 commande et variables d'environnement.
- `docs/COMPTES_ET_PROFILS.md` : profils Spring Boot (`dev`, `test`, `prod`) et rôles applicatifs.
- `docs/incident-postmortem.md` : compte rendu structuré en 5 points de l'incident `v1.1.0`.
- `docs/FICHE_PROJET.md` : fiche synthétique d'une page à remettre (architecture, digests, rollback, URLs CI).
- `docs/DEMO.md` : plan de démonstration chronométré de 10 minutes.
- `docs/QUESTIONS_SOUTENANCE.md` : 18 questions/réponses de révision.
- `preuves/journal-commandes.md` : journal complet des commandes et preuves (sans aucun secret).
