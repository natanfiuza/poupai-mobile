// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_colors.dart';
import '../providers/auth_provider.dart'; // Importe o AuthProvider
import 'home_screen.dart'; // Importe a HomeScreen
import 'welcome_screen.dart'; // Importe a WelcomeScreen

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Adiciona um listener para reagir às mudanças do AuthProvider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndRedirect();
    });
  }

  Future<void> _checkAuthAndRedirect() async {
    // Acessa o AuthProvider sem ouvir mudanças aqui
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // O checkAuthStatus já é chamado no construtor do AuthProvider.
    // Aqui, vamos apenas esperar o isLoading se tornar false.
    // Um listener é uma forma mais robusta de fazer isso.

    // O ideal é usar um Consumer ou um listener no próprio build.
    // Para simplificar, vamos fazer a verificação após um delay.
    await Future.delayed(const Duration(seconds: 3)); // Mantém a splash visível

    if (!mounted) return;

    if (authProvider.isAuthenticated) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ... o código do build continua o mesmo
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo_ico.png', width: 150),
            const SizedBox(height: 20),
            const Text(
              'Poupaí',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.secondaryColor,
              ),
            ),
            const SizedBox(height: 40),
              Image.asset(
              'assets/animations/loading_cart.gif', 
              height: 128, // Ajuste a altura conforme necessário
              width: 128, // Ajuste a largura conforme necessário
            ),
          ],
        ),
      ),
    );
  }
}
