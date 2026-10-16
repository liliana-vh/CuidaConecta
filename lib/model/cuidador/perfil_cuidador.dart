//preparar para firestore, datos usuario tipo 'cuidador'

class PerfilCuidadorModel {
  final String nombre;
  final String apellido;
  final String correo;
  final String rut;
  final String telefono;
  final String? fotoPerfil;
  final String nivelEstudios;
  final String? descripcion;
  final String experiencia;
  final String formacion;
  final String comuna;
  final List<String> serviciosOfrecidos;
  final String? documentoAntecedentes;

  PerfilCuidadorModel({
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.rut,
    required this.telefono,
    this.fotoPerfil,
    required this.nivelEstudios,
    this.descripcion,
    required this.experiencia,
    required this.formacion,
    required this.comuna,
    required this.serviciosOfrecidos,
    this.documentoAntecedentes,
  });

  factory PerfilCuidadorModel.desdeMapa(Map<String, dynamic> mapa) {
    return PerfilCuidadorModel(
      nombre: mapa['nombre'] ?? '',
      apellido: mapa['apellido'] ?? '',
      correo: mapa['correo'] ?? '',
      rut: mapa['rut'] ?? '',
      telefono: mapa['telefono'] ?? '',
      fotoPerfil: mapa['fotoPerfil'],
      nivelEstudios: mapa['nivelEstudios'] ?? '',
      descripcion: mapa['descripcion'],
      experiencia: mapa['experiencia'] ?? '',
      formacion: mapa['formacion'] ?? '',
      comuna: mapa['comuna'] ?? '',
      serviciosOfrecidos: List<String>.from(mapa['serviciosOfrecidos'] ?? []),
      documentoAntecedentes: mapa['documentoAntecedentes'],
    );
  }
}