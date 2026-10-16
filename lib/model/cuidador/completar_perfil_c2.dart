class PerfilC2Model {
  final String? descripcion;
  final String experiencia;
  final String formacion;
  final String? documentoAntecedentes;
  final String comuna;
  final List<String> serviciosOfrecidos;
  final bool perfilCompleto;

  PerfilC2Model({
    this.descripcion,
    required this.experiencia,
    required this.formacion,
    this.documentoAntecedentes,
    required this.comuna,
    required this.serviciosOfrecidos,
    this.perfilCompleto = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'descripcion': descripcion ?? '',
      'experiencia': experiencia,
      'formacion': formacion,
      if (documentoAntecedentes != null) 'documentoAntecedentes': documentoAntecedentes,
      'comuna': comuna,
      'serviciosOfrecidos': serviciosOfrecidos,
      'perfilCompleto': perfilCompleto,
    };
  }
}