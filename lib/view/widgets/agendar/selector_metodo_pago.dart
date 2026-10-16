import 'package:flutter/material.dart';

import '../../../../model/solicitud/estado_solicitud.dart';
import '../../../../viewmodel/agendar_vm.dart';

// Selector metodo pago
class SelectorMetodoPago extends StatelessWidget {
  final AgendarViewModel vm;

  const SelectorMetodoPago({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    if (!vm.puedeElegirTarjeta) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue),
            SizedBox(width: 10),
            Expanded(child: Text('Pago exclusivo en efectivo.')),
          ],
        ),
      );
    }

    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(
          value: MetodoPago.efectivo,
          label: Text('Efectivo'),
          icon: Icon(Icons.money),
        ),
        ButtonSegment(
          value: MetodoPago.tarjeta,
          label: Text('Tarjeta'),
          icon: Icon(Icons.credit_card),
        ),
      ],
      selected: {vm.metodoPago},
      onSelectionChanged: (s) => vm.seleccionarMetodoPago(s.first),
    );
  }
}