/// Point d'entree du TP 2 : demontre les 5 etapes de l'enonce.
///
/// Execution : `dart run scolarite`
library;

import 'package:scolarite/deliberation.dart';
import 'package:scolarite/service_distant.dart';
import 'package:scolarite/statistiques.dart';

void main() async {
  print('===== TP 2 : Scolarite =====\n');

  // --- Etape 1 : decoder la chaine JSON et afficher chaque etudiant ---
  print('Etape 1 : decodage de la promo (dart:convert)');
  final promo = decoderPromo(promoJson);
  for (final e in promo) {
    print('  - $e, contact : ${e.contact}');
  }

  // --- Etape 2 : statistiques (sans boucle for) ---
  print('\nEtape 2 : statistiques');
  final classe = classement(promo, uesPromo);
  classe.asMap().forEach(
        (i, e) => print('  ${i + 1}. ${e.nom} ${moyenne(e, uesPromo).toStringAsFixed(2)}'),
      );
  final parUE = moyenneParUE(promo);
  print('  Moyenne par UE : ${parUE.keys.map((c) => '$c ${parUE[c]!.toStringAsFixed(2)}').join(' | ')}');
  final (min, max) = extremes(promo.map((e) => moyenne(e, uesPromo)).toList());
  print('  Moyennes extremes : min ${min.toStringAsFixed(2)}, max ${max.toStringAsFixed(2)}');

  // --- Etape 3 : deliberation (sealed + switch) ---
  print('\nEtape 3 : deliberation');
  for (final e in promo) {
    print('  - ${e.nom} : ${message(deliberer(e, uesPromo))}');
  }

  // --- Etape 4 : asynchronisme ---
  print('\nEtape 4 : asynchronisme');

  // 1. Charger la promo (2 s simulees) avec gestion d'erreur.
  print('  Chargement de la promo (2 s simulees)...');
  try {
    final distante = await chargerPromo();
    print('  ${distante.length} etudiants charges avec succes.');
  } on FormatException catch (erreur) {
    print('  Erreur interceptee : $erreur');
  }

  // 4. Cas invalide : le matricule commence par « X ».
  try {
    await chargerPromo(json: promoJsonInvalide);
  } on FormatException catch (erreur) {
    print('  Erreur interceptee : $erreur');
  }

  // 2. Charger 5 UE en parallele (Future.wait) et mesurer (Stopwatch).
  final chrono = Stopwatch()..start();
  final uesChargees = await Future.wait(uesPromo.map((ue) => chargerUE(ue.code)));
  chrono.stop();
  print('  ${uesChargees.length} UE chargees EN PARALLELE en ${chrono.elapsedMilliseconds} ms.');

  // 3. Journal : un message par seconde, consomme avec await for.
  print('  Journal (1 message/seconde) :');
  await for (final ligne in journal()) {
    print('    $ligne');
  }

  print('\n===== Fin du TP 2 =====');
}
