import 'dart:async';

import 'package:flutter/foundation.dart';

import '../consultas/auth_repo.dart';
import '../consultas/chat_repo.dart';
import '../consultas/solicitud_repo.dart';
import '../model/chat/mensaje.dart';
import '../model/solicitud/estado_solicitud.dart';
import '../model/solicitud/solicitud.dart';
import 'utilidades/fecha_hora.dart';

class ChatViewModel extends ChangeNotifier {
  final String idSolicitud;
  ChatViewModel(this.idSolicitud);

  final SolicitudRepo _solicitudRepo = SolicitudRepo();
  final ChatRepo _chatRepo = ChatRepo();
  final AuthRepo _authRepo = AuthRepo();

  StreamSubscription<Solicitud?>? _subSolicitud;
  StreamSubscription<List<Mensaje>>? _subMensajes;

  Solicitud? solicitud;
  List<Mensaje> mensajes = [];

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

  //mismas condiciones que PanelPago
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

  bool esMio(Mensaje m) => m.uidEmisor == uidActual;

  void escuchar() {
    _subSolicitud = _solicitudRepo.solicitud(idSolicitud).listen((s) {
      solicitud = s;
      notifyListeners();
    });

    _subMensajes = _chatRepo.mensajes(idSolicitud).listen((lista) {
      mensajes = lista;
      notifyListeners();
    }, onError: (e) => debugPrint('Error escuchando mensajes: $e'));
  }

  Future<void> enviar(String texto) async {
    final limpio = texto.trim();
    if (limpio.isEmpty) return;
    if (!puedeEscribir) throw Exception(textoBloqueo);

    await _chatRepo.enviar(
      idSolicitud,
      Mensaje(uidEmisor: uidActual, texto: limpio),
    );
  }

  @override
  void dispose() {
    _subSolicitud?.cancel();
    _subMensajes?.cancel();
    super.dispose();
  }
}
