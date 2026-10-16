import 'dart:async';

import 'package:flutter/foundation.dart';

import '../consultas/auth_repo.dart';
import '../consultas/solicitud_repo.dart';
import '../model/solicitud/solicitud.dart';

class DetalleSolicitudViewModel extends ChangeNotifier {
  final String idSolicitud;

  DetalleSolicitudViewModel(this.idSolicitud);

  final SolicitudRepo _solicitudRepo = SolicitudRepo();
  final AuthRepo _authRepo = AuthRepo();

  StreamSubscription<Solicitud?>? _suscripcion;

  bool cargando = true;
  String? error;
  Solicitud? solicitud;

  bool procesando = false;

  bool get esCuidador =>
      solicitud != null && solicitud!.uidCuidador == _authRepo.uidActual;

  //ssolicitud en tiempo real
  void escuchar() {
    _suscripcion = _solicitudRepo
        .solicitud(idSolicitud)
        .listen(
          (s) {
            if (s == null) {
              error = 'Esta solicitud ya no existe.';
            } else {
              solicitud = s;
              error = null;
            }
            cargando = false;
            notifyListeners();
          },
          onError: (e) {
            debugPrint('Error escuchando solicitud: $e');
            error = 'No se pudo cargar la solicitud.';
            cargando = false;
            notifyListeners();
          },
        );
  }

  //estados cuidador
  Future<void> aceptar() =>
      _ejecutar(() => _solicitudRepo.aceptar(idSolicitud));

  Future<void> rechazar({String? motivo}) =>
      _ejecutar(() => _solicitudRepo.rechazar(idSolicitud, motivo: motivo));

  Future<void> iniciarSesion(int indice) =>
      _ejecutar(() => _solicitudRepo.iniciarSesion(idSolicitud, indice));

  Future<void> finalizarSesion(int indice) =>
      _ejecutar(() => _solicitudRepo.finalizarSesion(idSolicitud, indice));

  Future<void> actualizarTarea(
    int indiceSesion,
    int indiceTarea, {
    required bool completada,
    String? comentario,
  }) => _ejecutar(
    () => _solicitudRepo.actualizarTarea(
      idSolicitud,
      indiceSesion,
      indiceTarea,
      completada: completada,
      comentario: comentario,
    ),
  );

  // pago

  Future<void> pagarGarantia() =>
      _ejecutar(() => _solicitudRepo.pagarGarantia(idSolicitud));

  Future<void> registrarPagoFinal() =>
      _ejecutar(() => _solicitudRepo.registrarPagoFinal(idSolicitud));

  Future<void> reportarImpago() =>
      _ejecutar(() => _solicitudRepo.reportarImpago(idSolicitud));

  Future<void> _ejecutar(Future<void> Function() accion) async {
    procesando = true;
    notifyListeners();
    try {
      await accion();
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    } finally {
      procesando = false;
      notifyListeners();
    }
  }

  bool _liberado = false;

  @override
  void notifyListeners() {
    if (!_liberado) super.notifyListeners();
  }

  @override
  void dispose() {
    _suscripcion?.cancel();
    _liberado = true;
    super.dispose();
  }
}