import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../consultas/auth_repo.dart';
import '../../consultas/usuario_repo.dart';
import '../../model/autenticacion/registro_ca.dart';

class RegistroCAViewModel extends ChangeNotifier {
  final AuthRepo _authRepo = AuthRepo();
  final UsuarioRepo _usuarioRepo = UsuarioRepo();

  final TextEditingController correoController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();
  final TextEditingController confirmarContrasenaController = TextEditingController();

  bool cargando = false;
  String? error;
  bool ocultarContrasena = true;
  bool ocultarConfirmarContrasena = true;

  void alternarOcultarContrasena() {
    ocultarContrasena = !ocultarContrasena;
    notifyListeners();
  }

  void alternarOcultarConfirmarContrasena() {
    ocultarConfirmarContrasena = !ocultarConfirmarContrasena;
    notifyListeners();
  }

  bool esCorreoValido(String correo) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(correo);
  }

  bool esContrasenaSegura(String contrasena) {
    return contrasena.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(contrasena) &&
        RegExp(r'[0-9]').hasMatch(contrasena);
  }

  String? validarFormulario() {
    final correo = correoController.text.trim();
    final contrasena = contrasenaController.text.trim();
    final confirmar = confirmarContrasenaController.text.trim();

    if (correo.isEmpty || contrasena.isEmpty || confirmar.isEmpty) {
      return 'Por favor, complete todos los campos.';
    }
    if (!esCorreoValido(correo)) {
      return 'El correo electrónico no tiene un formato válido.';
    }
    if (!esContrasenaSegura(contrasena)) {
      return 'La contraseña debe tener al menos 8 caracteres, una mayúscula y un número.';
    }
    if (contrasena != confirmar) {
      return 'Las contraseñas no coinciden.';
    }
    return null;
  }

  Future<bool> registrarUsuario(String tipoUsuario) async {
    final errorFormulario = validarFormulario();
    if (errorFormulario != null) {
      error = errorFormulario;
      notifyListeners();
      return false;
    }

    cargando = true;
    error = null;
    notifyListeners();

    final correo = correoController.text.trim();
    final contrasena = contrasenaController.text.trim();

    try {
      final correoExiste = await _usuarioRepo.existeCorreo(correo);
      if (correoExiste) {
        throw Exception('El correo ya está registrado.');
      }

      final credencial = await _authRepo.registrarConCorreo(
        correo: correo,
        contrasena: contrasena,
      );

      final uid = credencial.user!.uid;
      await _authRepo.enviarVerificacionCorreo();

      final nuevoUsuario = CuidadorApoyoModel(
        uid: uid,
        correo: correo,
        tipoUsuario: tipoUsuario,
      );

      await _usuarioRepo.crearUsuario(uid, nuevoUsuario.toMap());
      await _authRepo.cerrarSesion();
      return true;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          error = 'El formato del correo no es válido.';
          break;
        case 'weak-password':
          error = 'La contraseña es demasiado débil.';
          break;
        default:
          error = 'Ocurrió un error: ${e.message}';
      }
      return false;
    } catch (e) {
      error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      cargando = false;
      notifyListeners();
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
    confirmarContrasenaController.dispose();
    super.dispose();
  }
}