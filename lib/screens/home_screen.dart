import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _onStartDecisionFlow() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("TrueNorth")),
      body: Padding(
        padding: EdgeInsetsGeometry.all(20),
        child: Column(
          children: [
            Text(
              "Welcome 🌟👋 Need help finding your direction? Let's ground ourselves in today's choices.",
              style: TextStyle(fontSize: 20.0),
            ),
            const SizedBox(height: 32.0),
            Center(
              child: OutlinedButton(
                onPressed: _onStartDecisionFlow,
                child: Column(
                  children: [
                    Icon(
                      Icons.explore,
                      color: Theme.of(context).primaryColor,
                      size: 32,
                    ),
                    Text(
                      "Begin Contemplation",
                      style: TextStyle(fontSize: 24.0),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
