import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/cuidador/mostrar_perfilc_vm.dart';
import '../widgets/perfil/perfil.dart';
import '../widgets/perfil/cabecera_perfil.dart';
import '../widgets/perfil/botones_perfil_acciones.dart';

class PerfilCuidadorView extends StatelessWidget {
  const PerfilCuidadorView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MostrarPerfilCViewModel()..cargarPerfil(),
      child: const _Contenido(),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido();

  static const primaryColor = Color(0xFFFF941F);
  static const secondaryColor = Color.fromARGB(255, 255, 216, 133);

  Future<void> _irAEditar(
    BuildContext context,
    MostrarPerfilCViewModel vm,
  ) async {
    final result = await context.push<bool?>(
      '/cuidador/editar-perfil',
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
    MostrarPerfilCViewModel vm,
  ) async {
    await vm.cerrarSesion();
    if (context.mounted) context.go('/');
  }

  void _verPDF(BuildContext context, String url) {
    context.push(
      '/visor-pdf',
      extra: {'url': url, 'titulo': 'Certificado de Antecedentes'},
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MostrarPerfilCViewModel>();

    if (vm.cargando) return const Center(child: CircularProgressIndicator());
    final perfil = vm.perfil;
    if (perfil == null) {
      return const Center(child: Text('No se encontraron datos.'));
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        CabeceraPerfil(
          fotoUrl: perfil.fotoPerfil,
          nombreCompleto: '${perfil.nombre} ${perfil.apellido}',
          correo: perfil.correo,
          descripcion: perfil.descripcion,
          colorAvatar: secondaryColor,
          iconoFallback: Icons.person,
        ),
        const Divider(height: 40),

        const SeccionTitulo(
          titulo: 'Datos Profesionales',
          icono: Icons.badge_outlined,
          color: primaryColor,
        ),
        InfoTile(etiqueta: 'Teléfono', valor: perfil.telefono),
        InfoTile(etiqueta: 'RUT', valor: perfil.rut),
        InfoTile(etiqueta: 'Comuna', valor: perfil.comuna),
        InfoTile(etiqueta: 'Años de experiencia', valor: perfil.experiencia),
        InfoTile(etiqueta: 'Nivel de estudio', valor: perfil.nivelEstudios),
        InfoTile(etiqueta: 'Formación específica', valor: perfil.formacion),

        const SizedBox(height: 20),
        const SeccionTitulo(
          titulo: 'Servicios Ofrecidos',
          icono: Icons.volunteer_activism_outlined,
          color: primaryColor,
        ),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: perfil.serviciosOfrecidos
              .map(
                (s) => Chip(
                  label: Text(s),
                  backgroundColor: secondaryColor.withAlpha(60),
                  avatar: const Icon(
                    Icons.check,
                    size: 18,
                    color: primaryColor,
                  ),
                  labelStyle: const TextStyle(color: primaryColor),
                ),
              )
              .toList(),
        ),

        if (perfil.documentoAntecedentes != null) ...[
          const SizedBox(height: 20),
          const SeccionTitulo(
            titulo: 'Documentos',
            icono: Icons.description_outlined,
            color: primaryColor,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.picture_as_pdf, color: primaryColor),
            title: const Text(
              'Ver Certificado de Antecedentes',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text('Documento PDF adjunto'),
            trailing: const Icon(Icons.visibility),
            onTap: () => _verPDF(context, perfil.documentoAntecedentes!),
          ),
        ],

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
