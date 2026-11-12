# TP 2 — Dart en pratique · Projet `scolarite`

Projet du TP 2 du module **Programmation mobile Android (Flutter)** — L3 Informatique.
Gestion de la scolarité : modèle de données, statistiques sans boucles, délibération
par classes scellées, asynchronisme et tests unitaires.

---

## 1. Prérequis

| Outil | Version minimale | Vérification |
|---|---|---|
| Dart SDK | 3.x (stable) | `dart --version` |
| Git | n'importe quelle version récente | `git --version` |

> Installation de Dart : <https://dart.dev/get-dart> (le SDK Flutter inclut aussi Dart).

## 2. Installation

```bash
cd tp2_scolarite
dart pub get          # télécharge les dépendances (test, lints)
```

## 3. Commandes essentielles

| Commande | Rôle |
|---|---|
| `dart run scolarite` | Exécute le programme de démonstration (≈ 8 s, délais réseau simulés) |
| `dart analyze` | Analyse statique — doit afficher « No issues found! » (exigence du TP) |
| `dart test` | Lance les 10 tests unitaires de `test/statistiques_test.dart` |
| `dart format lib bin test` | Formate le code avant chaque commit |

## 4. Structure du projet

```
tp2_scolarite/
├── bin/
│   └── scolarite.dart          # Point d'entrée : déroule les 5 étapes du TP
├── lib/
│   ├── modeles.dart            # Étape 1 : classes UE et Etudiant (null safety)
│   ├── statistiques.dart       # Étape 2 : moyenne, classement, moyenneParUE, extremes
│   ├── deliberation.dart       # Étape 3 : sealed Resultat, deliberer(), message()
│   └── service_distant.dart    # Étape 4 : JSON, chargerPromo, chargerUE, journal
├── test/
│   └── statistiques_test.dart  # Étape 5 : 10 tests unitaires
├── COMPTE_RENDU.md             # Réponses aux questions [Q1] [Q2] [Q3]
└── pubspec.yaml                # Nom du paquet : scolarite
```

## 5. Fonctionnement détaillé

### Étape 1 — Modèles et null safety (`lib/modeles.dart`)
- `UE` : code, intitulé, coefficient, constructeur `const` et factory `fromJson`.
- `Etudiant` : matricule, nom, `email` **nullable**, notes (`Map<String, double>`).
- `contact` : accesseur renvoyant l'e-mail ou « non renseigné » (opérateur `??`).
- `note(String codeUE)` : renvoie `double?` — `null` si l'UE est absente (voir [Q1]).
- Les entiers JSON (`15`) sont convertis en `double` dans `fromJson` via `(note as num).toDouble()`.

### Étape 2 — Statistiques (`lib/statistiques.dart`)
**Aucune boucle `for`** — uniquement `map`, `where`, `fold`, `reduce`, `sort` :
- `moyenne(e, ues)` : somme pondérée par `fold`, UE sans note = `0` (opérateur `??`).
- `classement(promo, ues)` : copie de la liste triée par moyenne décroissante (`sort`).
- `moyenneParUE(promo)` : moyenne de la promo pour chaque UE (`map` + `whereType` + `fold`).
- `extremes(valeurs)` : renvoie un **record** Dart `(min, max)` via deux `reduce`.

### Étape 3 — Délibération (`lib/deliberation.dart`)
- `sealed class Resultat` fermée sur 3 sous-classes : `Admis(mention)`, `Rattrapage(ues)`, `Ajourne`.
- `deliberer(e, ues)` : admis si moyenne ≥ 10 · rattrapage si 8 ≤ moyenne < 10
  (avec la liste des UE sous 10) · ajourné sinon.
- `message(r)` : expression `switch` exhaustive avec pattern matching
  (`Admis(:final mention)`). Voir [Q2] pour l'intérêt de `sealed`.

### Étape 4 — Asynchronisme (`lib/service_distant.dart`)
- `chargerPromo()` : attend 2 s (`Future.delayed`), décode le JSON, lève une
  `FormatException` si un matricule commence par « X » — interceptée dans `main`.
- `chargerUE(code)` : attend 500 ms ; les 5 UE sont chargées **en parallèle**
  avec `Future.wait` et chronométrées avec un `Stopwatch` (≈ 500 ms — voir [Q3]).
- `journal()` : `Stream` async* émettant « Calcul de la moyenne de … » une fois
  par seconde, consommée avec `await for`.

### Étape 5 — Tests (`test/statistiques_test.dart`)
10 tests avec `package:test` : moyenne pondérée, UE manquante, `note()` null,
`contact`, classement décroissant, moyenne par UE, record `extremes`,
et les trois issues de la délibération (admis / rattrapage / ajourné).

## 6. Données utilisées

Le TP renvoie à « la chaîne JSON fournie sur la plateforme pédagogique ».
En attendant, la constante **`promoJson`** (dans `lib/service_distant.dart`)
contient un jeu de démonstration : 5 étudiants, 5 UE (INF301 → INF305).
Pour utiliser la chaîne officielle, il suffit de remplacer le contenu de
cette constante — rien d'autre à modifier.

## 7. Workflow Git exigé par les consignes

```bash
git add -A
git commit -m "TP2 : <etape realisee>"     # un commit clair par étape
git push                                   # vers le dépôt du binôme
```

## 8. Vérifier la réponse [Q2] par vous-même

1. Dans `lib/deliberation.dart`, commentez la ligne `Ajourne() => 'Ajourne',`
   du `switch` de `message()`.
2. Lancez `dart analyze` : l'analyseur signale que `Resultat` n'est plus
   exhaustivement couvert (cas `Ajourne()` manquant) — **erreur de compilation**.
3. Prenez une capture d'écran pour le compte rendu, puis rétablissez la ligne.
