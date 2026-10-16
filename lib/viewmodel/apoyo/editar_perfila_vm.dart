import 'package:flutter/material.dart';

import '../cuenta_basica_vm.dart';
import '../../model/apoyo/completar_perfil_a1.dart';
import '../../model/apoyo/completar_perfil_a2.dart';
import '../../model/apoyo/completar_perfil_a3.dart';
import '../../model/comunas_disponibles.dart';
import '../../model/reglas_edad.dart';

class EditarPerfilAViewModel extends CuentaBasicaViewModel {
  static List<String> get comunasDisponibles => ComunasDisponibles.lista;
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

  @override
  String get carpetaFotos => 'fotos_apoyos';

  final calleController = TextEditingController();
  final numeroController = TextEditingController();
  final detallesController = TextEditingController();
  final edadFamiliarController = TextEditingController();

  String? comunaSeleccionada;
  String? relacionSeleccionada;
  String? condicionSeleccionada;
  String? dependenciaSeleccionada;

  void seleccionarComuna(String? v) {
    comunaSeleccionada = v;
    notifyListeners();
  }

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

  Future<void> cargarDatosActuales(String uid) async {
    cargando = true;
    notifyListeners();

    final perfil = await usuarioRepo.obtenerPerfilApoyo(uid);
    if (perfil != null) {
      cargarCamposBasicos(
        nombre: perfil.nombre,
        apellido: perfil.apellido,
        rut: perfil.rut,
        correo: perfil.correo,
        telefono: perfil.telefono,
        fotoPerfil: perfil.fotoPerfil,
      );
      calleController.text = perfil.calle;
      numeroController.text = perfil.numero;
      detallesController.text = perfil.detalles;
      edadFamiliarController.text = perfil.edadFamiliar;
      comunaSeleccionada = perfil.comuna;
      relacionSeleccionada = perfil.relacionFamiliar;
      condicionSeleccionada = perfil.condicionFamiliar;
      dependenciaSeleccionada = perfil.dependenciaFamiliar;
    }

    cargando = false;
    notifyListeners();
  }

  Future<String?> guardarCambios(String uid) async {
    if (comunaSeleccionada == null ||
        relacionSeleccionada == null ||
        dependenciaSeleccionada == null) {
      error = 'Completa todos los campos requeridos.';
      notifyListeners();
      return null;
    }

    final edadFamiliar = ReglasEdad.validar(edadFamiliarController.text);
    if (edadFamiliar == null) {
      error = ReglasEdad.mensajeError;
      notifyListeners();
      return null;
    }

    guardando = true;
    error = null;
    exito = null;
    notifyListeners();

    try {
      final camposBasicos = await prepararCuentaBasica(uid);

      final datos = {
        ...PerfilA1Model(
          nombre: camposBasicos['nombre'],
          apellido: camposBasicos['apellido'],
          rut: camposBasicos['rut'],
          telefono: camposBasicos['telefono'],
          fotoPerfil: camposBasicos['fotoPerfil'],
        ).toMap(),
        ...PerfilA2Model(
          comuna: comunaSeleccionada!,
          calle: calleController.text.trim(),
          numero: numeroController.text.trim(),
          detalles: detallesController.text.trim(),
        ).toMap(),
        ...PerfilA3Model(
          edad: edadFamiliar.toString(),
          relacion: relacionSeleccionada!,
          condicion: condicionSeleccionada,
          dependencia: dependenciaSeleccionada!,
        ).toMap(),
      };
      await usuarioRepo.actualizarDatos(uid, datos);

      return correoCambio ? 'correo_pendiente' : null;
    } catch (e) {
      error = e.toString().replaceAll('Exception: ', '');
      return null;
    } finally {
      guardando = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    calleController.dispose();
    numeroController.dispose();
    detallesController.dispose();
    edadFamiliarController.dispose();
    super.dispose();
  }
}
