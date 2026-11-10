import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../model/solicitud/solicitud.dart';
import '../viewmodel/chats_vm.dart';
import '../viewmodel/solicitudes_vm.dart';
import 'widgets/aviso/lista_en_vivo.dart';
import 'widgets/chat/tarjeta_chat.dart';
import 'widgets/detalle_solicitud/seccion_solicitudes.dart';

class ChatsView extends StatelessWidget {
  final RolSolicitudes _rol;
  final String _rutaBase;

  const ChatsView.cuidador({super.key})
      : _rol = RolSolicitudes.cuidador,
        _rutaBase = '/cuidador';

  const ChatsView.apoyo({super.key})
      : _rol = RolSolicitudes.cliente,
        _rutaBase = '/apoyo';

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => ChatsViewModel(_rol),
      child: _Contenido(rutaBase: _rutaBase),
    );
  }
}

class _Contenido extends StatelessWidget {
  final String rutaBase;

  const _Contenido({required this.rutaBase});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<ChatsViewModel>();
    final esCuidador = vm.rol == RolSolicitudes.cuidador;

    Widget tarjeta(BuildContext context, Solicitud s) => TarjetaChat(
          solicitud: s,
          mostrarNombreCliente: esCuidador,
          onTap: () => context.push('$rutaBase/chat/${s.id}'),
        );

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => context.push('$rutaBase/historial-chats'),
              icon: const Icon(Icons.history),
              label: const Text('Historial'),
            ),
          ),
          SeccionSolicitudes(
            titulo: 'Servicio en progreso',
            stream: vm.enCurso,
            itemBuilder: tarjeta,
            mensajeVacio: 'No hay servicios en progreso.',
          ),
          const SizedBox(height: 8),
          SeccionSolicitudes(
            titulo: 'Próximos servicios',
            stream: vm.proximos,
            itemBuilder: tarjeta,
            mensajeVacio: 'No hay servicios próximos.',
          ),
          const SizedBox(height: 8),
          SeccionSolicitudes(
            titulo: 'Finalizados, pendiente de pago',
            stream: vm.pendientesPago,
            itemBuilder: tarjeta,
            mensajeVacio: 'No hay pagos pendientes.',
          ),
        ],
      ),
    );
  }
}

class HistorialChatsView extends StatelessWidget {
  final RolSolicitudes _rol;
  final String _rutaBase;

  const HistorialChatsView.cuidador({super.key})
      : _rol = RolSolicitudes.cuidador,
        _rutaBase = '/cuidador';

  const HistorialChatsView.apoyo({super.key})
      : _rol = RolSolicitudes.cliente,
        _rutaBase = '/apoyo';

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => ChatsViewModel(_rol),
      child: Builder(
        builder: (context) {
          final vm = context.read<ChatsViewModel>();
          final esCuidador = vm.rol == RolSolicitudes.cuidador;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Historial de chats'),
              backgroundColor: const Color(0xFFFF941F),
              foregroundColor: Colors.black,
            ),
            body: ListaEnVivo<Solicitud>(
              stream: vm.historial,
              mensajeError: 'No se pudo cargar el historial.',
              mensajeVacio: 'Aún no hay chats en el historial.',
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, s) => TarjetaChat(
                solicitud: s,
                mostrarNombreCliente: esCuidador,
                onTap: () => context.push('$_rutaBase/chat/${s.id}'),
              ),
            ),
          );
        },
      ),
    );
  }
}