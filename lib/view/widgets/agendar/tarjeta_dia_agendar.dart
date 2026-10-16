import 'package:flutter/material.dart';

import '../../../../model/solicitud/agenda.dart';
import '../../../../model/solicitud/agenda_semanal.dart';
import '../../../viewmodel/utilidades/fecha_hora.dart';
import '../../../viewmodel/agendar_vm.dart';


class TarjetaDiaAgendar extends StatelessWidget {
  final AgendarViewModel vm;
  final DiaAgenda dia;

  const TarjetaDiaAgendar({super.key, required this.vm, required this.dia});

  static String _rango(Intervalo i) => '${hhmm(i.inicio)} - ${hhmm(i.fin)}';

  @override
  Widget build(BuildContext context) {
    final sel = dia.seleccion;
    final fin = sel?.fin;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: dia.habilitado ? 2 : 0,
      color: dia.habilitado ? Colors.white : Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${dia.nombre} ${dia.fecha.day}/${dia.fecha.month}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (dia.bloqueo != null)
                        Text(
                          dia.bloqueo!,
                          style: const TextStyle(color: Colors.black54),
                        ),
                    ],
                  ),
                ),
                if (dia.habilitado)
                  Switch(
                    value: dia.seleccionado,
                    onChanged: (v) => vm.alternarDia(dia.fecha, v),
                  ),
              ],
            ),

            if (dia.ocupados.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Ocupado: ${dia.ocupados.map(_rango).join(', ')}',
                  style: TextStyle(color: Colors.red.shade700, fontSize: 14),
                ),
              ),

            if (dia.habilitado && dia.libres.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Libre: ${dia.libres.map(_rango).join(', ')}',
                  style: TextStyle(color: Colors.green.shade800, fontSize: 14),
                ),
              ),

            if (sel != null) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.schedule, size: 18),
                    label: Text('Inicio: ${hhmm(sel.inicio)}'),
                    onPressed: () => _elegirHora(context, sel),
                  ),
                  DropdownButton<int>(
                    value: sel.horas,
                    items: vm.opcionesHoras
                        .map(
                          (h) => DropdownMenuItem(
                            value: h,
                            child: Text('$h horas'),
                          ),
                        )
                        .toList(),
                    onChanged: (h) {
                      if (h != null) vm.fijarHoras(dia.fecha, h);
                    },
                  ),
                  if (fin != null) Text('Termina a las ${hhmm(fin)}'),
                ],
              ),
              if (dia.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    dia.error!,
                    style: TextStyle(color: Colors.red.shade700, fontSize: 14),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _elegirHora(BuildContext context, Intervalo sel) async {
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(sel.inicio),
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (hora != null) vm.fijarInicio(dia.fecha, hora);
  }
}