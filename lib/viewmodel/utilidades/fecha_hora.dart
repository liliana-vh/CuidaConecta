import 'package:flutter/material.dart';

// Funciones puras de fecha/hora usadas al agendar, no dependen de estdos directamente

DateTime soloFecha(DateTime d) => DateTime(d.year, d.month, d.day);

bool mismoDia(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

DateTime combinar(DateTime fecha, TimeOfDay t) =>
    DateTime(fecha.year, fecha.month, fecha.day, t.hour, t.minute);

int? aMinutos(dynamic hhmm) {
  if (hhmm is! String) return null;
  final partes = hhmm.split(':');
  if (partes.length != 2) return null;
  final h = int.tryParse(partes[0]);
  final m = int.tryParse(partes[1]);
  return (h == null || m == null) ? null : h * 60 + m;
}

String dm(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

String hhmm(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

const _nombresDias = [
  'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo',
];

String nombreDia(DateTime d) => _nombresDias[d.weekday - 1];

DateTime lunesDe(DateTime fecha) =>
    DateTime(fecha.year, fecha.month, fecha.day - (fecha.weekday - 1));