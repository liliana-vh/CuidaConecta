import 'package:flutter/material.dart';

class BotonMenuAm extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  final bool destacado;

  final VoidCallback? onPressed;

  const BotonMenuAm({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.destacado = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final Color colorFondo = destacado 
        ? const Color(0xFFFF941F) 
        : Colors.black;

    final Color colorContenido = destacado 
        ? Colors.black87 
        : Colors.white;

    final Color colorFlecha = destacado 
        ? Colors.black54 
        : Colors.white70;

    return Card(
      elevation: 4,
      margin: EdgeInsets.zero,
      color: colorFondo,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPressed ??
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Próximamente'),
                  duration: Duration(milliseconds: 800),
                ),
              );
            },
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 96),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Icon(icon, size: 48, color: colorContenido),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colorContenido,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 17,
                            color: colorContenido,
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, size: 32, color: colorFlecha),
              ],
            ),
          ),
        ),
      ),
    );
  }
}