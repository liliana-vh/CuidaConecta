import '../perfil_ver_vm.dart';
import '../../consultas/usuario_repo.dart';
import '../../model/cuidador/perfil_cuidador.dart';

class MostrarPerfilCViewModel extends PerfilVerViewModel<PerfilCuidadorModel> {
  final UsuarioRepo _usuarioRepo = UsuarioRepo();

  @override
  Future<PerfilCuidadorModel?> obtenerPerfil(String uid) => _usuarioRepo.obtenerPerfilCuidador(uid);

  @override
  String obtenerCorreo(PerfilCuidadorModel perfil) => perfil.correo;
}