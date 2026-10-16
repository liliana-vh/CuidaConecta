import 'dart:io';
import 'package:flutter/material.dart';

import '../../consultas/auth_repo.dart';
import '../../consultas/usuario_repo.dart';
import '../../consultas/archivos_repo.dart';
import '../utilidades/logica_rut.dart' as logica_rut;
import '../utilidades/logica_telefono.dart';
import '../../model/cuidador/completar_perfil_c1.dart';
import '../../model/apoyo/completar_perfil_a1.dart';

class DatosPersonalesCAViewModel extends ChangeNotifier {
  final AuthRepo _authRepo = AuthRepo();
  final UsuarioRepo _usuarioRepo = UsuarioRepo();
  final ArchivosRepo _archivoRepo = ArchivosRepo();

  final String tipoUsuario;

  DatosPersonalesCAViewModel(this.tipoUsuario);

  static const List<String> nivelesEstudios = [
    'Educación media incompleta',
    'Educación media completa',
    'Técnico nivel medio',
    'Técnico nivel superior',
    'Profesional (universitario)',
    'Otro',
  ];

  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidoController = TextEditingController();
  final TextEditingController rutController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();

  String? nivelEstudios;
  File? imagenPerfil;
  String? fotoActualUrl;

  bool cargando = true;
  bool guardando = false;
  String? error;

  bool get esCuidador => tipoUsuario == 'Cuidador';

  void seleccionarImagen(File imagen) {
    imagenPerfil = imagen;
    notifyListeners();
  }

  void seleccionarNivelEstudios(String? v) {
    nivelEstudios = v;
    notifyListeners();
  }

  Future<void> cargarDatosActuales() async {
    cargando = true;
    notifyListeners();

    try {
      final uid = _authRepo.uidActual;
      if (uid == null) return;

      if (esCuidador) {
        final perfil = await _usuarioRepo.obtenerPerfilCuidador(uid);
        if (perfil != null) {
          nombreController.text = perfil.nombre;
          apellidoController.text = perfil.apellido;
          rutController.text = perfil.rut;
          telefonoController.text = sinPrefijoChile(perfil.telefono);
          nivelEstudios = perfil.nivelEstudios.isEmpty
              ? null
              : perfil.nivelEstudios;
          fotoActualUrl = perfil.fotoPerfil;
        }
      } else {
        final perfil = await _usuarioRepo.obtenerPerfilApoyo(uid);
        if (perfil != null) {
          nombreController.text = perfil.nombre;
          apellidoController.text = perfil.apellido;
          rutController.text = perfil.rut;
          telefonoController.text = sinPrefijoChile(perfil.telefono);
          fotoActualUrl = perfil.fotoPerfil;
        }
      }
    } catch (_) {
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  Future<bool> guardarPerfil() async {
    if (nombreController.text.trim().isEmpty) {
      error = 'Ingrese su Primer Nombre';
      notifyListeners();
      return false;
    }
    if (apellidoController.text.trim().isEmpty) {
      error = 'Ingrese su Primer Apellido';
      notifyListeners();
      return false;
    }
    if (esCuidador && nivelEstudios == null) {
      error = 'Selecciona tu nivel de estudios.';
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

      final rutFormateado = logica_rut.formatearRut(rutController.text);
      if (!logica_rut.validarRut(rutFormateado)) {
        throw Exception('RUT no válido.');
      }

      final telefonoIngresado = telefonoController.text.trim();
      if (!telefonoValido(telefonoIngresado)) {
        throw Exception('Formato inválido (Ej: 912345678)');
      }
      final telefonoCompleto = '+56$telefonoIngresado';

      if (!await _usuarioRepo.rutDisponible(rutFormateado, uid)) {
        throw Exception('Este RUT ya está registrado con otra cuenta.');
      }
      if (!await _usuarioRepo.telefonoDisponible(telefonoCompleto, uid)) {
        throw Exception('Este teléfono ya está registrado con otra cuenta.');
      }

      String? fotoUrl = fotoActualUrl;
      if (imagenPerfil != null) {
        fotoUrl = await _archivoRepo.subirArchivo(
          imagenPerfil!,
          carpeta: esCuidador ? 'fotos_cuidadores' : 'fotos_apoyos',
        );
      }

      final datos = esCuidador
          ? PerfilC1Model(
              nombre: nombreController.text.trim(),
              apellido: apellidoController.text.trim(),
              rut: rutFormateado,
              telefono: telefonoCompleto,
              nivelEstudios: nivelEstudios!,
              fotoPerfil: fotoUrl,
            ).toMap()
          : PerfilA1Model(
              nombre: nombreController.text.trim(),
              apellido: apellidoController.text.trim(),
              rut: rutFormateado,
              telefono: telefonoCompleto,
              fotoPerfil: fotoUrl,
            ).toMap();

      await _usuarioRepo.actualizarDatos(uid, datos);
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
    nombreController.dispose();
    apellidoController.dispose();
    rutController.dispose();
    telefonoController.dispose();
    super.dispose();
  }
}
