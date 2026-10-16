import 'dart:io';
import 'package:flutter/material.dart';

import '../../consultas/auth_repo.dart';
import '../../consultas/usuario_repo.dart';
import '../../consultas/archivos_repo.dart';
import '../../model/cuidador/completar_perfil_c2.dart';
import '../../model/lista_servicios.dart';
import '../../model/comunas_disponibles.dart';

class CompletarPerfilC2ViewModel extends ChangeNotifier {
  final AuthRepo _authRepo = AuthRepo();
  final UsuarioRepo _usuarioRepo = UsuarioRepo();
  final ArchivosRepo _archivoRepo = ArchivosRepo();

  static List<String> get comunasDisponibles => ComunasDisponibles.lista;
  static const List<String> experiencias = ['0-1', '1-3', '3-5', '5+'];
  static const List<String> formaciones = [
    'Sin formación formal',
    'Curso básico de cuidado de personas mayores',
    'Certificación como cuidador de personas mayores',
    'Técnico en Enfermería (TENS)',
  ];

  static List<String> get serviciosDisponibles => ListaServicios.nombres;
  static Map<String, String> get descripcionServicios =>
      ListaServicios.descripciones;

  final TextEditingController descripcionController = TextEditingController();

  String? experienciaSeleccionada;
  String? formacionSeleccionada;
  String? comunaSeleccionada;
  File? archivoAntecedentesPDF;
  String? _pdfActualUrl;
  List<String> serviciosSeleccionados = [];

  bool cargando = true;
  bool guardando = false;
  String? error;

  String? get nombreArchivoPdf => archivoAntecedentesPDF != null
      ? archivoAntecedentesPDF!.path.split('/').last
      : (_pdfActualUrl != null ? 'Ya tienes un documento cargado' : null);

  void seleccionarExperiencia(String? v) {
    experienciaSeleccionada = v;
    notifyListeners();
  }

  void seleccionarFormacion(String? v) {
    formacionSeleccionada = v;
    notifyListeners();
  }

  void seleccionarComuna(String? v) {
    comunaSeleccionada = v;
    notifyListeners();
  }

  void seleccionarPdf(File pdf) {
    archivoAntecedentesPDF = pdf;
    notifyListeners();
  }

  void alternarServicio(String servicio, bool seleccionado) {
    if (seleccionado) {
      serviciosSeleccionados.add(servicio);
    } else {
      serviciosSeleccionados.remove(servicio);
    }
    notifyListeners();
  }

  Future<void> cargarDatosActuales() async {
    cargando = true;
    notifyListeners();

    try {
      final uid = _authRepo.uidActual;
      if (uid == null) return;

      final perfil = await _usuarioRepo.obtenerPerfilCuidador(uid);
      if (perfil != null) {
        descripcionController.text = perfil.descripcion ?? '';
        experienciaSeleccionada = perfil.experiencia.isEmpty
            ? null
            : perfil.experiencia;
        formacionSeleccionada = perfil.formacion.isEmpty
            ? null
            : perfil.formacion;
        comunaSeleccionada = perfil.comuna.isEmpty ? null : perfil.comuna;
        serviciosSeleccionados = List<String>.from(perfil.serviciosOfrecidos);
        _pdfActualUrl = perfil.documentoAntecedentes;
      }
    } catch (_) {
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  Future<bool> guardarPerfilYFinalizar() async {
    if (serviciosSeleccionados.isEmpty) {
      error = 'Selecciona al menos un servicio ofrecido.';
      notifyListeners();
      return false;
    }
    if (archivoAntecedentesPDF == null && _pdfActualUrl == null) {
      error = 'Debes subir tu Certificado de Antecedentes (PDF).';
      notifyListeners();
      return false;
    }
    if (experienciaSeleccionada == null ||
        formacionSeleccionada == null ||
        comunaSeleccionada == null) {
      error = 'Completa todos los campos requeridos.';
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

      String? pdfUrl = _pdfActualUrl;
      if (archivoAntecedentesPDF != null) {
        pdfUrl = await _archivoRepo.subirArchivo(
          archivoAntecedentesPDF!,
          carpeta: 'antecedentes_penales',
          tipoRecurso: 'raw',
        );
      }

      final datos = PerfilC2Model(
        descripcion: descripcionController.text.trim(),
        experiencia: experienciaSeleccionada!,
        formacion: formacionSeleccionada!,
        documentoAntecedentes: pdfUrl,
        comuna: comunaSeleccionada!,
        serviciosOfrecidos: serviciosSeleccionados,
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
    descripcionController.dispose();
    super.dispose();
  }
}
