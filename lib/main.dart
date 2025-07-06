import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const StillWatersApp());
}

class StillWatersApp extends StatelessWidget {
  const StillWatersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Still Waters',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFFB4E1FF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal[400],
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
