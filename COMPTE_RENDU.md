# COMPTE RENDU — TP 2 · Dart en pratique

> **Module** : Programmation mobile Android (Flutter) — L3 Informatique
> **TP** : 2 — Dart en pratique · **Binôme** : KONI BETSALEEL ANGE DANIEL (24INF00909S) & BOSSON YVAN (24INF00356B)
> **Dépôt Git** : [tp2_scolarite](https://github.com/BVDK4/tp2_scolarite.git) · **Dernier commit** : `5149c02` (à mettre à jour après chaque nouveau commit)

---

## Réponses aux questions [Q]

### [Q1] — Étapes 1 : pourquoi `note()` renvoie-t-elle `double?` et pas `double` ? Que se passe-t-il si l'on écrit `note('X')! + 1` pour une UE absente ?

**Pourquoi `double?` :**

Le type `double?` signifie « un `double` **ou** la valeur `null` ». C'est un choix de conception dicté par la **null safety** de Dart :

- Les notes d'un étudiant sont stockées dans une `Map<String, double>`. Quand on interroge une clé qui **n'existe pas** (l'étudiant n'a pas passé l'UE, ou n'a pas encore de note), la map ne peut rien renvoyer d'autre que **`null`** : l'information « pas de note » doit être représentable dans le type de retour.
- Si `note()` renvoyait un `double` non nullable, il faudrait choisir une valeur de repli (par exemple `0.0`), ce qui serait **dangereux** : un 0 est une vraie note possible, on ne pourrait plus distinguer « l'étudiant a eu 0 » de « l'étudiant n'a pas de note ».
- Le type `double?` **force le compilateur** à exiger que tout appelant traite le cas `null` (avec `??`, `if (n != null)`, `?.` …). L'oubli devient une **erreur de compilation** et non un bug silencieux à l'exécution.

C'est exactement ce que fait `moyenne()` : `(e.note(ue.code) ?? 0) * ue.coefficient` — conformément à l'énoncé, une UE sans note vaut 0, mais **seulement au point de calcul**, jamais dans le modèle.

**Que se passe-t-il avec `note('X')! + 1` :**

- Le code **compile sans erreur** : l'opérateur `!` (« null assertion ») affirme au compilateur « je garantis que ce n'est pas null ». Dart lui fait confiance à la compilation.
- À l'**exécution**, la promesse est rompue : `note('X')` vaut `null`, l'opérateur `!` lève une **`TypeError`** avec le message *« Null check operator used on a null value »*, et le programme **plante** à cette ligne.
- La bonne pratique est de gérer l'absence explicitement : `note('X') ?? 0` (valeur par défaut) ou `if (note('X') != null) ...` (traitement conditionnel).

### [Q2] — Étape 3 : supprimez le cas `Ajourne()` du switch. Quel message donne l'analyseur ? Quel est l'intérêt de `sealed` ?

**Message de l'analyseur** (testé réellement, voir capture) :

```
The type 'Resultat' is not exhaustively matched by the switch cases
since it doesn't match 'Ajourne()'.
Try adding a default case, a wildcard case '_', or a case for 'Ajourne()'.
```

→ **Erreur de compilation**, pas un simple avertissement : le switch n'est plus **exhaustif**, le programme refuse de se compiler.

**Intérêt de `sealed` :**

- `sealed class Resultat` définit une hiérarchie **fermée** : la liste complète des sous-classes (`Admis`, `Rattrapage`, `Ajourne`) est connue du compilateur, car toute sous-classe doit être déclarée **dans le même fichier**. Personne ne peut, dans un autre fichier, ajouter un 4ᵉ type de résultat à notre insu.
- Le compilateur peut donc **vérifier l'exhaustivité** de tout `switch` sur un `Resultat` : si un cas manque, c'est une erreur de compilation.
- Bénéfices concrets :
  1. **Aucun cas oublié** : impossible d'ajouter un sous-type un jour (par exemple `Exclusion`) et de voir un `switch` l'ignorer silencieusement ;
  2. **Pas besoin de `default`** : un `default` qui absorbe tout masquerait justement les oublis ;
  3. Le **pattern matching** Dart (`Admis(:final mention)`) s'appuie sur cette connaissance pour déstructurer proprement chaque sous-type.

C'est l'équivalent Dart des *algebraic data types* : la logique métier (3 issues possibles à une délibération) est encodée dans le type lui-même.

### [Q3] — Étape 4 : quelle est la durée mesurée au 4.2 ? Quelle serait-elle avec cinq `await` successifs ?

**Mesure réelle** (sortie du programme) :

```
5 UE chargees EN PARALLELE en 522 ms.
```

- Avec `Future.wait` : les 5 futurs sont lancés **simultanément** ; la durée totale est celle du **plus lent** d'entre eux, soit ≈ **500 ms** (522 ms mesurées, l'écart étant le coût du lancement et du chronométrage).
- Avec cinq `await` successifs (`await chargerUE(c1); await chargerUE(c2); …`) : chaque `await` **bloque** jusqu'à la fin du chargement avant de lancer le suivant. Durée = 5 × 500 ms = **≈ 2 500 ms (2,5 s)**, soit **5 fois plus lent**.

**Conclusion** : `Future.wait` est indispensable dès que les tâches sont indépendantes ; les `await` successifs ne se justifient que quand chaque étape a besoin du résultat de la précédente.

---

## Résultats d'exécution

### `dart analyze`

```
Analyzing tp2_scolarite...
No issues found!
```

### `dart run scolarite`

```
===== TP 2 : Scolarite =====

Etape 1 : decodage de la promo (dart:convert)
  - Awa KONAN (21A0101), contact : awa.konan@univ.cm
  - Yann TALLA (21A0102), contact : non renseigne
  - Fatou DIOP (21A0103), contact : f.diop@univ.cm
  - Serge MELLE (21A0104), contact : s.melle@univ.cm
  - Beatrice NGO (21A0105), contact : non renseigne

Etape 2 : statistiques
  1. Awa KONAN 15.50
  2. Yann TALLA 11.41
  3. Fatou DIOP 9.45
  4. Beatrice NGO 7.55
  5. Serge MELLE 6.77
  Moyenne par UE : INF301 11.10 | INF302 11.00 | INF303 10.90 | INF304 10.50 | INF305 11.50
  Moyennes extremes : min 6.77, max 15.50

Etape 3 : deliberation
  - Awa KONAN : Admis, mention Bien
  - Yann TALLA : Admis, mention Passable
  - Fatou DIOP : Rattrapage : a repasser INF301, INF302, INF303
  - Serge MELLE : Ajourne
  - Beatrice NGO : Ajourne

Etape 4 : asynchronisme
  Chargement de la promo (2 s simulees)...
  5 etudiants charges avec succes.
  Erreur interceptee : FormatException: Matricule invalide : commence par « X »
  5 UE chargees EN PARALLELE en 522 ms.
  Journal (1 message/seconde) :
    Calcul de la moyenne de Awa KONAN...
    Calcul de la moyenne de Yann TALLA...
    Calcul de la moyenne de Fatou DIOP...
    Calcul de la moyenne de Serge MELLE...
    Calcul de la moyenne de Beatrice NGO...

===== Fin du TP 2 =====
```

### `dart test`

```
00:00 +10: All tests passed!
```

→ 10 tests unitaires (au-delà des 4 exigés) : moyenne pondérée, UE manquante, `note()` null, `contact`, classement, moyenne par UE, `extremes`, et les 3 issues de la délibération.

### [Bonus Q2] Capture de l'erreur du switch sans `Ajourne()`

_[Insérer ici la capture d'écran de l'analyseur après suppression du cas `Ajourne()` — voir la démarche dans le README, section « Vérifier la réponse Q2 par vous-même ».]_

---

## Difficultés rencontrées

1. **Générics de `Future.wait`** : `uesPromo.map(chargerUE)` passait une `UE` à une fonction qui attend un `String` (`Future<UE> Function(String)` non assignable). Corrigé avec une lambda : `uesPromo.map((ue) => chargerUE(ue.code))`.
2. **Conversion JSON des notes** : en JSON, `15` décode en `int` Dart et non en `double`. `Etudiant.fromJson` convertit donc systématiquement avec `(note as num).toDouble()` pour garantir la cohérence du type `Map<String, double>`.
3. **Import inutilisé** signalé par l'analyseur dans `bin/scolarite.dart` après refactorisation — corrigé (le livrable exige zéro problème).
4. **Chaîne JSON de la plateforme** : le TP renvoie à « la chaîne fournie sur la plateforme ». Nous avons utilisé en attendant un jeu de données de démonstration (5 étudiants, 5 UE) ; la constante `promoJson` dans `lib/service_distant.dart` est à remplacer par la chaîne officielle le cas échéant.

## Ce qui reste à faire de notre côté

- [ ] Remplacer `promoJson` par la chaîne officielle de la plateforme si elle diffère.
- [ ] Insérer la capture d'écran de l'erreur du switch ([Q2]).
- [ ] Créer le dépôt distant et pousser : `git remote add origin <URL>` puis `git push -u origin master`.
