# Recette — Piste

Vérifications à faire à la main, sur le téléphone ou l'émulateur. Elles
complètent `flutter test`, qui ne touche jamais SQLite (spec § 8).

Cocher chaque ligne et noter la date. En cas d'échec, décrire ce qui s'est
passé dans la colonne « Remarque ».

- **Appareil** : Pixel 9 Pro XL, Android ____
- **Commit testé** : ________
- **Date** : ________

## Préparation

Pour repartir d'une base vide : désinstaller l'application, ou effacer ses
données dans les réglages Android (*Applications → Piste → Stockage → Vider le
stockage*).

## Parcours de la spécification (§ 8)

| # | Action | Résultat attendu | OK | Remarque |
|---|---|---|---|---|
| 1 | Premier lancement | « Aucune candidature », une phrase et le bouton « Ajouter une candidature ». | ☐ | |
| 2 | Bouton +, puis « Enregistrer » sans rien saisir | Refusé : « Indiquez le nom de l'entreprise. » sous le champ, l'écran reste ouvert. | ☐ | |
| 3 | Créer deux candidatures distinctes, dont une avec une relance à une date passée | Les deux cartes apparaissent. | ☐ | |
| 4 | Accueil | « Candidatures en cours » vaut 2, « À relancer » vaut 1, « +2 cette semaine », les 2 cartes sous « Récentes ». | ☐ | |
| 5 | Candidatures : puce « Entretien », puis rechercher une entreprise | Les deux filtres se combinent. Avec « zzz » : « Aucun résultat » et « Effacer la recherche ». | ☐ | |
| 6 | Ouvrir une fiche, « Modifier », changer le statut et la date | La fiche affiche les nouvelles valeurs et « Modifiée le » change. | ☐ | |
| 7 | Fermer complètement l'application (la balayer depuis les applis récentes), la relancer | Les données sont là, modification comprise. | ☐ | |
| 8 | Supprimer une candidature : « Annuler », puis recommencer et confirmer | Annuler ne change rien ; confirmer revient à la liste sans la candidature. Après un redémarrage, elle n'est pas revenue. | ☐ | |
| 9 | Statistiques | Total, nombres et pourcentages correspondent aux données. Une recherche active sur Candidatures ne les change pas. | ☐ | |
| 10 | *(Complément, pas encore fait)* Saisir un prénom, passer en sombre, relancer | Les deux sont conservés. | ☐ | |

## Vérifications ajoutées

Ces points ne se testent pas, ou mal, avec `flutter test`.

| # | Action | Résultat attendu | OK | Remarque |
|---|---|---|---|---|
| A | Après une suppression, créer une nouvelle candidature | Aucune erreur (R2 : `AUTOINCREMENT` ne réutilise pas l'id). | ☐ | |
| B | Formulaire : ouvrir le clavier sur le champ « Notes » | Le formulaire défile, aucun champ ni message n'est caché (F16). | ☐ | |
| C | Lien « https:// » sans nom de site | Refusé : « Indiquez une adresse complète… » (F13). | ☐ | |
| D | Bouton retour Android : formulaire → fiche → liste | Chaque appui revient à l'écran précédent (N2). | ☐ | |
| E | Accueil : toucher « Rechercher une candidature » | L'onglet Candidatures s'ouvre, clavier prêt (F5). | ☐ | |
| F | Thème sombre d'Android | Tout reste lisible : pastilles, barres, carte de synthèse. | ☐ | |
| G | Taille de police au maximum (*Réglages → Affichage*) | Aucun texte coupé ni bande jaune et noire ; les écrans défilent. | ☐ | |
| H | TalkBack sur Statistiques | Chaque ligne est lue seule : « Entretien : 2, 50 % ». | ☐ | |

## Correspondance exigences → vérifications

Les tests nommés commencent par le numéro de l'exigence (`F7 — …`, `T3 — …`).

| Exigence | Où c'est vérifié |
|---|---|
| D1, D2, D3 | T2, T1, T4 (`test/job_application_test.dart`) |
| F1–F4 | `test/home_shell_test.dart`, `test/applications_summary_test.dart`, recette 4 |
| F5 | `test/search_test.dart`, recette E |
| F6 | T7, `test/home_shell_test.dart` (ordre), `test/format_test.dart` (âge) |
| F7, F8 | `test/application_filter_test.dart`, `test/search_test.dart`, T3, recette 5 |
| F9–F11 | `test/application_detail_page_test.dart`, recette 6 et 8 |
| F12–F15 | `test/application_form_page_test.dart` (T6, T7), `test/form_validators_test.dart`, recette 2 et C |
| F16 | recette B |
| F17–F19 | `test/statistics_page_test.dart`, `test/applications_summary_test.dart`, recette 9 |
| S1–S3 | T5, `test/load_states_test.dart`, recette 1 et 5 |
| N2 | `test/application_detail_page_test.dart`, recette D |
| R1 | `closing the app closes the repository (R1)`, relecture du code |
| R2 | recette 7, 8 et A |
| R3 | relecture de `lib/data/sqlite_job_application_repository.dart` (`whereArgs`) |
| R4 | `R4 — …` (`test/applications_controller_test.dart`) avec le faux repository ; la règle SQLite elle-même se relit dans le code |
| R5 | `leaving during a slow save…` (`test/application_form_page_test.dart`) |
| R7, R8 | relecture de `pubspec.yaml` et du code |
