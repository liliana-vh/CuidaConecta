import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../model/solicitud/solicitud.dart';

class ResumenSolicitud extends StatelessWidget {
  final Solicitud previa;
  final NumberFormat moneda;

  const ResumenSolicitud({
    super.key,
    required this.previa,
    required this.moneda,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.deepPurple.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.deepPurple.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _fila('Días elegidos', '${previa.sesiones.length}'),
            _fila(
              'Horas totales',
              previa.horasTotales.toStringAsFixed(
                previa.horasTotales % 1 == 0 ? 0 : 1,
              ),
            ),
            _fila('Tarifa por hora', moneda.format(previa.tarifaHora)),
            if (previa.requiereGarantia)
              _fila('Garantía inicial', moneda.format(previa.montoGarantia)),
            const Divider(height: 24),
            _fila(
              'Total estimado',
              moneda.format(previa.montoEstimado),
              destacado: true,
            ),
            const SizedBox(height: 10),
            Text(
              previa.textoPago,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fila(String etiqueta, String valor, {bool destacado = false}) {
    final estilo = TextStyle(
      fontSize: destacado ? 18 : 15,
      fontWeight: destacado ? FontWeight.bold : FontWeight.normal,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(etiqueta, style: estilo), Text(valor, style: estilo)],
      ),
    );
  }
}