import 'package:cloud_firestore/cloud_firestore.dart';

class TipoComprobante {
  static const String garantia = 'garantia';
  static const String saldoFinal = 'saldo_final';
  static const String pagoEfectivo = 'pago_efectivo';
}

//documento dentro de solicitudes/{idSolicitud}/comprobantes
class Comprobante {
  final String id;
  final String tipo;
  final double monto;
  final double comision;
  final String metodoPago;
  final String uidRegistrador;
  final DateTime? creadoEn;

  const Comprobante({
    this.id = '',
    required this.tipo,
    required this.monto,
    this.comision = 0,
    required this.metodoPago,
    required this.uidRegistrador,
    this.creadoEn,
  });

  String get numero =>
      id.length < 8 ? id : 'CC-${id.substring(0, 8).toUpperCase()}';

  String get titulo {
    if (tipo == TipoComprobante.garantia) return 'Garantía inicial';
    if (tipo == TipoComprobante.saldoFinal) return 'Pago final (saldo)';
    return 'Pago en efectivo';
  }

  factory Comprobante.desdeMapa(String id, Map<String, dynamic> mapa) {
    return Comprobante(
      id: id,
      tipo: mapa['tipo'] ?? '',
      monto: (mapa['monto'] as num?)?.toDouble() ?? 0,
      comision: (mapa['comision'] as num?)?.toDouble() ?? 0,
      metodoPago: mapa['metodoPago'] ?? '',
      uidRegistrador: mapa['uidRegistrador'] ?? '',
      creadoEn: (mapa['creadoEn'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tipo': tipo,
      'monto': monto,
      'comision': comision,
      'metodoPago': metodoPago,
      'uidRegistrador': uidRegistrador,
      'creadoEn': FieldValue.serverTimestamp(),
    };
  }
}
