import 'package:flutter/material.dart';

//boton CONTINUAR para apoyo y cuidador, experimento implementcion wizard aplicar a am?
class BotonContinuarFlujo extends StatelessWidget {
  final bool cargando;
  final VoidCallback onPressed;
  final bool esFinal;
  final Color color;

  const BotonContinuarFlujo({
    super.key,
    required this.cargando,
    required this.onPressed,
    this.esFinal = false,
    this.color = const Color.fromARGB(255, 207, 29, 29),
  });

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(esFinal ? Icons.check_circle : Icons.arrow_forward, color: Colors.white),
        label: Text(
          esFinal ? 'Finalizar registro' : 'Continuar',
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}