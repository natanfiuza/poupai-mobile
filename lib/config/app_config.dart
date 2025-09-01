// lib/config/app_config.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // URL Base da API
  static String baseUrl = dotenv.env['BASE_URL'] ?? 'http://localhost:8080/api';

  // Endpoints de Autenticação
  static String endpointLogin = dotenv.env['ENDPOINT_LOGIN'] ?? '/app/login';
  static String endpointRegister =
      dotenv.env['ENDPOINT_REGISTER'] ?? '/app/register';

  // Endpoints de Transações
  static String endpointTransactions =
      dotenv.env['ENDPOINT_TRANSACTIONS'] ?? '/app/transactions';
  static String endpointSummary = dotenv.env['ENDPOINT_SUMMARY'] ?? '/app/summary';
}
