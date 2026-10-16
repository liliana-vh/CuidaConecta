import 'package:flutter/material.dart';

import '../../consultas/auth_repo.dart';
import '../../consultas/usuario_repo.dart';
import '../../model/am/completar_perfilam1.dart';

class NombreApellidoAMViewModel extends ChangeNotifier {
  final AuthRepo _authRepo = AuthRepo();
  final UsuarioRepo _usuarioRepo = UsuarioRepo();

  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidoController = TextEditingController();

  bool cargando = false;
  String? error;

  String _capitalizar(String texto) {
    final palabras = texto.trim().toLowerCase().split(' ');
    return palabras
        .where((p) => p.isNotEmpty)
        .map((p) => p[0].toUpperCase() + p.substring(1))
        .join(' ');
  }

  Future<bool> guardarYContinuar({
    required String nombre,
    required String apellido,
  }) async {
    cargando = true;
    error = null;
    notifyListeners();

    try {
      final uid = _authRepo.uidActual;
      if (uid == null) {
        throw Exception('Sesión no válida. Intente ingresar de nuevo.');
      }

      final datosPaso1 = PerfilAM1Model(
        nombre: _capitalizar(nombre),
        apellido: _capitalizar(apellido),
      );

      await _usuarioRepo.actualizarDatos(uid, datosPaso1.toMap());
      return true;
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
    nombreController.dispose();
    apellidoController.dispose();
    super.dispose();
  }
}