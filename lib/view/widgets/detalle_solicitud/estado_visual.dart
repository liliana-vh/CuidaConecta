import 'package:flutter/material.dart';

import '../../../model/solicitud/estado_solicitud.dart';


class EstadoVisual {
  static const Map<String, Color> _colores = {
    EstadoSolicitud.pendiente: Colors.orange,
    EstadoSolicitud.aceptada: Colors.green,
    EstadoSolicitud.enProgreso: Colors.blue,
    EstadoSolicitud.finalizada: Colors.indigo,
    EstadoSolicitud.rechazada: Colors.grey,
  };

  static const Map<String, String> _etiquetas = {
    EstadoSolicitud.pendiente: 'Pendiente',
    EstadoSolicitud.aceptada: 'Aceptada',
    EstadoSolicitud.enProgreso: 'En progreso',
    EstadoSolicitud.finalizada: 'Finalizada',
    EstadoSolicitud.rechazada: 'Rechazada',
  };

  static Color colorDe(String estado) => _colores[estado] ?? Colors.grey;
  static String etiquetaDe(String estado) => _etiquetas[estado] ?? estado;
}

//formato escritura estados
class ChipEstado extends StatelessWidget {
  final String estado;
  const ChipEstado(this.estado, {super.key});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        EstadoVisual.etiquetaDe(estado).toUpperCase(),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      backgroundColor: EstadoVisual.colorDe(estado).withValues(alpha: 0.12),
    );
  }
}