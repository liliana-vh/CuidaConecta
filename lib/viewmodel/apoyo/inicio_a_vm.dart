import '../../consultas/aviso_repo.dart';
import '../../model/cuidador/aviso_servicio.dart';

class InicioApoyoViewModel {
  final AvisoRepo _avisoRepo = AvisoRepo();

  late final Stream<List<AvisoServicio>> avisos = _avisoRepo.avisosActivos();
}
