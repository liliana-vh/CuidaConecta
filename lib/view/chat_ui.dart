import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../viewmodel/chat_vm.dart';
import '../viewmodel/utilidades/errores.dart';
import '../viewmodel/utilidades/fecha_hora.dart';

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

  bool _mismoDia(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChatViewModel>();

    final mensajes = vm.mensajes.reversed.toList();

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
            if (vm.avisoPago != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _avisoAutomatico(
                  vm.avisoPago!,
                  // solo el cliente paga; el cuidador solo espera
                  onIrAPagar: vm.esCuidador
                      ? null
                      : () => context.push(vm.rutaDetalle),
                ),
              ),

            Expanded(
              child: mensajes.isEmpty
                  ? const Center(
                      child: Text(
                        'Aún no hay mensajes.',
                        style: TextStyle(color: Colors.black54),
                      ),
                    )
                  : ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.all(12),
                      itemCount: mensajes.length,
                      itemBuilder: (context, i) {
                        final m = mensajes[i];
                        final fecha = m.creadaEn ?? DateTime.now();

                        final hayAnterior = i + 1 < mensajes.length;
                        final anterior =
                            hayAnterior ? mensajes[i + 1].creadaEn : null;

                        final cambioDia = !hayAnterior ||
                            (anterior != null && !_mismoDia(fecha, anterior));

                        final esMio = vm.esMio(m);

                        return Column(
                          children: [
                            if (cambioDia) _separadorDia(fecha),
                            if (m.esAutomatico)
                              _avisoAutomatico(m.texto)
                            else
                              Align(
                                alignment: esMio
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 3),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: esMio
                                        ? _naranja.withValues(alpha: 0.3)
                                        : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(m.texto),
                                      const SizedBox(height: 2),
                                      Text(
                                        m.creadaEn == null
                                            ? 'enviando...'
                                            : hhmm(fecha),
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.black45,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
            ),

            vm.puedeEscribir
                ? _BarraEscribir(onEnviar: vm.enviar)
                : _barraBloqueada(vm.textoBloqueo),
          ],
        ),
      ),
    );
  }

  Widget _separadorDia(DateTime fecha) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        '${nombreDia(fecha)} ${dm(fecha)}',
        style: const TextStyle(color: Colors.black54, fontSize: 12),
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

  Widget _barraBloqueada(String texto) {
    return Container(
      width: double.infinity,
      color: Colors.grey.shade200,
      padding: const EdgeInsets.all(14),
      child: Text(texto, style: const TextStyle(color: Colors.black54)),
    );
  }
}

class _BarraEscribir extends StatefulWidget {
  final Future<void> Function(String texto) onEnviar;

  const _BarraEscribir({required this.onEnviar});

  @override
  State<_BarraEscribir> createState() => _BarraEscribirState();
}

class _BarraEscribirState extends State<_BarraEscribir> {
  final TextEditingController _controlador = TextEditingController();

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    final texto = _controlador.text.trim();
    if (texto.isEmpty) return;
    _controlador.clear();

    final ok = await ejecutarAccion(context, () => widget.onEnviar(texto));
    if (!ok && mounted) _controlador.text = texto;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controlador,
              minLines: 1,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Escribe un mensaje',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            onPressed: _enviar,
            icon: const Icon(Icons.send),
            color: const Color(0xFFFF941F),
          ),
        ],
      ),
    );
  }
}