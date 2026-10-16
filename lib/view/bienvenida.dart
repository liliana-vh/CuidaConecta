import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Bienvenida extends StatelessWidget {
  const Bienvenida({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [

            // FONDO PRINCIPAL//////////////////////////////////////////////////////////////////
            Positioned.fill(
              child: Column(
                children: [

                  // Espacio blanco superior
                  const SizedBox(height: 120),

                  Expanded(
                    child: Stack(
                      children: [

                        // FONDO NARANJA / AMARILLO//////////////////////////////////////////////////
                        Positioned.fill(
                          child: ClipPath(
                            clipper: CurvaSuperiorClipper(),
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFFF941F),
                                    Color(0xFFFFE06A),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // PARTE VERDE/////////////////////////////////////////////////////////////////
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
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // LOGO + NOMBRE//////////////////////////////////////////////////////////////////////
            Positioned(
              top: 18,
              left: 35,
              right: 35,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Image.asset(
                    'lib/assets/logo_1.png',
                    width: 120,
                    height: 120,
                  ),

                  const SizedBox(width: 12),

                  const Text(
                    'Cuida\nConecta',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      height: 1.30,
                    ),
                  ),
                ],
              ),
            ),

            // TEXTO PRINCIPAL///////////////////////////////////////////////////////////////////////
            const Positioned(
              top: 180,
              left: 35,
              right: 35,
              child: Text(
                'Conectando a quienes\nnecesitan cuidado con\nquienes lo brindan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 25,
                  height: 1.15,
                ),
              ),
            ),

            // IMAGEN DE LAS PERSONAS////////////////////////////////////////////////////
            Positioned(
              top: 295,
              left: 20,
              right: 20,
              child: Image.asset(
                'lib/assets/bienvenida_1.png',
                height: 250,
                fit: BoxFit.contain,
              ),
            ),

            // BOTÓN INICIAR////////////////////////////////////////////////////////////////
            Positioned(
              left: 45,
              right: 45,
              bottom: 55,
              child: SizedBox(
                height: 70,
                child: ElevatedButton(
                  onPressed: () {
                    context.push('/auth/seleccion-usuario');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE51B23),
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    'Iniciar',
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// CURVA NARANJA SUPERIOR/////////////////////////////////////////////////////////////

class CurvaSuperiorClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.moveTo(0, 70);

    path.quadraticBezierTo(
      size.width * 0.5,
      -10,
      size.width,
      65,
    );

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


// CURVA VERDE INFERIOR/////////////////////////////////////////////////////////////////////////

class CurvaVerdeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Comienza en el lado izquierdo
    path.moveTo(0, 35);

    // Una sola curva suave, igual que la naranja
    path.quadraticBezierTo(
      size.width * 0.5,
      -40,
      size.width,
      35,
    );

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