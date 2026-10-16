import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../model/cuidador/aviso_servicio.dart';
import '../../viewmodel/cuidador/inicio_c_vm.dart';
import '../widgets/aviso/tarjeta_aviso.dart';
import '../widgets/aviso/lista_en_vivo.dart';
import '../widgets/barra_busqueda_placeholder.dart';

class InicioCuidadorView extends StatelessWidget {
  const InicioCuidadorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => InicioCuidadorViewModel(),
      child: const _Contenido(),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido();

  Future<void> _confirmarEliminacion(
    BuildContext context,
    InicioCuidadorViewModel vm,
    String idAviso,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text(
          '¿Seguro quieres eliminar este aviso? Dejará de mostrarse a los '
          'clientes. Los servicios ya contratados no se ven afectados.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Eliminar')),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await vm.archivarAviso(idAviso);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aviso eliminado')));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<InicioCuidadorViewModel>();

    return Column(
      children: [
        const BarraBusquedaPlaceholder(texto: 'Buscar avisos (próximamente)'),
        const SizedBox(height: 8),
        Expanded(
          child: ListaEnVivo<AvisoServicio>(
            stream: vm.misAvisos,
            mensajeError: 'No se pudieron cargar tus avisos.',
            mensajeVacio: 'No has publicado ningún aviso aún.',
            itemBuilder: (context, aviso) => TarjetaAviso(
              aviso: aviso,
              onTapCallback: () => context.push('/aviso/${aviso.id}'),
              onEditar: () => context.push('/cuidador/editar-aviso/${aviso.id}'),
              onEliminar: () => _confirmarEliminacion(context, vm, aviso.id),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/cuidador/publicar-aviso'),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Publicar aviso de servicio'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF941F),
                foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}