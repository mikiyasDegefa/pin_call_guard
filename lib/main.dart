import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const PinCallGuardApp());
}

class PinCallGuardApp extends StatelessWidget {
  const PinCallGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PIN Call Guard',
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
