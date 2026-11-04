import 'package:flutter/foundation.dart';

import '../model/cuidador/aviso_servicio.dart';

// test para barra busqueda en listado de avisos
class FiltroAvisos extends ChangeNotifier {
  String texto = '';

  List<AvisoServicio> aplicar(List<AvisoServicio> avisos) {
    final q = _normalizar(texto.trim());
    if (q.isEmpty) return avisos;

    return avisos.where((a) {
      final campos = _normalizar(
        [a.nombreCuidador, a.titulo, ...a.servicios].join(' '),
      );
      return campos.contains(q);
    }).toList();
  }

  static String _normalizar(String t) => t
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ñ', 'n');

  bool get hayBusqueda => texto.trim().isNotEmpty;

  void cambiarTexto(String valor) {
    texto = valor;
    notifyListeners();
  }
}