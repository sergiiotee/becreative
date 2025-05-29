import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    // Si quieres simular una inicialización, podrías agregar un retraso aquí.
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FakeUser?>(
      stream: _authService.userChanges,
      builder: (context, snapshot) {
        // Una vez que el stream esté activo, muestra la pantalla adecuada.
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user == null) {
            return LoginScreen(authService: _authService);
          } else {
            return HomeScreen(authService: _authService);
          }
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}