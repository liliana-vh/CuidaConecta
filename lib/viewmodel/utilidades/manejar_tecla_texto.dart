import 'package:flutter/material.dart';
import 'logica_rut.dart';

void manejarTeclaTexto(TextEditingController controller, String key) {
  final textoActual = controller.text;
  final seleccion = controller.selection;

  if (key == '<') {
    if (textoActual.isNotEmpty && seleccion.start > 0) {
      final nuevoTexto = textoActual.replaceRange(seleccion.start - 1, seleccion.start, '');
      controller.value = TextEditingValue(
        text: nuevoTexto,
        selection: TextSelection.collapsed(offset: seleccion.start - 1),
      );
    }
    return;
  }

  final caracter = key == 'ESPACIO' ? ' ' : key;
  final nuevoTexto = textoActual.replaceRange(seleccion.start, seleccion.end, caracter);
  controller.value = TextEditingValue(
    text: nuevoTexto,
    selection: TextSelection.collapsed(offset: seleccion.start + 1),
  );
}

void manejarTeclaNumerica(TextEditingController controller, String key, {required int maxLength}) {
  final textoActual = controller.text;

  if (key == '<') {
    if (textoActual.isNotEmpty) {
      final nuevoTexto = textoActual.substring(0, textoActual.length - 1);
      controller.value = TextEditingValue(
        text: nuevoTexto,
        selection: TextSelection.collapsed(offset: nuevoTexto.length),
      );
    }
    return;
  }

  if (textoActual.length < maxLength) {
    final nuevoTexto = textoActual + key;
    controller.value = TextEditingValue(
      text: nuevoTexto,
      selection: TextSelection.collapsed(offset: nuevoTexto.length),
    );
  }
}

void manejarTeclaRutONumero(
  TextEditingController controller,
  String key, {
  required bool esRut,
  required int maxLength,
}) {
  final textoActual = controller.text;
  final seleccion = controller.selection;

  String aplicar(String texto) => esRut
      ? formatearRut(limpiarRut(texto))
      : texto.replaceAll(RegExp(r'[^0-9]'), '');

  void escribir(String texto) {
    controller.value = TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }

  if (key == '<') {
    if (textoActual.isNotEmpty && seleccion.start > 0) {
      escribir(aplicar(
        textoActual.replaceRange(seleccion.start - 1, seleccion.start, ''),
      ));
    }
    return;
  }

  final limpioActual = esRut ? limpiarRut(textoActual) : textoActual;
  if (limpioActual.length >= maxLength) return;

  escribir(aplicar(
    textoActual.replaceRange(seleccion.start, seleccion.end, key),
  ));
}