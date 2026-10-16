import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/am/registro_am_vm.dart';
import '../widgets/number_pad.dart';

class RegistroAdultoMayorView extends StatelessWidget {
  const RegistroAdultoMayorView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegistroAMViewModel(),
      child: _Contenido(),
    );
  }
}

class _Contenido extends StatelessWidget {
  _Contenido();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  static const Color _naranja = Color(0xFFFF941F);
  static const Color _rojo = Color(0xFFE51B23);

  Future<void> _continuar(BuildContext context, RegistroAMViewModel vm) async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final ruta = await vm.enviarCodigo();
      if (ruta != null && context.mounted) context.go(ruta);
    } catch (_) {
    }
  }

  Future<void> _verificarOTP(
    BuildContext context,
    RegistroAMViewModel vm,
  ) async {
    try {
      final ruta = await vm.verificarOTP();
      if (context.mounted) context.go(ruta);
    } catch (_) {
    }
  }

  Widget _buildCampoRegistro(
    RegistroAMViewModel vm, {
    required String etiqueta,
    required IconData icono,
    required TextEditingController controller,
    required String nombreCampo,
    String? prefijo,
  }) {
    final activo = vm.campoActivo == nombreCampo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          etiqueta,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: () => vm.seleccionarCampo(nombreCampo),
          showCursor: activo,
          style: const TextStyle(fontSize: 20),
          decoration: InputDecoration(
            prefixIcon: Icon(icono, size: 22),
            prefixText: prefijo,
            border: const OutlineInputBorder(),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: activo ? _rojo : Colors.grey,
                width: activo ? 3 : 1,
              ),
            ),
          ),
          validator: (value) {
            if (nombreCampo == 'rut') {
              if (value == null || value.isEmpty) return 'RUT NO ESCRITO';
              if (!vm.validarRut(value)) return 'RUT NO VALIDO';
              return null;
            }
            if (value == null ||
                value.isEmpty ||
                value.length != 9 ||
                !value.startsWith('9')) {
              return 'EJEMPLO: 912345678';
            }
            return null;
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RegistroAMViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear cuenta', style: TextStyle(fontSize: 25)),
        backgroundColor: _naranja,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!vm.codigoEnviado) ...[
                      _buildCampoRegistro(
                        vm,
                        etiqueta: 'Ingrese su RUT:',
                        icono: Icons.badge,
                        controller: vm.rutController,
                        nombreCampo: 'rut',
                      ),
                      const SizedBox(height: 12),
                      _buildCampoRegistro(
                        vm,
                        etiqueta: 'Ingrese su NUMERO DE TELEFONO:',
                        icono: Icons.phone,
                        controller: vm.telefonoController,
                        nombreCampo: 'telefono',
                        prefijo: '+56 ',
                      ),
                      const SizedBox(height: 14),
                      Center(
                        child: vm.cargando
                            ? const CircularProgressIndicator()
                            : ElevatedButton.icon(
                                onPressed: () => _continuar(context, vm),
                                icon: const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 22,
                                ),
                                label: const Text(
                                  'Continuar',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _rojo,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 28,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                              ),
                      ),
                    ] else ...[
                      const Text(
                        'Ingrese el código',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Espere unos segundos...',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: vm.otpController,
                        readOnly: true,
                        showCursor: true,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 20),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Center(
                        child: vm.cargando
                            ? const CircularProgressIndicator()
                            : ElevatedButton.icon(
                                onPressed: () => _verificarOTP(context, vm),
                                icon: const Icon(
                                  Icons.check_circle_outline,
                                  size: 22,
                                ),
                                label: const Text(
                                  'Continuar',
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _rojo,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 28,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                              ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    if (vm.error != null)
                      Text(
                        vm.error!,
                        style: const TextStyle(
                          color: _rojo,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: NumberPad(
              onKeyPressed: vm.manejarTecla,
              enableK: !vm.codigoEnviado && vm.campoActivo == 'rut',
            ),
          ),
        ],
      ),
    );
  }
}
