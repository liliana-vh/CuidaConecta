import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/agendar_vm.dart';
import '../widgets/agendar/resumen_solicitud_am.dart';
import '../widgets/agendar/tarjeta_dia_agendar_am.dart';

class AgendarAMView extends StatelessWidget {
  final String idAviso;

  const AgendarAMView({super.key, required this.idAviso});

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
          'Pedir un servicio',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: _naranja,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(child: _buildCuerpo(context, vm)),
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
            style: const TextStyle(fontSize: 20, color: Colors.black),
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
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${_moneda.format(aviso.tarifaHora)} por hora',
          style: const TextStyle(fontSize: 19, color: Colors.black),
        ),
        const SizedBox(height: 20),

        if (aviso.servicios.length > 1) ...[
          const Text(
            '¿Qué servicio necesita?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          ...aviso.servicios.map((s) {
            final elegido = vm.servicioSeleccionado == s;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => vm.seleccionarServicio(s),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: elegido ? _naranja : Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Colors.black, width: 2),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: Text(s),
                ),
              ),
            );
          }),
          const SizedBox(height: 20),
        ],

        const Text(
          '¿Qué semana?',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<DateTime>(
          value: vm.semanaSeleccionada,
          style: const TextStyle(fontSize: 18, color: Colors.black),
          decoration: const InputDecoration(border: OutlineInputBorder()),
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
        ),
        const SizedBox(height: 20),

        const Text(
          '¿Qué días quiere el servicio?',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Elija entre 2 y 7 días.',
          style: TextStyle(fontSize: 16, color: Colors.black),
        ),
        const SizedBox(height: 10),
        ...vm.diasDeLaSemana
            .where((dia) => dia.ofrecidoPorCuidador)
            .map((dia) => TarjetaDiaAgendarAM(vm: vm, dia: dia)),

        if (previa != null)
          ResumenSolicitudAM(previa: previa, moneda: _moneda),
        const SizedBox(height: 16),

        if (error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, color: Colors.black),
            ),
          ),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: vm.puedeEnviar && !vm.enviando
                ? () => _enviar(context, vm)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              textStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: vm.enviando
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Pedir este servicio'),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Future<void> _enviar(BuildContext context, AgendarViewModel vm) async {
    final error = await vm.enviar();
    if (!context.mounted) return;

    final mensajes = ScaffoldMessenger.of(context);
    if (error != null) {
      mensajes.showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    mensajes.showSnackBar(
      const SnackBar(
        content: Text(
          'Su pedido fue enviado. Espere a que el cuidador lo acepte.',
        ),
      ),
    );
    context.pop();
  }
}