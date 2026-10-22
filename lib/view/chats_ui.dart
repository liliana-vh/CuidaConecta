import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../model/solicitud/estado_solicitud.dart';
import '../model/solicitud/solicitud.dart';
import '../viewmodel/chats_vm.dart';
import '../viewmodel/solicitudes_vm.dart';
import 'widgets/aviso/lista_en_vivo.dart';
import '../viewmodel/utilidades/fecha_hora.dart';
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

    // misma tarjeta para las 3 secciones
    Widget tarjeta(BuildContext context, Solicitud s) => _TarjetaChat(
          solicitud: s,
          esCuidador: esCuidador,
          onTap: () => context.push('$rutaBase/chat/${s.id}'),
        );

    return ListView(
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
              itemBuilder: (context, s) => _TarjetaChat(
                solicitud: s,
                esCuidador: esCuidador,
                onTap: () => context.push('$_rutaBase/chat/${s.id}'),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TarjetaChat extends StatelessWidget {
  final Solicitud solicitud;
  final bool esCuidador;
  final VoidCallback onTap;

  const _TarjetaChat({
    required this.solicitud,
    required this.esCuidador,
    required this.onTap,
  });

  // fecha/hora que se muestra según el estado del servicio
  String _textoFecha(Solicitud s) {
    if (s.haySesionEnCurso) {
      final inicio = s.sesiones[s.indiceSesionEnCurso].inicioReal;
      return inicio == null
          ? 'En curso ahora'
          : 'En curso desde las ${hhmm(inicio)}';
    }
    final proxima = s.proximaSesion;
    if (proxima != null) {
      return 'Próximo: ${nombreDia(proxima.inicio)} ${dm(proxima.inicio)}, '
          '${hhmm(proxima.inicio)} a ${hhmm(proxima.fin)}';
    }
    return 'Semana del ${dm(s.inicioSemana)}';
  }

  @override
  Widget build(BuildContext context) {
    final s = solicitud;

    final String etiqueta;
    final Color color;
    if (s.chatEnHistorial) {
      etiqueta = 'Finalizado';
      color = Colors.grey;
    } else if (s.chatActivo) {
      etiqueta = 'Activo';
      color = Colors.green;
    } else if (s.estado == EstadoSolicitud.finalizada) {
      etiqueta = 'Pago pendiente';
      color = Colors.blue;
    } else {
      etiqueta = 'Cerrado por ahora';
      color = Colors.orange;
    }

    return Card(
      child: ListTile(
        onTap: onTap,
        isThreeLine: true,
        leading: Icon(Icons.chat_bubble_outline, color: color),
        title: Text(esCuidador ? s.nombreCliente : s.nombreCuidador),
        subtitle: Text('${s.servicio}\n${_textoFecha(s)}'),
        trailing: Text(etiqueta, style: TextStyle(color: color)),
      ),
    );
  }
}