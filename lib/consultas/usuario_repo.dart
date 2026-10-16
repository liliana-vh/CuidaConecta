import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/am/registro_am.dart';
import '../model/autenticacion/registro_ca.dart';
import '../model/apoyo/perfil_a.dart';
import '../model/cuidador/perfil_cuidador.dart';
import '../model/identidad_usuario.dart';

class UsuarioRepo {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // AYUDANTES INTERNOS ////////////////////////////////////////////////////

  /// Primer usuario cuyo [campo] vale [valor], o null si no hay ninguno.
  Future<QueryDocumentSnapshot<Map<String, dynamic>>?> _primeroConCampo(
    String campo,
    String valor,
  ) async {
    final resultado = await _db
        .collection('usuarios')
        .where(campo, isEqualTo: valor)
        .limit(1)
        .get();
    return resultado.docs.isEmpty ? null : resultado.docs.first;
  }

  Future<bool> _existeCampo(String campo, String valor) async {
    return await _primeroConCampo(campo, valor) != null;
  }

  /// true si nadie más (distinto de [uidActual]) usa ese valor.
  Future<bool> _campoDisponible(
    String campo,
    String valor,
    String uidActual,
  ) async {
    final doc = await _primeroConCampo(campo, valor);
    return doc == null || doc.id == uidActual;
  }

  Future<Map<String, dynamic>?> _datosDe(String uid) async {
    final doc = await _db.collection('usuarios').doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  // COMPARTIDO ////////////////////////////////////////////////////////////

  Future<bool> existeUsuario(String uid) async {
    final doc = await _db.collection('usuarios').doc(uid).get();
    return doc.exists;
  }

  Future<void> crearUsuario(String uid, Map<String, dynamic> datos) async {
    await _db.collection('usuarios').doc(uid).set(datos);
  }

  Future<void> actualizarDatos(String uid, Map<String, dynamic> datos) async {
    await _db
        .collection('usuarios')
        .doc(uid)
        .set(datos, SetOptions(merge: true));
  }

  // Registro: ¿ya existe en cualquier tipo de usuario?
  Future<bool> existeRut(String rut) => _existeCampo('rut', rut);
  Future<bool> existeCorreo(String correo) => _existeCampo('correo', correo);
  Future<bool> existeTelefono(String telefono) =>
      _existeCampo('telefono', telefono);

  // Edición de perfil: ¿lo usa alguien más aparte de mí?
  Future<bool> rutDisponible(String rut, String uidActual) =>
      _campoDisponible('rut', rut, uidActual);
  Future<bool> correoDisponible(String correo, String uidActual) =>
      _campoDisponible('correo', correo, uidActual);
  Future<bool> telefonoDisponible(String telefono, String uidActual) =>
      _campoDisponible('telefono', telefono, uidActual);

  /// Nombre completo y tipo de usuario (quién contrata o atiende un aviso).
  Future<IdentidadUsuario?> obtenerIdentidad(String uid) async {
    final datos = await _datosDe(uid);
    if (datos == null) return null;

    final nombre = '${datos['nombre'] ?? ''} ${datos['apellido'] ?? ''}'.trim();
    return IdentidadUsuario(
      nombre: nombre.isEmpty ? 'Usuario' : nombre,
      tipoUsuario: datos['tipoUsuario'] ?? '',
    );
  }

  // SOLO ADULTO MAYOR /////////////////////////////////////////////////////

  Future<AdultoMayorModel?> obtenerUsuarioAM(String uid) async {
    final datos = await _datosDe(uid);
    return datos == null ? null : AdultoMayorModel.desdeMapa(datos);
  }

  // Requiere índice compuesto en Firestore: rut + tipoUsuario
  Future<AdultoMayorModel?> buscarPorRutYTipo(
    String rut,
    String tipoUsuario,
  ) async {
    final resultado = await _db
        .collection('usuarios')
        .where('tipoUsuario', isEqualTo: tipoUsuario)
        .where('rut', isEqualTo: rut)
        .limit(1)
        .get();

    if (resultado.docs.isEmpty) return null;
    return AdultoMayorModel.desdeMapa(resultado.docs.first.data());
  }

  // SOLO CUIDADOR / APOYO /////////////////////////////////////////////////

  Future<CuidadorApoyoModel?> obtenerUsuarioCA(String uid) async {
    final datos = await _datosDe(uid);
    return datos == null ? null : CuidadorApoyoModel.desdeMapa(datos);
  }

  Future<PerfilApoyoModel?> obtenerPerfilApoyo(String uid) async {
    final datos = await _datosDe(uid);
    return datos == null ? null : PerfilApoyoModel.desdeMapa(datos);
  }

  Future<PerfilCuidadorModel?> obtenerPerfilCuidador(String uid) async {
    final datos = await _datosDe(uid);
    return datos == null ? null : PerfilCuidadorModel.desdeMapa(datos);
  }
}