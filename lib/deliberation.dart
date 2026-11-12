/// Deliberation du jury (etape 3 du TP) : classes scellees (sealed) et
/// expression `switch` exhaustive.
library;

import 'modeles.dart';
import 'statistiques.dart';

/// Resultat de la deliberation : exactement l'un des trois sous-types
/// ci-dessous. `sealed` interdit toute autre sous-classe hors de ce
/// fichier, le compilateur connait donc la liste complete des cas.
sealed class Resultat {}

/// Moyenne >= 10 : l'etudiant est admis, avec sa mention.
class Admis extends Resultat {
  final String mention;
  Admis(this.mention);
}

/// 8 <= moyenne < 10 : l'etudiant passe en rattrapage pour les UE sous 10.
class Rattrapage extends Resultat {
  final List<String> ues;
  Rattrapage(this.ues);
}

/// Moyenne < 8 : l'etudiant est ajourne.
class Ajourne extends Resultat {}

/// Delibere pour [e] :
/// - admis si la moyenne est >= 10 ;
/// - rattrapage si elle est comprise entre 8 et 10 (liste des UE sous 10) ;
/// - ajourne sinon.
Resultat deliberer(Etudiant e, List<UE> ues) {
  final m = moyenne(e, ues);
  if (m >= 10) {
    return Admis(_mention(m));
  } else if (m >= 8) {
    final sousDix = ues
        .map((ue) => ue.code)
        .where((code) => (e.note(code) ?? 0) < 10)
        .toList();
    return Rattrapage(sousDix);
  } else {
    return Ajourne();
  }
}

/// Mention associee a une moyenne d'admis.
String _mention(double m) {
  if (m >= 16) return 'Tres bien';
  if (m >= 14) return 'Bien';
  if (m >= 12) return 'Assez bien';
  return 'Passable';
}

/// Message lisible associe a un resultat. L'expression `switch` doit
/// couvrir TOUTES les sous-classes de `Resultat` : le compilateur
/// verifie l'exhaustivite grace a `sealed`.
String message(Resultat r) => switch (r) {
      Admis(:final mention) => 'Admis, mention $mention',
      Rattrapage(:final ues) => 'Rattrapage : a repasser ${ues.join(', ')}',
      Ajourne() => 'Ajourne',
    };
