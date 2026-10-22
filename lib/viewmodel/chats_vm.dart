import '../consultas/auth_repo.dart';
import '../consultas/solicitud_repo.dart';
import '../model/solicitud/estado_solicitud.dart';
import '../model/solicitud/solicitud.dart';
import 'solicitudes_vm.dart';

class ChatsViewModel {
  final SolicitudRepo _solicitudRepo = SolicitudRepo();
  final AuthRepo _authRepo = AuthRepo();
  final RolSolicitudes rol;

  ChatsViewModel(this.rol);

  late final Stream<List<Solicitud>> _todas = rol == RolSolicitudes.cliente
      ? _solicitudRepo.solicitudesDeCliente(_authRepo.uidActual ?? '')
      : _solicitudRepo.solicitudesDeCuidador(_authRepo.uidActual ?? '');

  late final Stream<List<Solicitud>> enCurso =
      _todas.map((l) => l.where((s) => s.chatActivo).toList());

  late final Stream<List<Solicitud>> proximos = _todas.map(
    (l) => l
        .where((s) =>
            s.chatVigente &&
            !s.chatActivo &&
            s.estado != EstadoSolicitud.finalizada)
        .toList(),
  );

  late final Stream<List<Solicitud>> pendientesPago = _todas.map(
    (l) => l
        .where((s) => s.chatVigente && s.estado == EstadoSolicitud.finalizada)
        .toList(),
  );

  late final Stream<List<Solicitud>> historial =
      _todas.map((l) => l.where((s) => s.chatEnHistorial).toList());
}