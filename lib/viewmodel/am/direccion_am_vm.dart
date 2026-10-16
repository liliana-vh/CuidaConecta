import 'package:flutter/material.dart';

import '../../consultas/auth_repo.dart';
import '../../consultas/usuario_repo.dart';
import '../../model/am/completar_perfilam4.dart';
import '../../model/comunas_disponibles.dart';

class DireccionAMViewModel extends ChangeNotifier {
  final AuthRepo _authRepo = AuthRepo();
  final UsuarioRepo _usuarioRepo = UsuarioRepo();

  static List<String> get comunasDisponibles => ComunasDisponibles.lista;
  
  String? comunaSeleccionada;
  final TextEditingController calleController = TextEditingController();
  final TextEditingController numeroController = TextEditingController();

  bool cargando = false;
  String? error;

  void seleccionarComuna(String? comuna) {
    comunaSeleccionada = comuna;
    notifyListeners();
  }

  String _capitalizar(String texto) {
    final palabras = texto.trim().toLowerCase().split(' ');
    return palabras
        .where((p) => p.isNotEmpty)
        .map((p) => p[0].toUpperCase() + p.substring(1))
        .join(' ');
  }

  bool validarDireccion({
    required String? comuna,
    required String calle,
    required String numero,
  }) {
    if (comuna == null || comuna.isEmpty) return false;
    if (calle.trim().length < 3) return false;
    if (numero.trim().isEmpty) return false;
    return true;
  }

  // Valida y guarda comuna+calle+número
  Future<bool> guardarYFinalizar({
    required String comuna,
    required String calle,
    required String numero,
  }) async {
    if (!validarDireccion(comuna: comuna, calle: calle, numero: numero)) {
      error = 'ESCRIBA SU NUMERO DE HOGAR.';
      notifyListeners();
      return false;
    }

    cargando = true;
    error = null;
    notifyListeners();

    try {
      final uid = _authRepo.uidActual;
      if (uid == null) {
        throw Exception('Usuario no autenticado. Inicia sesión de nuevo.');
      }

      final datosPaso4 = PerfilAM4Model(
        comuna: comuna,
        calle: _capitalizar(calle),
        numero: numero.trim(),
      );

      await _usuarioRepo.actualizarDatos(uid, datosPaso4.toMap());
      return true;
    } catch (e) {
      error = 'Error al guardar la dirección: $e';
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
    calleController.dispose();
    numeroController.dispose();
    super.dispose();
  }
}
