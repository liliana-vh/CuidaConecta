import 'package:flutter/material.dart';

import '../consultas/auth_repo.dart';
import '../consultas/aviso_repo.dart';
import '../consultas/solicitud_repo.dart';
import '../consultas/usuario_repo.dart';
import '../model/cuidador/aviso_servicio.dart';
import '../model/identidad_usuario.dart';
import '../model/solicitud/agenda_semanal.dart';
import '../model/solicitud/estado_solicitud.dart';
import '../model/solicitud/solicitud.dart';

class AgendarViewModel extends ChangeNotifier {
  AgendarViewModel(this.idAviso);

  final String idAviso;

  final _auth = AuthRepo();
  final _avisos = AvisoRepo();
  final _usuarios = UsuarioRepo();
  final _solicitudes = SolicitudRepo();

  AgendaSemanal? _semana;
  IdentidadUsuario? _identidad;
  bool _liberado = false;

  bool cargando = true;
  bool enviando = false;
  String? errorCarga;

  String? servicioSeleccionado;
  String metodoPago = MetodoPago.efectivo;

  Future<void> cargar() async {
    try {
      final uid = _auth.uidActual;
      if (uid == null) {
        errorCarga = 'No hay una sesión activa.';
        return;
      }

      _identidad = await _usuarios.obtenerIdentidad(uid);
      if (_identidad == null) {
        errorCarga = 'No se encontró tu perfil.';
        return;
      }

      errorCarga = await _actualizarSemana(uid);

      final servicios = _semana?.aviso.servicios;
      if (servicios != null && servicios.length == 1) {
        servicioSeleccionado = servicios.first;
      }
      if (!puedeElegirTarjeta) metodoPago = MetodoPago.efectivo;
    } catch (e) {
      debugPrint('Error cargando datos para agendar: $e');
      errorCarga = 'No se pudieron cargar los datos. Intenta nuevamente.';
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  Future<String?> _actualizarSemana(String uid) async {
    final aviso = await _avisos.obtener(idAviso);
    if (aviso == null || !aviso.activo) return 'Este aviso ya no está disponible.';

    final reservas = await _solicitudes.sesionesOcupadasDeCuidador(aviso.uidCuidador);
    final delCliente = await _solicitudes.sesionesActivasDeCliente(uid);

    final semana = _semana;
    if (semana == null) {
      _semana = AgendaSemanal(
        aviso: aviso,
        reservasDelCuidador: reservas,
        sesionesDelCliente: delCliente,
      );
    } else {
      semana.actualizarDatos(
        aviso: aviso,
        reservasDelCuidador: reservas,
        sesionesDelCliente: delCliente,
      );
    }
    return null;
  }


  AvisoServicio? get aviso => _semana?.aviso;
  bool get puedeElegirTarjeta => _identidad?.puedePagarConTarjeta ?? false;

  DateTime get semanaSeleccionada => _semana?.lunes ?? AgendaSemanal.proximasSemanas.first;
  List<DateTime> get semanas => AgendaSemanal.proximasSemanas;
  String etiquetaSemana(DateTime lunes) => AgendaSemanal.etiquetaSemana(lunes);
  List<int> get opcionesHoras => AgendaSemanal.opcionesHoras;

  List<DiaAgenda> get diasDeLaSemana => _semana?.dias ?? const [];

  String? get errorGeneral {
    final semana = _semana;
    if (semana == null) return 'No se pudieron cargar los datos del aviso.';
    return semana.errorDeSolicitud(servicioSeleccionado);
  }

  bool get puedeEnviar => errorGeneral == null;

  Solicitud? get vistaPrevia => _armar();


  void seleccionarServicio(String? servicio) =>
      _cambiar(() => servicioSeleccionado = servicio);

  void seleccionarMetodoPago(String metodo) {
    if (metodo == MetodoPago.tarjeta && !puedeElegirTarjeta) return;
    _cambiar(() => metodoPago = metodo);
  }

  void cambiarSemana(DateTime lunes) => _cambiar(() => _semana?.cambiarSemana(lunes));

  void alternarDia(DateTime fecha, bool activo) =>
      _cambiar(() => _semana?.alternar(fecha, activo));

  void fijarInicio(DateTime fecha, TimeOfDay hora) =>
      _cambiar(() => _semana?.fijarInicio(fecha, hora));

  void fijarHoras(DateTime fecha, int horas) =>
      _cambiar(() => _semana?.fijarHoras(fecha, horas));

  void _cambiar(void Function() accion) {
    accion();
    notifyListeners();
  }

  Future<String?> enviar() async {
    if (enviando) return 'Ya se está enviando la solicitud.';

    enviando = true;
    notifyListeners();

    try {
      final uid = _auth.uidActual;
      if (uid == null) return 'No hay una sesión activa.';

      try {
        final problema = await _actualizarSemana(uid);
        if (problema != null) return problema;
      } catch (_) {
        return 'No se pudo verificar la disponibilidad. Intenta nuevamente.';
      }

      final error = errorGeneral;
      if (error != null) return error;

      try {
        await _solicitudes.crear(_armar()!);
        return null;
      } catch (_) {
        return 'No se pudo enviar la solicitud. Intenta nuevamente.';
      }
    } finally {
      enviando = false;
      notifyListeners();
    }
  }

  Solicitud? _armar() {
    final semana = _semana;
    final identidad = _identidad;
    if (semana == null || identidad == null || semana.sesiones.isEmpty) return null;

    final a = semana.aviso;
    return Solicitud.nueva(
      uidCliente: _auth.uidActual ?? '',
      tipoCliente: identidad.tipoUsuario,
      nombreCliente: identidad.nombre,
      uidCuidador: a.uidCuidador,
      nombreCuidador: a.nombreCuidador,
      idAviso: a.id,
      servicio: servicioSeleccionado ?? '',
      comuna: a.comuna,
      tarifaHora: a.tarifaHora,
      sesiones: semana.sesiones,
      metodoPago: metodoPago,
    );
  }

  @override
  void notifyListeners() {
    if (!_liberado) super.notifyListeners();
  }

  @override
  void dispose() {
    _liberado = true;
    super.dispose();
  }
}