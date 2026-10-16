import 'package:flutter/material.dart';

//streambuilder lista avisos
class ListaEnVivo<T> extends StatelessWidget {
  final Stream<List<T>> stream;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final String mensajeError;
  final String mensajeVacio;
  final EdgeInsetsGeometry padding;
  final double tamanoLetraMensajes;

  const ListaEnVivo({
    super.key,
    required this.stream,
    required this.itemBuilder,
    required this.mensajeError,
    required this.mensajeVacio,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.tamanoLetraMensajes = 16,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<T>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint('Error cargando lista: ${snapshot.error}');
          return Center(
            child: Text(
              mensajeError,
              style: TextStyle(fontSize: tamanoLetraMensajes, color: Colors.black54),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return Center(
            child: Text(
              mensajeVacio,
              style: TextStyle(fontSize: tamanoLetraMensajes, color: Colors.black54),
            ),
          );
        }

        return ListView.builder(
          padding: padding,
          itemCount: items.length,
          itemBuilder: (context, index) => itemBuilder(context, items[index]),
        );
      },
    );
  }
}