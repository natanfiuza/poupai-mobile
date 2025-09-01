import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../config/app_config.dart';
import '../models/user_model.dart';

class AuthService {
  final Dio _dio = Dio(BaseOptions(baseUrl: AppConfig.baseUrl));
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Chave para salvar o token no storage
  static const String _tokenKey = 'auth_token';
  // Chave para salver os dados do usuario logado
  static const String _userKey = 'auth_user';

  Future<bool> login(String email, String password) async {
    try {
      final response = await _dio.post(
        AppConfig.endpointLogin,
        data: {'email': email, 'password': password},
      );

      // Verifica se a requisição foi bem-sucedida (código 200)
      if (response.statusCode == 200 && response.data != null) {
        // Acessa o objeto 'data' aninhado na resposta
        final responseData = response.data['data'];

        // Verifica se o objeto 'data' e o 'token' dentro dele não são nulos
        if (responseData != null && responseData['token'] != null) {
          // Extrai o token de dentro do objeto 'data'
          final String token = responseData['token'];
          await _storage.write(key: _tokenKey, value: token);

          if (responseData['user'] != null) {
            // Converte o mapa do usuário para uma string JSON e salva
            final String userJson = jsonEncode(responseData['user']);
            await _storage.write(key: _userKey, value: userJson);
          }
          print('Login bem-sucedido. Token salvo.');
          return true;
        }
      }

      // Se a estrutura da resposta não for a esperada, retorna falso
      print('Falha no login: Formato de resposta inesperado.');
      return false;
    } on DioException catch (e) {
      print('Erro no login: ${e.response?.data}');
      return false;
    }
  }

  Future<UserModel?> getUser() async {
    final userJson = await _storage.read(key: _userKey);
    if (userJson != null) {
      return UserModel.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  // Atualize o método logout para limpar os dados do usuário também
  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey); // <-- ADICIONE ESTA LINHA
    print('Usuário deslogado.');
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      final response = await _dio.post(
        AppConfig.endpointRegister,
        data: {'name': name, 'email': email, 'password': password},
      );

      // Verifica se a requisição foi bem-sucedida (código 201 ou 200)
      if ((response.statusCode == 201 || response.statusCode == 200) &&
          response.data != null) {
        // Acessa o objeto 'data' aninhado na resposta
        final responseData = response.data['data'];

        // Verifica se o objeto 'data' e o 'token' dentro dele não são nulos
        if (responseData != null && responseData['token'] != null) {
          // Extrai o token de dentro do objeto 'data'
          final String token = responseData['token'];
          await _storage.write(key: _tokenKey, value: token);
          if (responseData['user'] != null) {
            // Converte o mapa do usuário para uma string JSON e salva
            final String userJson = jsonEncode(responseData['user']);
            await _storage.write(key: _userKey, value: userJson);
          }
          print('Cadastro bem-sucedido. Usuário logado.');
          return true;
        }
      }

      // Se a estrutura da resposta não for a esperada, retorna falso
      print('Falha no cadastro: Formato de resposta inesperado.');
      return false;
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        print('Erro de validação: ${e.response?.data}');
      } else {
        print('Erro no cadastro: ${e.response?.data}');
      }
      return false;
    }
  }
}
