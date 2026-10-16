import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../model/solicitud/solicitud.dart';
import 'estado_visual.dart';

class TarjetaSolicitud extends StatelessWidget {
  final Solicitud solicitud;
  final VoidCallback onTap;

  // true (cuidador) muestra el nombre del cliente / false (cliente) muestra el nombre del cuidador.
  final bool mostrarNombreCliente;

  const TarjetaSolicitud({
    super.key,
    required this.solicitud,
    required this.onTap,
    this.mostrarNombreCliente = true,
  });

  static final NumberFormat _moneda = NumberFormat.currency(
    locale: 'es_CL',
    customPattern: '\$#,##0',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final color = EstadoVisual.colorDe(solicitud.estado);
    final proxima = solicitud.proximaSesion;
    final nombre =
        mostrarNombreCliente ? solicitud.nombreCliente : solicitud.nombreCuidador;

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
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      EstadoVisual.etiquetaDe(solicitud.estado).toUpperCase(),
                      style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(solicitud.servicio, style: const TextStyle(fontSize: 14)),
              const SizedBox(height: 4),
              Text(
                '${solicitud.sesiones.length} días · '
                '${solicitud.horasTotales.toStringAsFixed(solicitud.horasTotales % 1 == 0 ? 0 : 1)} horas',
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
              if (proxima != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Próxima sesión: ${DateFormat('dd/MM HH:mm').format(proxima.inicio)}',
                  style: TextStyle(fontSize: 13, color: color),
                ),
              ],
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  _moneda.format(solicitud.montoEstimado),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}