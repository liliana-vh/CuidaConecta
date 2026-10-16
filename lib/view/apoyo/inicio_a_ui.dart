import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../model/cuidador/aviso_servicio.dart';
import '../../viewmodel/apoyo/inicio_a_vm.dart';
import '../widgets/aviso/tarjeta_aviso.dart';
import '../widgets/aviso/lista_en_vivo.dart';
import '../widgets/barra_busqueda_placeholder.dart';

class InicioApoyoView extends StatelessWidget {
  const InicioApoyoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => InicioApoyoViewModel(),
      child: const _Contenido(),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido();

  @override
  Widget build(BuildContext context) {
    final vm = context.read<InicioApoyoViewModel>();

    return Column(
      children: [
        const BarraBusquedaPlaceholder(texto: 'Filtrar avisos (próximamente)'),
        const SizedBox(height: 8),
        Expanded(
          child: ListaEnVivo<AvisoServicio>(
            stream: vm.avisos,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            mensajeError: 'No se pudieron cargar los avisos.',
            mensajeVacio: 'No hay avisos de cuidadores disponibles.',
            itemBuilder: (context, aviso) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TarjetaAviso(
                aviso: aviso,
                onTapCallback: () => context.push('/aviso/${aviso.id}'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}