import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _storage = const FlutterSecureStorage();

  final _mutation = """
    mutation LoginUser(\$input: LoginInput!) {
      login(input: \$input)
    }
  """;

  void _onLogin(RunMutation runMutation) {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) return;

    runMutation({
      'input': {'email': email, 'password': password},
    });
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final logoPath = brightness == Brightness.dark
        ? 'assets/images/logo_dark.png'
        : 'assets/images/logo_light.png';

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Mutation(
        options: MutationOptions(
          document: gql(_mutation),
          onCompleted: (data) {
            final String? token = data?['login'] as String?;
            if (token != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Success!')));
              _storage.write(key: 'jwt', value: token);
              Navigator.pushReplacementNamed(context, '/home');
            } else {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Login failed.')));
            }
          },
          onError: (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${error?.graphqlErrors.first.message}'),
              ),
            );
          },
        ),
        builder: (runMutation, result) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(logoPath, width: 200),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _onLogin(runMutation),
                  child: const Text('Log In'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
