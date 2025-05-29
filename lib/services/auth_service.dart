// Implementación simulada actual:
import 'dart:async';

/// Clase de usuario simulado.
class FakeUser {
  final String email;
  FakeUser({required this.email});
}

/// Servicio de autenticación simulado.
class AuthService {
  FakeUser? _user;
  final StreamController<FakeUser?> _controller = StreamController<FakeUser?>.broadcast();

  AuthService() {
    // Inicialmente no hay usuario autenticado.
    _controller.add(_user);
  }

  /// Stream que simula authStateChanges.
  Stream<FakeUser?> get userChanges => _controller.stream;

  /// Simula iniciar sesión con email y contraseña.
  Future<FakeUser?> signIn(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simula retraso de red.
    if (email.isNotEmpty && password.isNotEmpty) {
      _user = FakeUser(email: email);
      _controller.add(_user);
      return _user;
    }
    return null;
  }

  /// Simula el registro.
  Future<FakeUser?> register(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (email.isNotEmpty && password.isNotEmpty) {
      _user = FakeUser(email: email);
      _controller.add(_user);
      return _user;
    }
    return null;
  }

  /// Simula cerrar sesión.
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _user = null;
    _controller.add(null);
  }
}

/* 
// A continuación se muestra la implementación real con Firebase. 
// Cuando decidas integrar Firebase, descomenta la sección y elimina la implementación simulada.

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Devuelve un stream de cambios en el usuario.
  Stream<User?> get userChanges => _auth.authStateChanges();

  // Iniciar sesión con email y contraseña.
  Future<User?> signIn(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return result.user;
    } on FirebaseAuthException catch (e) {
      print('Error en signIn: ${e.message}');
      return null;
    }
  }

  // Registro con email y contraseña.
  Future<User?> register(String email, String password) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return result.user;
    } on FirebaseAuthException catch (e) {
      print('Error en register: ${e.message}');
      return null;
    }
  }

  // Cerrar sesión.
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
*/