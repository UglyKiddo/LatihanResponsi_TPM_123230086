import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screen/login_screen.dart';
import 'screen/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
  final username = prefs.getString('username') ?? '';

  runApp(MyApp(isLoggedIn: isLoggedIn, username: username));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String username;

  const MyApp({super.key, required this.isLoggedIn, required this.username});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpaceFlight App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          primary: const Color(0xFF6C63FF),
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF6C63FF),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
      home: isLoggedIn && username.isNotEmpty
          ? HomeScreen(username: username)
          : const LoginScreen(),
    );
  }
}