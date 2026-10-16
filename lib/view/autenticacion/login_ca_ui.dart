import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/autenticacion/login_ca_vm.dart';

class LoginCuidadorApoyoView extends StatelessWidget {
  const LoginCuidadorApoyoView({super.key});

  @override
  Widget build(BuildContext context) {
    final stateExtra = GoRouterState.of(context).extra;
    String tipoUsuario = 'Cuidador';
    if (stateExtra is String) {
      tipoUsuario = stateExtra;
    } else if (stateExtra is Map && stateExtra['tipoUsuario'] is String) {
      tipoUsuario = stateExtra['tipoUsuario'];
    }

    return ChangeNotifierProvider(
      create: (_) => LoginCAViewModel(),
      child: _Contenido(tipoUsuario: tipoUsuario),
    );
  }
}

class _Contenido extends StatelessWidget {
  final String tipoUsuario;

  const _Contenido({required this.tipoUsuario});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LoginCAViewModel>();

    Future<void> iniciarSesion() async {
      final ruta = await vm.iniciarSesion(tipoUsuario);
      if (!context.mounted) return;
      if (ruta != null) context.go(ruta);
    }

    Future<void> recuperarContrasena() async {
      final ok = await vm.enviarCorreoRecuperacion();
      if (!context.mounted) return;
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Se envió un correo de recuperación a ${vm.correoController.text.trim()}',
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Iniciar Sesión - $tipoUsuario'),
        backgroundColor: const Color(0xFFFF941F),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: vm.correoController,
              decoration: const InputDecoration(
                labelText: 'Ingrese su Correo Electrónico',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),

            TextField(
              controller: vm.contrasenaController,
              obscureText: vm.ocultarContrasena,
              decoration: InputDecoration(
                labelText: 'Ingrese su Contraseña',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(vm.ocultarContrasena ? Icons.visibility_off : Icons.visibility),
                  onPressed: vm.alternarOcultarContrasena,
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (vm.error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  vm.error!,
                  style: const TextStyle(color: Color(0xFFE51B23)),
                  textAlign: TextAlign.center,
                ),
              ),

            vm.cargando
                ? const CircularProgressIndicator()
                : Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: iniciarSesion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE51B23),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Ingresar', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                      TextButton(
                        onPressed: recuperarContrasena,
                        child: const Text(
                          '¿Contraseña olvidada?',
                          style: TextStyle(color: Color(0xFFE51B23)),
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}