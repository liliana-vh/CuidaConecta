import './reglas_servicio.dart';
import 'sesion_solicitud.dart';
import '../../viewmodel/utilidades/fecha_hora.dart';

class Intervalo {
  final DateTime inicio;
  final DateTime fin;

  const Intervalo(this.inicio, this.fin);

  int get minutos => fin.difference(inicio).inMinutes;
  int get horas => minutos ~/ 60;

}

// horas ocupadas y libres agenda cuidador
class Agenda {
  final List<Sesion> ocupadas;

  const Agenda(this.ocupadas);

  static const Duration _separacion = Duration(
    minutes: ReglasServicio.separacionMinimaMinutos,
  );

  bool hayConflicto(DateTime inicio, DateTime fin) {
    for (final s in ocupadas) {
      if (inicio.isBefore(s.fin.add(_separacion)) &&
          fin.add(_separacion).isAfter(s.inicio)) {
        return true;
      }
    }
    return false;
  }

  List<Intervalo> ocupadasEl(DateTime fecha) => ocupadas
    .where((s) => mismoDia(s.inicio, fecha))
    .map((s) => Intervalo(s.inicio, s.fin))
    .toList()
  ..sort((a, b) => a.inicio.compareTo(b.inicio));

  // Franjas donde cabe una sesion completa dentro de la ventana tiempo
  List<Intervalo> franjasLibres(
    DateTime ventanaInicio,
    DateTime ventanaFin, {
    int minMinutos = 0,
    
  }) {
    var libres = <Intervalo>[Intervalo(ventanaInicio, ventanaFin)];

    for (final s in ocupadas) {
      final bloqueoInicio = s.inicio.subtract(_separacion);
      final bloqueoFin = s.fin.add(_separacion);
      final nuevas = <Intervalo>[];

      for (final l in libres) {
        final sinChoque =
            !bloqueoFin.isAfter(l.inicio) || !bloqueoInicio.isBefore(l.fin);
        if (sinChoque) {
          nuevas.add(l);
          continue;
        }
        if (l.inicio.isBefore(bloqueoInicio)) {
          nuevas.add(Intervalo(l.inicio, bloqueoInicio));
        }
        if (bloqueoFin.isBefore(l.fin)) {
          nuevas.add(Intervalo(bloqueoFin, l.fin));
        }
      }
      libres = nuevas;
    }

    return libres.where((i) => i.minutos >= minMinutos).toList();
  }
}