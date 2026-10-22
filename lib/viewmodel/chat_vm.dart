import 'dart:async';
import 'package:flutter/foundation.dart';

import '../consultas/auth_repo.dart';
import '../consultas/solicitud_repo.dart';
import '../model/chat/mensaje.dart';
import '../model/solicitud/solicitud.dart';
import '../model/solicitud/estado_solicitud.dart';
import 'utilidades/fecha_hora.dart';

class ChatViewModel extends ChangeNotifier {
  final String idSolicitud;
  ChatViewModel(this.idSolicitud);

  final SolicitudRepo _solicitudRepo = SolicitudRepo();
  final AuthRepo _authRepo = AuthRepo();
  StreamSubscription<Solicitud?>? _suscripcion;

  Solicitud? solicitud;

  String get uidActual => _authRepo.uidActual ?? '';

  bool get esCuidador =>
      solicitud != null && solicitud!.uidCuidador == uidActual;

  String get nombreOtro => solicitud == null
      ? 'Chat'
      : (esCuidador ? solicitud!.nombreCliente : solicitud!.nombreCuidador);

  bool get puedeEscribir => solicitud?.chatActivo ?? false;

  String get textoBloqueo {
    if (solicitud?.estado == EstadoSolicitud.finalizada) {
      return 'El servicio finalizó, el chat quedó cerrado.';
    }
    return 'El chat se activa cuando el cuidador inicia el servicio del día.';
  }

  String? get avisoEstado {
    final s = solicitud;
    if (s == null || !s.haySesionEnCurso) return null;
    final inicio = s.sesiones[s.indiceSesionEnCurso].inicioReal;
    return inicio == null
        ? 'Servicio en progreso.'
        : 'Servicio en progreso desde las ${hhmm(inicio)}.';
  }

  //mismas condiciones que PanelPago, cambiar despues a mas oficial
  String? get avisoPago {
    final s = solicitud;
    if (s == null) return null;

    if (s.requiereGarantia &&
        s.estado == EstadoSolicitud.aceptada &&
        !s.garantiaPagada) {
      return esCuidador
          ? 'Esperando que el cliente pague la garantía inicial.'
          : 'Debes pagar la garantía inicial para poder comenzar el servicio.';
    }

    if (s.puedePagarFinal && s.metodoPago == MetodoPago.tarjeta) {
      final dia = '${nombreDia(s.fechaPago)} ${dm(s.fechaPago)}';
      return esCuidador
          ? 'Esperando el pago final del cliente (máximo el $dia).'
          : 'El servicio terminó. Puedes pagar el saldo hasta el $dia.';
    }
    return null;
  }

  String get rutaDetalle => esCuidador
      ? '/cuidador/detalle-solicitud/$idSolicitud'
      : '/apoyo/detalle-solicitud/$idSolicitud';

  //cambiar por mensajes reales en firestore despues
  List<Mensaje> get mensajes => [
    const Mensaje(uidEmisor: 'otro', texto: 'test mensaje 1'),
    Mensaje(uidEmisor: uidActual, texto: 'test mensaje 2'),
  ];

  void escuchar() {
    _suscripcion = _solicitudRepo.solicitud(idSolicitud).listen((s) {
      solicitud = s;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _suscripcion?.cancel();
    super.dispose();
  }
}
