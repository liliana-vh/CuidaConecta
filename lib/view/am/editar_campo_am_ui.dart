import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/am/editar_campo_am_vm.dart';
import '../widgets/letter_pad.dart';
import '../widgets/number_pad.dart';
import '../widgets/completar_perfil_am/texto_error_perfil.dart';

class EditarCampoAMView extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final String campoFirestore;
  final String valorInicial;
  final bool esNumerico;
  final int maxLength;
  final TextAlign textAlign;
  final String? Function(String texto) validar;
  final dynamic Function(String texto) transformar;

  const EditarCampoAMView({
    super.key,
    required this.titulo,
    required this.icono,
    required this.campoFirestore,
    required this.valorInicial,
    required this.validar,
    required this.transformar,
    this.esNumerico = false,
    this.maxLength = 40,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditarCampoAMViewModel(
        campoFirestore: campoFirestore,
        valorInicial: valorInicial,
        esNumerico: esNumerico,
        maxLength: maxLength,
        validar: validar,
        transformar: transformar,
      ),
      child: _Contenido(titulo: titulo, icono: icono, esNumerico: esNumerico, textAlign: textAlign),
    );
  }
}

class _Contenido extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final bool esNumerico;
  final TextAlign textAlign;

  const _Contenido({required this.titulo, required this.icono, required this.esNumerico, required this.textAlign});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EditarCampoAMViewModel>();

    Future<void> guardar() async {
      final ok = await vm.guardar();
      if (!context.mounted) return;
      if (ok) Navigator.pop(context, true);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(titulo, style: const TextStyle(fontSize: 22)),
        centerTitle: true,
        backgroundColor: const Color(0xFFFF941F),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: vm.controller,
                    readOnly: true,
                    showCursor: true,
                    textAlign: textAlign,
                    style: const TextStyle(fontSize: 26),
                    decoration: InputDecoration(
                      prefixIcon: Icon(icono, size: 26),
                      border: const OutlineInputBorder(),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 24),
                  vm.guardando
                      ? const CircularProgressIndicator()
                      : ElevatedButton.icon(
                          onPressed: guardar,
                          icon: const Icon(Icons.check_circle_outline, size: 26),
                          label: const Text('Guardar', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                        ),
                  TextoErrorPerfil(mensaje: vm.error),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: esNumerico
                ? NumberPad(onKeyPressed: vm.manejarTecla, enableK: false)
                : LetterPad(onKeyPressed: vm.manejarTecla),
          ),
        ],
      ),
    );
  }
}