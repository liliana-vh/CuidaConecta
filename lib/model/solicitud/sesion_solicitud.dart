import 'package:cloud_firestore/cloud_firestore.dart';

import 'estado_solicitud.dart';
import 'tarea_realizada.dart';

//dia individual solicitud servicio semanal
class Sesion {
  final DateTime inicio;
  final DateTime fin;
  final String estado;
  final DateTime? inicioReal;
  final DateTime? finReal;
  final List<TareaRealizada> tareas;

  const Sesion({
    required this.inicio,
    required this.fin,
    this.estado = EstadoSesion.pendiente,
    this.inicioReal,
    this.finReal,
    this.tareas = const [],
  });

  double get horas => fin.difference(inicio).inMinutes / 60;

  Sesion copiarCon({
    String? estado,
    DateTime? inicioReal,
    DateTime? finReal,
    List<TareaRealizada>? tareas,
  }) {
    return Sesion(
      inicio: inicio,
      fin: fin,
      estado: estado ?? this.estado,
      inicioReal: inicioReal ?? this.inicioReal,
      finReal: finReal ?? this.finReal,
      tareas: tareas ?? this.tareas,
    );
  }

  factory Sesion.desdeMapa(Map<String, dynamic> mapa) {
    return Sesion(
      inicio: (mapa['inicio'] as Timestamp).toDate(),
      fin: (mapa['fin'] as Timestamp).toDate(),
      estado: mapa['estado'] ?? EstadoSesion.pendiente,
      inicioReal: (mapa['inicioReal'] as Timestamp?)?.toDate(),
      finReal: (mapa['finReal'] as Timestamp?)?.toDate(),
      tareas: ((mapa['tareas'] as List?) ?? [])
          .map(
            (t) =>
                TareaRealizada.desdeMapa(Map<String, dynamic>.from(t as Map)),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'inicio': Timestamp.fromDate(inicio),
      'fin': Timestamp.fromDate(fin),
      'estado': estado,
      if (inicioReal != null) 'inicioReal': Timestamp.fromDate(inicioReal!),
      if (finReal != null) 'finReal': Timestamp.fromDate(finReal!),
      'tareas': tareas.map((t) => t.toMap()).toList(),
    };
  }
}
