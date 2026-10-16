class PerfilA1Model {
  final String nombre;
  final String apellido;
  final String rut;
  final String telefono;
  final String? fotoPerfil;

  PerfilA1Model({
    required this.nombre,
    required this.apellido,
    required this.rut,
    required this.telefono,
    this.fotoPerfil,
  });

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'apellido': apellido,
      'rut': rut,
      'telefono': telefono,
      if (fotoPerfil != null) 'fotoPerfil': fotoPerfil,
    };
  }
}