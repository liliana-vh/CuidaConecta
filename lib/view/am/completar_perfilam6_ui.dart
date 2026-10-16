import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../widgets/number_pad.dart';
import '../widgets/completar_perfil_am/paso_app_bar.dart';
import '../widgets/completar_perfil_am/boton_continuar_perfil.dart';
import '../widgets/completar_perfil_am/texto_error_perfil.dart';
import '../../viewmodel/utilidades/manejar_tecla_texto.dart';
import '../../viewmodel/am/direccion_am_vm.dart';

class CompletarPerfilAM6View extends StatelessWidget {
  final String comuna;
  final String calle;

  const CompletarPerfilAM6View({super.key, required this.comuna, required this.calle});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DireccionAMViewModel(),
      child: _Contenido(comuna: comuna, calle: calle),
    );
  }
}

class _Contenido extends StatelessWidget {
  final String comuna;
  final String calle;

  const _Contenido({required this.comuna, required this.calle});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DireccionAMViewModel>();

    Future<void> guardarYFinalizar() async {
      final ok = await vm.guardarYFinalizar(
        comuna: comuna,
        calle: calle,
        numero: vm.numeroController.text,
      );
      if (!context.mounted) return;
      if (ok) context.go('/am/inicio');
    }

    return Scaffold(
      appBar: const PasoAppBar(numeroPaso: 6, rutaAtras: '/am/completar-perfil/paso-5'),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'ingrese NUMERO DE HOGAR:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: vm.numeroController,
                    readOnly: true,
                    showCursor: true,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 22),
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 40),
                  BotonContinuarPerfil(
                    cargando: vm.cargando,
                    onPressed: guardarYFinalizar,
                    esFinal: true,
                  ),
                  TextoErrorPerfil(mensaje: vm.error),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: NumberPad(
              onKeyPressed: (key) => manejarTeclaNumerica(vm.numeroController, key, maxLength: 6),
              enableK: false,
            ),
          ),
        ],
      ),
    );
  }
}