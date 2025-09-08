import 'package:flutter/material.dart';
import 'config/routes.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'My App',
      routerConfig: AppRoutes.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
