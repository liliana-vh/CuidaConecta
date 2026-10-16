import 'package:flutter/material.dart';

import '../consultas/auth_repo.dart';
import '../consultas/cuenta_repo.dart';

abstract class PerfilVerViewModel<T> extends ChangeNotifier {
  final AuthRepo authRepo = AuthRepo();
  final CuentaRepo _cuentaRepo = CuentaRepo();

  T? perfil;
  bool cargando = true;
  bool enviandoContrasena = false;
  String? error;
  String? mensajeExito;

  String? get uidActual => authRepo.uidActual;

  Future<T?> obtenerPerfil(String uid);

  String obtenerCorreo(T perfil);

  Future<void> cargarPerfil() async {
    cargando = true;
    notifyListeners();

    final uid = authRepo.uidActual;
    perfil = uid == null ? null : await obtenerPerfil(uid);

    cargando = false;
    notifyListeners();
  }

  Future<void> cambiarContrasena() async {
    final p = perfil;
    if (p == null) return;
    final correo = obtenerCorreo(p);

    enviandoContrasena = true;
    error = null;
    mensajeExito = null;
    notifyListeners();

    try {
      await _cuentaRepo.solicitarCambioContrasena(correo);
      mensajeExito = 'Se envió un correo de recuperación a $correo';
    } catch (e) {
      error = e.toString().replaceAll('Exception: ', '');
    } finally {
      enviandoContrasena = false;
      notifyListeners();
    }
  }

  Future<void> cerrarSesion() => authRepo.cerrarSesion();

  bool _liberado = false;

  @override
  void notifyListeners() {
    if (!_liberado) super.notifyListeners();
  }

  @override
  void dispose() {
    _liberado = true;
    super.dispose();
  }
}
