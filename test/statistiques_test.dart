/// Tests unitaires du TP 2 (etape 5) : au moins quatre tests couvrant
/// la moyenne, les UE manquantes, le classement et la deliberation.
///
/// Execution : `dart test`
library;

import 'package:scolarite/deliberation.dart';
import 'package:scolarite/modeles.dart';
import 'package:scolarite/statistiques.dart';
import 'package:test/test.dart';

void main() {
  const ues = [UE('A', 'Algo', 2), UE('B', 'BD', 1)];
  final e = Etudiant('21A0001', 'Test', null, {'A': 12, 'B': 15});

  test('moyenne ponderee', () {
    // (12*2 + 15*1) / (2+1) = 39/3 = 13
    expect(moyenne(e, ues), closeTo(13.0, 0.001));
  });

  test('UE manquante compte pour 0', () {
    final e2 = Etudiant('21A0002', 'Test2', null, {'A': 12});
    // (12*2 + 0*1) / 3 = 8
    expect(moyenne(e2, ues), closeTo(8.0, 0.001));
  });

  test('note() renvoie la note ou null si UE absente', () {
    expect(e.note('A'), 12.0);
    expect(e.note('X'), isNull);
  });

  test('contact renvoie l\'e-mail ou « non renseigne »', () {
    expect(e.contact, 'non renseigne');
    final avecEmail = Etudiant('21A0003', 'T3', 't3@univ.cm', {});
    expect(avecEmail.contact, 't3@univ.cm');
  });

  test('classement par moyenne decroissante', () {
    final meilleur = Etudiant('21A0002', 'Second', null, {'A': 18, 'B': 18});
    final classe = classement([e, meilleur], ues);
    expect(classe.first.nom, 'Second');
    expect(classe.last.nom, 'Test');
  });

  test('moyenneParUE calcule la moyenne de chaque UE', () {
    final e2 = Etudiant('21A0002', 'Second', null, {'A': 18, 'B': 18});
    final m = moyenneParUE([e, e2]);
    expect(m['A'], closeTo(15.0, 0.001)); // (12 + 18) / 2
    expect(m['B'], closeTo(16.5, 0.001)); // (15 + 18) / 2
  });

  test('extremes renvoie le record (min, max)', () {
    expect(extremes([3.5, 10, 2.5]), (2.5, 10.0));
  });

  test('deliberation : admis', () {
    final fort = Etudiant('21A0004', 'Fort', null, {'A': 15, 'B': 15});
    final r = deliberer(fort, ues);
    expect(r, isA<Admis>());
    expect(message(r), contains('Admis'));
  });

  test('deliberation : rattrapage avec liste des UE sous 10', () {
    final moyen = Etudiant('21A0005', 'Moyen', null, {'A': 9, 'B': 9});
    final r = deliberer(moyen, ues);
    expect(r, isA<Rattrapage>());
    expect((r as Rattrapage).ues, ['A', 'B']);
    expect(message(r), contains('Rattrapage'));
  });

  test('deliberation : ajourne', () {
    final faible = Etudiant('21A0006', 'Faible', null, {'A': 6, 'B': 7});
    final r = deliberer(faible, ues);
    expect(r, isA<Ajourne>());
    expect(message(r), contains('Ajourn'));
  });
}
