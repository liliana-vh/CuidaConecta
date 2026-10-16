import 'dart:io';
import 'package:flutter/material.dart';

import '../cuenta_basica_vm.dart';
import '../../model/cuidador/completar_perfil_c1.dart';
import '../../model/cuidador/completar_perfil_c2.dart';
import '../../model/comunas_disponibles.dart';

class EditarPerfilCViewModel extends CuentaBasicaViewModel {
  static const List<String> nivelesEstudios = [
    'Educación media incompleta',
    'Educación media completa',
    'Técnico nivel medio',
    'Técnico nivel superior',
    'Profesional (universitario)',
    'Otro',
  ];
  static const List<String> experiencias = ['0-1', '1-3', '3-5', '5+'];
  static const List<String> formaciones = [
    'Sin formación formal',
    'Curso básico de cuidado de personas mayores',
    'Certificación como cuidador de personas mayores',
    'Técnico en Enfermería (TENS)',
  ];
    static List<String> get comunasDisponibles => ComunasDisponibles.lista;
  static const List<String> serviciosDisponibles = [
    'Acompañamiento y apoyo básico',
    'Cuidado a domicilio avanzado',
  ];
  static const Map<String, String> descripcionServicios = {
    'Acompañamiento y apoyo básico':
        'Compañía, alimentación, compras, orden básico, paseos, recordatorios de medicamentos.',
    'Cuidado a domicilio avanzado':
        'Acompañamiento y apoyo básico + asistencia en higiene personal, movilidad, asistencia con medicamentos o tratamientos médicos.',
  };

  @override
  String get carpetaFotos => 'fotos_cuidadores';

  final descripcionController = TextEditingController();

  String? nivelEstudiosSeleccionado;
  String? experienciaSeleccionada;
  String? formacionSeleccionada;
  String? comunaSeleccionada;
  List<String> serviciosSeleccionados = [];

  String? _pdfActualUrl;
  File? pdfNuevo;

  void seleccionarPdf(File pdf) {
    pdfNuevo = pdf;
    notifyListeners();
  }

  String? get nombreArchivoPdf => pdfNuevo != null
      ? pdfNuevo!.path.split('/').last
      : (_pdfActualUrl != null ? 'Ya tienes un documento cargado' : null);

  void seleccionarNivelEstudios(String? v) {
    nivelEstudiosSeleccionado = v;
    notifyListeners();
  }

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

  void alternarServicio(String servicio, bool seleccionado) {
    if (seleccionado) {
      serviciosSeleccionados.add(servicio);
    } else {
      serviciosSeleccionados.remove(servicio);
    }
    notifyListeners();
  }

  Future<void> cargarDatosActuales(String uid) async {
    cargando = true;
    notifyListeners();

    final perfil = await usuarioRepo.obtenerPerfilCuidador(uid);
    if (perfil != null) {
      cargarCamposBasicos(
        nombre: perfil.nombre,
        apellido: perfil.apellido,
        rut: perfil.rut,
        correo: perfil.correo,
        telefono: perfil.telefono,
        fotoPerfil: perfil.fotoPerfil,
      );
      descripcionController.text = perfil.descripcion ?? '';
      nivelEstudiosSeleccionado = perfil.nivelEstudios;
      experienciaSeleccionada = perfil.experiencia;
      formacionSeleccionada = perfil.formacion;
      comunaSeleccionada = perfil.comuna;
      serviciosSeleccionados = List<String>.from(perfil.serviciosOfrecidos);
      _pdfActualUrl = perfil.documentoAntecedentes;
    }

    cargando = false;
    notifyListeners();
  }

  Future<String?> guardarCambios(String uid) async {
    if (serviciosSeleccionados.isEmpty) {
      error = 'Selecciona al menos un servicio ofrecido.';
      notifyListeners();
      return null;
    }
    if (nivelEstudiosSeleccionado == null ||
        experienciaSeleccionada == null ||
        formacionSeleccionada == null ||
        comunaSeleccionada == null) {
      error = 'Completa todos los campos requeridos.';
      notifyListeners();
      return null;
    }

    guardando = true;
    error = null;
    exito = null;
    notifyListeners();

    try {
      final camposBasicos = await prepararCuentaBasica(uid);

      String? pdfUrl = _pdfActualUrl;
      if (pdfNuevo != null) {
        pdfUrl = await archivoRepo.subirArchivo(
          pdfNuevo!,
          carpeta: 'antecedentes_penales',
          tipoRecurso: 'raw',
        );
      }

      final datos = {
        ...PerfilC1Model(
          nombre: camposBasicos['nombre'],
          apellido: camposBasicos['apellido'],
          rut: camposBasicos['rut'],
          telefono: camposBasicos['telefono'],
          nivelEstudios: nivelEstudiosSeleccionado!,
          fotoPerfil: camposBasicos['fotoPerfil'],
        ).toMap(),
        ...PerfilC2Model(
          descripcion: descripcionController.text.trim(),
          experiencia: experienciaSeleccionada!,
          formacion: formacionSeleccionada!,
          documentoAntecedentes: pdfUrl,
          comuna: comunaSeleccionada!,
          serviciosOfrecidos: serviciosSeleccionados,
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
    descripcionController.dispose();
    super.dispose();
  }
}
