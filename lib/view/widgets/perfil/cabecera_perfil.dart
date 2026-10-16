import 'package:flutter/material.dart';

//para cuidador
class CabeceraPerfil extends StatelessWidget {
  final String? fotoUrl;
  final String nombreCompleto;
  final String correo;
  final String? descripcion;
  final Color colorAvatar;
  final IconData iconoFallback;

  const CabeceraPerfil({
    super.key,
    required this.fotoUrl,
    required this.nombreCompleto,
    required this.correo,
    this.descripcion,
    required this.colorAvatar,
    required this.iconoFallback,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: colorAvatar,
          backgroundImage: fotoUrl != null ? NetworkImage(fotoUrl!) : null,
          child: fotoUrl == null ? Icon(iconoFallback, size: 50, color: Colors.black) : null,
        ),
        const SizedBox(height: 15),
        Text(
          nombreCompleto,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(correo, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
        if (descripcion != null && descripcion!.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Text(
              descripcion!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
      ],
    );
  }
}