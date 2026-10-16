import 'package:cloud_firestore/cloud_firestore.dart';
import 'streams_sesion.dart';
import '../model/cuidador/aviso_servicio.dart';

class AvisoRepo {
  final CollectionReference<Map<String, dynamic>> _coleccion = FirebaseFirestore
      .instance
      .collection('avisos_cuidadores');

  // LECTURA EN TIEMPO REAL (Stream) ////////////////////////////////////////////////////////////////

  Stream<List<AvisoServicio>> avisosDeCuidador(String uidCuidador) {
    return _coleccion
        .where('uidCuidador', isEqualTo: uidCuidador)
        .where('activo', isEqualTo: true)
        .snapshots()
        .map(_aListaOrdenada)
        .hastaCerrarSesion();
  }

  Stream<List<AvisoServicio>> avisosActivos() {
    return _coleccion
        .where('activo', isEqualTo: true)
        .snapshots()
        .map(_aListaOrdenada)
        .hastaCerrarSesion();
  }

  Stream<List<AvisoServicio>> avisosActivosPorServicio(String servicio) {
    return _coleccion
        .where('activo', isEqualTo: true)
        .where('servicios', arrayContains: servicio)
        .snapshots()
        .map(_aListaOrdenada)
        .hastaCerrarSesion();
  }

  Future<AvisoServicio?> obtener(String idAviso) async {
    final doc = await _coleccion.doc(idAviso).get();
    if (!doc.exists) return null;
    return AvisoServicio.desdeMapa(doc.id, doc.data()!);
  }

  // ESCRITURA ////////////////////////////////////////////////////////////

  Future<String> publicar(AvisoServicio aviso) async {
    final ref = await _coleccion.add(aviso.toMap());
    return ref.id;
  }

  Future<void> actualizar(AvisoServicio aviso) {
    return _coleccion.doc(aviso.id).update(aviso.toMapEdicion());
  }

  Future<void> archivar(String idAviso) {
    return _coleccion.doc(idAviso).update({'activo': false});
  }

  // AYUDANTES ///////////////////////////////////////////////////////////

  List<AvisoServicio> _aListaOrdenada(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final ahora = DateTime.now().millisecondsSinceEpoch;
    int ms(dynamic t) => t is Timestamp ? t.millisecondsSinceEpoch : ahora;

    final docs = snapshot.docs.toList()
      ..sort(
        (a, b) => ms(
          b.data()['fechaPublicacion'],
        ).compareTo(ms(a.data()['fechaPublicacion'])),
      );

    return docs
        .map((doc) => AvisoServicio.desdeMapa(doc.id, doc.data()))
        .toList();
  }
}
