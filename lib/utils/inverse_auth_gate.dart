import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class InverseAuthGate extends StatelessWidget {
  final Widget unauthenticatedChild;
  final String redirectIfAuthenticated;

  const InverseAuthGate({
    super.key,
    required this.unauthenticatedChild,
    this.redirectIfAuthenticated = '/home',
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
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == false) {
          return unauthenticatedChild;
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, redirectIfAuthenticated);
          });
          return const SizedBox.shrink();
        }
      },
    );
  }
}
