import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../widgets/number_pad.dart';
import '../widgets/completar_perfil_am/paso_app_bar.dart';
import '../widgets/completar_perfil_am/boton_continuar_perfil.dart';
import '../widgets/completar_perfil_am/texto_error_perfil.dart';
import '../../viewmodel/utilidades/manejar_tecla_texto.dart';
import '../../viewmodel/am/edad_am_vm.dart';

class CompletarPerfilAM3View extends StatelessWidget {
  const CompletarPerfilAM3View({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EdadAMViewModel(),
      child: const _Contenido(),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EdadAMViewModel>();

    Future<void> guardarYContinuar() async {
      final ok = await vm.guardarYContinuar();
      if (!context.mounted) return;
      if (ok) context.go('/am/completar-perfil/paso-4');
    }

    return Scaffold(
      appBar: const PasoAppBar(numeroPaso: 3, rutaAtras: '/am/completar-perfil/paso-2'),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Ingrese AÑOS DE EDAD:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  TextFormField(
                    controller: vm.edadController,
                    readOnly: true,
                    showCursor: true,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 28),
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                  ),

                  const SizedBox(height: 40),

                  BotonContinuarPerfil(cargando: vm.cargando, onPressed: guardarYContinuar),

                  TextoErrorPerfil(mensaje: vm.error),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: NumberPad(
              onKeyPressed: (key) => manejarTeclaNumerica(vm.edadController, key, maxLength: 2),
              enableK: false,
            ),
          ),
        ],
      ),
    );
  }
}