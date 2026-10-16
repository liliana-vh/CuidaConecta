import 'package:firebase_auth/firebase_auth.dart';
import 'streams_sesion.dart';

class AuthRepo {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get uidActual => _auth.currentUser?.uid;
  bool get correoVerificado => _auth.currentUser?.emailVerified ?? false;

  //registro
  Future<UserCredential> registrarConCorreo({
    required String correo,
    required String contrasena,
  }) {
    return _auth.createUserWithEmailAndPassword(
      email: correo,
      password: contrasena,
    );
  }

  Future<void> verificarTelefono({
    required String telefono,
    required void Function(PhoneAuthCredential credential) autoVerificado,
    required void Function(FirebaseAuthException e) fallo,
    required void Function(String verId, int? resendToken) codigoEnviado,
    required void Function(String verId) tiempoAgotado,
  }) {
    return _auth.verifyPhoneNumber(
      phoneNumber: telefono.startsWith('+') ? telefono : '+56$telefono',
      verificationCompleted: autoVerificado,
      verificationFailed: fallo,
      codeSent: codigoEnviado,
      codeAutoRetrievalTimeout: tiempoAgotado,
    );
  }

  PhoneAuthCredential credencialDesdeOtp({
    required String verificationId,
    required String otp,
  }) {
    return PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );
  }

  //login
  Future<UserCredential> iniciarSesionConCorreo({
    required String correo,
    required String contrasena,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: correo,
      password: contrasena,
    );
  }

  Future<UserCredential> iniciarSesionConCredencial(
    PhoneAuthCredential credential,
  ) {
    return _auth.signInWithCredential(credential);
  }

  Future<void> enviarVerificacionCorreo() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  Future<void> enviarCorreoRecuperacion(String correo) {
    return _auth.sendPasswordResetEmail(email: correo);
  }

  Future<void> reautenticar(String contrasenaActual) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('No fue posible verificar la sesión actual.');
    }

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: contrasenaActual,
    );

    await user.reauthenticateWithCredential(credential);
  }

  Future<void> solicitarCambioCorreo(String nuevoCorreo) async {
    await _auth.currentUser?.verifyBeforeUpdateEmail(nuevoCorreo);
  }

  Future<void> cerrarSesion() async {
    await StreamsSesion.cancelarTodos();
    await _auth.signOut();
  }
}
