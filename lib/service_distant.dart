/// Simulation d'un service distant (etape 4 du TP) : futures, streams,
/// chargements paralleles et gestion d'erreurs.
library;

import 'dart:async';
import 'dart:convert';

import 'modeles.dart';

/// Chaine JSON « recue du serveur » : liste d'etudiants.
/// Remplacer par la chaine fournie sur la plateforme pedagogique.
const String promoJson = '''
[
  {"matricule": "21A0101", "nom": "Awa KONAN", "email": "awa.konan@univ.cm",
   "notes": {"INF301": 16.5, "INF302": 15, "INF303": 14, "INF304": 17, "INF305": 12}},
  {"matricule": "21A0102", "nom": "Yann TALLA", "email": null,
   "notes": {"INF301": 12, "INF302": 13.5, "INF303": 10, "INF304": 9.5, "INF305": 14}},
  {"matricule": "21A0103", "nom": "Fatou DIOP", "email": "f.diop@univ.cm",
   "notes": {"INF301": 9, "INF302": 8.5, "INF303": 9.5, "INF304": 10, "INF305": 11}},
  {"matricule": "21A0104", "nom": "Serge MELLE", "email": "s.melle@univ.cm",
   "notes": {"INF301": 7, "INF302": 6, "INF303": 8, "INF304": 5.5, "INF305": 9}},
  {"matricule": "21A0105", "nom": "Beatrice NGO", "email": null,
   "notes": {"INF301": 11, "INF302": 12, "INF303": 13}}
]
''';

/// Variante contenant un matricule invalide (commence par « X »),
/// pour tester la gestion d'erreur de l'etape 4.4.
const String promoJsonInvalide = '''
[
  {"matricule": "X21A999", "nom": "Etudiant Invalide", "email": null,
   "notes": {"INF301": 10, "INF302": 10, "INF303": 10, "INF304": 10, "INF305": 10}}
]
''';

/// Les 5 UE de la promotion, utilisees pour le chargement parallele.
const List<UE> uesPromo = [
  UE('INF301', 'Algorithmique avancee', 3),
  UE('INF302', 'Bases de donnees', 2),
  UE('INF303', 'Reseaux', 2),
  UE('INF304', 'Programmation mobile', 3),
  UE('INF305', 'Statistiques', 1),
];

/// Decode la chaine JSON [json] en liste d'etudiants.
List<Etudiant> decoderPromo(String json) {
  final donnees = jsonDecode(json) as List<dynamic>;
  return donnees
      .map((j) => Etudiant.fromJson(j as Map<String, dynamic>))
      .toList();
}

/// Simule un appel reseau : attend 2 secondes (Future.delayed) puis
/// renvoie la promo decodee. Leve une FormatException si un matricule
/// commence par « X » (etape 4.4).
Future<List<Etudiant>> chargerPromo({String json = promoJson}) async {
  await Future.delayed(const Duration(seconds: 2));
  final etudiants = decoderPromo(json);
  if (etudiants.any((e) => e.matricule.startsWith('X'))) {
    throw const FormatException('Matricule invalide : commence par « X »');
  }
  return etudiants;
}

/// Simule le chargement d'une UE : attend 500 ms puis la renvoie.
/// Les appels sont concus pour etre lances en parallele avec Future.wait.
Future<UE> chargerUE(String code) async {
  await Future.delayed(const Duration(milliseconds: 500));
  return uesPromo.firstWhere((ue) => ue.code == code);
}

/// Emit un message par seconde : « Calcul de la moyenne de ... ».
/// A consommer avec `await for` dans le main.
Stream<String> journal() async* {
  final promo = decoderPromo(promoJson);
  for (final e in promo) {
    yield 'Calcul de la moyenne de ${e.nom}...';
    await Future.delayed(const Duration(seconds: 1));
  }
}
