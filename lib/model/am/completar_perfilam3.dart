//preparar para firestore

class PerfilAM3Model {
  final int edad;

  PerfilAM3Model({
    required this.edad,
  });

  Map<String, dynamic> toMap() {
    return {
      'edad': edad,
    };
  }
}