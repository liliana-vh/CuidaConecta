import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../model/solicitud/solicitud.dart';
import '../viewmodel/solicitudes_vm.dart';
import 'widgets/detalle_solicitud/seccion_solicitudes.dart';
import 'widgets/detalle_solicitud/tarjeta_solicitud.dart';

//solo apoyo y cuidador
class SolicitudesView extends StatelessWidget {
  final RolSolicitudes _rol;

  const SolicitudesView.cuidador({super.key}) : _rol = RolSolicitudes.cuidador;
  const SolicitudesView.apoyo({super.key}) : _rol = RolSolicitudes.cliente;

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => SolicitudesViewModel(_rol),
      child: const _Contenido(),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido();

  @override
  Widget build(BuildContext context) {
    final vm = context.read<SolicitudesViewModel>();
    final esCuidador = vm.rol == RolSolicitudes.cuidador;
    final rutaBase = esCuidador ? '/cuidador' : '/apoyo';

    Widget tarjeta(BuildContext context, Solicitud s) => TarjetaSolicitud(
          solicitud: s,
          // El cuidador ve el nombre del cliente, el cliente el del cuidador
          mostrarNombreCliente: esCuidador,
          onTap: () => context.push('$rutaBase/detalle-solicitud/${s.id}'),
        );

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => context.push('$rutaBase/historial-solicitudes'),
              icon: const Icon(Icons.history),
              label: const Text('Historial'),
            ),
          ),
          SeccionSolicitudes(
            titulo: esCuidador ? 'Nuevas solicitudes' : 'Pendientes de respuesta',
            stream: vm.pendientes,
            itemBuilder: tarjeta,
          ),
          const SizedBox(height: 8),
          SeccionSolicitudes(
            titulo: esCuidador ? 'En curso' : 'Activas',
            stream: vm.activas,
            itemBuilder: tarjeta,
          ),
        ],
      ),
    );
  }
}