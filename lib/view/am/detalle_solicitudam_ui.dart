import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../model/solicitud/estado_solicitud.dart';
import '../../viewmodel/detalle_solicitud_vm.dart';
import '../widgets/detalle_solicitud/tarjeta_sesion.dart';

class DetalleSolicitudAMView extends StatelessWidget {
  final String idSolicitud;

  const DetalleSolicitudAMView({super.key, required this.idSolicitud});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DetalleSolicitudViewModel(idSolicitud)..escuchar(),
      child: const _Contenido(),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido();

  static const Color _naranja = Color(0xFFFF941F);
  static const Color _verde = Color(0xFF1B7A1B);
  static const Color _rojo = Color(0xFFB3261E);

  static final NumberFormat _moneda = NumberFormat.currency(
    locale: 'es_CL',
    customPattern: '\$#,##0',
    decimalDigits: 0,
  );

  static const Map<String, String> _mensajes = {
    EstadoSolicitud.pendiente: 'Esperando que el cuidador responda',
    EstadoSolicitud.aceptada: 'Aceptado, esperando el primer día',
    EstadoSolicitud.enProgreso: 'El cuidador está trabajando ahora',
    EstadoSolicitud.finalizada: 'Este servicio ya terminó',
    EstadoSolicitud.rechazada: 'El cuidador no aceptó este pedido',
  };

  Color _colorDe(String estado) {
    switch (estado) {
      case EstadoSolicitud.pendiente:
        return _naranja;
      case EstadoSolicitud.aceptada:
      case EstadoSolicitud.enProgreso:
        return _verde;
      case EstadoSolicitud.rechazada:
        return _rojo;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DetalleSolicitudViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Su servicio', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: _naranja,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _buildCuerpo(vm),
    );
  }

  Widget _buildCuerpo(DetalleSolicitudViewModel vm) {
    if (vm.cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    final s = vm.solicitud;
    if (vm.error != null || s == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            vm.error ?? 'Esta solicitud ya no existe.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, color: Colors.black),
          ),
        ),
      );
    }

    final color = _colorDe(s.estado);
    final proxima = s.proximaSesion;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          s.nombreCuidador,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 4),
        Text(
          s.servicio,
          style: const TextStyle(fontSize: 19, color: Colors.black),
        ),
        const SizedBox(height: 16),

        // --- Estado, bien destacado ---------------------------------------
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            _mensajes[s.estado] ?? s.estado,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
        ),

        if (proxima != null) ...[
          const SizedBox(height: 16),
          Text(
            'Próximo día: ${DateFormat('EEEE dd/MM', 'es').format(proxima.inicio)} '
            'a las ${DateFormat('HH:mm').format(proxima.inicio)}',
            style: const TextStyle(fontSize: 19, color: Colors.black),
          ),
        ],

        const SizedBox(height: 20),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sobre el pago',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 10),
              Text(
                'Total: ${_moneda.format(s.montoEstimado)}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 8),
              Text(
                s.pagoRealizado
                    ? 'Ya se pagó a este cuidador.'
                    : 'Se paga en efectivo, directo al cuidador, '
                        'el ${DateFormat('EEEE dd/MM', 'es').format(s.fechaPago)}.',
                style: const TextStyle(fontSize: 18, color: Colors.black),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        if (s.sesiones.isNotEmpty) ...[
          const Text(
            'Días de servicio',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 10),
          for (final sesion in s.sesiones)
            TarjetaSesion(sesion: sesion, grande: true),
        ],
        const SizedBox(height: 20),
      ],
    );
  }
}