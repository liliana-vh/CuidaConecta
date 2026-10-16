import 'package:flutter/material.dart';

import '../../consultas/auth_repo.dart';
import '../../consultas/usuario_repo.dart';
import '../../model/apoyo/completar_perfil_a3.dart';
import '../../model/reglas_edad.dart';

class CompletarPerfilA3ViewModel extends ChangeNotifier {
  final AuthRepo _authRepo = AuthRepo();
  final UsuarioRepo _usuarioRepo = UsuarioRepo();

  static const List<String> relaciones = [
    'Hijo/a',
    'Nieto/a',
    'Cónyuge',
    'Familiar',
    'Tutor legal',
    'Otro',
  ];
  static const List<String> condiciones = [
    'Movilidad reducida',
    'Problemas de memoria',
    'Condición crónica',
    'Ninguna',
  ];
  static const List<String> nivelesDependencia = [
    'Leve (Autónomo)',
    'Moderada (Requiere ayuda puntual)',
    'Severa (Dependencia total)',
  ];

  final TextEditingController edadController = TextEditingController();

  String? relacionSeleccionada;
  String? condicionSeleccionada;
  String? dependenciaSeleccionada;

  bool cargando = true;
  bool guardando = false;
  String? error;

  void seleccionarRelacion(String? v) {
    relacionSeleccionada = v;
    notifyListeners();
  }

  void seleccionarCondicion(String? v) {
    condicionSeleccionada = v;
    notifyListeners();
  }

  void seleccionarDependencia(String? v) {
    dependenciaSeleccionada = v;
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
        edadController.text = perfil.edadFamiliar;
        relacionSeleccionada = perfil.relacionFamiliar.isEmpty
            ? null
            : perfil.relacionFamiliar;
        condicionSeleccionada = perfil.condicionFamiliar;
        dependenciaSeleccionada = perfil.dependenciaFamiliar.isEmpty
            ? null
            : perfil.dependenciaFamiliar;
      }
    } catch (_) {
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  bool validarDatos({
    required String edad,
    required String? relacion,
    required String? dependencia,
  }) {
    if (edad.trim().isEmpty) return false;
    if (relacion == null) return false;
    if (dependencia == null) return false;
    return true;
  }

  Future<bool> guardarYFinalizar() async {
    final edad = ReglasEdad.validar(edadController.text);

    if (edad == null) {
      error = ReglasEdad.mensajeError;
      notifyListeners();
      return false;
    }
    if (relacionSeleccionada == null) {
      error = 'Seleccione una opción';
      notifyListeners();
      return false;
    }
    if (dependenciaSeleccionada == null) {
      error = 'Selecciona el nivel de autonomía';
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

      final datos = PerfilA3Model(
        edad: edad.toString(),
        relacion: relacionSeleccionada!,
        condicion: condicionSeleccionada,
        dependencia: dependenciaSeleccionada!,
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
    edadController.dispose();
    super.dispose();
  }
}
