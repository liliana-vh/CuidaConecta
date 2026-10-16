import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/apoyo/mostrar_perfila_vm.dart';
import '../widgets/perfil/perfil.dart';
import '../widgets/perfil/cabecera_perfil.dart';
import '../widgets/perfil/botones_perfil_acciones.dart';

class PerfilApoyoView extends StatelessWidget {
  const PerfilApoyoView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MostrarPerfilAViewModel()..cargarPerfil(),
      child: const _Contenido(),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido();

  static const primaryColor = Color(0xFFFF941F);

  Future<void> _irAEditar(
    BuildContext context,
    MostrarPerfilAViewModel vm,
  ) async {
    final result = await context.pushNamed<bool?>(
      'editar_perfil_apoyo',
      extra: {'uid': vm.uidActual},
    );
    if (result != null) {
      await vm.cargarPerfil();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Perfil actualizado')));
      }
    }
  }

  Future<void> _cerrarSesion(
    BuildContext context,
    MostrarPerfilAViewModel vm,
  ) async {
    await vm.cerrarSesion();
    if (context.mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MostrarPerfilAViewModel>();

    if (vm.cargando) return const Center(child: CircularProgressIndicator());
    final perfil = vm.perfil;
    if (perfil == null) {
      return const Center(child: Text('No se encontraron datos.'));
    }

    final direccion = [
      '${perfil.calle} ${perfil.numero}, ${perfil.comuna}',
      if (perfil.detalles.trim().isNotEmpty) perfil.detalles,
    ].join(' — ');

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        CabeceraPerfil(
          fotoUrl: perfil.fotoPerfil,
          nombreCompleto: '${perfil.nombre} ${perfil.apellido}',
          correo: perfil.correo,
          colorAvatar: primaryColor,
          iconoFallback: Icons.family_restroom,
        ),
        const Divider(height: 40),

        const SeccionTitulo(
          titulo: 'Mis Datos',
          icono: Icons.person_outline,
          color: primaryColor,
        ),
        InfoTile(etiqueta: 'RUT', valor: perfil.rut),
        InfoTile(etiqueta: 'Teléfono', valor: perfil.telefono),
        InfoTile(etiqueta: 'Dirección', valor: direccion),
        const SizedBox(height: 20),

        const SeccionTitulo(
          titulo: 'Familiar a Cargo',
          icono: Icons.volunteer_activism_outlined,
          color: primaryColor,
        ),
        InfoTile(etiqueta: 'Relación', valor: perfil.relacionFamiliar),
        InfoTile(etiqueta: 'Edad', valor: '${perfil.edadFamiliar} años'),
        InfoTile(etiqueta: 'Dependencia', valor: perfil.dependenciaFamiliar),
        InfoTile(etiqueta: 'Condición médica', valor: perfil.condicionFamiliar),

        const Divider(height: 40),
        if (vm.error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              vm.error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        if (vm.mensajeExito != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              vm.mensajeExito!,
              style: const TextStyle(color: Colors.green),
              textAlign: TextAlign.center,
            ),
          ),

        BotonesPerfilAcciones(
          onEditar: () => _irAEditar(context, vm),
          onCambiarContrasena: vm.cambiarContrasena,
          onCerrarSesion: () => _cerrarSesion(context, vm),
          enviandoContrasena: vm.enviandoContrasena,
          color: primaryColor,
        ),
      ],
    );
  }
}
