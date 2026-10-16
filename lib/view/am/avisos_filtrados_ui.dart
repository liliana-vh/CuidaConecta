import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../model/cuidador/aviso_servicio.dart';
import '../../viewmodel/am/avisos_filtrados_vm.dart';
import '../widgets/aviso/tarjeta_aviso_am.dart';
import '../widgets/aviso/lista_en_vivo.dart';

class AvisosFiltradosAMView extends StatelessWidget {
  final String servicio;

  const AvisosFiltradosAMView({super.key, required this.servicio});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => AvisosFiltradosViewModel(servicio),
      child: const _Contenido(),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido();

  static const Color _naranja = Color(0xFFFF941F);

  @override
  Widget build(BuildContext context) {
    final vm = context.read<AvisosFiltradosViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          vm.nombreServicio,
          style: const TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: _naranja,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(
              'Estos cuidadores ofrecen este servicio:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListaEnVivo<AvisoServicio>(
              stream: vm.avisos,
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
              tamanoLetraMensajes: 20,
              mensajeError:
                  'No pudimos cargar los avisos. Intente de nuevo más tarde.',
              mensajeVacio:
                  'Por ahora no hay cuidadores que ofrezcan este servicio.',
              itemBuilder: (context, aviso) => TarjetaAvisoAM(
                key: ValueKey(aviso.id),
                aviso: aviso,
                onTap: () => context.push('/am/aviso-detalle/${aviso.id}'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
