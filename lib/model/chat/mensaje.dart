class Mensaje {
  final String uidEmisor;
  final String texto;
  final bool esAutomatico;

  const Mensaje({
    required this.uidEmisor,
    required this.texto,
    this.esAutomatico = false,
  });
}