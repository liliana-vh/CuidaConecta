import 'package:cloud_firestore/cloud_firestore.dart';

class Mensaje {
  static const String uidSistema = 'sistema';

  final String id;
  final String uidEmisor;
  final String texto;
  final DateTime? creadaEn;

  const Mensaje({
    this.id = '',
    required this.uidEmisor,
    required this.texto,
    this.creadaEn,
  });

  bool get esAutomatico => uidEmisor == uidSistema;

  factory Mensaje.desdeMapa(String id, Map<String, dynamic> mapa) {
    return Mensaje(
      id: id,
      uidEmisor: mapa['uidEmisor'] ?? '',
      texto: mapa['texto'] ?? '',
      creadaEn: (mapa['creadaEn'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uidEmisor': uidEmisor,
      'texto': texto,
      'creadaEn': FieldValue.serverTimestamp(),
    };
  }
}
