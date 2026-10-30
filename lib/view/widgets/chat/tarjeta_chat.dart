import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../model/solicitud/estado_solicitud.dart';
import '../../../model/solicitud/solicitud.dart';
import '../../../viewmodel/utilidades/fecha_hora.dart';
import '../detalle_solicitud/estado_visual.dart';

class TarjetaChat extends StatelessWidget {
  final Solicitud solicitud;
  final VoidCallback onTap;

  final bool mostrarNombreCliente;

  const TarjetaChat({
    super.key,
    required this.solicitud,
    required this.onTap,
    this.mostrarNombreCliente = true,
  });

  String _etiqueta(Solicitud s) {
    if (s.chatEnHistorial) return 'Finalizado';
    if (s.chatActivo) return 'Activo';
    if (s.estado == EstadoSolicitud.finalizada) return 'Pago pendiente';
    return 'Cerrado por ahora';
  }

  @override
  Widget build(BuildContext context) {
    final s = solicitud;
    final color = EstadoVisual.colorDe(s.estado);
    final proxima = s.proximaSesion;
    final nombre = mostrarNombreCliente ? s.nombreCliente : s.nombreCuidador;

    final Widget lineaFecha;
    if (s.haySesionEnCurso) {
      final inicio = s.sesiones[s.indiceSesionEnCurso].inicioReal;
      lineaFecha = Text(
        inicio == null
            ? 'En curso ahora'
            : 'En curso desde las ${hhmm(inicio)}',
        style: TextStyle(fontSize: 13, color: color),
      );
    } else if (proxima != null) {
      lineaFecha = Text(
        'Próxima sesión: ${DateFormat('dd/MM HH:mm').format(proxima.inicio)}',
        style: TextStyle(fontSize: 13, color: color),
      );
    } else {
      lineaFecha = Text(
        'Semana del ${dm(s.inicioSemana)}',
        style: const TextStyle(fontSize: 13, color: Colors.black54),
      );
    }

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      nombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _etiqueta(s).toUpperCase(),
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(s.servicio, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 4),
              lineaFecha,
            ],
          ),
        ),
      ),
    );
  }
}