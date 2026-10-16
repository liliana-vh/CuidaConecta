import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../model/solicitud/solicitud.dart';
import '../viewmodel/solicitudes_vm.dart';
import 'widgets/aviso/lista_en_vivo.dart';
import 'widgets/detalle_solicitud/tarjeta_solicitud.dart';
import 'widgets/detalle_solicitud/tarjeta_solicitud_am.dart';

/// Historial de solicitudes para todos los clientes
class HistorialSolicitudesView extends StatelessWidget {
  final RolSolicitudes rol;
  final String rutaDetalle;
  final bool adultoMayor;

  const HistorialSolicitudesView.cuidador({super.key})
      : rol = RolSolicitudes.cuidador,
        rutaDetalle = '/cuidador/detalle-solicitud',
        adultoMayor = false;

  const HistorialSolicitudesView.apoyo({super.key})
      : rol = RolSolicitudes.cliente,
        rutaDetalle = '/apoyo/detalle-solicitud',
        adultoMayor = false;

  const HistorialSolicitudesView.am({super.key})
      : rol = RolSolicitudes.cliente,
        rutaDetalle = '/am/detalle-solicitud',
        adultoMayor = true;

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => SolicitudesViewModel(rol),
      child: _Contenido(rutaDetalle: rutaDetalle, adultoMayor: adultoMayor),
    );
  }
}

class _Contenido extends StatelessWidget {
  final String rutaDetalle;
  final bool adultoMayor;

  const _Contenido({required this.rutaDetalle, required this.adultoMayor});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<SolicitudesViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Historial de solicitudes')),
      body: ListaEnVivo<Solicitud>(
        stream: vm.historial,
        mensajeError: 'No se pudo cargar el historial.',
        mensajeVacio: 'Aún no hay solicitudes en el historial.',
        padding: const EdgeInsets.all(16),
        tamanoLetraMensajes: adultoMayor ? 20 : 16,
        itemBuilder: (context, s) {
          void abrir() => context.push('$rutaDetalle/${s.id}');

          return adultoMayor
              ? TarjetaSolicitudAM(solicitud: s, onTap: abrir)
              : TarjetaSolicitud(
                  solicitud: s,
                  // El cuidador ve el nombre del cliente, el cliente el del cuidador
                  mostrarNombreCliente: vm.rol == RolSolicitudes.cuidador,
                  onTap: abrir,
                );
        },
      ),
    );
  }
}