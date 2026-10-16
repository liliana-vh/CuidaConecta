import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/agendar_vm.dart';
import '../widgets/agendar/resumen_solicitud.dart';
import '../widgets/agendar/selector_metodo_pago.dart';
import '../widgets/agendar/tarjeta_dia_agendar.dart';

class AgendarView extends StatelessWidget {
  final String idAviso;

  const AgendarView({super.key, required this.idAviso});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AgendarViewModel(idAviso)..cargar(),
      child: const _Contenido(),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido();

  static const Color _naranja = Color(0xFFFF941F);

  static final NumberFormat _moneda = NumberFormat.currency(
    locale: 'es_CL',
    customPattern: '\$#,##0',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AgendarViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Contratar servicio',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: _naranja,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: _buildCuerpo(context, vm),
      ),
    );
  }

  Widget _buildCuerpo(BuildContext context, AgendarViewModel vm) {
    if (vm.cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    final aviso = vm.aviso;
    if (vm.errorCarga != null || aviso == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            vm.errorCarga ?? 'Este aviso ya no está disponible.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ),
      );
    }

    final previa = vm.vistaPrevia;
    final error = vm.errorGeneral;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          aviso.nombreCuidador,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(
          '${_moneda.format(aviso.tarifaHora)} por hora'
          '${aviso.comuna.isEmpty ? '' : ' · ${aviso.comuna}'}',
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
        const SizedBox(height: 16),

        DropdownButtonFormField<String>(
          value: vm.servicioSeleccionado,
          hint: const Text('Seleccione un servicio'),
          items: aviso.servicios
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: vm.seleccionarServicio,
          decoration: const InputDecoration(
            labelText: 'Servicio',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.medical_services_outlined),
          ),
        ),
        const SizedBox(height: 16),

        DropdownButtonFormField<DateTime>(
          value: vm.semanaSeleccionada,
          items: vm.semanas
              .map(
                (s) => DropdownMenuItem(
                  value: s,
                  child: Text(vm.etiquetaSemana(s)),
                ),
              )
              .toList(),
          onChanged: (s) {
            if (s != null) vm.cambiarSemana(s);
          },
          decoration: const InputDecoration(
            labelText: 'Semana',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.calendar_month),
          ),
        ),
        const SizedBox(height: 16),

        ...vm.diasDeLaSemana.map((dia) => TarjetaDiaAgendar(vm: vm, dia: dia)),

        const SizedBox(height: 8),

        const Text(
          'Método de pago',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SelectorMetodoPago(vm: vm),
        const SizedBox(height: 20),

        if (previa != null) ResumenSolicitud(previa: previa, moneda: _moneda),
        const SizedBox(height: 16),

        if (error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.orange.shade800, fontSize: 14),
            ),
          ),

        ElevatedButton(
          onPressed:
              vm.puedeEnviar && !vm.enviando ? () => _enviar(context, vm) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _naranja,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          child: vm.enviando
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Enviar solicitud'),
        ),

        const SizedBox(height: 36),
      ],
    );
  }

  Future<void> _enviar(BuildContext context, AgendarViewModel vm) async {
    final error = await vm.enviar();
    if (!context.mounted) return;

    final mensajes = ScaffoldMessenger.of(context);
    if (error != null) {
      mensajes.showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
      return;
    }

    mensajes.showSnackBar(
      const SnackBar(content: Text('Solicitud enviada. El cuidador debe aceptarla.')),
    );
    context.pop();
  }
}