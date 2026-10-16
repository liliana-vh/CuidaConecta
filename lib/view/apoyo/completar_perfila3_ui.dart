import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../viewmodel/apoyo/completar_perfila3_vm.dart';
import '../widgets/perfil/boton_continuar_flujoa.dart';

class CompletarPerfilA3View extends StatelessWidget {
  const CompletarPerfilA3View({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CompletarPerfilA3ViewModel()..cargarDatosActuales(),
      child: const _Contenido(),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido();

  static const primaryColor = Color(0xFFFF941F);

  Future<void> _guardar(
    BuildContext context,
    CompletarPerfilA3ViewModel vm,
  ) async {
    final ok = await vm.guardarYFinalizar();
    if (!context.mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Perfil completado con éxito!')),
      );
      context.go('/apoyo/inicio');
    }
  }

  AppBar _appBar() => AppBar(
    title: const Text('Completar perfil (3/3)'),
    backgroundColor: primaryColor,
    leading: Builder(
      builder: (context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.go('/apoyo/completar-perfil/paso-2'),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CompletarPerfilA3ViewModel>();

    if (vm.cargando) {
      return Scaffold(
        appBar: _appBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: _appBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cuéntenos sobre la persona que recibirá el servicio.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),

            TextFormField(
              controller: vm
                  .edadController,
              decoration: const InputDecoration(
                labelText: 'Edad del adulto mayor',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.cake),
                counterText: '',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 2,
            ),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: '¿Cuál es su relación con él/ella?',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.family_restroom),
              ),
              value: vm.relacionSeleccionada,
              items: CompletarPerfilA3ViewModel.relaciones
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: vm.seleccionarRelacion,
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Condición principal',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.health_and_safety),
              ),
              value: vm.condicionSeleccionada,
              items: CompletarPerfilA3ViewModel.condiciones
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: vm.seleccionarCondicion,
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Nivel de dependencia',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.accessibility_new),
              ),
              value: vm.dependenciaSeleccionada,
              items: CompletarPerfilA3ViewModel.nivelesDependencia
                  .map((n) => DropdownMenuItem(value: n, child: Text(n)))
                  .toList(),
              onChanged: vm.seleccionarDependencia,
            ),

            const SizedBox(height: 15),
            if (vm.error != null)
              Text(
                vm.error!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),

            const SizedBox(height: 25),
            BotonContinuarFlujo(
              cargando: vm.guardando,
              onPressed: () => _guardar(context, vm),
              esFinal: true,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
