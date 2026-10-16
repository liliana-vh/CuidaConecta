import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SeleccionIniciar extends StatelessWidget {
  const SeleccionIniciar({super.key});

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra;
    final String tipoUsuario =
        (extra is String && extra.isNotEmpty) ? extra : 'Cuidador';

    // Mapear rutas según el tipo de usuario///////////////////////////////////////////////////////////
    String obtenerRuta(String accion) {
      switch (tipoUsuario) {
        case 'Adulto Mayor':
          return accion == 'login' ? '/auth/login-am' : '/auth/registro-am';
        case 'Apoyo':
        case 'Cuidador':
        default:
          return accion == 'login'
              ? '/auth/login-cuidador-apoyo'
              : '/auth/registro-cuidador-apoyo';
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido $tipoUsuario'),
        backgroundColor: const Color(0xFFFF941F),
        centerTitle: true,
      ),

      body: Stack(
        children: [
          // FONDO AMARILLO///////////////////////////////////////////////////////////
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFFFFE06A),
          ),

          // PARTE VERDE////////////////////////////////////////////////////////////////////////////
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 270,
            child: ClipPath(
              clipper: CurvaVerdeClipper(),
              child: Container(
                color: const Color(0xFFA9C33F),
              ),
            ),
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '¿Qué desea hacer como $tipoUsuario?',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black, 
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  ElevatedButton(
                    onPressed: () {
                      context.push(
                        obtenerRuta('login'),
                        extra: tipoUsuario,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color.fromARGB(255, 37, 60, 90),
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 50,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Iniciar Sesión',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {
                      context.push(
                        obtenerRuta('registro'),
                        extra: tipoUsuario,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 50,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Registrarse',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class CurvaVerdeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 35);
    path.quadraticBezierTo(
      size.width * 0.5,
      -25,
      size.width,
      35,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}