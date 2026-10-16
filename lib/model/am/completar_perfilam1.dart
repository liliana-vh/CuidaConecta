//preparar para firesore

class PerfilAM1Model {
  final String nombre;
  final String apellido;

  PerfilAM1Model({
    required this.nombre,
    required this.apellido,
  });

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'apellido': apellido,
    };
  }
}