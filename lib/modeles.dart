/// Modeles de donnees du TP 2 : une UE et un Etudiant.
///
/// Ce fichier couvre l'etape 1 du TP : null safety, constructeurs,
/// factory fromJson et accesseurs.
library;

/// Une Unite d'Enseignement (UE) du programme.
class UE {
  final String code;
  final String intitule;
  final int coefficient;

  const UE(this.code, this.intitule, this.coefficient);

  /// Construit une UE a partir d'un objet JSON de la forme :
  /// `{"code": "INF351", "intitule": "...", "coefficient": 3}`
  factory UE.fromJson(Map<String, dynamic> json) => UE(
        json['code'] as String,
        json['intitule'] as String,
        json['coefficient'] as int,
      );

  @override
  String toString() => '$code - $intitule (coeff. $coefficient)';
}

/// Un etudiant et ses notes, codees `{codeUE: note}`.
class Etudiant {
  final String matricule;
  final String nom;

  /// Adresse e-mail facultative : peut valoir null (null safety).
  final String? email;

  /// Notes par code d'UE, ex. `{"INF351": 14.5, "INF302": 12}`.
  final Map<String, double> notes;

  const Etudiant(this.matricule, this.nom, this.email, this.notes);

  /// Construit un Etudiant a partir d'un objet JSON. Les notes forment un
  /// objet JSON `{"INF351": 14.5, ...}` ; les entiers JSON (ex. 15) sont
  /// convertis en double pour rester homogenes.
  factory Etudiant.fromJson(Map<String, dynamic> json) => Etudiant(
        json['matricule'] as String,
        json['nom'] as String,
        json['email'] as String?,
        (json['notes'] as Map<String, dynamic>)
            .map((code, note) => MapEntry(code, (note as num).toDouble())),
      );

  /// Adresse e-mail de l'etudiant, ou « non renseigne » si absente.
  String get contact => email ?? 'non renseigne';

  /// Note obtenue dans l'UE [codeUE], ou null si l'UE est absente.
  double? note(String codeUE) => notes[codeUE];

  @override
  String toString() => '$nom ($matricule)';
}
