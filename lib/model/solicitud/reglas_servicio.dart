import 'package:flutter/material.dart';

class ReglasServicio {
  //true permite iniciar servicios antes de la fecha y hora acordada
  static bool modoPruebas = false;

  static const TimeOfDay horaMinima = TimeOfDay(hour: 5, minute: 0);
  static const TimeOfDay horaMaxima = TimeOfDay(hour: 22, minute: 0);
  static const int separacionMinimaMinutos = 30;

  static const int minDiasPorSemana = 2;
  static const int maxDiasPorSemana = 7;
  static const int minHorasPorSesion = 2;
  static const int maxHorasPorSesion = 8;

  static const int anticipacionMinimaHoras = 24;
  static const int limiteRespuestaHorasAntes = 12;

  static const double porcentajeGarantia = 0.20; // solo tarjeta
  static const double porcentajeComision = 0.10; // solo tarjeta
}