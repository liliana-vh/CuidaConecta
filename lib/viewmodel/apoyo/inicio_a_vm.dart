import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../consultas/aviso_repo.dart';
import '../../model/cuidador/aviso_servicio.dart';
import '../filtro_avisos.dart';

class InicioApoyoViewModel extends ChangeNotifier {
  final AvisoRepo _avisoRepo = AvisoRepo();
  final FiltroAvisos filtro = FiltroAvisos();

  StreamSubscription<List<AvisoServicio>>? _suscripcion;

  List<AvisoServicio> _todos = [];

  bool cargando = true;
  String? error;

  InicioApoyoViewModel() {
    // cuando cambia un filtro, la pantalla se redibuja
    filtro.addListener(notifyListeners);
  }

  List<AvisoServicio> get filtrados => filtro.aplicar(_todos);

  List<String> get serviciosDisponibles => FiltroAvisos.serviciosEn(_todos);
  double get tarifaTope => FiltroAvisos.tarifaTopeEn(_todos);

  void escuchar() {
    _suscripcion = _avisoRepo.avisosActivos().listen(
      (lista) {
        _todos = lista;
        error = null;
        cargando = false;
        notifyListeners();
      },
      onError: (e) {
        debugPrint('Error escuchando avisos: $e');
        error = 'No se pudieron cargar los avisos.';
        cargando = false;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _suscripcion?.cancel();
    filtro.removeListener(notifyListeners);
    filtro.dispose();
    super.dispose();
  }
}