import 'dart:async';

import 'package:flutter/material.dart';

import '../../model/am/registro_am.dart';
import '../../consultas/auth_repo.dart';
import '../../consultas/usuario_repo.dart';
import '../utilidades/manejar_tecla_texto.dart';
import '../utilidades/logica_rut.dart' as logica_rut;

class RegistroAMViewModel extends ChangeNotifier {
  final AuthRepo _authRepo = AuthRepo();
  final UsuarioRepo _usuarioRepo = UsuarioRepo();

  final TextEditingController rutController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  String campoActivo = 'rut';

  bool codigoEnviado = false;
  bool cargando = false;
  String? error;
  String? _verificationId;

  void seleccionarCampo(String campo) {
    campoActivo = campo;
    notifyListeners();
  }

  TextEditingController get controllerActivo {
    if (codigoEnviado) return otpController;
    return campoActivo == 'rut' ? rutController : telefonoController;
  }

  void manejarTecla(String key) {
    final esRut = !codigoEnviado && campoActivo == 'rut';
    final maxLength = esRut ? 10 : (codigoEnviado ? 6 : 9);
    manejarTeclaRutONumero(
      controllerActivo,
      key,
      esRut: esRut,
      maxLength: maxLength,
    );
  }

  bool validarRut(String rut) => logica_rut.validarRut(rut);
  String formatearRut(String rut) => logica_rut.formatearRut(rut);
  String limpiarRut(String rut) => logica_rut.limpiarRut(rut);

  // solo se usan los codigos de telefonos pruebas en firebase auth
  Future<String?> enviarCodigo() async {
    cargando = true;
    error = null;
    notifyListeners();

    try {
      final rut = rutController.text.trim();
      final telefono = telefonoController.text.trim();
      final rutFormateado = formatearRut(rut);

      if (await _usuarioRepo.existeRut(rutFormateado)) {
        throw Exception('Este RUT ya está registrado.');
      }

      final telefonoCompleto = '+56$telefono';
      final telefonoExiste = await _usuarioRepo.existeTelefono(
        telefonoCompleto,
      );
      if (telefonoExiste) {
        throw Exception('Este teléfono ya está registrado con otra cuenta.');
      }

      final completer = Completer<String?>();

      await _authRepo.verificarTelefono(
        telefono: telefono,
        autoVerificado: (credential) async {
          try {
            await _authRepo.iniciarSesionConCredencial(credential);
            await guardarUsuario();
            if (!completer.isCompleted) {
              completer.complete('/am/completar-perfil/paso-1');
            }
          } catch (_) {
            if (!completer.isCompleted) {
              completer.completeError(
                Exception('No se pudo completar la verificación automática.'),
              );
            }
          }
        },
        fallo: (e) {
          if (!completer.isCompleted) {
            completer.completeError(
              Exception('Error de verificación: ${e.message}'),
            );
          }
        },
        codigoEnviado: (verId, resendToken) {
          _verificationId = verId;
          codigoEnviado = true;
          if (!completer.isCompleted) completer.complete(null);
        },
        tiempoAgotado: (verId) => _verificationId = verId,
      );

      return await completer.future;
    } catch (e) {
      error = e.toString().replaceAll('Exception: ', '');
      rethrow;
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  Future<String> verificarOTP() async {
    cargando = true;
    error = null;
    notifyListeners();

    try {
      final otp = otpController.text.trim();
      if (otp.isEmpty || _verificationId == null) {
        throw Exception('Ingrese el código recibido');
      }

      final credential = _authRepo.credencialDesdeOtp(
        verificationId: _verificationId!,
        otp: otp,
      );

      final userCred = await _authRepo.iniciarSesionConCredencial(credential);
      await guardarUsuario(userId: userCred.user!.uid);

      return '/am/completar-perfil/paso-1';
    } catch (_) {
      error = 'Código incorrecto. Intentar de nuevo.';
      rethrow;
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  Future<void> guardarUsuario({String? userId}) async {
    final uid = userId ?? _authRepo.uidActual!;
    final existe = await _usuarioRepo.existeUsuario(uid);

    if (!existe) {
      final nuevoUsuario = AdultoMayorModel(
        uid: uid,
        rut: formatearRut(rutController.text.trim()),
        telefono: '+56${telefonoController.text.trim()}',
      );
      await _usuarioRepo.crearUsuario(uid, nuevoUsuario.toMap());
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
    rutController.dispose();
    telefonoController.dispose();
    otpController.dispose();
    super.dispose();
  }
}
