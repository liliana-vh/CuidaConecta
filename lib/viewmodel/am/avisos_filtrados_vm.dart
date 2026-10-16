import '../../consultas/aviso_repo.dart';
import '../../model/lista_servicios.dart';
import '../../model/cuidador/aviso_servicio.dart';

class AvisosFiltradosViewModel {
  final String servicio;

  AvisosFiltradosViewModel(this.servicio);

  final AvisoRepo _avisoRepo = AvisoRepo();

  String get nombreServicio =>
      ListaServicios.nombresCortos[servicio] ?? servicio;

  late final Stream<List<AvisoServicio>> avisos =
      _avisoRepo.avisosActivosPorServicio(servicio);
}