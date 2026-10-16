import 'dart:math' as math;
import '../../viewmodel/utilidades/fecha_hora.dart';
import 'package:flutter/material.dart' show TimeOfDay;

import '../cuidador/aviso_servicio.dart';
import 'agenda.dart';
import 'reglas_servicio.dart';
import 'sesion_solicitud.dart';

//datos necesarios para agenda en 1 dia
class DiaAgenda {
  final DateTime fecha;
  final String? bloqueo; 
  final bool ofrecidoPorCuidador;
  final List<Intervalo> libres;
  final List<Intervalo> ocupados;
  final Intervalo? seleccion; 
  final String? error; 

  const DiaAgenda({
    required this.fecha,
    required this.bloqueo,
    required this.ofrecidoPorCuidador,
    required this.libres,
    required this.ocupados,
    required this.seleccion,
    required this.error,
  });

  String get nombre => nombreDia(fecha);
  bool get habilitado => bloqueo == null;
  bool get seleccionado => seleccion != null;
}

// REGLAS AGENDAS SEMANA
//  1. no se puede fuera horario cuidador
//  2. no choca con otra reserva del cuidador (separar x 30 mins).
//  3. See pide con 24 h de anticipación (modopruebas false).
//  4. cliente no tiene otro servicio mismo dia
//  5. min 2 dias max 7 dias x semana
class AgendaSemanal {
  AgendaSemanal({
    required AvisoServicio aviso,
    required List<Sesion> reservasDelCuidador,
    required List<Sesion> sesionesDelCliente,
  }) {
    actualizarDatos(
      aviso: aviso,
      reservasDelCuidador: reservasDelCuidador,
      sesionesDelCliente: sesionesDelCliente,
    );
  }

  late AvisoServicio aviso;
  late Agenda _agenda;
  late Set<DateTime> _diasDelCliente;

  DateTime lunes = lunesDe(DateTime.now());
  final Map<DateTime, Intervalo> _elegidas = {};

  void actualizarDatos({
    required AvisoServicio aviso,
    required List<Sesion> reservasDelCuidador,
    required List<Sesion> sesionesDelCliente,
  }) {
    this.aviso = aviso;
    _agenda = Agenda(reservasDelCuidador);
    _diasDelCliente = sesionesDelCliente.map((s) => soloFecha(s.inicio)).toSet();
  }

  // opciones semanas
  static List<DateTime> get proximasSemanas {
    final hoy = lunesDe(DateTime.now());
    return List.generate(4, (i) => DateTime(hoy.year, hoy.month, hoy.day + 7 * i));
  }

  static String etiquetaSemana(DateTime lunes) {
    final domingo = DateTime(lunes.year, lunes.month, lunes.day + 6);
    return 'Semana del ${dm(lunes)} al ${dm(domingo)}';
  }

  static List<int> get opcionesHoras => List.generate(
        ReglasServicio.maxHorasPorSesion - ReglasServicio.minHorasPorSesion + 1,
        (i) => ReglasServicio.minHorasPorSesion + i,
      );

  List<DiaAgenda> get dias => List.generate(7, (i) {
        final fecha = DateTime(lunes.year, lunes.month, lunes.day + i);
        final elegida = _elegidas[fecha];
        return DiaAgenda(
          fecha: fecha,
          bloqueo: _motivoBloqueo(fecha),
          ofrecidoPorCuidador: _horario(fecha) != null,
          libres: _libres(fecha),
          ocupados: _agenda.ocupadasEl(fecha),
          seleccion: elegida,
          error: elegida == null ? null : _errorDeSesion(elegida),
        );
      });

  List<Intervalo> get sesiones => _elegidas.values.toList();



  void cambiarSemana(DateTime nuevoLunes) {
    lunes = nuevoLunes;
    _elegidas.clear();
  }

  void alternar(DateTime fecha, bool activo) {
    if (!activo) {
      _elegidas.remove(fecha);
    } else if (_motivoBloqueo(fecha) == null) {
      final inicio = _libres(fecha).first.inicio;
      _elegidas[fecha] = _sesion(inicio, ReglasServicio.minHorasPorSesion);
    }
  }

  void fijarInicio(DateTime fecha, TimeOfDay hora) {
    final actual = _elegidas[fecha];
    if (actual != null) _elegidas[fecha] = _sesion(combinar(fecha, hora), actual.horas);
  }

  void fijarHoras(DateTime fecha, int horas) {
    final actual = _elegidas[fecha];
    if (actual != null) _elegidas[fecha] = _sesion(actual.inicio, horas);
  }

  Intervalo _sesion(DateTime inicio, int horas) =>
      Intervalo(inicio, inicio.add(Duration(hours: horas)));

  // reglas

  String? errorDeSolicitud(String? servicio) {
    if (servicio == null) return 'Seleccione un servicio.';

    if (_elegidas.length < ReglasServicio.minDiasPorSemana ||
        _elegidas.length > ReglasServicio.maxDiasPorSemana) {
      return 'Elija entre ${ReglasServicio.minDiasPorSemana} y '
          '${ReglasServicio.maxDiasPorSemana} días de la semana.';
    }

    for (final e in _elegidas.entries) {
      final error = _errorDeSesion(e.value);
      if (error != null) return '${nombreDia(e.key)}: $error';
    }
    return null;
  }

  /// Reglas 1, 2 y 3 sobre una sesión puntual.
  String? _errorDeSesion(Intervalo s) {
    final h = _horario(soloFecha(s.inicio));
    if (h == null) return 'El cuidador no atiende este día.';

    if (s.inicio.isBefore(h.inicio) || s.fin.isAfter(h.fin)) {
      return 'Fuera del horario del cuidador (${hhmm(h.inicio)} a ${hhmm(h.fin)}).';
    }
    if (!ReglasServicio.modoPruebas && s.inicio.isBefore(_inicioMinimo)) {
      return 'Debe pedirse con al menos '
          '${ReglasServicio.anticipacionMinimaHoras} horas de anticipación.';
    }
    if (_agenda.hayConflicto(s.inicio, s.fin)) {
      return 'El cuidador ya tiene una reserva en ese horario '
          '(se necesitan ${ReglasServicio.separacionMinimaMinutos} minutos libres entre servicios).';
    }
    return null;
  }

  /// Regla 4 disponibilidad
  String? _motivoBloqueo(DateTime fecha) {
    if (fecha.isBefore(soloFecha(DateTime.now()))) return 'Fecha pasada';
    if (_horario(fecha) == null) return 'El cuidador no atiende este día';
    if (_diasDelCliente.contains(fecha)) return 'Ya tiene un servicio contratado este día';
    if (_libres(fecha).isEmpty) return 'Sin horarios libres';
    return null;
  }

  /// horario del dia cuidador
  Intervalo? _horario(DateTime fecha) {
    final franja = aviso.disponibilidad[nombreDia(fecha)];
    if (franja is! Map) return null;

    final ini = aMinutos(franja['inicio']);
    final fin = aMinutos(franja['fin']);
    if (ini == null || fin == null) return null;

    final desde = math.max(
      ini,
      ReglasServicio.horaMinima.hour * 60 + ReglasServicio.horaMinima.minute,
    );
    final hasta = math.min(
      fin,
      ReglasServicio.horaMaxima.hour * 60 + ReglasServicio.horaMaxima.minute,
    );
    if (hasta <= desde) return null;

    return Intervalo(
      DateTime(fecha.year, fecha.month, fecha.day, 0, desde),
      DateTime(fecha.year, fecha.month, fecha.day, 0, hasta),
    );
  }

  /// tiempos libres para agendae
  List<Intervalo> _libres(DateTime fecha) {
    final h = _horario(fecha);
    if (h == null) return [];

    final minimo = ReglasServicio.modoPruebas ? h.inicio : _inicioMinimo;
    final desde = minimo.isAfter(h.inicio) ? minimo : h.inicio;
    if (!desde.isBefore(h.fin)) return [];

    return _agenda.franjasLibres(
      desde,
      h.fin,
      minMinutos: ReglasServicio.minHorasPorSesion * 60,
    );
  }

  DateTime get _inicioMinimo {
    final d = DateTime.now().add(
      const Duration(hours: ReglasServicio.anticipacionMinimaHoras),
    );
    final base = DateTime(d.year, d.month, d.day, d.hour, d.minute);
    final exacto = d.second == 0 && d.millisecond == 0 && d.microsecond == 0;
    final resto = d.minute % 30;
    if (resto == 0 && exacto) return base;
    return base.add(Duration(minutes: 30 - resto));
  }
}