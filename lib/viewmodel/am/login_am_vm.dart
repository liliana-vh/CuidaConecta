import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../model/am/registro_am.dart';
import '../../consultas/auth_repo.dart';
import '../../consultas/usuario_repo.dart';
import '../utilidades/manejar_tecla_texto.dart';
import '../utilidades/logica_rut.dart' as logica_rut;

class LoginAMViewModel extends ChangeNotifier {
  final AuthRepo _authRepo = AuthRepo();
  final UsuarioRepo _usuarioRepo = UsuarioRepo();

  final TextEditingController rutController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  bool codigoEnviado = false;
  bool cargando = false;
  String? error;

  String _telefono = '';
  String? _verificationId;

  TextEditingController get controllerActivo =>
      codigoEnviado ? otpController : rutController;

  bool validarRut(String rut) => logica_rut.validarRut(rut);
  String formatearRut(String rut) => logica_rut.formatearRut(rut);
  String limpiarRut(String rut) => logica_rut.limpiarRut(rut);

  void manejarTecla(String key) {
    final esRut = !codigoEnviado;
    manejarTeclaRutONumero(
      controllerActivo,
      key,
      esRut: esRut,
      maxLength: esRut ? 10 : 6,
    );
  }

  Future<String?> pedirCodigo() async {
    cargando = true;
    error = null;
    notifyListeners();

    try {
      final rutFormateado = formatearRut(rutController.text.trim());

      final usuario = await _usuarioRepo.buscarPorRutYTipo(
        rutFormateado,
        'Adulto Mayor',
      );
      if (usuario == null) {
        throw Exception('RUT no registrado');
      }
      if (usuario.telefono.isEmpty) {
        throw Exception('No se encontró un teléfono asociado a este RUT.');
      }
      _telefono = usuario.telefono;

      final completer = Completer<String?>();

      await _authRepo.verificarTelefono(
        telefono: _telefono,
        autoVerificado: (credential) async {
          try {
            await _authRepo.iniciarSesionConCredencial(credential);
            final ruta = await _determinarRuta(rutFormateado);
            if (!completer.isCompleted) completer.complete(ruta);
          } catch (e) {
            if (!completer.isCompleted) {
              completer.completeError(
                Exception(e.toString().replaceAll('Exception: ', '')),
              );
            }
          }
        },
        fallo: (e) {
          if (!completer.isCompleted) {
            completer.completeError(
              Exception(e.message ?? 'Error de verificación telefónica'),
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
      if (_verificationId == null) {
        throw Exception('Solicitar envío de código.');
      }
      final otp = otpController.text.trim();
      if (otp.isEmpty) {
        throw Exception('Ingrese el código recibido');
      }

      final credential = _authRepo.credencialDesdeOtp(
        verificationId: _verificationId!,
        otp: otp,
      );

      try {
        await _authRepo.iniciarSesionConCredencial(credential);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'invalid-verification-code') {
          throw Exception('Código incorrecto. Intentar de nuevo.');
        }
        throw Exception('Código fallido. Intentar de nuevo.');
      }

      return await _determinarRuta(formatearRut(rutController.text.trim()));
    } catch (e) {
      error = e.toString().replaceAll('Exception: ', '');
      rethrow;
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  Future<String> _determinarRuta(String rutFormateado) async {
    final uid = _authRepo.uidActual;
    if (uid == null) {
      throw Exception('Inicio sesión fallido.');
    }

    final existe = await _usuarioRepo.existeUsuario(uid);
    if (!existe) {
      final nuevoUsuario = AdultoMayorModel(
        uid: uid,
        rut: rutFormateado,
        telefono: _telefono,
      );
      await _usuarioRepo.crearUsuario(uid, nuevoUsuario.toMap());
      return '/am/completar-perfil/paso-1';
    }

    final usuario = await _usuarioRepo.obtenerUsuarioAM(uid);
    final perfilCompleto = usuario?.perfilCompleto ?? false;
    return perfilCompleto ? '/am/inicio' : '/am/completar-perfil/paso-1';
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
    otpController.dispose();
    super.dispose();
  }
}
