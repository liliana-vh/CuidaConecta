import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../servicios/cloudinary_config.dart';

class ArchivosRepo {
  Future<String?> subirArchivo(
    File archivo, {
    required String carpeta,
    String tipoRecurso = 'image',
  }) async {
    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/${CloudinaryConfig.cloudName}/$tipoRecurso/upload',
    );

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = CloudinaryConfig.uploadPreset
      ..fields['folder'] = carpeta
      ..files.add(await http.MultipartFile.fromPath('file', archivo.path));

    try {
      final respuestaStream = await request.send();
      final respuesta = await http.Response.fromStream(respuestaStream);

      if (respuesta.statusCode == 200) {
        final datos = jsonDecode(respuesta.body) as Map<String, dynamic>;
        return datos['secure_url'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}