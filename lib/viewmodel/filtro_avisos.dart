import 'package:flutter/foundation.dart';

import '../model/cuidador/aviso_servicio.dart';

// Filtros para listas de avisos + barra busqueda
class FiltroAvisos extends ChangeNotifier {
  String texto = '';
  String? servicio;
  String? dia;
  double? tarifaMin;
  double? tarifaMax;

  static const List<String> dias = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];

  List<AvisoServicio> aplicar(List<AvisoServicio> avisos) {
    final q = _normalizar(texto.trim());
    final s = servicio;
    final d = dia;
    final minimo = tarifaMin;
    final maximo = tarifaMax;

    return avisos.where((a) {
      if (q.isNotEmpty) {
        final campos = _normalizar(
          [a.nombreCuidador, a.titulo, ...a.servicios].join(' '),
        );
        if (!campos.contains(q)) return false;
      }
      if (s != null && !a.servicios.contains(s)) return false;
      // disponible ese día si el aviso tiene horario para él
      if (d != null && a.disponibilidad[d] is! Map) return false;
      if (minimo != null && a.tarifaHora < minimo) return false;
      if (maximo != null && a.tarifaHora > maximo) return false;
      return true;
    }).toList();
  }

  static List<String> serviciosEn(List<AvisoServicio> avisos) =>
      ({for (final a in avisos) ...a.servicios}.toList()..sort());

  static double tarifaTopeEn(List<AvisoServicio> avisos) {
    if (avisos.isEmpty) return 0;
    final maxima = avisos.fold<double>(
      0,
      (m, a) => a.tarifaHora > m ? a.tarifaHora : m,
    );
    return (maxima / 1000).ceil() * 1000.0;
  }

  static String _normalizar(String t) => t
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ñ', 'n');

  int get cantidadFiltros =>
      (servicio != null ? 1 : 0) +
      (dia != null ? 1 : 0) +
      (tarifaMin != null || tarifaMax != null ? 1 : 0);

  bool get hayBusqueda => texto.trim().isNotEmpty || cantidadFiltros > 0;

  void cambiarTexto(String valor) {
    texto = valor;
    notifyListeners();
  }

  void elegirServicio(String? valor) {
    servicio = valor;
    notifyListeners();
  }

  void elegirDia(String? valor) {
    dia = valor;
    notifyListeners();
  }

  void elegirTarifa(double desde, double hasta, double tope) {
    tarifaMin = desde <= 0 ? null : desde;
    tarifaMax = hasta >= tope ? null : hasta;
    notifyListeners();
  }

  void limpiar() {
    servicio = null;
    dia = null;
    tarifaMin = null;
    tarifaMax = null;
    notifyListeners();
  }
}
