import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../model/cuidador/aviso_servicio.dart';
import '../../viewmodel/apoyo/inicio_a_vm.dart';
import '../widgets/aviso/buscador_avisos.dart';
import '../widgets/aviso/tarjeta_aviso.dart';

class InicioApoyoView extends StatelessWidget {
  const InicioApoyoView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => InicioApoyoViewModel()..escuchar(),
      child: const _Contenido(),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<InicioApoyoViewModel>();

    return Column(
      children: [
        BuscadorAvisos(filtro: vm.filtro),
        const SizedBox(height: 8),
        Expanded(child: _lista(vm)),
      ],
    );
  }

  Widget _lista(InicioApoyoViewModel vm) {
    if (vm.cargando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.error != null) {
      return _mensaje(vm.error!);
    }

    final List<AvisoServicio> avisos = vm.filtrados;
    if (avisos.isEmpty) {
      return _mensaje(
        vm.filtro.hayBusqueda
            ? 'Ningún aviso coincide con tu búsqueda.'
            : 'No hay avisos de cuidadores disponibles.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: avisos.length,
      itemBuilder: (context, i) {
        final aviso = avisos[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: TarjetaAviso(
            aviso: aviso,
            onTapCallback: () => context.push('/aviso/${aviso.id}'),
          ),
        );
      },
    );
  }

  Widget _mensaje(String texto) {
    return Center(
      child: Text(
        texto,
        style: const TextStyle(fontSize: 16, color: Colors.black54),
      ),
    );
  }
}