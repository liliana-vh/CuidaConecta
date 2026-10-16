bool telefonoValido(String telefono) {
  return telefono.length == 9 && telefono.startsWith('9');
}

String sinPrefijoChile(String telefono) =>
    telefono.startsWith('+56') ? telefono.substring(3) : telefono;