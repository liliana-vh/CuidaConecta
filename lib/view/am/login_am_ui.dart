import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/am/login_am_vm.dart';
import '../widgets/autenticacion_am/boton_continuar_am.dart';
import '../widgets/autenticacion_am/campo_teclado_am.dart';
import '../widgets/number_pad.dart';

class LoginAdultoMayorView extends StatelessWidget {
  const LoginAdultoMayorView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginAMViewModel(),
      child: _Contenido(),
    );
  }
}

class _Contenido extends StatelessWidget {
  _Contenido();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  static const Color _naranja = Color(0xFFFF941F);
  static const Color _rojo = Color(0xFFE51B23);

  Future<void> _pedirCodigo(BuildContext context, LoginAMViewModel vm) async {
    if (!_formKey.currentState!.validate()) return;
    try {
      final ruta = await vm.pedirCodigo();
      if (ruta != null && context.mounted) context.go(ruta);
    } catch (_) {
    }
  }

  Future<void> _verificarOTP(BuildContext context, LoginAMViewModel vm) async {
    try {
      final ruta = await vm.verificarOTP();
      if (context.mounted) context.go(ruta);
    } catch (_) {
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LoginAMViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingresar CuidaConecta', style: TextStyle(fontSize: 20)),
        backgroundColor: _naranja,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!vm.codigoEnviado) ...[
                      const Text(
                        'Ingrese su RUT',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      CampoTecladoAM(
                        controller: vm.rutController,
                        icono: Icons.person,
                        hintText: 'Ej: 12.345.678-K',
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'RUT NO ESCRITO';
                          if (!vm.validarRut(value)) return 'RUT NO EXISTE';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: BotonContinuarAM(
                          cargando: vm.cargando,
                          onPressed: () => _pedirCodigo(context, vm),
                        ),
                      ),
                    ] else ...[
                      const Text(
                        'Ingrese el código',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Espere unos segundos...',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      CampoTecladoAM(
                        controller: vm.otpController,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: BotonContinuarAM(
                          cargando: vm.cargando,
                          icono: Icons.check_circle_outline,
                          onPressed: () => _verificarOTP(context, vm),
                        ),
                      ),
                    ],
                    const SizedBox(height: 15),
                    if (vm.error != null)
                      Text(
                        vm.error!,
                        style: const TextStyle(color: _rojo, fontWeight: FontWeight.bold),
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
              enableK: !vm.codigoEnviado,
            ),
          ),
        ],
      ),
    );
  }
}