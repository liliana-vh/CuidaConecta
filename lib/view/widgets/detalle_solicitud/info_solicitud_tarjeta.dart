import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../model/solicitud/estado_solicitud.dart';
import '../../../model/solicitud/solicitud.dart';

class InfoSolicitudTarjeta extends StatelessWidget {
  final Solicitud solicitud;

  // true (cuidador) muestra el nombre del cliente / false (cliente) muestra el nombre del cuidador.
  final bool mostrarNombreCliente;

  const InfoSolicitudTarjeta({
    super.key,
    required this.solicitud,
    this.mostrarNombreCliente = true,
  });

  static const Color _naranja = Color(0xFFFF941F);

  static final NumberFormat _moneda = NumberFormat.currency(
    locale: 'es_CL',
    customPattern: '\$#,##0',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final s = solicitud;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _fila(
              Icons.person,
              mostrarNombreCliente ? 'Cliente' : 'Cuidador',
              mostrarNombreCliente ? s.nombreCliente : s.nombreCuidador,
            ),
            _fila(Icons.work, 'Servicio', s.servicio),
            _fila(Icons.place, 'Comuna', s.comuna),
            _fila(
              Icons.attach_money,
              'Total estimado',
              _moneda.format(s.montoEstimado),
            ),
            _fila(
              Icons.payment,
              'Método de pago',
              s.metodoPago == MetodoPago.tarjeta ? 'Tarjeta' : 'Efectivo',
            ),
            if (s.requiereGarantia)
              _fila(
                Icons.shield_outlined,
                'Garantía inicial',
                s.garantiaPagada
                    ? '${_moneda.format(s.montoGarantia)} (pagada)'
                    : '${_moneda.format(s.montoGarantia)} (pendiente de pago)',
              ),
            _fila(
              Icons.event,
              'Fecha de pago',
              DateFormat('EEEE dd/MM', 'es').format(s.fechaPago),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fila(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: _naranja),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}