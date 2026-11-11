import 'package:cloud_firestore/cloud_firestore.dart';

import 'streams_sesion.dart';
import '../model/solicitud/comprobante.dart';

//los comprobantes viven en una subcoleccion de la solicitud: ( solicitudes/{idSolicitud}/comprobantes/{idComprobante} )
class ComprobanteRepo {
  CollectionReference<Map<String, dynamic>> _comprobantes(String idSolicitud) =>
      FirebaseFirestore.instance
          .collection('solicitudes')
          .doc(idSolicitud)
          .collection('comprobantes');

  Stream<List<Comprobante>> comprobantes(String idSolicitud) {
    return _comprobantes(idSolicitud)
        .orderBy('creadoEn')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((d) => Comprobante.desdeMapa(d.id, d.data()))
              .toList(),
        )
        .hastaCerrarSesion();
  }
}