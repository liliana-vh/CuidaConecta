import 'package:cloud_firestore/cloud_firestore.dart';

class AvisoServicio {
  final String id;
  final String uidCuidador;
  final String nombreCuidador;

  final String? fotoCuidador;

  final String titulo;
  final String descripcion;
  final List<String> servicios;
  final String comuna;

  final Map<String, dynamic> disponibilidad;
  final double tarifaHora;

  // false = aviso archivado, no se elimina de la bbdd por ahora
  final bool activo;

  const AvisoServicio({
    this.id = '',
    required this.uidCuidador,
    required this.nombreCuidador,
    this.fotoCuidador,
    required this.titulo,
    required this.descripcion,
    required this.servicios,
    required this.comuna,
    required this.disponibilidad,
    required this.tarifaHora,
    this.activo = true,
  });

  factory AvisoServicio.desdeMapa(String id, Map<String, dynamic> mapa) {
    return AvisoServicio(
      id: id,
      uidCuidador: mapa['uidCuidador'] ?? '',
      nombreCuidador: mapa['nombreCuidador'] ??
          '${mapa['nombre'] ?? ''} ${mapa['apellido'] ?? ''}'.trim(),
      fotoCuidador: _aTextoOpcional(mapa['fotoCuidador'] ?? mapa['fotoUrl']),
      titulo: mapa['titulo'] ?? '',
      descripcion: mapa['descripcion'] ?? '',
      servicios: _aLista(mapa['servicios'] ?? mapa['serviciosOfrecidos']),
      comuna: mapa['comuna'] ??
          _primeraComuna(mapa['comunasTrabajo'] ?? mapa['comunas']),
      disponibilidad: _aMapa(mapa['disponibilidad']),
      tarifaHora: _aDouble(mapa['tarifaHora']),
      activo: mapa['activo'] != false,
    );
  }

  //publicar un aviso nuevo
  Map<String, dynamic> toMap() {
    return {
      'uidCuidador': uidCuidador,
      'nombreCuidador': nombreCuidador,
      'fotoCuidador': fotoCuidador,
      'titulo': titulo,
      'descripcion': descripcion,
      'servicios': servicios,
      'comuna': comuna,
      'disponibilidad': disponibilidad,
      'tarifaHora': tarifaHora,
      'activo': true,
      'fechaPublicacion': FieldValue.serverTimestamp(),
    };
  }

  //editar
  Map<String, dynamic> toMapEdicion() {
    return {
      'fotoCuidador': fotoCuidador,
      'titulo': titulo,
      'descripcion': descripcion,
      'servicios': servicios,
      'disponibilidad': disponibilidad,
      'tarifaHora': tarifaHora,
      'fechaEdicion': FieldValue.serverTimestamp(),
    };
  }

  static double _aDouble(dynamic valor) {
    if (valor == null) return 0.0;
    if (valor is num) return valor.toDouble();
    if (valor is String) return double.tryParse(valor) ?? 0.0;
    return 0.0;
  }

  static List<String> _aLista(dynamic valor) {
    if (valor is List) return valor.map((e) => e.toString()).toList();
    return [];
  }

  static Map<String, dynamic> _aMapa(dynamic valor) {
    if (valor is Map) return Map<String, dynamic>.from(valor);
    return {};
  }

  static String _primeraComuna(dynamic valor) =>
      valor is List && valor.isNotEmpty ? valor.first.toString() : '';

  static String? _aTextoOpcional(dynamic valor) =>
      valor is String && valor.isNotEmpty ? valor : null;
}