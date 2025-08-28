import 'package:flutter/material.dart';

class AppColors {
  // Cores da Identidade Visual do Poupaí
  static const Color primaryColor = Color(0xFF3AA094); // Verde economia
  static const Color secondaryColor = Color(0xFF172334); // Azul escuro profissional

  // Cores de Apoio
  static const Color backgroundColor = Color(0xFFF5F5F5); // Cinza claro de fundo
  static const Color cardBackground = Color(0xFFFFFFFF); // Fundo dos cards
  static const Color textPrimary = Color(0xFF222222); // Preto suave para textos principais
  static const Color textSecondary = Color(0xFFA1A1A1); // Cinza médio para textos secundários

  // Cores de Feedback
  static const Color errorColor = Color(0xFFD32F2F); // Vermelho para erros
  static const Color successColor = Color(0xFF2E7D32); // Verde para sucesso

  // Cores específicas da aplicação
  static const Color _receipt = successColor; // Verde para receitas
  static const Color expense = errorColor; // Vermelho para despesas
}