import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SeleccionUsuario extends StatelessWidget {
  const SeleccionUsuario({super.key});

  @override
  Widget build(BuildContext context) {
    Widget botonUsuario(String texto, String tipoUsuario) {
      return ElevatedButton(
        onPressed: () {
          context.push('/auth/seleccion-iniciar', extra: tipoUsuario);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color.fromARGB(255, 0, 0, 0),
          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          texto,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Volver'),
        backgroundColor: const Color(0xFFFF941F),
        centerTitle: true,
      ),

      body: Stack(
        children: [
          // FONDO AMARILLO///////////////////////////////////////////////////////////////////////////
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFFFFE06A),
          ),

          // PARTE VERDE/////////////////////////////////////////////////////////////////////////////////
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 270,
            child: ClipPath(
              clipper: CurvaVerdeClipper(),
              child: Container(color: const Color(0xFFA9C33F)),
            ),
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment
                    .center,
                children: [
                  const Text(
                    '¿Qué tipo de usuario es?',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 10),

                  botonUsuario('Cuidador', 'Cuidador'),

                  const SizedBox(height: 20),

                  botonUsuario('Apoyo', 'Apoyo'),

                  const SizedBox(height: 20),

                  botonUsuario('Adulto Mayor', 'Adulto Mayor'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// CURVA VERDE///////////////////////////////////////////////////////////////////////////////////////

class CurvaVerdeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.moveTo(0, 35);

    path.quadraticBezierTo(size.width * 0.5, -25, size.width, 35);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
