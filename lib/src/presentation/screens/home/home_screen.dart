import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: const Text("Go to Login"),
            ),
            ElevatedButton(
              onPressed: () => context.go('/foodSearch'),
              child: const Text("Go to Food"),
            ),
          ],
        ),
      ),
    );
  }
}
