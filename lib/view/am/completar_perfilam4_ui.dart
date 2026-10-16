import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../widgets/completar_perfil_am/paso_app_bar.dart';
import '../widgets/completar_perfil_am/boton_continuar_perfil.dart';
import '../widgets/completar_perfil_am/texto_error_perfil.dart';
import '../../viewmodel/am/direccion_am_vm.dart';

class CompletarPerfilAM4View extends StatelessWidget {
  const CompletarPerfilAM4View({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DireccionAMViewModel(),
      child: const _Contenido(),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DireccionAMViewModel>();

    void continuar() {
      if (vm.comunaSeleccionada == null) {
        vm.error = 'COMUNA NO ELEGIDA';
        vm.notifyListeners();
        return;
      }

      context.go('/am/completar-perfil/paso-5', extra: {'comuna': vm.comunaSeleccionada});
    }

    return Scaffold(
      appBar: const PasoAppBar(numeroPaso: 4, rutaAtras: '/am/completar-perfil/paso-3'),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Ingrese COMUNA DONDE VIVE:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: vm.comunaSeleccionada,
              style: const TextStyle(fontSize: 22, color: Colors.black),
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: DireccionAMViewModel.comunasDisponibles
                  .map((comuna) => DropdownMenuItem(value: comuna, child: Text(comuna)))
                  .toList(),
              onChanged: vm.seleccionarComuna,
            ),

            const SizedBox(height: 40),

            BotonContinuarPerfil(cargando: false, onPressed: continuar),

            TextoErrorPerfil(mensaje: vm.error),
          ],
        ),
      ),
    );
  }
}