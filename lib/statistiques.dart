/// Statistiques de la promo : moyenne ponderee, classement, moyennes par UE
/// et valeurs extremes (etape 2 du TP).
///
/// Contrainte de l'enonce : AUCUNE boucle `for`.
/// On utilise exclusivement `map`, `where`, `fold`, `reduce` et `sort`.
library;

import 'modeles.dart';

/// Moyenne ponderee de [e] sur les UE de [ues].
/// Une UE sans note vaut 0 : `(e.note(ue.code) ?? 0)`.
double moyenne(Etudiant e, List<UE> ues) {
  final sommeCoefficients =
      ues.fold<int>(0, (acc, ue) => acc + ue.coefficient);
  final sommePoints = ues.fold<double>(
    0,
    (acc, ue) => acc + (e.note(ue.code) ?? 0) * ue.coefficient,
  );
  return sommePoints / sommeCoefficients;
}

/// Renvoie la promo triee par moyenne decroissante.
/// On trie une copie pour ne pas modifier la liste recue.
List<Etudiant> classement(List<Etudiant> promo, List<UE> ues) {
  final copie = List<Etudiant>.of(promo);
  copie.sort((a, b) => moyenne(b, ues).compareTo(moyenne(a, ues)));
  return copie;
}

/// Moyenne de la promo pour chaque UE ou au moins un etudiant a une note.
Map<String, double> moyenneParUE(List<Etudiant> promo) {
  final codes = promo.expand((e) => e.notes.keys).toSet();
  return Map.fromEntries(codes.map((code) {
    final notes =
        promo.map((e) => e.notes[code]).whereType<double>().toList();
    final somme = notes.fold(0.0, (acc, n) => acc + n);
    return MapEntry(code, somme / notes.length);
  }));
}

/// Plus petite et plus grande valeur de la liste, sous forme de
/// record Dart `(min, max)`.
(double, double) extremes(List<double> valeurs) {
  final min = valeurs.reduce((a, b) => a < b ? a : b);
  final max = valeurs.reduce((a, b) => a > b ? a : b);
  return (min, max);
}
