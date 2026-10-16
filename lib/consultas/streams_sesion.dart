import 'dart:async';

//registro streams abiertos firestore, cancelar antes de cerrar sesion
class StreamsSesion {
  StreamsSesion._();

  static final Set<Future<void> Function()> _cierres = {};

  static Future<void> cancelarTodos() async {
    final pendientes = _cierres.toList();
    _cierres.clear();
    await Future.wait(pendientes.map((cierre) => cierre()));
  }
}

extension StreamHastaCerrarSesion<T> on Stream<T> {
  Stream<T> hastaCerrarSesion() {
    StreamSubscription<T>? sub;
    late final StreamController<T> ctrl;

    Future<void> cierre() async {
      final actual = sub;
      sub = null;
      await actual?.cancel();
      if (!ctrl.isClosed) unawaited(ctrl.close());
    }

    ctrl = StreamController<T>.broadcast(
      onListen: () {
        sub = listen(
          ctrl.add,
          onError: ctrl.addError,
          onDone: () {
            StreamsSesion._cierres.remove(cierre);
            if (!ctrl.isClosed) unawaited(ctrl.close());
          },
        );
        StreamsSesion._cierres.add(cierre);
      },
      onCancel: () async {
        StreamsSesion._cierres.remove(cierre);
        final actual = sub;
        sub = null;
        await actual?.cancel();
      },
    );

    return ctrl.stream;
  }
}