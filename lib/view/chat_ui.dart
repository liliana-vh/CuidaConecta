import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../viewmodel/chat_vm.dart';

class ChatView extends StatelessWidget {
  final String idSolicitud;

  const ChatView({super.key, required this.idSolicitud});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatViewModel(idSolicitud)..escuchar(),
      child: const _Contenido(),
    );
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido();

  static const Color _naranja = Color(0xFFFF941F);

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChatViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(vm.nombreOtro),
        backgroundColor: _naranja,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            if (vm.avisoEstado != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _avisoAutomatico(vm.avisoEstado!),
              ),
            if (vm.avisoPago != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _avisoAutomatico(
                  vm.avisoPago!,
                  onIrAPagar: vm.esCuidador
                      ? null
                      : () => context.push(vm.rutaDetalle),
                ),
              ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  for (final m in vm.mensajes)
                    if (m.esAutomatico)
                      _avisoAutomatico(m.texto)
                    else
                      Align(
                        alignment: m.uidEmisor == vm.uidActual
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 3),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: m.uidEmisor == vm.uidActual
                                ? _naranja.withValues(alpha: 0.3)
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(m.texto),
                        ),
                      ),
                ],
              ),
            ),
            vm.puedeEscribir
                ? _barraEscribir()
                : _barraBloqueada(vm.textoBloqueo),
          ],
        ),
      ),
    );
  }

  Widget _avisoAutomatico(String texto, {VoidCallback? onIrAPagar}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(10),
      color: Colors.blueGrey.withValues(alpha: 0.1),
      child: Column(
        children: [
          Text(texto, textAlign: TextAlign.center),
          if (onIrAPagar != null)
            TextButton(onPressed: onIrAPagar, child: const Text('Ir a pagar')),
        ],
      ),
    );
  }

  Widget _barraEscribir() {
    return const Padding(
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Escribe un mensaje',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(onPressed: null, icon: Icon(Icons.send)),
        ],
      ),
    );
  }

  Widget _barraBloqueada(String texto) {
    return Container(
      width: double.infinity,
      color: Colors.grey.shade200,
      padding: const EdgeInsets.all(14),
      child: Text(texto, style: const TextStyle(color: Colors.black54)),
    );
  }
}