import '../consultas/auth_repo.dart';
import '../consultas/solicitud_repo.dart';
import '../model/solicitud/estado_solicitud.dart';
import '../model/solicitud/solicitud.dart';

enum RolSolicitudes { cliente, cuidador }

class SolicitudesViewModel {
  final SolicitudRepo _solicitudRepo = SolicitudRepo();
  final AuthRepo _authRepo = AuthRepo();
  final RolSolicitudes rol;

  SolicitudesViewModel(this.rol);

  late final Stream<List<Solicitud>> _todas = rol == RolSolicitudes.cliente
      ? _solicitudRepo.solicitudesDeCliente(_authRepo.uidActual ?? '')
      : _solicitudRepo.solicitudesDeCuidador(_authRepo.uidActual ?? '');

  late final Stream<List<Solicitud>> pendientes =
      _todas.map((l) => l.where((s) => s.estado == EstadoSolicitud.pendiente).toList());

  late final Stream<List<Solicitud>> activas = _todas.map(
    (l) => l
        .where((s) =>
            s.estado == EstadoSolicitud.aceptada ||
            s.estado == EstadoSolicitud.enProgreso ||
            (s.estado == EstadoSolicitud.finalizada && !s.pagoRealizado))
        .toList(),
  );

  late final Stream<List<Solicitud>> historial = _todas.map(
    (l) => l
        .where((s) =>
            (s.estado == EstadoSolicitud.finalizada && s.pagoRealizado) ||
            s.estado == EstadoSolicitud.rechazada)
        .toList(),
  );
}