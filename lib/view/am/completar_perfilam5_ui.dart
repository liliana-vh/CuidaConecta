import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../widgets/letter_pad.dart';
import '../widgets/completar_perfil_am/paso_app_bar.dart';
import '../widgets/completar_perfil_am/boton_continuar_perfil.dart';
import '../../viewmodel/utilidades/manejar_tecla_texto.dart';
import '../../viewmodel/am/direccion_am_vm.dart';

class CompletarPerfilAM5View extends StatelessWidget {
  final String comuna;

  const CompletarPerfilAM5View({super.key, required this.comuna});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DireccionAMViewModel(),
      child: _Contenido(comuna: comuna),
    );
  }
}

class _Contenido extends StatelessWidget {
  final String comuna;

  const _Contenido({required this.comuna});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DireccionAMViewModel>();
    final formKey = GlobalKey<FormState>();

    void continuar() {
      if (!formKey.currentState!.validate()) return;

      context.go(
        '/am/completar-perfil/paso-6',
        extra: {'comuna': comuna, 'calle': vm.calleController.text},
      );
    }

    return Scaffold(
      appBar: const PasoAppBar(numeroPaso: 5, rutaAtras: '/am/completar-perfil/paso-4'),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Ingrese CALLE DONDE VIVE:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: vm.calleController,
                      readOnly: true,
                      showCursor: true,
                      style: const TextStyle(fontSize: 22),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().length < 3) {
                          return 'CALLE NO ESCRITA';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: BotonContinuarPerfil(cargando: false, onPressed: continuar),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: LetterPad(
              onKeyPressed: (key) => manejarTeclaTexto(vm.calleController, key),
            ),
          ),
        ],
      ),
    );
  }
}