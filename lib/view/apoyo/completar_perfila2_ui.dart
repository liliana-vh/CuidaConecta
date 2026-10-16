import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/apoyo/completar_perfila2_vm.dart';
import '../widgets/perfil/boton_continuar_flujoa.dart';

class CompletarPerfilA2View extends StatelessWidget {
  const CompletarPerfilA2View({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CompletarPerfilA2ViewModel()..cargarDatosActuales(),
      child: const _Contenido(),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido();

  static const primaryColor = Color(0xFFFF941F);

  Future<void> _guardar(BuildContext context, CompletarPerfilA2ViewModel vm) async {
    final ok = await vm.guardarDireccion();
    if (!context.mounted) return;
    if (ok) context.go('/apoyo/completar-perfil/paso-3');
  }

  AppBar _appBar() => AppBar(
        title: const Text('Completar Perfil (2/3)'),
        backgroundColor: primaryColor,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/apoyo/completar-perfil/paso-1'),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CompletarPerfilA2ViewModel>();

    if (vm.cargando) {
      return Scaffold(appBar: _appBar(), body: const Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: _appBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.location_on_outlined, size: 60, color: primaryColor),
            const SizedBox(height: 16),
            const Text(
              '¿Dónde se requiere el servicio de cuidado?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Esta dirección nos ayuda a encontrar cuidadores disponibles en tu zona.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Comuna',
                prefixIcon: Icon(Icons.map_outlined),
                border: OutlineInputBorder(),
              ),
              value: vm.comunaSeleccionada,
              items: CompletarPerfilA2ViewModel.comunasDisponibles
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: vm.seleccionarComuna,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: vm.calleController,
              decoration: const InputDecoration(
                labelText: 'Calle / Avenida',
                prefixIcon: Icon(Icons.add_road),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: vm.numeroController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Número de casa / Depto',
                prefixIcon: Icon(Icons.home_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: vm.detallesController,
              decoration: const InputDecoration(
                labelText: 'Referencia o detalles adicionales (Opcional)',
                hintText: 'Ej: Depto 402, timbre falla...',
                prefixIcon: Icon(Icons.info_outline),
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),

            const SizedBox(height: 15),
            if (vm.error != null)
              Text(vm.error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),

            const SizedBox(height: 25),
            BotonContinuarFlujo(cargando: vm.guardando, onPressed: () => _guardar(context, vm)),
          ],
        ),
      ),
    );
  }
}