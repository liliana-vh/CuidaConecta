import 'package:cloud_firestore/cloud_firestore.dart';

//preparar para firestore, datos principales usuario tipo 'adulto mayor'

class AdultoMayorModel {
  final String uid;
  final String rut;
  final String tipoUsuario;
  final String telefono;
  final String nombre;
  final String apellido;
  final int? edad;
  final String comuna;
  final String calle;
  final String numero;
  final String estado;
  final bool perfilCompleto;

  AdultoMayorModel({
    required this.uid,
    required this.rut,
    required this.telefono,
    this.tipoUsuario = 'Adulto Mayor',
    this.nombre = '',
    this.apellido = '',
    this.edad,
    this.comuna = '',
    this.calle = '',
    this.numero = '',
    this.estado = 'activo',
    this.perfilCompleto = false,
  });

  /// Nombre y apellido juntos, listo para mostrar.
  String get nombreCompleto => '$nombre $apellido'.trim();

  /// Calle, número y comuna juntos, listo para mostrar. Vacío si falta algo.
  String get direccionCompleta {
    if (calle.isEmpty || numero.isEmpty || comuna.isEmpty) return '';
    return '$calle $numero, $comuna';
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'rut': rut,
      'tipoUsuario': tipoUsuario,
      'telefono': telefono,
      'nombre': nombre,
      'estado': estado,
      'perfilCompleto': perfilCompleto,
      'fechaRegistro': FieldValue.serverTimestamp(),
    };
  }

  factory AdultoMayorModel.desdeMapa(Map<String, dynamic> mapa) {
    return AdultoMayorModel(
      uid: mapa['uid'] ?? '',
      rut: mapa['rut'] ?? '',
      telefono: mapa['telefono'] ?? '',
      tipoUsuario: mapa['tipoUsuario'] ?? 'Adulto Mayor',
      nombre: mapa['nombre'] ?? '',
      apellido: mapa['apellido'] ?? '',
      edad: mapa['edad'] as int?,
      comuna: mapa['comuna'] ?? '',
      calle: mapa['calle'] ?? '',
      numero: mapa['numero'] ?? '',
      estado: mapa['estado'] ?? 'activo',
      perfilCompleto: mapa['perfilCompleto'] ?? false,
    );
  }
}