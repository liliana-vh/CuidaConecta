//preparar para firestore datos principales usuario tipo 'apoyo'

class PerfilApoyoModel {
  final String nombre;
  final String apellido;
  final String correo;
  final String rut;
  final String telefono;
  final String? fotoPerfil;

  // Direccion de atencion
  final String comuna;
  final String calle;
  final String numero;
  final String detalles;

  // Familiar a cargo
  final String edadFamiliar;
  final String relacionFamiliar;
  final String? condicionFamiliar;
  final String dependenciaFamiliar;

  PerfilApoyoModel({
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.rut,
    required this.telefono,
    this.fotoPerfil,
    required this.comuna,
    required this.calle,
    required this.numero,
    this.detalles = '',
    required this.edadFamiliar,
    required this.relacionFamiliar,
    this.condicionFamiliar,
    required this.dependenciaFamiliar,
  });

  factory PerfilApoyoModel.desdeMapa(Map<String, dynamic> mapa) {
    final direccion = mapa['direccionServicio'] as Map<String, dynamic>? ?? {};
    final familiar = mapa['perfilAdultoMayor'] as Map<String, dynamic>? ?? {};

    return PerfilApoyoModel(
      nombre: mapa['nombre'] ?? '',
      apellido: mapa['apellido'] ?? '',
      correo: mapa['correo'] ?? '',
      rut: mapa['rut'] ?? '',
      telefono: mapa['telefono'] ?? '',
      fotoPerfil: mapa['fotoPerfil'],
      comuna: direccion['comuna'] ?? '',
      calle: direccion['calle'] ?? '',
      numero: direccion['numero'] ?? '',
      detalles: direccion['detalles'] ?? '',
      edadFamiliar: familiar['edad'] ?? '',
      relacionFamiliar: familiar['relacion'] ?? '',
      condicionFamiliar: familiar['condicion'],
      dependenciaFamiliar: familiar['dependencia'] ?? '',
    );
  }
}