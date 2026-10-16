import 'package:flutter/material.dart';

//teclado letras am
class LetterPad extends StatelessWidget {
  final ValueSetter<String> onKeyPressed;

  const LetterPad({
    super.key,
    required this.onKeyPressed,
  });

  static const List<String> _filas = [
    'ABCDE',
    'FGHIJ',
    'KLMNÑ',
    'OPQRS',
    'TUVWX',
    'YZ',
  ];

  Widget _buildButton(
    String text,
    IconData? icon, {
    Color color = const Color.fromARGB(255, 0, 0, 0),
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: ElevatedButton(
          onPressed: () => onKeyPressed(text),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: icon != null
              ? Icon(icon, size: 26)
              : Text(
                  text,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final fila in _filas)
          Row(
            children: fila.split('').map((letra) {
              return _buildButton(letra, null);
            }).toList(),
          ),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: _buildButton('ESPACIO', null, color: const Color.fromARGB(255, 51, 51, 51)),
            ),
            Expanded(
              flex: 1,
              child: _buildButton('<', Icons.backspace_outlined, color: const Color(0xFFE51B23)),
            ),
          ],
        ),
      ],
    );
  }
}