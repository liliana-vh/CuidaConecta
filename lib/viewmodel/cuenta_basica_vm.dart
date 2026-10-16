import 'dart:io';
import 'package:flutter/material.dart';

import '../consultas/auth_repo.dart';
import '../consultas/usuario_repo.dart';
import '../consultas/archivos_repo.dart';
import '../consultas/cuenta_repo.dart';
import 'utilidades/logica_rut.dart' as logica_rut;
import 'utilidades/logica_telefono.dart';

abstract class CuentaBasicaViewModel extends ChangeNotifier {
  final AuthRepo authRepo = AuthRepo();
  final UsuarioRepo usuarioRepo = UsuarioRepo();
  final ArchivosRepo archivoRepo = ArchivosRepo();
  final CuentaRepo _cuentaRepo = CuentaRepo();

  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidoController = TextEditingController();
  final TextEditingController rutController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();

  String? fotoActualUrl;
  File? imagenNueva;
  String correoOriginal = '';

  bool cargando = true;
  bool guardando = false;
  String? error;
  String? exito;

  String get carpetaFotos;

  void seleccionarImagen(File imagen) {
    imagenNueva = imagen;
    notifyListeners();
  }

  void cargarCamposBasicos({
    required String nombre,
    required String apellido,
    required String rut,
    required String correo,
    required String telefono,
    String? fotoPerfil,
  }) {
    nombreController.text = nombre;
    apellidoController.text = apellido;
    rutController.text = rut;
    correoController.text = correo;
    correoOriginal = correo;
        telefonoController.text = sinPrefijoChile(telefono);
    fotoActualUrl = fotoPerfil;
  }

  Future<Map<String, dynamic>> prepararCuentaBasica(String uid) async {
    final rutFormateado = logica_rut.formatearRut(rutController.text);
    if (!logica_rut.validarRut(rutFormateado)) {
      throw Exception('El RUT ingresado no es válido.');
    }

    final telefonoIngresado = telefonoController.text.trim();
    if (!telefonoValido(telefonoIngresado)) {
      throw Exception('Formato de teléfono inválido (Ej: 912345678).');
    }
    final telefonoCompleto = '+56$telefonoIngresado';

    if (!await usuarioRepo.rutDisponible(rutFormateado, uid)) {
      throw Exception('Este RUT ya está registrado con otra cuenta.');
    }
    if (!await usuarioRepo.telefonoDisponible(telefonoCompleto, uid)) {
      throw Exception('Este teléfono ya está registrado con otra cuenta.');
    }

    String? fotoUrl = fotoActualUrl;
    if (imagenNueva != null) {
      fotoUrl = await archivoRepo.subirArchivo(
        imagenNueva!,
        carpeta: carpetaFotos,
      );
    }

    return {
      'nombre': nombreController.text.trim(),
      'apellido': apellidoController.text.trim(),
      'rut': rutFormateado,
      'telefono': telefonoCompleto,
      'fotoPerfil': fotoUrl,
    };
  }

  bool get correoCambio => correoController.text.trim() != correoOriginal;

  Future<bool> confirmarCambioCorreo(
    String uid,
    String contrasenaActual,
  ) async {
    if (contrasenaActual.isEmpty) {
      error = 'Debes ingresar tu contraseña actual para cambiar el correo.';
      notifyListeners();
      return false;
    }
    try {
      await _cuentaRepo.cambiarCorreo(
        uid: uid,
        correoNuevo: correoController.text.trim(),
        contrasenaActual: contrasenaActual,
      );
      exito =
          'Revisa tu nuevo correo (${correoController.text.trim()}) para confirmar el cambio.';
      return true;
    } catch (e) {
      error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
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
    rutController.dispose();
    correoController.dispose();
    telefonoController.dispose();
    super.dispose();
  }
}
