class TipoUsuario {
  static const String cuidador = 'Cuidador';
  static const String apoyo = 'Apoyo';
  static const String adultoMayor = 'Adulto Mayor';
}

class IdentidadUsuario {
  final String nombre;
  final String tipoUsuario;

  const IdentidadUsuario({required this.nombre, required this.tipoUsuario});

  bool get puedePagarConTarjeta => tipoUsuario == TipoUsuario.apoyo;
}