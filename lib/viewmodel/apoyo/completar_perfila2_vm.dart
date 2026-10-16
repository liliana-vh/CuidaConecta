import 'package:flutter/material.dart';

import '../../consultas/auth_repo.dart';
import '../../consultas/usuario_repo.dart';
import '../../model/apoyo/completar_perfil_a2.dart';
import '../../model/comunas_disponibles.dart';

class CompletarPerfilA2ViewModel extends ChangeNotifier {
  final AuthRepo _authRepo = AuthRepo();
  final UsuarioRepo _usuarioRepo = UsuarioRepo();

  static List<String> get comunasDisponibles => ComunasDisponibles.lista;

  final TextEditingController calleController = TextEditingController();
  final TextEditingController numeroController = TextEditingController();
  final TextEditingController detallesController = TextEditingController();

  String? comunaSeleccionada;

  bool cargando = true;
  bool guardando = false;
  String? error;

  void seleccionarComuna(String? v) {
    comunaSeleccionada = v;
    notifyListeners();
  }

  Future<void> cargarDatosActuales() async {
    cargando = true;
    notifyListeners();

    try {
      final uid = _authRepo.uidActual;
      if (uid == null) return;

      final perfil = await _usuarioRepo.obtenerPerfilApoyo(uid);
      if (perfil != null) {
        comunaSeleccionada = perfil.comuna.isEmpty ? null : perfil.comuna;
        calleController.text = perfil.calle;
        numeroController.text = perfil.numero;
        detallesController.text = perfil.detalles;
      }
    } catch (_) {
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  Future<bool> guardarDireccion() async {
    if (comunaSeleccionada == null) {
      error = 'Seleccione comuna';
      notifyListeners();
      return false;
    }
    if (calleController.text.trim().isEmpty) {
      error = 'Ingrese la calle';
      notifyListeners();
      return false;
    }
    if (numeroController.text.trim().isEmpty) {
      error = 'Ingrese el número';
      notifyListeners();
      return false;
    }

    guardando = true;
    error = null;
    notifyListeners();

    try {
      final uid = _authRepo.uidActual;
      if (uid == null) {
        throw Exception('Sesión no válida. Intenta ingresar de nuevo.');
      }

      final datos = PerfilA2Model(
        comuna: comunaSeleccionada!,
        calle: calleController.text.trim(),
        numero: numeroController.text.trim(),
        detalles: detallesController.text.trim(),
      );

      await _usuarioRepo.actualizarDatos(uid, datos.toMap());
      return true;
    } catch (e) {
      error = e.toString().replaceAll('Exception: ', '');
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
    calleController.dispose();
    numeroController.dispose();
    detallesController.dispose();
    super.dispose();
  }
}