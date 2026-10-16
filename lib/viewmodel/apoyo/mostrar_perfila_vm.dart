import '../perfil_ver_vm.dart';
import '../../consultas/usuario_repo.dart';
import '../../model/apoyo/perfil_a.dart';

class MostrarPerfilAViewModel extends PerfilVerViewModel<PerfilApoyoModel> {
  final UsuarioRepo _usuarioRepo = UsuarioRepo();

  @override
  Future<PerfilApoyoModel?> obtenerPerfil(String uid) => _usuarioRepo.obtenerPerfilApoyo(uid);

  @override
  String obtenerCorreo(PerfilApoyoModel perfil) => perfil.correo;
}