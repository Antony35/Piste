# Piste

Carnet de suivi de candidatures pour Android, qui fonctionne **hors ligne**.

Quand on postule à plusieurs entreprises en parallèle, les informations se
dispersent entre courriels, sites et notes. Piste les rassemble : chaque
candidature a un statut, des dates et des notes, et l'accueil indique en un
coup d'œil ce qui avance et qui relancer. Il n'y a ni compte ni serveur : les
données restent sur le téléphone.

> Projet réalisé dans le cadre d'une formation Flutter (2026). La V1 est en
> cours de développement : voir [SPECIFICATION.md](SPECIFICATION.md) pour le
> périmètre détaillé.

## Fonctionnalités

*À compléter au fil des étapes, uniquement avec ce qui fonctionne réellement.*

## Stack

| | |
|---|---|
| Framework | Flutter (stable), Dart avec null safety, Material 3 |
| Cible | Android |
| Stockage | SQLite (`sqflite`, `path`) |
| Gestion d'état | `ChangeNotifier` + `ListenableBuilder` (inclus dans Flutter) |

## Architecture

```
lib/
  main.dart     création des dépendances et de l'application
  models/       objets métier typés
  data/         contrats de repository et implémentation SQLite
  state/        contrôleurs ChangeNotifier
  ui/           écrans et widgets
```

Les données circulent dans un seul sens : écran → contrôleur → repository →
SQLite. Aucun écran ne contient de requête SQL.

## Lancer le projet

```bash
flutter pub get
flutter run
```

## Tests

```bash
flutter analyze
flutter test
```

## Choix techniques

*À compléter : stockage, gestion d'état, dépendances.*

## Limites de la V1

Pas de compte ni de synchronisation entre appareils, pas de notification de
relance, pas de version web ni iOS.
