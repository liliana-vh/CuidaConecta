//preparar para firestore, datos compartidos entre apoyo/cuidador

class CuidadorApoyoModel {
  final String uid;
  final String correo;
  final String tipoUsuario; // cuidador o apoyo
  final String estado;
  final bool perfilCompleto;

  CuidadorApoyoModel({
    required this.uid,
    required this.correo,
    required this.tipoUsuario,
    this.estado = 'pendiente_verificacion',
    this.perfilCompleto = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'correo': correo,
      'tipoUsuario': tipoUsuario,
      'estado': estado,
      'perfilCompleto': perfilCompleto,
    };
  }

  factory CuidadorApoyoModel.desdeMapa(Map<String, dynamic> mapa) {
    return CuidadorApoyoModel(
      uid: mapa['uid'] ?? '',
      correo: mapa['correo'] ?? '',
      tipoUsuario: mapa['tipoUsuario'] ?? '',
      estado: mapa['estado'] ?? 'pendiente_verificacion',
      perfilCompleto: mapa['perfilCompleto'] ?? false,
    );
  }
}