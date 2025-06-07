import 'package:flutter/material.dart';
import 'package:true_north/screens/home_screen.dart';
import 'package:true_north/screens/login_screen.dart';
import 'package:true_north/screens/register_screen.dart';
import 'package:true_north/screens/splash_screen.dart';

class TrueNorthApp extends StatefulWidget {
  @override
  State<TrueNorthApp> createState() => _TrueNorthState();
}

class _TrueNorthState extends State<TrueNorthApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _setThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrueNorth',
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        primaryColor: const Color(0xFF1976D2),
        cardColor: const Color(0xFFFAFAFA),
        colorScheme: ColorScheme.light(
          primary: Color(0xFF1976D2),
          secondary: Color(0xFF26A69A),
          surface: Color(0xFFFAFAFA),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Color(0xFF2C2C2C),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF1976D2),
            foregroundColor: Colors.white,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 16.0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            side: const BorderSide(width: 2.0),
            textStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Color(0xFF1976D2),
            textStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF2C2C2C),
        primaryColor: const Color(0xFF1976D2),
        cardColor: const Color(0xFF424242),
        colorScheme: ColorScheme.dark(
          primary: Color(0xFF1976D2),
          secondary: Color(0xFF26A69A),
          surface: Color(0xFF424242),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF1976D2),
            foregroundColor: Colors.white,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.white70),
          hintStyle: TextStyle(color: Colors.white60),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white54),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF26A69A), width: 2),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 16.0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            side: const BorderSide(width: 2.0, color: Colors.white),
            textStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Color(0xFF424242),
          contentTextStyle: TextStyle(color: Colors.white),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            textStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      themeMode: _themeMode,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
