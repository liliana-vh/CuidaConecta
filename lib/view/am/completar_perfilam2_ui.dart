import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../widgets/letter_pad.dart';
import '../widgets/completar_perfil_am/paso_app_bar.dart';
import '../widgets/completar_perfil_am/boton_continuar_perfil.dart';
import '../widgets/completar_perfil_am/texto_error_perfil.dart';
import '../../viewmodel/utilidades/manejar_tecla_texto.dart';
import '../../viewmodel/am/nombre_apellido_am_vm.dart';

class CompletarPerfilAM2View extends StatelessWidget {
  final String nombre;

  const CompletarPerfilAM2View({super.key, required this.nombre});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NombreApellidoAMViewModel(),
      child: _Contenido(nombre: nombre),
    );
  }
}

class _Contenido extends StatelessWidget {
  final String nombre;

  const _Contenido({required this.nombre});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NombreApellidoAMViewModel>();
    final formKey = GlobalKey<FormState>();

    Future<void> guardarYContinuar() async {
      if (!formKey.currentState!.validate()) return;

      final ok = await vm.guardarYContinuar(
        nombre: nombre,
        apellido: vm.apellidoController.text,
      );

      if (!context.mounted) return;
      if (ok) context.go('/am/completar-perfil/paso-3');
    }

    return Scaffold(
      appBar: const PasoAppBar(numeroPaso: 2, rutaAtras: '/am/completar-perfil/paso-1'),
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
                      'Ingrese su PRIMER APELLIDO',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: vm.apellidoController,
                      readOnly: true,
                      showCursor: true,
                      style: const TextStyle(fontSize: 22),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person_outline, size: 24),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().length < 2) {
                          return 'APELLIDO NO INGRESADO';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: BotonContinuarPerfil(
                        cargando: vm.cargando,
                        onPressed: guardarYContinuar,
                      ),
                    ),
                    TextoErrorPerfil(mensaje: vm.error),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: LetterPad(
              onKeyPressed: (key) => manejarTeclaTexto(vm.apellidoController, key),
            ),
          ),
        ],
      ),
    );
  }
}