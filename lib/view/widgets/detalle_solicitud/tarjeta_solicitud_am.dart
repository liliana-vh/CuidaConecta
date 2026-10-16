import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../model/solicitud/estado_solicitud.dart';
import '../../../model/solicitud/solicitud.dart';

// Tarjeta de solicitud para am
class TarjetaSolicitudAM extends StatelessWidget {
  final Solicitud solicitud;
  final VoidCallback onTap;

  const TarjetaSolicitudAM({super.key, required this.solicitud, required this.onTap});

  static const Color _verde = Color(0xFF1B7A1B);
  static const Color _naranja = Color(0xFFFF941F);
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
    EstadoSolicitud.finalizada: 'Terminado',
    EstadoSolicitud.rechazada: 'No fue aceptado',
  };

  Color get _color {
    switch (solicitud.estado) {
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
    final proxima = solicitud.proximaSesion;
    final color = _color;

    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color, width: 2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                solicitud.nombreCuidador,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 4),
              Text(
                solicitud.servicio,
                style: const TextStyle(fontSize: 18, color: Colors.black),
              ),
              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _mensajes[solicitud.estado] ?? solicitud.estado,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
                ),
              ),

              if (proxima != null) ...[
                const SizedBox(height: 10),
                Text(
                  'Próximo día: ${DateFormat('EEEE dd/MM', 'es').format(proxima.inicio)} '
                  'a las ${DateFormat('HH:mm').format(proxima.inicio)}',
                  style: const TextStyle(fontSize: 17, color: Colors.black),
                ),
              ],

              const SizedBox(height: 10),
              Text(
                'Total: ${_moneda.format(solicitud.montoEstimado)}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              ),

              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('Ver más'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}