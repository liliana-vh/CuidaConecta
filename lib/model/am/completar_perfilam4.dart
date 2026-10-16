//preparar para firestore

class PerfilAM4Model {
  final String comuna;
  final String calle;
  final String numero;
  final bool perfilCompleto;

  PerfilAM4Model({
    required this.comuna,
    required this.calle,
    required this.numero,
    this.perfilCompleto = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'comuna': comuna,
      'calle': calle,
      'numero': numero,
      'perfilCompleto': perfilCompleto,
    };
  }
}