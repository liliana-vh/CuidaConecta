import 'package:cloud_firestore/cloud_firestore.dart';

import './reglas_servicio.dart';
import 'estado_solicitud.dart';
import 'sesion_solicitud.dart';
import '../lista_servicios.dart';
import 'tarea_realizada.dart';
import 'agenda.dart';
import '../../viewmodel/utilidades/fecha_hora.dart';

class Solicitud {
  final String id;

  final String uidCliente;
  final String tipoCliente;
  final String nombreCliente;
  final String uidCuidador;
  final String nombreCuidador;

  final String idAviso;
  final String servicio;
  final String comuna;
  final double tarifaHora;

  // Semana y sesiones
  final DateTime inicioSemana; // lunes
  final List<Sesion> sesiones;
  final String estado;

  final String metodoPago;
  final double montoEstimado;
  final double montoGarantia;
  final bool garantiaPagada;
  final DateTime fechaPago;
  final bool pagoRealizado;
  final double comisionPlataforma; // solo tarjeta, se calcula al pagar el saldo
  final bool impagoReportado;

  final String? motivo;
  final DateTime? creadaEn;

  const Solicitud({
    this.id = '',
    required this.uidCliente,
    required this.tipoCliente,
    required this.nombreCliente,
    required this.uidCuidador,
    required this.nombreCuidador,
    required this.idAviso,
    required this.servicio,
    required this.comuna,
    required this.tarifaHora,
    required this.inicioSemana,
    required this.sesiones,
    this.estado = EstadoSolicitud.pendiente,
    required this.metodoPago,
    required this.montoEstimado,
    required this.montoGarantia,
    this.garantiaPagada = false,
    required this.fechaPago,
    this.pagoRealizado = false,
    this.comisionPlataforma = 0,
    this.impagoReportado = false,
    this.motivo,
    this.creadaEn,
  });

  // calculos semana, montos y fechas pago
  factory Solicitud.nueva({
    required String uidCliente,
    required String tipoCliente,
    required String nombreCliente,
    required String uidCuidador,
    required String nombreCuidador,
    required String idAviso,
    required String servicio,
    required String comuna,
    required double tarifaHora,
    required List<Intervalo> sesiones,
    required String metodoPago,
  }) {
    final base = [...sesiones]..sort((a, b) => a.inicio.compareTo(b.inicio));
    final ordenadas = base
        .map(
          (s) => Sesion(
            inicio: s.inicio,
            fin: s.fin,
            tareas: _tareasPara(servicio),
          ),
        )
        .toList();
    final lunes = lunesDe(ordenadas.first.inicio);

    final horas = ordenadas.fold<double>(0, (suma, s) => suma + s.horas);
    final estimado = (horas * tarifaHora).roundToDouble();
    final conGarantia = metodoPago == MetodoPago.tarjeta;

    return Solicitud(
      uidCliente: uidCliente,
      tipoCliente: tipoCliente,
      nombreCliente: nombreCliente,
      uidCuidador: uidCuidador,
      nombreCuidador: nombreCuidador,
      idAviso: idAviso,
      servicio: servicio,
      comuna: comuna,
      tarifaHora: tarifaHora,
      inicioSemana: lunes,
      sesiones: ordenadas,
      metodoPago: metodoPago,
      montoEstimado: estimado,
      montoGarantia: conGarantia
          ? (estimado * ReglasServicio.porcentajeGarantia).roundToDouble()
          : 0,
      fechaPago: calcularFechaPago(metodoPago, ordenadas, lunes),
    );
  }

  static DateTime calcularFechaPago(
    String metodoPago,
    List<Sesion> sesiones,
    DateTime lunes,
  ) {
    if (metodoPago == MetodoPago.efectivo) {
      final ultima = sesiones
          .map((s) => s.inicio)
          .reduce((a, b) => a.isAfter(b) ? a : b);
      return DateTime(ultima.year, ultima.month, ultima.day);
    }
    return DateTime(lunes.year, lunes.month, lunes.day + 6);
  }

  static List<TareaRealizada> _tareasPara(String servicio) {
    final titulos = <String>[];
    final incluye = ListaServicios.incluye[servicio];
    if (incluye != null) titulos.addAll(ListaServicios.tareas[incluye] ?? []);
    titulos.addAll(ListaServicios.tareas[servicio] ?? []);
    return titulos.map((t) => TareaRealizada(titulo: t)).toList();
  }

  //consultas estado
  double get horasTotales => sesiones.fold<double>(0, (s, x) => s + x.horas);

  double get horasRealizadas => sesiones
      .where((s) => s.estado == EstadoSesion.finalizada)
      .fold<double>(0, (s, x) => s + x.horas);

  int get indiceSesionEnCurso =>
      sesiones.indexWhere((s) => s.estado == EstadoSesion.enProgreso);

  bool get haySesionEnCurso => indiceSesionEnCurso >= 0;

  bool get requiereGarantia => metodoPago == MetodoPago.tarjeta;

  bool get puedePagarFinal =>
      estado == EstadoSolicitud.finalizada && !pagoRealizado;

  //pago vencido solo aplica a metodo tarjeta, dia maximo domingos x semana (agregar metodo efectivo??)
  bool get pagoVencido {
    if (metodoPago != MetodoPago.tarjeta) return false;
    if (pagoRealizado) return false;
    final finDelDomingo = DateTime(
      fechaPago.year,
      fechaPago.month,
      fechaPago.day,
      23,
      59,
      59,
    );
    return DateTime.now().isAfter(finDelDomingo);
  }

  //cosa para lo de futuro plan de costos, por ahora comision 10% nomas?
  double calcularComision() => metodoPago == MetodoPago.tarjeta
      ? (montoEstimado * ReglasServicio.porcentajeComision).roundToDouble()
      : 0;

  Sesion? get proximaSesion {
    final ahora = DateTime.now();
    final futuras =
        sesiones
            .where(
              (s) => s.estado == EstadoSesion.pendiente && s.fin.isAfter(ahora),
            )
            .toList()
          ..sort((a, b) => a.inicio.compareTo(b.inicio));
    return futuras.isEmpty ? null : futuras.first;
  }

  String? motivoNoPuedeIniciar(int indice, DateTime ahora) {
    if (estado != EstadoSolicitud.aceptada &&
        estado != EstadoSolicitud.enProgreso) {
      return 'La solicitud no está aceptada.';
    }
    if (indice < 0 || indice >= sesiones.length) return 'Sesión inválida.';
    if (haySesionEnCurso) return 'Ya hay una sesión en curso.';

    final sesion = sesiones[indice];
    if (sesion.estado != EstadoSesion.pendiente) {
      return 'Esta sesión ya fue iniciada.';
    }
    if (requiereGarantia && !garantiaPagada) {
      return 'Falta el pago de la garantía inicial.';
    }
   //eliminar en presentacion final el modopruebas o no?? limite es de 24 hrs antes PREGUNTAR PROFE 
    if (!ReglasServicio.modoPruebas) {
      final mismoDia =
          ahora.year == sesion.inicio.year &&
          ahora.month == sesion.inicio.month &&
          ahora.day == sesion.inicio.day;
      if (!mismoDia) return 'Solo se puede iniciar el día de la sesión.';
    }
    return null;
  }

  String get textoPago {
    final dia = '${nombreDia(fechaPago)} ${dm(fechaPago)}';
    return requiereGarantia
        ? 'Pago semanal: la garantía se paga cuando el cuidador acepte, y el saldo el $dia.'
        : 'Pago semanal en efectivo: se paga el último día de servicio ($dia).';
  }

//para firestore (separar en otro model o aqui nomas?)
  factory Solicitud.desdeMapa(String id, Map<String, dynamic> mapa) {
    return Solicitud(
      id: id,
      uidCliente: mapa['uidCliente'] ?? '',
      tipoCliente: mapa['tipoCliente'] ?? '',
      nombreCliente: mapa['nombreCliente'] ?? '',
      uidCuidador: mapa['uidCuidador'] ?? '',
      nombreCuidador: mapa['nombreCuidador'] ?? '',
      idAviso: mapa['idAviso'] ?? '',
      servicio: mapa['servicio'] ?? '',
      comuna: mapa['comuna'] ?? '',
      tarifaHora: (mapa['tarifaHora'] as num?)?.toDouble() ?? 0,
      inicioSemana: (mapa['inicioSemana'] as Timestamp).toDate(),
      sesiones: ((mapa['sesiones'] as List?) ?? [])
          .map((s) => Sesion.desdeMapa(Map<String, dynamic>.from(s as Map)))
          .toList(),
      estado: mapa['estado'] ?? EstadoSolicitud.pendiente,
      metodoPago: mapa['metodoPago'] ?? MetodoPago.efectivo,
      montoEstimado: (mapa['montoEstimado'] as num?)?.toDouble() ?? 0,
      montoGarantia: (mapa['montoGarantia'] as num?)?.toDouble() ?? 0,
      garantiaPagada: mapa['garantiaPagada'] ?? false,
      fechaPago: (mapa['fechaPago'] as Timestamp).toDate(),
      pagoRealizado: mapa['pagoRealizado'] ?? false,
      comisionPlataforma: (mapa['comisionPlataforma'] as num?)?.toDouble() ?? 0,
      impagoReportado: mapa['impagoReportado'] ?? false,
      motivo: mapa['motivo'] as String?,
      creadaEn: (mapa['creadaEn'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uidCliente': uidCliente,
      'tipoCliente': tipoCliente,
      'nombreCliente': nombreCliente,
      'uidCuidador': uidCuidador,
      'nombreCuidador': nombreCuidador,
      'idAviso': idAviso,
      'servicio': servicio,
      'comuna': comuna,
      'tarifaHora': tarifaHora,
      'inicioSemana': Timestamp.fromDate(inicioSemana),
      'sesiones': sesiones.map((s) => s.toMap()).toList(),
      'estado': estado,
      'metodoPago': metodoPago,
      'montoEstimado': montoEstimado,
      'montoGarantia': montoGarantia,
      'garantiaPagada': garantiaPagada,
      'fechaPago': Timestamp.fromDate(fechaPago),
      'pagoRealizado': pagoRealizado,
      'comisionPlataforma': comisionPlataforma,
      'impagoReportado': impagoReportado,
      'creadaEn': FieldValue.serverTimestamp(),
    };
  }
}
