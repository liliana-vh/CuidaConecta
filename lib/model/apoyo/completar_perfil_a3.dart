class PerfilA3Model {
  final String edad;
  final String relacion;
  final String? condicion;
  final String dependencia;
  final bool perfilCompleto;

  PerfilA3Model({
    required this.edad,
    required this.relacion,
    this.condicion,
    required this.dependencia,
    this.perfilCompleto = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'perfilAdultoMayor': {
        'edad': edad,
        'relacion': relacion,
        'condicion': condicion,
        'dependencia': dependencia,
      },
      'perfilCompleto': perfilCompleto,
    };
  }
}