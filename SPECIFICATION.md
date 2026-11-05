# Spécification — Piste V1

Piste est un carnet de suivi de candidatures, sur téléphone et **hors ligne**.
Ce document dit ce que la V1 doit faire. Chaque exigence porte un identifiant
(`F1`, `R2`…) repris par les tests et la recette.

Les exigences sont classées en deux niveaux :

- **Cœur** : le socle noté par le cours. Il est livré en premier.
- **Complément** : le profil, les paramètres, le menu latéral et le thème. Il
  est livré une fois le cœur terminé et vérifié.

## 1. Besoin

| | |
|---|---|
| **Utilisateur** | Une personne en recherche d'emploi ou d'alternance, qui postule à plusieurs entreprises en parallèle. |
| **Problème** | Les candidatures sont dispersées entre courriels, sites et notes : on ne sait plus où on en est avec chaque entreprise, ni qui relancer. |
| **Action principale** | Enregistrer une candidature en quelques secondes, puis faire évoluer son statut. |
| **Contrainte** | Tout fonctionne sans réseau, sans compte et sans serveur. Les données restent sur l'appareil. |

## 2. Données

Un seul objet métier : la **candidature**.

| Champ | Type | Obligatoire | Règle |
|---|---|---|---|
| `id` | entier | auto | Attribué par la base, stable, jamais réutilisé. |
| `entreprise` | texte | **oui** | Espaces de début et de fin retirés, non vide. |
| `poste` | texte | **oui** | Espaces de début et de fin retirés, non vide. |
| `statut` | énumération | oui | Valeur par défaut : `envoyee`. |
| `dateCandidature` | date | non | Choisie avec un sélecteur de date. |
| `prochaineRelance` | date | non | Choisie avec un sélecteur de date. |
| `url` | texte | non | Si elle est renseignée, elle commence par `http://` ou `https://`. |
| `notes` | texte long | non | Libre. |
| `dateCreation` | date-heure | auto | Fixée au premier enregistrement, jamais modifiée ensuite. |
| `dateModification` | date-heure | auto | Mise à jour à chaque enregistrement. |

**Statuts**, dans l'ordre d'avancement : `envoyee` (Envoyée), `enCours` (En
cours), `entretien` (Entretien), `offre` (Offre), `refusee` (Refusée).

- **D1**. Un statut inconnu en base, venu par exemple d'une ancienne version,
  est lu comme `envoyee` au lieu de faire planter l'application.
- **D2**. Les dates sont stockées en texte ISO 8601 et relues en `DateTime`.
  Une candidature enregistrée puis relue est identique à l'originale.
- **D3**. Une candidature est **à relancer** si `prochaineRelance` est
  aujourd'hui ou passée et que son statut n'est ni `offre` ni `refusee`.

**Préférences** (complément), stockées hors de la base de candidatures :

| Clé | Valeurs | Défaut |
|---|---|---|
| `prenom` | texte libre, facultatif | vide |
| `theme` | `systeme`, `clair`, `sombre` | `systeme` |

## 3. Navigation

```
                  ┌────────── menu latéral ──────────┐
                  │  Profil · Paramètres · À propos  │
                  └──────────────────────────────────┘
Barre du bas :  Accueil │ Candidatures │ Statistiques

Candidatures ──tap carte──▶ Fiche détail ──Modifier──▶ Formulaire (édition)
     │                           └─ Supprimer ─▶ confirmation
     └─ bouton Ajouter (visible sur les trois onglets) ─▶ Formulaire (création)
```

- **N1**. La barre du bas porte les trois écrans principaux. Le menu latéral
  porte uniquement le secondaire, pour ne rien proposer deux fois.
- **N2**. Le retour Android ramène toujours à l'écran précédent attendu.

## 4. Écrans

### E1 — Accueil (cœur)

- **F1**. Une salutation : « Bonjour » suivi du prénom s'il est renseigné, et
  la date du jour.
- **F2**. Une carte de synthèse : le nombre de candidatures en cours (tous les
  statuts sauf `offre` et `refusee`), le nombre créées dans les 7 derniers
  jours, et une barre de répartition par statut.
- **F3**. Trois compteurs : Entretiens, Offres et À relancer (D3).
- **F4**. Les 3 candidatures modifiées le plus récemment, avec un lien
  « Tout voir » vers l'onglet Candidatures.
- **F5**. Le champ de recherche de l'accueil ouvre l'onglet Candidatures, la
  recherche active.

### E2 — Candidatures (cœur)

- **F6**. La liste complète, de la plus récemment modifiée à la plus ancienne.
  Chaque carte affiche le poste (titre), l'entreprise, le statut et l'âge de la
  dernière modification (« il y a 2 j »).
- **F7**. La recherche porte sur l'entreprise **et** sur le poste, sans tenir
  compte des majuscules ni des espaces autour.
- **F8**. Des puces de filtre (« Toutes » ou un statut) se **combinent** avec
  la recherche.

### E3 — Fiche détail (cœur)

- **F9**. Elle affiche tous les champs, dont les dates de création et de
  dernière modification. Elle est en lecture seule.
- **F10**. Le bouton « Modifier » ouvre le formulaire prérempli.
- **F11**. Le bouton « Supprimer » ouvre une boîte de dialogue qui nomme la
  candidature. Ce n'est qu'après confirmation que la candidature est
  supprimée et que l'écran revient à la liste. Annuler ne change rien.

### E4 — Formulaire, création et édition sur un seul écran (cœur)

- **F12**. Le titre affiche « Nouvelle candidature » ou « Modifier la
  candidature ». En édition, l'`id` et la `dateCreation` sont conservés.
- **F13**. Si un champ obligatoire est vide ou si l'URL est invalide,
  l'enregistrement est refusé et le message d'erreur apparaît sous le champ,
  sans fermer l'écran.
- **F14**. Pendant l'enregistrement, le bouton est désactivé : deux appuis
  rapprochés ne créent **qu'une** candidature.
- **F15**. En cas de succès, l'écran se ferme. En cas d'échec, il reste ouvert,
  les valeurs saisies sont conservées et un message s'affiche.
- **F16**. Le formulaire défile quand le clavier est ouvert : aucun champ ni
  message d'erreur ne reste caché.

### E5 — Statistiques (cœur)

- **F17**. Le nombre total, puis le nombre et la proportion pour chaque statut,
  avec une barre par statut.
- **F18**. Les chiffres portent sur **toutes** les données, même si un filtre
  est actif sur l'onglet Candidatures.
- **F19**. Avec zéro candidature, les proportions valent 0 : pas de division
  par zéro ni d'affichage `NaN`.

### E6 — Profil (complément)

- **F20**. Il affiche le prénom (avec ses initiales en avatar) et des chiffres
  personnels : nombre de candidatures et d'offres.
- **F21**. Il contient un emplacement « Compte (bientôt disponible) »,
  désactivé et visiblement présenté comme à venir. **Aucune donnée fictive** :
  pas de faux nom, de fausse adresse ni de bouton Déconnexion.

### E7 — Paramètres (complément)

- **F22**. Le prénom est modifiable. Il est enregistré sur l'appareil et repris
  par l'accueil (F1) et le profil (F20).
- **F23**. Le thème se règle sur Système, Clair ou Sombre. Le choix s'applique
  immédiatement et survit au redémarrage.

### E8 — À propos (complément)

- **F24**. Il affiche la version de l'application (lue dans `pubspec.yaml`),
  une phrase sur la confidentialité (« Vos données restent sur cet appareil »)
  et les licences, avec `showLicensePage`.

## 5. États de chargement (cœur)

Tout écran alimenté par la base distingue quatre états :

| État | Affichage |
|---|---|
| **loading** | Indicateur de progression. |
| **success** | Données et actions disponibles. |
| **empty** | « Aucune candidature », une phrase d'invitation et le bouton « Ajouter une candidature ». |
| **error** | Le message transmis par le contrôleur et un bouton « Réessayer », qui relance le chargement. |

- **S1**. Une erreur de lecture n'est **jamais** affichée comme une liste vide :
  ce serait mentir à l'utilisateur.
- **S2**. Une recherche sans résultat n'est pas l'état empty. Elle affiche
  « Aucun résultat » et propose d'effacer la recherche.
- **S3**. L'écran d'erreur n'écrit pas de message en dur : il affiche celui que
  le contrôleur lui transmet. En V1, l'erreur vient du stockage local
  (« Chargement impossible »). Une future V2 en réseau pourra dire « Connexion
  impossible » sans qu'on touche à l'écran.

## 6. Identité visuelle

Les couleurs sont déclarées **une seule fois** dans le `ThemeData` (un
`ColorScheme` clair et un sombre). Aucun écran n'écrit de couleur en dur :
c'est ce qui permet de changer de thème sans toucher aux écrans.

| Rôle | Clair | Sombre |
|---|---|---|
| Fond | `#F5F6F8` gris-blanc | `#0A0F2E` bleu nuit |
| Surface (cartes, champs) | `#FFFFFF` | `#131A42` |
| Encre (texte) | `#0D1150` bleu nuit | `#EAF2FF` |
| Texte secondaire | `#5B6390` | `#8A94C2` |
| Bordure | `#E3E5EA` | `#1E2754` |
| Carte de synthèse | `#2A4BA8` | `#1A3F8A` |
| Primaire (onglet actif, liens) | `#2F6FC9` · aplats `#4A8BDF` | `#7FB0F0` |
| Action (Ajouter, À relancer) | `#A0006D` aubergine | `#E0569F` |

**Statuts** : chaque statut a une teinte pastel (fond clair et texte foncé de
la même famille), toujours accompagnée de son libellé.

| Statut | Teinte |
|---|---|
| Envoyée | bleu-gris |
| En cours | bleu royal |
| Entretien | aubergine |
| Offre | vert |
| Refusée | gris |

- **V1**. **Pas de noir** en thème clair : l'encre est bleu nuit.
- **V2**. Le texte atteint un contraste d'au moins 4,5:1 sur son fond. Le bleu
  `#4A8BDF` ne sert qu'aux aplats et aux grands chiffres, jamais au petit
  texte sur blanc.
- **V3**. **Icônes** : chaque entrée de navigation, chaque compteur, chaque
  ligne de la fiche détail et chaque état (vide, erreur, aucun résultat) a une
  icône Material arrondie, éventuellement posée sur une pastille colorée. Elles
  rendent l'interface plus vivante sans la charger : une icône par élément au
  plus, jamais décorative seule, et toujours accompagnée d'un libellé ou d'un
  `tooltip`.
- **V4**. Coins arrondis (12 à 20 px), espacements multiples de 4, marges
  latérales de 20 px. Material 3, sans ombre portée.

## 7. Règles techniques

- **R1. Architecture** : `ui/` → `state/` (`ChangeNotifier`) → `data/`
  (contrat `CandidatureRepository`) → SQLite. Aucune requête SQL hors de
  `data/`. Repositories et contrôleurs sont créés **une seule fois** dans
  `main.dart` et libérés dans `dispose()`.
- **R2. Persistance** : `sqflite` + `path`, fichier `piste.db`. La table est
  versionnée, avec `onCreate` et `onUpgrade`. Les données survivent à la
  fermeture complète de l'application.
- **R3. Sécurité des requêtes** : mises à jour et suppressions ciblent l'`id`
  par `whereArgs`, jamais par concaténation de chaînes.
- **R4. Écriture vérifiée** : une mise à jour ou une suppression qui ne touche
  aucune ligne lève une erreur. Elle ne passe jamais pour un succès.
- **R5. Cycle de vie** : `mounted` est vérifié après chaque `await` avant
  d'utiliser le `context`. Chaque `TextEditingController` est libéré.
- **R6. Préférences** (complément) : `shared_preferences`, derrière un contrat
  `PreferencesRepository`. C'est l'outil prévu pour quelques réglages, pas
  pour des données métier.
- **R7. Dépendances** : `sqflite`, `path` et `shared_preferences`, rien
  d'autre. Chaque paquet ajouté doit être justifié dans le README.

## 8. Critères d'acceptation

### Tests automatisés (`flutter test`)

| # | Type | Vérifie |
|---|---|---|
| T1 | unitaire | Aller-retour `toDatabase` → `fromDatabase` sans perte (D2). |
| T2 | unitaire | Statut inconnu lu comme `envoyee` (D1). |
| T3 | unitaire | La recherche et le filtre se combinent sans changer les totaux des statistiques (F7, F8, F18). |
| T4 | unitaire | Règle « à relancer » : date passée, date future, statut clos (D3). |
| T5 | unitaire | Lecture en échec → `error` avec message, puis réparée → `empty` (S1, S3). |
| T6 | widget | Formulaire vide → message « Indiquez le nom de l'entreprise. » (F13). |
| T7 | widget | Formulaire rempli → nouvelle carte visible dans la liste (F6, F15). |

Les tests utilisent des faux repositories, capables de simuler une erreur de
lecture ou d'écriture, et jamais SQLite.

### Recette manuelle (émulateur ou téléphone)

1. Premier lancement : l'état empty s'affiche avec son bouton.
2. Valider le formulaire vide : il est refusé, avec le message sous le champ.
3. Créer deux candidatures distinctes, dont une avec une relance passée.
4. Accueil : les compteurs et la carte de synthèse correspondent.
5. Candidatures : filtrer sur « Entretien », puis rechercher une entreprise.
6. Ouvrir une fiche, puis modifier son statut et sa date.
7. Fermer complètement l'application, la relancer : les données sont là.
8. Supprimer une candidature : annuler d'abord, puis confirmer.
9. Statistiques : les chiffres correspondent aux données.
10. *(Complément)* Saisir un prénom, passer en sombre, relancer : les deux sont
    conservés.

### Livraison

- `flutter analyze` ne remonte aucun problème.
- `version: 1.0.0+1`, identifiant `io.github.antony35.piste`.
- APK release signé avec une clé personnelle. Ni la clé ni `key.properties`
  ne sont dans le dépôt.

## 9. Hors périmètre V1

Comptes et synchronisation entre appareils, notifications de relance, panneau
de filtres multi-statuts avec tri, export, version web, iOS, publication sur un
store. Ces limites sont assumées et décrites dans le README.
