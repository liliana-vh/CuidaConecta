import 'package:cloud_firestore/cloud_firestore.dart';

import 'streams_sesion.dart';
import '../model/chat/mensaje.dart';

class ChatRepo {
  CollectionReference<Map<String, dynamic>> _mensajes(String idSolicitud) =>
      FirebaseFirestore.instance
          .collection('solicitudes')
          .doc(idSolicitud)
          .collection('mensajes');

  Stream<List<Mensaje>> mensajes(String idSolicitud) {
    return _mensajes(idSolicitud)
        .orderBy('creadaEn')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((d) => Mensaje.desdeMapa(d.id, d.data()))
              .toList(),
        )
        .hastaCerrarSesion();
  }

  Future<void> enviar(String idSolicitud, Mensaje mensaje) async {
    await _mensajes(idSolicitud).add(mensaje.toMap());
  }
}