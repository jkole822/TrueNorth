import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:true_north/screens/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _mutation = """
    mutation RegisterUser(\$input: RegisterInput!) {
      registerUser(input: \$input)
    }
  """;

  void _onRegister(RunMutation runMutation) {
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
      appBar: AppBar(title: const Text('Register')),
      body: Mutation(
        options: MutationOptions(
          document: gql(_mutation),
          onCompleted: (data) {
            final success = data?['registerUser'] == true;
            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Registered! Sign in to experience TrueNorth.'),
                ),
              );
              Navigator.pushReplacementNamed(context, '/login');
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Registration failed.')),
              );
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
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _onRegister(runMutation),
                  child: const Text('Register'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: const Text('Already have an account? Log in.'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
