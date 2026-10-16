import 'package:flutter/material.dart';

import '../../consultas/auth_repo.dart';
import '../../consultas/usuario_repo.dart';
import '../../model/am/completar_perfilam3.dart';
import '../../model/reglas_edad.dart';

class EdadAMViewModel extends ChangeNotifier {
  final AuthRepo _authRepo = AuthRepo();
  final UsuarioRepo _usuarioRepo = UsuarioRepo();

  final TextEditingController edadController = TextEditingController();

  bool cargando = false;
  String? error;

  int? validarEdad(String edadStr) => ReglasEdad.validar(edadStr);

  Future<bool> guardarYContinuar() async {
    final edad = validarEdad(edadController.text);

    if (edad == null) {
      error =
          'INGRESAR EDAD DE ${ReglasEdad.minima} A ${ReglasEdad.maxima} AÑOS';
      notifyListeners();
      return false;
    }

    cargando = true;
    error = null;
    notifyListeners();

    try {
      final uid = _authRepo.uidActual;
      if (uid == null) {
        throw Exception('Usuario no autenticado.');
      }

      final datosPaso3 = PerfilAM3Model(edad: edad);
      await _usuarioRepo.actualizarDatos(uid, datosPaso3.toMap());
      return true;
    } catch (e) {
      error = 'Error al guardar la edad: $e';
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
    edadController.dispose();
    super.dispose();
  }
}
