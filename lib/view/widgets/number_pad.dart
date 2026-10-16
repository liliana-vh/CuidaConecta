import 'package:flutter/material.dart';

//teclado numerico am
class NumberPad extends StatelessWidget {
  final ValueSetter<String> onKeyPressed;
  final bool enableK;

  const NumberPad({
    super.key,
    required this.onKeyPressed,
    this.enableK = false,
  });

  Widget _buildButton(
    String text,
    IconData? icon, {
    Color color = const Color.fromARGB(255, 0, 0, 0),
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          onPressed: () => onKeyPressed(text),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: icon != null
              ? Icon(icon, size: 30)
              : Text(
                  text,
                  style: const TextStyle(
                    fontSize: 28,
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
        Row(
          children: [
            _buildButton('1', null),
            _buildButton('2', null),
            _buildButton('3', null),
          ],
        ),
        Row(
          children: [
            _buildButton('4', null),
            _buildButton('5', null),
            _buildButton('6', null),
          ],
        ),
        Row(
          children: [
            _buildButton('7', null),
            _buildButton('8', null),
            _buildButton('9', null),
          ],
        ),
        Row(
          children: [
            enableK
                ? _buildButton('K', null, color: const Color.fromARGB(255, 0, 0, 0))
                : Expanded(child: Container(padding: const EdgeInsets.all(4.0))),
            _buildButton('0', null),
            _buildButton('<', Icons.backspace_outlined, color: const Color(0xFFE51B23),),
          ],
        ),
      ],
    );
  }
}