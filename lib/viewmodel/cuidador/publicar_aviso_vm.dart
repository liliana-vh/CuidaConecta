import 'package:flutter/material.dart';

import '../../consultas/auth_repo.dart';
import '../../consultas/aviso_repo.dart';
import '../../consultas/usuario_repo.dart';
import '../../model/cuidador/aviso_servicio.dart';
import '../../model/solicitud/reglas_servicio.dart';

class PublicarAvisoViewModel extends ChangeNotifier {
  final AuthRepo _authRepo = AuthRepo();
  final UsuarioRepo _usuarioRepo = UsuarioRepo();
  final AvisoRepo _avisoRepo = AvisoRepo();

  final String? idAviso;

  PublicarAvisoViewModel({this.idAviso});

  bool get esEdicion => idAviso != null;

  static const List<String> dias = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];

  final TextEditingController tituloController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  final TextEditingController tarifaController = TextEditingController();

  bool cargando = true;
  bool guardando = false;
  String? errorCarga;

  String _nombreCuidador = '';
  String comuna = '';
  List<String> serviciosDisponibles = [];
  String? _fotoCuidador;

  String? _servicioSeleccionado;
  final Map<String, bool> _diasActivos = {for (final d in dias) d: false};
  final Map<String, TimeOfDay?> _horaInicio = {};
  final Map<String, TimeOfDay?> _horaFin = {};

  Future<void> cargarPerfil() async {
    try {
      final uid = _authRepo.uidActual;
      if (uid == null) {
        errorCarga = 'No hay una sesión activa.';
        return;
      }

      final perfil = await _usuarioRepo.obtenerPerfilCuidador(uid);
      if (perfil == null) {
        errorCarga = 'No se encontró tu perfil.';
        return;
      }

      _nombreCuidador = '${perfil.nombre} ${perfil.apellido}'.trim();
      _fotoCuidador = perfil.fotoPerfil;
      comuna = perfil.comuna;
      serviciosDisponibles = perfil.serviciosOfrecidos;

      descripcionController.text = perfil.descripcion ?? '';

      tituloController.text = _tituloAutomatico(null);

      if (esEdicion) await _prellenarDesdeAviso(uid);
    } catch (_) {
      errorCarga = 'No se pudo cargar tu perfil. Intenta nuevamente.';
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  Future<void> _prellenarDesdeAviso(String uid) async {
    final aviso = await _avisoRepo.obtener(idAviso!);

    if (aviso == null || aviso.uidCuidador != uid || !aviso.activo) {
      errorCarga = 'Este aviso ya no está disponible.';
      return;
    }

    tituloController.text = aviso.titulo;
    descripcionController.text = aviso.descripcion;
    tarifaController.text = aviso.tarifaHora.toStringAsFixed(0);

    final previos = aviso.servicios.where(serviciosDisponibles.contains);
    _servicioSeleccionado = previos.isEmpty ? null : previos.first;

    aviso.disponibilidad.forEach((dia, franja) {
      if (franja is Map && dias.contains(dia)) {
        final ini = _aTimeOfDay(franja['inicio']);
        final fin = _aTimeOfDay(franja['fin']);
        if (ini != null && fin != null) {
          _diasActivos[dia] = true;
          _horaInicio[dia] = ini;
          _horaFin[dia] = fin;
        }
      }
    });
  }

  TimeOfDay? _aTimeOfDay(dynamic hhmm) {
    if (hhmm is! String) return null;
    final partes = hhmm.split(':');
    if (partes.length != 2) return null;
    final h = int.tryParse(partes[0]);
    final m = int.tryParse(partes[1]);
    return (h == null || m == null) ? null : TimeOfDay(hour: h, minute: m);
  }

  String _tituloAutomatico(String? servicio) =>
      servicio != null && comuna.isNotEmpty
          ? '$servicio en $comuna'
          : 'Servicio de cuidador';

  bool servicioSeleccionado(String servicio) =>
      _servicioSeleccionado == servicio;

  void seleccionarServicio(String servicio) {
    final tituloActual = tituloController.text.trim();
    final eraAutomatico = tituloActual.isEmpty ||
        tituloActual == _tituloAutomatico(_servicioSeleccionado);

    _servicioSeleccionado = servicio;
    if (!esEdicion && eraAutomatico) {
      tituloController.text = _tituloAutomatico(servicio);
    }
    notifyListeners();
  }

  //disponibilidad
  bool diaActivo(String dia) => _diasActivos[dia] ?? false;
  TimeOfDay? horaInicioDe(String dia) => _horaInicio[dia];
  TimeOfDay? horaFinDe(String dia) => _horaFin[dia];

  void alternarDia(String dia, bool activo) {
    _diasActivos[dia] = activo;
    notifyListeners();
  }

  void fijarHora(
    String dia, {
    required bool esInicio,
    required TimeOfDay hora,
  }) {
    if (esInicio) {
      _horaInicio[dia] = hora;
    } else {
      _horaFin[dia] = hora;
    }
    notifyListeners();
  }

  static String hhmm(TimeOfDay hora) =>
      '${hora.hour.toString().padLeft(2, '0')}:'
      '${hora.minute.toString().padLeft(2, '0')}';

  Map<String, dynamic> _construirDisponibilidad() {
    final disponibilidad = <String, dynamic>{};
    final incompletos = <String>[];

    final minimo =
        ReglasServicio.horaMinima.hour * 60 + ReglasServicio.horaMinima.minute;
    final maximo =
        ReglasServicio.horaMaxima.hour * 60 + ReglasServicio.horaMaxima.minute;

    for (final dia in dias) {
      if (!diaActivo(dia)) continue;

      final inicio = _horaInicio[dia];
      final fin = _horaFin[dia];

      if (inicio == null || fin == null) {
        incompletos.add(dia);
        continue;
      }

      final ini = inicio.hour * 60 + inicio.minute;
      final fi = fin.hour * 60 + fin.minute;

      if (fi <= ini) {
        throw Exception(
          'El $dia: la hora de fin debe ser posterior a la de inicio.',
        );
      }
      if (fi - ini < ReglasServicio.minHorasPorSesion * 60) {
        throw Exception(
          'El $dia: el horario debe cubrir al menos '
          '${ReglasServicio.minHorasPorSesion} horas.',
        );
      }
      if (ini < minimo || fi > maximo) {
        throw Exception(
          'El $dia: el horario debe estar entre '
          '${hhmm(ReglasServicio.horaMinima)} y ${hhmm(ReglasServicio.horaMaxima)}.',
        );
      }

      disponibilidad[dia] = {'inicio': hhmm(inicio), 'fin': hhmm(fin)};
    }

    if (incompletos.isNotEmpty) {
      throw Exception(
        'Falta la hora de inicio y fin en: ${incompletos.join(', ')}.',
      );
    }
    if (disponibilidad.isEmpty) {
      throw Exception('Selecciona al menos un día con horario.');
    }
    if (disponibilidad.length < ReglasServicio.minDiasPorSemana) {
      throw Exception(
        'El aviso debe ofrecer al menos '
        '${ReglasServicio.minDiasPorSemana} días a la semana.',
      );
    }

    return disponibilidad;
  }

  double _leerTarifa() {
    return double.tryParse(tarifaController.text.trim()) ?? 0;
  }

  Future<void> publicar() async {
    final uid = _authRepo.uidActual;
    if (uid == null) throw Exception('No hay una sesión activa.');

    final titulo = tituloController.text.trim();
    final descripcion = descripcionController.text.trim();

    if (titulo.isEmpty || descripcion.isEmpty) {
      throw Exception('Completa el título y la descripción.');
    }
    if (_servicioSeleccionado == null) {
      throw Exception('Selecciona el tipo de servicio del aviso.');
    }

    final tarifa = _leerTarifa();
    if (tarifa <= 0) {
      throw Exception('Ingresa una tarifa por hora válida.');
    }

    final disponibilidad = _construirDisponibilidad();

    final aviso = AvisoServicio(
      id: idAviso ?? '',
      uidCuidador: uid,
      nombreCuidador: _nombreCuidador,
      fotoCuidador: _fotoCuidador,
      titulo: titulo,
      descripcion: descripcion,
      servicios: [_servicioSeleccionado!],
      comuna: comuna,
      disponibilidad: disponibilidad,
      tarifaHora: tarifa,
    );

    guardando = true;
    notifyListeners();

    try {
      if (esEdicion) {
        await _avisoRepo.actualizar(aviso);
      } else {
        await _avisoRepo.publicar(aviso);
      }
    } on Exception catch (_) {
      rethrow;
    } catch (_) {
      throw Exception(
        esEdicion
            ? 'No se pudieron guardar los cambios. Intenta nuevamente.'
            : 'No se pudo publicar el aviso. Intenta nuevamente.',
      );
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
    tituloController.dispose();
    descripcionController.dispose();
    tarifaController.dispose();
    super.dispose();
  }
}