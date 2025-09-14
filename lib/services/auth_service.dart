import 'dart:convert';
import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../models/user_model.dart';
import 'database_helper.dart';

class AuthService {
  final Dio _dio = Dio(BaseOptions(baseUrl: AppConfig.baseUrl));

  Future<bool> login(String email, String password) async {
    try {
      final response = await _dio.post(
        AppConfig.endpointLogin,
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data['data'];
        if (responseData != null &&
            responseData['token'] != null &&
            responseData['user'] != null) {
          final String token = responseData['token'];
          final UserModel user = UserModel.fromJson(responseData['user']);

          // Salva o utilizador e o token na base de dados local
          final dbHelper = DatabaseHelper.instance;
          await dbHelper.saveUser(user);
          await dbHelper.saveToken(token);

          print('Login bem-sucedido. Dados guardados na BD local.');
          return true;
        }
      }
      return false;
    } on DioException catch (e) {
      print('Erro no login: ${e.response?.data}');
      return false;
    }
  }

  // SUBSTITUA O MÉTODO register
  Future<bool> register(String name, String email, String password) async {
    try {
      final response = await _dio.post(
        AppConfig.endpointRegister,
        data: {'name': name, 'email': email, 'password': password},
      );

      if ((response.statusCode == 201 || response.statusCode == 200) &&
          response.data != null) {
        final responseData = response.data['data'];
        if (responseData != null &&
            responseData['token'] != null &&
            responseData['user'] != null) {
          final String token = responseData['token'];
          final UserModel user = UserModel.fromJson(responseData['user']);

          // Salva o utilizador e o token na base de dados local
          final dbHelper = DatabaseHelper.instance;
          await dbHelper.saveUser(user);
          await dbHelper.saveToken(token);

          print('Registo bem-sucedido. Dados guardados na BD local.');
          return true;
        }
      }
      return false;
    } on DioException catch (e) {
      print('Erro no registo: ${e.response?.data}');
      return false;
    }
  }

  Future<void> logout() async {
    // No futuro, pode adicionar uma chamada à API aqui para invalidar o token no servidor.
    // A limpeza local será feita no AuthProvider.
    print('Logout chamado no AuthService.');
  }
}
