import '../../consultas/auth_repo.dart';
import '../../consultas/usuario_repo.dart';
import '../../model/am/registro_am.dart';

class MostrarDatosAMViewModel {
  final AuthRepo _authRepo = AuthRepo();
  final UsuarioRepo _usuarioRepo = UsuarioRepo();

  Future<AdultoMayorModel?> cargarDatos() async {
    final uid = _authRepo.uidActual;
    if (uid == null) return null;
    return _usuarioRepo.obtenerUsuarioAM(uid);
  }

  Future<void> actualizarComuna(String comuna) async {
    final uid = _authRepo.uidActual;
    if (uid == null) return;
    await _usuarioRepo.actualizarDatos(uid, {'comuna': comuna});
  }
}