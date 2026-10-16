import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/solicitudes_vm.dart';
import '../widgets/detalle_solicitud/tarjeta_solicitud_am.dart';
import '../widgets/detalle_solicitud/seccion_solicitudes.dart';

class SolicitudesAMView extends StatelessWidget {
  const SolicitudesAMView({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => SolicitudesViewModel(RolSolicitudes.cliente),
      child: const _Contenido(),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido();

  @override
  Widget build(BuildContext context) {
    final vm = context.read<SolicitudesViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis servicios', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: const Color(0xFFFF941F),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => context.push('/am/historial-solicitudes'),
              icon: const Icon(Icons.history, size: 26),
              label: const Text('Historial', style: TextStyle(fontSize: 18)),
            ),
          ),
          SeccionSolicitudes(
            titulo: 'En espera',
            stream: vm.pendientes,
            mensajeVacio: 'No hay nada aquí por ahora.',
            tamanoTitulo: 22,
            tamanoMensajeVacio: 18,
            itemBuilder: (context, s) => TarjetaSolicitudAM(
              solicitud: s,
              onTap: () => context.push('/am/detalle-solicitud/${s.id}'),
            ),
          ),
          const SizedBox(height: 12),
          SeccionSolicitudes(
            titulo: 'Sus servicios',
            stream: vm.activas,
            mensajeVacio: 'No hay nada aquí por ahora.',
            tamanoTitulo: 22,
            tamanoMensajeVacio: 18,
            itemBuilder: (context, s) => TarjetaSolicitudAM(
              solicitud: s,
              onTap: () => context.push('/am/detalle-solicitud/${s.id}'),
            ),
          ),
        ],
      ),
    );
  }
}