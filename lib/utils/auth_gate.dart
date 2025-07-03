import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthGate extends StatelessWidget {
  final Widget authenticatedChild;
  final Widget? loadingScreen;
  final String redirectIfUnauthenticated;

  const AuthGate({
    super.key,
    required this.authenticatedChild,
    this.loadingScreen,
    this.redirectIfUnauthenticated = '/register',
  });

  Future<bool> isAuthenticated() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'jwt');
    return token != null && token.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: isAuthenticated(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingScreen ??
              const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.data == true) {
          return authenticatedChild;
        } else {
          // Redirect after first frame to avoid build errors
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, redirectIfUnauthenticated);
          });
          return const SizedBox.shrink();
        }
      },
    );
  }
}
