import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../consultas/auth_repo.dart';
import '../../consultas/usuario_repo.dart';

class LoginCAViewModel extends ChangeNotifier {
  final AuthRepo _authRepo = AuthRepo();
  final UsuarioRepo _usuarioRepo = UsuarioRepo();

  final TextEditingController correoController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();

  bool cargando = false;
  String? error;
  bool ocultarContrasena = true;

  void alternarOcultarContrasena() {
    ocultarContrasena = !ocultarContrasena;
    notifyListeners();
  }

  Future<String?> iniciarSesion(String tipoUsuario) async {
    final correo = correoController.text.trim();
    final contrasena = contrasenaController.text.trim();

    if (correo.isEmpty || contrasena.isEmpty) {
      error = 'Por favor, completa todos los campos.';
      notifyListeners();
      return null;
    }

    cargando = true;
    error = null;
    notifyListeners();

    try {
      try {
        await _authRepo.iniciarSesionConCorreo(
          correo: correo,
          contrasena: contrasena,
        );
      } on FirebaseAuthException catch (e) {
        error = _traducirErrorAuth(e);
        return null;
      }

      if (!_authRepo.correoVerificado) {
        await _authRepo.cerrarSesion();
        error =
            'Tu correo aún no ha sido verificado. Revisa tu bandeja de entrada.';
        return null;
      }

      final uid = _authRepo.uidActual;
      if (uid == null) {
        error = 'No fue posible autenticar al usuario.';
        return null;
      }

      final usuario = await _usuarioRepo.obtenerUsuarioCA(uid);
      if (usuario == null) {
        await _authRepo.cerrarSesion();
        error = 'Usuario no encontrado en la base de datos.';
        return null;
      }

      if (usuario.tipoUsuario != tipoUsuario) {
        await _authRepo.cerrarSesion();
        error =
            'Este usuario no pertenece al tipo "$tipoUsuario". Selecciona el tipo correcto.';
        return null;
      }

      if (!usuario.perfilCompleto) {
        return tipoUsuario == 'Cuidador'
            ? '/cuidador/completar-perfil/paso-1'
            : '/apoyo/completar-perfil/paso-1';
      }

      return tipoUsuario == 'Cuidador' ? '/cuidador/inicio' : '/apoyo/inicio';
    } catch (_) {
      error = 'Ocurrió un error inesperado. Intenta nuevamente.';
      return null;
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  Future<bool> enviarCorreoRecuperacion() async {
    final correo = correoController.text.trim();
    if (correo.isEmpty) {
      error = 'Por favor, ingresa tu correo para recuperar la contraseña.';
      notifyListeners();
      return false;
    }

    try {
      await _authRepo.enviarCorreoRecuperacion(correo);
      return true;
    } on FirebaseAuthException catch (e) {
      error = 'Error al enviar correo: ${e.message}';
      notifyListeners();
      return false;
    }
  }

  String _traducirErrorAuth(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos.';
      case 'invalid-email':
        return 'El formato del correo no es válido.';
      case 'too-many-requests':
        return 'Demasiados intentos fallidos. Intenta más tarde.';
      default:
        return 'Error al iniciar sesión: ${e.message}';
    }
  }

  bool _liberado = false;

  @override
  void notifyListeners() {
    if (!_liberado) super.notifyListeners();
  }

  @override
  void dispose() {
    _liberado = true;
    correoController.dispose();
    contrasenaController.dispose();
    super.dispose();
  }
}
