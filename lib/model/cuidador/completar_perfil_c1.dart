class PerfilC1Model {
  final String nombre;
  final String apellido;
  final String rut;
  final String telefono;
  final String nivelEstudios;
  final String? fotoPerfil;

  PerfilC1Model({
    required this.nombre,
    required this.apellido,
    required this.rut,
    required this.telefono,
    required this.nivelEstudios,
    this.fotoPerfil,
  });

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'apellido': apellido,
      'rut': rut,
      'telefono': telefono,
      'nivelEstudios': nivelEstudios,
      if (fotoPerfil != null) 'fotoPerfil': fotoPerfil,
    };
  }
}