import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

//ver pdf desde app
class VisorPDFView extends StatelessWidget {
  final String url;
  final String titulo;

  const VisorPDFView({
    super.key,
    required this.url,
    this.titulo = 'Documento',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: SfPdfViewer.network(
        url,
        onDocumentLoadFailed: (details) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No se pudo cargar el PDF: ${details.error}')),
          );
          debugPrint('Error PDF: ${details.error} — ${details.description}');
        },
      ),
    );
  }
}