// lib/screens/welcome_screen.dart
import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import 'login_screen.dart'; // Importe a tela de Login
import 'register_screen.dart'; // Importe a tela de Cadastro

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Image.asset(
                'assets/images/logo_ico.png', // Corrigido para o nome de arquivo que usamos anteriormente
                height: 100, // Tamanho ajustado para dar mais espaço às frases
              ),
              const SizedBox(height: 24),              
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  // Estilo padrão do texto (preto/azul escuro)
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondaryColor,
                    height: 1.2, // Melhora o espaçamento entre linhas
                  ),
                  children: <TextSpan>[
                    TextSpan(text: 'Vamos cuidar do '),
                    TextSpan(
                      text: 'seu bolso',
                      // Estilo customizado para a parte colorida
                      style: TextStyle(color: AppColors.primaryColor),
                    ),
                    TextSpan(text: ' hoje?'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Um aplicativo fácil de usar que ajuda você a controlar suas finanças pessoais com simplicidade.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),         
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                child: const Text('ENTRAR'),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const RegisterScreen(),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryColor,
                  side: const BorderSide(
                    color: AppColors.primaryColor,
                    width: 2,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 14.0,
                    horizontal: 28.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text('CADASTRAR'),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
