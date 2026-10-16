import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// circulo para cambio foto perfil
class SelectorFotoPerfil extends StatelessWidget {
  final String? fotoActualUrl;
  final File? imagenNueva;
  final ValueChanged<File> onImagenSeleccionada;
  final Color colorBoton;

  const SelectorFotoPerfil({
    super.key,
    required this.fotoActualUrl,
    required this.imagenNueva,
    required this.onImagenSeleccionada,
    required this.colorBoton,
  });

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final XFile? imagen = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (imagen != null) onImagenSeleccionada(File(imagen.path));
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 55,
            backgroundColor: Colors.grey[200],
            backgroundImage: imagenNueva != null
                ? FileImage(imagenNueva!)
                : (fotoActualUrl != null ? NetworkImage(fotoActualUrl!) : null) as ImageProvider?,
            child: (imagenNueva == null && fotoActualUrl == null)
                ? const Icon(Icons.person, size: 60, color: Colors.grey)
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              backgroundColor: colorBoton,
              radius: 18,
              child: IconButton(
                icon: const Icon(Icons.camera_alt, size: 16, color: Colors.black),
                onPressed: _seleccionarImagen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}