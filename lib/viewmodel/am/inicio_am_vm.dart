import '../../consultas/auth_repo.dart';
import '../../consultas/usuario_repo.dart';

class InicioAMViewModel {
  final AuthRepo _authRepo = AuthRepo();
  final UsuarioRepo _usuarioRepo = UsuarioRepo();

  Future<String> obtenerNombrePila() async {
    final uid = _authRepo.uidActual;
    if (uid == null) return '';

    try {
      final usuario = await _usuarioRepo.obtenerUsuarioAM(uid);
      final nombre = usuario?.nombre.trim() ?? '';
      return nombre.isEmpty ? '' : nombre.split(' ').first;
    } catch (_) {
      return '';
    }
  }

  Future<void> cerrarSesion() => _authRepo.cerrarSesion();
}