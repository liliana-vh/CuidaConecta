import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../widgets/letter_pad.dart';
import '../widgets/completar_perfil_am/paso_app_bar.dart';
import '../widgets/completar_perfil_am/boton_continuar_perfil.dart';
import '../../viewmodel/utilidades/manejar_tecla_texto.dart';
import '../../viewmodel/am/nombre_apellido_am_vm.dart';

class CompletarPerfilAM1View extends StatelessWidget {
  const CompletarPerfilAM1View({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NombreApellidoAMViewModel(),
      child: const _Contenido(),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NombreApellidoAMViewModel>();
    final formKey = GlobalKey<FormState>();

    void continuar() {
      if (!formKey.currentState!.validate()) return;
      context.go('/am/completar-perfil/paso-2', extra: {'nombre': vm.nombreController.text});
    }

    return Scaffold(
      appBar: const PasoAppBar(numeroPaso: 1, rutaAtras: null),
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
                      'Ingrese su PRIMER NOMBRE:',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: vm.nombreController,
                      readOnly: true,
                      showCursor: true,
                      style: const TextStyle(fontSize: 22),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person, size: 24),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().length < 2) {
                          return 'NOMBRE NO ESCRITO';
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
              onKeyPressed: (key) => manejarTeclaTexto(vm.nombreController, key),
            ),
          ),
        ],
      ),
    );
  }
}