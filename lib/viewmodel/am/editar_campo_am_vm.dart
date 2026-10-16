import 'package:flutter/material.dart';

import '../../consultas/auth_repo.dart';
import '../../consultas/usuario_repo.dart';
import '../utilidades/manejar_tecla_texto.dart';

class EditarCampoAMViewModel extends ChangeNotifier {
  final AuthRepo _authRepo = AuthRepo();
  final UsuarioRepo _usuarioRepo = UsuarioRepo();

  final String campoFirestore;
  final bool esNumerico;
  final int maxLength;
  final String? Function(String texto) validar;
  final dynamic Function(String texto) transformar;

  final TextEditingController controller = TextEditingController();

  bool guardando = false;
  String? error;

  EditarCampoAMViewModel({
    required this.campoFirestore,
    required String valorInicial,
    required this.validar,
    required this.transformar,
    this.esNumerico = false,
    this.maxLength = 40,
  }) {
    controller.text = valorInicial;
  }

  void manejarTecla(String key) {
    if (esNumerico) {
      manejarTeclaNumerica(controller, key, maxLength: maxLength);
    } else {
      manejarTeclaTexto(controller, key);
    }
  }

  Future<bool> guardar() async {
    final texto = controller.text.trim();
    final mensaje = validar(texto);
    if (mensaje != null) {
      error = mensaje;
      notifyListeners();
      return false;
    }

    guardando = true;
    error = null;
    notifyListeners();

    try {
      final uid = _authRepo.uidActual;
      if (uid == null) throw Exception('Sesión no válida.');
      await _usuarioRepo.actualizarDatos(uid, {campoFirestore: transformar(texto)});
      return true;
    } catch (e) {
      error = 'Error al guardar: ${e.toString().replaceAll('Exception: ', '')}';
      return false;
    } finally {
      guardando = false;
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
    controller.dispose();
    super.dispose();
  }
}