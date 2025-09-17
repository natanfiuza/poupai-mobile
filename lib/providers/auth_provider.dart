import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../services/database_helper.dart';
import '../services/sync_service.dart';
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isAuthenticated = false;
  bool _isLoading = true; // Começa carregando para verificar o status inicial

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  AuthProvider() {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    final dbHelper = DatabaseHelper.instance;
    final token = await dbHelper.getToken();
    final user = await dbHelper.getUser();

    if (token != null && user != null) {
      _isAuthenticated = true;
      _currentUser = user;
      print('Sessão carregada a partir da BD local.');
     
    } else {
      _isAuthenticated = false;
      _currentUser = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    // Primeiro, limpa os dados locais
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.clearAllTables();

    // Depois, pode chamar o serviço para notificar o servidor (opcional)
    await _authService.logout();

    // Finalmente, atualiza o estado da aplicação
    _isAuthenticated = false;
    _currentUser = null;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final success = await _authService.login(email, password);

    _isAuthenticated = success;
    if (success) {
      // Busca o utilizador diretamente da base de dados local
      _currentUser = await DatabaseHelper.instance.getUser();
      
    }
    _isLoading = false;
    notifyListeners();

    return success;
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final success = await _authService.register(name, email, password);

    _isAuthenticated = success;
    if (success) {
      // Busca o utilizador diretamente da base de dados local
      _currentUser = await DatabaseHelper.instance.getUser();
      
    }
    _isLoading = false;
    notifyListeners();

    return success;
  }
}
