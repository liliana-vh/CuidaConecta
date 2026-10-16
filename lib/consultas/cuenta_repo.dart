import 'auth_repo.dart';
import 'usuario_repo.dart';

class CuentaRepo {
  final AuthRepo _authRepo = AuthRepo();
  final UsuarioRepo _usuarioRepo = UsuarioRepo();

  Future<void> cambiarCorreo({
    required String uid,
    required String correoNuevo,
    required String contrasenaActual,
  }) async {
    final disponible = await _usuarioRepo.correoDisponible(correoNuevo, uid);
    if (!disponible) {
      throw Exception('Este correo ya está en uso por otra cuenta.');
    }

    await _authRepo.reautenticar(contrasenaActual);
    await _authRepo.solicitarCambioCorreo(correoNuevo);
  }

  Future<void> solicitarCambioContrasena(String correo) {
    return _authRepo.enviarCorreoRecuperacion(correo);
  }
  
}