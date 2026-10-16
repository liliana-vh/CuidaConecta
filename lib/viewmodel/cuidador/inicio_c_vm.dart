import '../../consultas/auth_repo.dart';
import '../../consultas/aviso_repo.dart';
import '../../model/cuidador/aviso_servicio.dart';

class InicioCuidadorViewModel {
  final AvisoRepo _avisoRepo = AvisoRepo();
  final AuthRepo _authRepo = AuthRepo();

  late final Stream<List<AvisoServicio>> misAvisos =
    _avisoRepo.avisosDeCuidador(_authRepo.uidActual ?? '');

  Future<void> archivarAviso(String idAviso) async {
    try {
      await _avisoRepo.archivar(idAviso);
    } catch (_) {
      throw Exception('No se pudo eliminar el aviso. Intenta nuevamente.');
    }
  }
}