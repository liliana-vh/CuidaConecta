import 'package:flutter/foundation.dart';

import '../consultas/auth_repo.dart';
import '../consultas/aviso_repo.dart';
import '../consultas/usuario_repo.dart';
import '../model/cuidador/aviso_servicio.dart';
import '../model/cuidador/perfil_cuidador.dart';

class DetalleAvisoViewModel extends ChangeNotifier {
  final String idAviso;

  DetalleAvisoViewModel(this.idAviso);

  final AvisoRepo _avisoRepo = AvisoRepo();
  final UsuarioRepo _usuarioRepo = UsuarioRepo();
  final AuthRepo _authRepo = AuthRepo();

  bool cargando = true;
  String? error;
  AvisoServicio? aviso;
  PerfilCuidadorModel? cuidador;

  bool get esDuenio => aviso != null && aviso!.uidCuidador == _authRepo.uidActual;

  String? get fotoCuidadorUrl => cuidador?.fotoPerfil ?? aviso?.fotoCuidador;

  bool get tieneFoto => fotoCuidadorUrl != null && fotoCuidadorUrl!.isNotEmpty;

  String get formacionTexto =>
      (cuidador == null || cuidador!.formacion.isEmpty) ? 'No especificada' : cuidador!.formacion;

  String get experienciaTexto => (cuidador == null || cuidador!.experiencia.isEmpty)
      ? 'No especificada'
      : '${cuidador!.experiencia} años';

  String get comunaTexto => (aviso == null || aviso!.comuna.isEmpty) ? 'No especificada' : aviso!.comuna;

  String? get certificadoUrl => cuidador?.documentoAntecedentes;

  bool get tieneCertificado => certificadoUrl != null && certificadoUrl!.isNotEmpty;

  Future<void> cargar() async {
    try {
      final encontrado = await _avisoRepo.obtener(idAviso);

      if (encontrado == null || !encontrado.activo) {
        error = 'Este aviso ya no está disponible.';
        return;
      }

      aviso = encontrado;
      error = null;
      cuidador = await _usuarioRepo.obtenerPerfilCuidador(encontrado.uidCuidador);
    } catch (_) {
      error = 'No se pudo cargar el aviso. Intenta nuevamente.';
    } finally {
      cargando = false;
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
    super.dispose();
  }
}